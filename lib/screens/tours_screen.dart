
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour_data.dart';
import '../models/location.dart';
import '../models/user_role.dart';
import '../notifiers/plan_notifier.dart';
import '../notifiers/navigation_notifier.dart';
import '../notifiers/tour_notifier.dart';
import '../notifiers/auth_notifier.dart';
import '../repositories/auth_repository.dart';
import '../repositories/database_helper.dart';
import 'tour_detail_screen.dart';
import 'add_edit_tour_screen.dart';
import 'login_screen.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

  @override
  ConsumerState<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedContinent = 'All';

  Location _getTourAsLocation(TourData tour) {
    return Location(
      id: tour.id ?? 0,
      name: tour.name,
      address: tour.provider,
      description: tour.overview,
      countStar: 0,
      imageUrl: tour.mainImageUrl,
      continent: tour.continent.toLowerCase(),
      type: 'tour',
    );
  }

  void _showAddToPlanBottomSheet(TourData tour) async {
    final userRole = ref.read(authNotifierProvider);
    if (userRole == UserRole.guest) {
      _showLoginRequiredDialog();
      return;
    }

    final location = _getTourAsLocation(tour);
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
              child: Text('Add Tour to Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        await DatabaseHelper.instance.insertLocation(location);
                        final success = await ref.read(planNotifierProvider.notifier).addLocationToPlan(plan.id, location.id);
                        if (!mounted) return;
                        Navigator.pop(context);
                        if (success) {
                          ref.read(navigationIndexProvider.notifier).state = 4;
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.folder, color: Colors.white, size: 40),
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
        content: const Text('Bạn cần đăng nhập để thêm tour vào kế hoạch.'),
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
    final controller = TextEditingController();
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
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Plan Name', border: InputBorder.none),
                ),
              ),
              const Divider(),
              InkWell(
                onTap: () async {
                  if (controller.text.trim().isNotEmpty) {
                    await ref.read(planNotifierProvider.notifier).addPlan(controller.text.trim());
                    final plans = await ref.read(planNotifierProvider.future);
                    final newPlan = plans.first;

                    await DatabaseHelper.instance.insertLocation(location);
                    await ref.read(planNotifierProvider.notifier).addLocationToPlan(newPlan.id, location.id);

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

  void _showAddTourDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditTourScreen()),
    );
  }

  void _showFilterBottomSheet(List<String> continents) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by Continent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedContinent == 'All',
                  onSelected: (selected) {
                    setState(() => _selectedContinent = 'All');
                    Navigator.pop(context);
                  },
                ),
                ...continents.map((c) => FilterChip(
                  label: Text(c),
                  selected: _selectedContinent == c,
                  onSelected: (selected) {
                    setState(() => _selectedContinent = c);
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toursAsync = ref.watch(tourNotifierProvider);
    final userRole = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _isSearching
          ? AppBar(
        backgroundColor: const Color(0xFFC8F2C2),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search tours...', border: InputBorder.none),
          onChanged: (val) {
            ref.read(tourNotifierProvider.notifier).searchTours(val);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() => _isSearching = false);
              _searchController.clear();
              ref.read(tourNotifierProvider.notifier).loadTours();
            },
          )
        ],
      )
          : null,
      floatingActionButton: userRole == UserRole.admin 
        ? FloatingActionButton.extended(
            heroTag: 'tours_fab',
            onPressed: _showAddTourDialog,
            backgroundColor: const Color(0xFF0D2D44),
            icon: const Icon(Icons.add, size: 28, color: Colors.white),
            label: const Text('Add Tour', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        : null,
      body: toursAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tours) {
          final allContinents = tours.map((e) => e.continent).toSet().toList();
          final filteredTours = _selectedContinent == 'All'
              ? tours
              : tours.where((t) => t.continent == _selectedContinent).toList();
          final continentsToShow = _selectedContinent == 'All'
              ? allContinents
              : [_selectedContinent];

          return CustomScrollView(
            slivers: [
              if (!_isSearching)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                    decoration: const BoxDecoration(color: Color(0xFFC8F2C2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Next Adventure\nIs Here',
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, height: 1.1, color: Color(0xFF0D2D44)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Find your perfect getaway with trips from top providers, giờ đây đã có trên thị trường.",
                          style: TextStyle(fontSize: 16, color: Color(0xFF0D2D44)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset('assets/img_6.png', height: 120, width: 200, fit: BoxFit.contain),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              SliverList(
                delegate: SliverChildListDelegate([
                  if (!_isSearching)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() => _isSearching = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D2D44),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Discover All Trip Offers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => _showFilterBottomSheet(allContinents),
                            icon: const Icon(Icons.tune, color: Color(0xFF0D2D44), size: 30),
                          ),
                        ],
                      ),
                    ),

                  if (_isSearching && tours.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('No tours found.')),
                    ),

                  for (var continent in continentsToShow) ...[
                    if (filteredTours.any((t) => t.continent == continent)) ...[
                      _buildSectionTitle('Best of $continent'),
                      _buildToursList(context, ref, filteredTours.where((t) => t.continent == continent).toList()),
                    ]
                  ],
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
      ),
    );
  }

  Widget _buildToursList(BuildContext context, WidgetRef ref, List<TourData> items) {
    return SizedBox(
      height: 400,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TourDetailScreen(tourId: item.id!)),
            ),
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
                        child: item.mainImageUrl.startsWith('assets/')
                            ? Image.asset(item.mainImageUrl, height: 200, width: 280, fit: BoxFit.cover)
                            : Image.file(File(item.mainImageUrl), height: 200, width: 280, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _showAddToPlanBottomSheet(item),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: Icon(Icons.bookmark_border, size: 20, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D2D44), height: 1.2),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(item.provider, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(item.duration, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    item.price, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D6A4F)),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Explore Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D2D44))),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward, size: 20, color: Color(0xFF2D6A4F)),
                      ),
                    ],
                  ),
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
