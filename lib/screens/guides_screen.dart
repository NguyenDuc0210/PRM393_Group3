
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/location_notifier.dart';
import '../notifiers/navigation_notifier.dart';
import '../notifiers/plan_notifier.dart';
import '../models/location.dart';
import '../repositories/database_helper.dart';
import 'guide_detail_screen.dart';
import 'the_100_screen.dart';
import 'location_page.dart';

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  bool _isSearching = false;
  final TextEditingController _newPlanController = TextEditingController();

  @override
  void dispose() {
    _newPlanController.dispose();
    super.dispose();
  }

  void _showAddToPlanBottomSheet(Location location) async {
    final plans = await ref.read(planNotifierProvider.future);
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text('Add to Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  GestureDetector(
                    onTap: () => _showCreatePlanDialog(location),
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add, size: 30),
                        ),
                        const SizedBox(height: 8),
                        const Text('New Plan', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ...plans.map((plan) => Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () async {
                        final success = await ref.read(planNotifierProvider.notifier).addLocationToPlan(plan.id, location.id);
                        if (!mounted) return;
                        Navigator.pop(context);
                        if (success) {
                          ref.read(navigationIndexProvider.notifier).state = 4;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Already in this plan.'), backgroundColor: Color(0xFF0D2D44)),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 8),
                          Text(plan.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCreatePlanDialog(Location location) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create New Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _newPlanController,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Plan Name', border: InputBorder.none),
                ),
              ),
              const Divider(),
              InkWell(
                onTap: () async {
                  if (_newPlanController.text.trim().isNotEmpty) {
                    await ref.read(planNotifierProvider.notifier).addPlan(_newPlanController.text.trim());
                    final plans = await ref.read(planNotifierProvider.future);
                    final newPlan = plans.first;
                    await ref.read(planNotifierProvider.notifier).addLocationToPlan(newPlan.id, location.id);
                    
                    _newPlanController.clear();
                    if (mounted) {
                      Navigator.pop(context);
                      ref.read(navigationIndexProvider.notifier).state = 4;
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  color: const Color(0xFFC8F2C2),
                  alignment: Alignment.center,
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2D44))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(allLocationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          locationsAsync.when(
            data: (locations) => _buildContent(context, locations),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          if (_isSearching) _buildSearchOverlay(),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Where to?',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _isSearching = false),
                  icon: const Icon(Icons.close, color: Colors.black87, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Browse by Continent',
                    style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 32),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1.1,
                    children: [
                      _buildContinentCard('Asia', 'asia', Icons.temple_buddhist_outlined, const Color(0xFFFFE8D6)),
                      _buildContinentCard('Europe', 'europe', Icons.castle_outlined, const Color(0xFFDDE5FF)),
                      _buildContinentCard('North America', 'america', Icons.location_city_outlined, const Color(0xFFE2F4C5)),
                      _buildContinentCard('Africa', 'africa', Icons.landscape_outlined, const Color(0xFFFFF4D6)),
                      _buildContinentCard('Australia', 'oceania', Icons.surfing_outlined, const Color(0xFFD6F5FF)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinentCard(String name, String continentId, IconData icon, Color bgColor) {
    return GestureDetector(
      onTap: () async {
        final locations = await ref.read(allLocationsProvider.future);
        final city = locations.firstWhere(
          (l) => l.continent.toLowerCase() == continentId && l.type == 'city',
          orElse: () => locations.firstWhere((l) => l.continent.toLowerCase() == continentId, orElse: () => locations.first),
        );
        
        setState(() => _isSearching = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => LocationPage(locationId: city.id, cityName: city.name)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: bgColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: bgColor.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(icon, size: 32, color: const Color(0xFF0D2D44)),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Location> locations) {
    // Lấy bài đầu tiên của mỗi category từ mỗi thành phố
    List<Location> getFirstOfCategory(String type) {
      final List<Location> filtered = [];
      final Set<String> seenCities = {};
      
      for (var loc in locations) {
        if (loc.type == type) {
          // Trích xuất tên thành phố từ địa chỉ (giả định định dạng "City, Country")
          final cityName = loc.address.split(',').first.trim();
          if (!seenCities.contains(cityName)) {
            filtered.add(loc);
            seenCities.add(cityName);
          }
        }
      }
      return filtered;
    }

    final foodLocations = getFirstOfCategory('food');
    final guidesLocations = getFirstOfCategory('guides_tips');
    final cultureLocations = getFirstOfCategory('culture');

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            decoration: const BoxDecoration(color: Color(0xFFC8F2C2)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hello, Culture\nTripper!',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                          color: Color(0xFF0D2D44),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Let's start making travel\nplans with expert local help.",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                Image.asset('assets/img_6.png', height: 120, width: 120, fit: BoxFit.contain),
              ],
            ),
          ),
        ),

        SliverPersistentHeader(
          pinned: true,
          delegate: _StickySearchBarDelegate(onSearchTap: () => setState(() => _isSearching = true)),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCircleItem(context, 'San Francisco', 'assets/img_1.png', 100),
                  _buildCircleItem(context, 'Tokyo', 'assets/img_2.png', 200),
                  _buildCircleItem(context, 'Paris', 'assets/img.png', 300),
                  _buildCircleItem(context, 'Cape Town', 'assets/img_3.png', 400),
                  _buildCircleItem(context, 'Sydney', 'assets/img_1.png', 500),
                ],
              ),
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            _buildSectionTitle('Food & Drink'),
            _buildHorizontalList(context, foodLocations, 'Food & Drink'),
            
            _buildSectionTitle('Guides & Tips'),
            _buildHorizontalList(context, guidesLocations, 'Guides & Tips'),
            
            _buildSectionTitle('Culture'),
            _buildHorizontalList(context, cultureLocations, 'Culture'),
          ]),
        ),

        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  const Color(0xFFC8F2C2).withOpacity(0.2),
                  const Color(0xFFC8F2C2),
                ],
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'The 100',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D2D44),
                    letterSpacing: -3,
                  ),
                ),
                const Text(
                  '2026 Official Selection',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const The100Screen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2D44),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Explore The 100', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 60),
                Image.asset('assets/img_5.png', height: 200),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleItem(BuildContext context, String title, String assetPath, int id) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LocationPage(locationId: id, cityName: title))),
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: CircleAvatar(
                radius: 36,
                backgroundImage: AssetImage(assetPath),
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<Location> items, String categoryLabel) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GuideDetailScreen(location: item))),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(item.imageUrl, height: 200, width: 280, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 12, left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Text(categoryLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Positioned(
                        top: 12, right: 12,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final isInPlanAsync = ref.watch(isLocationInAnyPlanProvider(item.id));
                            return isInPlanAsync.when(
                              data: (isInPlan) => GestureDetector(
                                onTap: () => _showAddToPlanBottomSheet(item),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 18,
                                  child: Icon(
                                    isInPlan ? Icons.bookmark : Icons.bookmark_border, 
                                    size: 20, 
                                    color: isInPlan ? Colors.black : Colors.grey[800],
                                  ),
                                ),
                              ),
                              loading: () => const CircleAvatar(radius: 18, backgroundColor: Colors.white, child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))),
                              error: (_, __) => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, height: 1.2),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  const Text('Read More →', style: TextStyle(color: Color(0xFF42868E), fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onSearchTap;
  _StickySearchBarDelegate({required this.onSearchTap});

  @override double get minExtent => 72.0;
  @override double get maxExtent => 72.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: overlapsContent ? Colors.white : const Color(0xFFC8F2C2),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: onSearchTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: const [
              Icon(Icons.location_on_outlined, color: Colors.blueGrey),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Find a guide you love',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              Icon(Icons.search, color: Colors.black87),
            ],
          ),
        ),
      ),
    );
  }

  @override bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) => false;
}
