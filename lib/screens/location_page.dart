
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location.dart';
import '../models/user_role.dart';
import '../notifiers/location_notifier.dart';
import '../notifiers/navigation_notifier.dart';
import '../notifiers/plan_notifier.dart';
import '../notifiers/auth_notifier.dart';
import '../repositories/auth_repository.dart';
import '../repositories/plan_repository.dart';
import 'guide_detail_screen.dart';
import 'login_screen.dart';

class LocationPage extends ConsumerStatefulWidget {
  final int locationId;
  final String? cityName;

  const LocationPage({super.key, required this.locationId, this.cityName});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Discover', 'Food & Drink', 'Things To Do', 'Places to Stay', 'Guides & Tips', 'Culture', 'Inspiration'];
  final TextEditingController _newPlanController = TextEditingController();

  final GlobalKey _discoverKey = GlobalKey();
  final GlobalKey _foodKey = GlobalKey();
  final GlobalKey _thingsKey = GlobalKey();
  final GlobalKey _placesKey = GlobalKey();
  final GlobalKey _guidesKey = GlobalKey();
  final GlobalKey _cultureKey = GlobalKey();
  final GlobalKey _inspirationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newPlanController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  void _showAddToPlanBottomSheet(Location location) async {
    final userRole = ref.read(authNotifierProvider);
    if (userRole == UserRole.guest) {
      _showLoginRequiredDialog();
      return;
    }

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
                          ref.read(navigationIndexProvider.notifier).state = 4; // My Plans index
                          Navigator.pop(context); // Also close the LocationPage
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

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng nhập bắt buộc'),
        content: const Text('Bạn cần đăng nhập để thêm địa điểm vào kế hoạch.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            }, 
            child: const Text('Đăng nhập')
          ),
        ],
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
                      ref.read(navigationIndexProvider.notifier).state = 4; // My Plans index
                      Navigator.pop(context); // Also close the LocationPage
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
    final allLocationsAsync = ref.watch(allLocationsProvider);

    return allLocationsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (locations) {
        final mainLocation = locations.firstWhere(
          (loc) => loc.id == widget.locationId, 
          orElse: () => locations.firstWhere((l) => l.name == widget.cityName, orElse: () => locations.first)
        );
        
        final cityNameStr = widget.cityName ?? mainLocation.name;
        final cityData = locations.where((loc) => 
          loc.address.toLowerCase().contains(cityNameStr.toLowerCase()) && 
          loc.id != mainLocation.id
        ).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                key: _discoverKey,
                expandedHeight: 320,
                pinned: true,
                backgroundColor: const Color(0xFF2D6A4F),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(mainLocation.imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 60, left: 0, right: 0,
                        child: Center(
                          child: Text(
                            cityNameStr,
                            style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: const Color(0xFF2D6A4F),
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: const Color(0xFF2D6A4F),
                      indicatorWeight: 3,
                      tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                      onTap: (index) {
                        switch (index) {
                          case 0: _scrollToSection(_discoverKey); break;
                          case 1: _scrollToSection(_foodKey); break;
                          case 2: _scrollToSection(_thingsKey); break;
                          case 3: _scrollToSection(_placesKey); break;
                          case 4: _scrollToSection(_guidesKey); break;
                          case 5: _scrollToSection(_cultureKey); break;
                          case 6: _scrollToSection(_inspirationKey); break;
                        }
                      },
                    ),
                  ),
                  48.0,
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate([
                  _buildSection(_foodKey, 'Food & Drink', cityData.where((l) => l.type == 'food').toList()),
                  _buildSection(_thingsKey, 'Things To Do', cityData.where((l) => l.type == 'things_to_do').toList()),
                  _buildSection(_placesKey, 'Places To Stay', cityData.where((l) => l.type == 'places_to_stay').toList()),
                  _buildSection(_guidesKey, 'Guides & Tips', cityData.where((l) => l.type == 'guides_tips').toList()),
                  _buildSection(_cultureKey, 'Culture', cityData.where((l) => l.type == 'culture').toList()),
                  _buildSection(_inspirationKey, 'Inspiration', cityData.where((l) => l.type == 'inspiration').toList()),
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(GlobalKey key, String title, List<Location> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44))),
        ),
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Location item) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GuideDetailScreen())),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(item.imageUrl, height: 220, width: 300, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      item.type == 'food' ? 'Planning - Restaurants' : 
                      item.type == 'things_to_do' ? 'See And Do' :
                      item.type == 'places_to_stay' ? 'Recommendations - Hotels' : 'Orientation',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)
                    ),
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
                            backgroundColor: Colors.white, radius: 18,
                            child: Icon(
                              isInPlan ? Icons.bookmark : Icons.bookmark_border, 
                              size: 22, 
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
            const SizedBox(height: 14),
            Text(
              item.name, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Color(0xFF0D2D44), height: 1.2), 
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const Text('Read More →', style: TextStyle(color: Color(0xFF42868E), fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._widget, this.height);
  final Widget _widget;
  final double height;

  @override double get minExtent => height;
  @override double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _widget;
  }

  @override bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
