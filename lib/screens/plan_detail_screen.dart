import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location.dart';
import '../repositories/plan_repository.dart';
import '../notifiers/plan_notifier.dart';
import 'guide_detail_screen.dart';
import 'tour_detail_screen.dart';

class PlanDetailScreen extends ConsumerWidget {
  final MyPlanModel plan;
  const PlanDetailScreen({super.key, required this.plan});

  void _confirmDelete(BuildContext context, WidgetRef ref, Location location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold))),
        content: const Text('Do you want to delete this article?', textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(planNotifierProvider.notifier).removeLocationFromPlan(plan.id, location.id);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(planLocationsProvider(plan.id));

    return Scaffold(
      backgroundColor: const Color(0xFFC8F2C2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0D2D44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('PLAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44))),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz, color: Color(0xFF0D2D44)), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(plan.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44))),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: locationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (locations) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                        child: Text('${locations.length} articles', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        child: locations.isEmpty 
                          ? const Center(child: Text('No articles in this plan yet.'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: locations.length,
                              itemBuilder: (context, index) {
                                final item = locations[index];
                                return _buildArticleCard(context, ref, item);
                              },
                            ),
                      ),
                    ],
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, WidgetRef ref, Location item) {
    return GestureDetector(
      // Cho phép nhấn vào toàn bộ card để xem chi tiết
      onTap: () => _navigateToDetail(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(item.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
                if (item.type != null)
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Text(item.type!.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 12, right: 12,
                  child: GestureDetector(
                    onTap: () => _confirmDelete(context, ref, item),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: Icon(Icons.bookmark, size: 20, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  const Text('Read More →', style: TextStyle(color: Color(0xFF42868E), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Location item) {
    if (item.type == 'tour') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TourDetailScreen(tourId: item.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GuideDetailScreen()),
      );
    }
  }
}
