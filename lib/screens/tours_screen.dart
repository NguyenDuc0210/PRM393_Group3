
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour_data.dart';
import '../models/location.dart';
import '../notifiers/plan_notifier.dart';
import '../notifiers/navigation_notifier.dart';
import '../repositories/database_helper.dart';
import 'tour_detail_screen.dart';

// Tạo một provider để load dữ liệu tour
final toursProvider = FutureProvider<Map<String, List<TourData>>>((ref) async {
  final db = DatabaseHelper.instance;
  return {
    'Europe': await db.getToursByContinent('Europe'),
    'Asia': await db.getToursByContinent('Asia'),
    'Africa': await db.getToursByContinent('Africa'),
    'South America': await db.getToursByContinent('South America'),
    'Australia': await db.getToursByContinent('Australia'),
  };
});

class ToursScreen extends ConsumerWidget {
  const ToursScreen({super.key});

  Location _getTourAsLocation(TourData tour) {
    return Location(
      id: tour.id!,
      name: tour.name,
      address: tour.provider,
      description: tour.overview,
      countStar: 0,
      imageUrl: tour.images.isNotEmpty ? tour.images[0] : 'assets/img.png',
      continent: tour.continent.toLowerCase(),
      type: 'tour',
    );
  }

  void _showAddToPlanBottomSheet(BuildContext context, WidgetRef ref, TourData tour) async {
    final location = _getTourAsLocation(tour);
    final plans = await ref.read(planNotifierProvider.future);
    
    if (!context.mounted) return;

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
                    onTap: () => _showCreatePlanDialog(context, ref, location),
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
                        if (!context.mounted) return;
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

  void _showCreatePlanDialog(BuildContext context, WidgetRef ref, Location location) {
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
                    
                    if (context.mounted) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final toursAsync = ref.watch(toursProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: toursAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (toursMap) => CustomScrollView(
          slivers: [
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
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: Color(0xFF0D2D44),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Find your perfect getaway with trips from top providers, now on The Culture Trip Marketplace.",
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
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2D44),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Discover All Trip Offers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),

                if (toursMap['Europe']!.isNotEmpty) ...[
                  _buildSectionTitle('Travel In Europe 2026'),
                  _buildToursList(context, ref, toursMap['Europe']!),
                ],
                if (toursMap['Asia']!.isNotEmpty) ...[
                  _buildSectionTitle('Best Of Asia 2026'),
                  _buildToursList(context, ref, toursMap['Asia']!),
                ],
                if (toursMap['Africa']!.isNotEmpty) ...[
                  _buildSectionTitle('Tours In Africa 2026'),
                  _buildToursList(context, ref, toursMap['Africa']!),
                ],
                if (toursMap['South America']!.isNotEmpty) ...[
                  _buildSectionTitle('Travel In South America 2026'),
                  _buildToursList(context, ref, toursMap['South America']!),
                ],
                if (toursMap['Australia']!.isNotEmpty) ...[
                  _buildSectionTitle('Travel In Australia 2026'),
                  _buildToursList(context, ref, toursMap['Australia']!),
                ],
                const SizedBox(height: 40),
              ]),
            ),
          ],
        ),
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
      height: 380,
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
                        child: Image.asset(
                          item.images.isNotEmpty ? item.images[0] : 'assets/img.png',
                          height: 200, width: 280, fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _showAddToPlanBottomSheet(context, ref, item),
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
                  const SizedBox(height: 12),
                  Text(item.provider, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(item.duration, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'From ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            TextSpan(text: item.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D2D44))),
                          ],
                        ),
                      ),
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
