import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour_data.dart';
import '../models/location.dart';
import '../notifiers/plan_notifier.dart';
import '../notifiers/navigation_notifier.dart';
import '../notifiers/tour_notifier.dart';
import '../repositories/database_helper.dart';
import 'add_edit_tour_screen.dart';

class TourDetailScreen extends ConsumerStatefulWidget {
  final int tourId;
  const TourDetailScreen({super.key, required this.tourId});

  @override
  ConsumerState<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends ConsumerState<TourDetailScreen> {
  final TextEditingController _newPlanController = TextEditingController();
  final PageController _pageController = PageController();
  Timer? _autoPlayTimer;
  int _currentPage = 0;
  bool _isVisitingExpanded = false;
  late Future<TourData> _tourFuture;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _loadTour();
    _loadReviews();
  }

  void _loadTour() {
    setState(() {
      _tourFuture = DatabaseHelper.instance.getFullTourDetails(widget.tourId);
    });
    _startAutoPlay();
  }

  void _loadReviews() {
    setState(() {
      _reviewsFuture = DatabaseHelper.instance.getReviewsByTourId(widget.tourId);
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _tourFuture.then((tour) {
        if (tour.images.isEmpty) return;
        if (_currentPage < tour.images.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    _newPlanController.dispose();
    super.dispose();
  }

  void _showFullMap(String mapUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: mapUrl.startsWith('assets/')
                  ? Image.asset(mapUrl, fit: BoxFit.contain)
                  : Image.file(File(mapUrl), fit: BoxFit.contain),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Location _getTourAsLocation(TourData tour) {
    return Location(
      id: tour.id!,
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
                          Navigator.pop(context);
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
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

                    await DatabaseHelper.instance.insertLocation(location);
                    await ref.read(planNotifierProvider.notifier).addLocationToPlan(newPlan.id, location.id);

                    _newPlanController.clear();
                    if (mounted) {
                      Navigator.pop(context);
                      ref.read(navigationIndexProvider.notifier).state = 4;
                      Navigator.pop(context);
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

  void _showDeleteConfirmation(int tourId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tour', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this tour? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await ref.read(tourNotifierProvider.notifier).deleteTour(tourId);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to list
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog(int tourId) {
    final nameController = TextEditingController();
    final commentController = TextEditingController();
    double currentRating = 5.0;
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Review', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Your Name', hintText: 'Enter your name'),
                  onChanged: (_) => setDialogState(() => errorText = null),
                ),
                const SizedBox(height: 20),
                const Align(alignment: Alignment.centerLeft, child: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: currentRating, min: 1, max: 5, divisions: 4, activeColor: Colors.amber,
                        label: currentRating.toString(),
                        onChanged: (val) => setDialogState(() => currentRating = val),
                      ),
                    ),
                    Text(currentRating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Icon(Icons.star, color: Colors.amber),
                  ],
                ),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(labelText: 'Comment', hintText: 'Share your experience'),
                  maxLines: 3,
                  onChanged: (_) => setDialogState(() => errorText = null),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final comment = commentController.text.trim();

                if (name.isEmpty || comment.isEmpty) {
                  setDialogState(() {
                    errorText = 'Please fill in both name and comment';
                  });
                  return;
                }

                await DatabaseHelper.instance.insertReview(tourId, name, currentRating, comment);
                if (mounted) {
                  Navigator.pop(context);
                  _loadReviews(); // Refresh only reviews
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review posted successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2D44)),
              child: const Text('Post Review', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: width, height: height, fit: fit);
    } else {
      return Image.file(File(path), width: width, height: height, fit: fit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TourData>(
      future: _tourFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }
        final tour = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: const Color(0xFF0D2D44),
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, color: Colors.black, size: 20),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddEditTourScreen(tour: tour)),
                      );
                      if (result == true) {
                        _loadTour();
                      }
                    },
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    ),
                    onPressed: () => _showDeleteConfirmation(tour.id!),
                  ),
                  const SizedBox(width: 10),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: tour.images.length,
                        onPageChanged: (index) => setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          return _displayImage(tour.images[index], width: double.infinity);
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: GestureDetector(
                            onTap: () {
                              _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.5),
                              child: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withOpacity(0.5),
                              child: const Icon(Icons.keyboard_arrow_right, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      if (tour.mapImageUrl.isNotEmpty)
                        Positioned(
                          top: 100,
                          right: 20,
                          child: GestureDetector(
                            onTap: () => _showFullMap(tour.mapImageUrl),
                            child: Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: _displayImage(tour.mapImageUrl),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tour.views, style: const TextStyle(color: Color(0xFF0D2D44), fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      Text(
                        tour.name,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44), height: 1.1, letterSpacing: -1),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(tour.duration, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const Spacer(),
                          Text(
                            tour.price,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D6A4F)),
                          ),
                        ],
                      ),
                      if (tour.visiting.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 16, color: Color(0xFF0D2D44), height: 1.5),
                            children: [
                              const TextSpan(text: 'Visiting: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: _isVisitingExpanded ? tour.visiting : (tour.visiting.length > 200 ? '${tour.visiting.substring(0, 200)}...' : tour.visiting),
                              ),
                            ],
                          ),
                        ),
                        if (tour.visiting.length > 200)
                          GestureDetector(
                            onTap: () => setState(() => _isVisitingExpanded = !_isVisitingExpanded),
                            child: Text(_isVisitingExpanded ? "less" : "...more", style: const TextStyle(color: Colors.teal, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold)),
                          ),
                      ],
                      const SizedBox(height: 32),
                      _buildDetailsGrid(tour),
                      const SizedBox(height: 32),
                      const Text('Tour Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                      const SizedBox(height: 16),
                      Text(tour.overview, style: const TextStyle(fontSize: 17, height: 1.6, color: Colors.black87)),
                      const SizedBox(height: 32),
                      if (tour.highlights.isNotEmpty) ...[
                        const Text('Highlights', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                        const SizedBox(height: 16),
                        ...tour.highlights.map((h) => _buildCheckHighlight(h.title)),
                        const SizedBox(height: 32),
                      ],
                      if (tour.itinerary.isNotEmpty) ...[
                        const Text('Itinerary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                        const SizedBox(height: 16),
                        ...tour.itinerary.map((day) => _buildItineraryDay(
                          day.dayTitle,
                          isLast: tour.itinerary.indexOf(day) == tour.itinerary.length - 1,
                          isExpanded: true,
                          description: day.description,
                        )),
                      ],
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Reviews', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                          TextButton.icon(
                            onPressed: () => _showAddReviewDialog(tour.id!),
                            icon: const Icon(Icons.rate_review_outlined),
                            label: const Text('Write a review'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _reviewsFuture,
                        builder: (context, revSnapshot) {
                          if (revSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!revSnapshot.hasData || revSnapshot.data!.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                              child: const Column(
                                children: [
                                  Icon(Icons.reviews_outlined, color: Colors.grey, size: 40),
                                  SizedBox(height: 8),
                                  Text('No reviews yet. Be the first to review!', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: revSnapshot.data!.map((rev) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              color: Colors.grey[50],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(backgroundColor: Color(0xFFC8F2C2), child: Icon(Icons.person, color: Color(0xFF0D2D44))),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(rev['userName'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              Text(rev['date'] != null ? rev['date'].toString().substring(0, 10) : 'Recently', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                          child: Row(
                                            children: [
                                              Text(rev['rating'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                                              const Icon(Icons.star, color: Colors.amber, size: 16),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(rev['comment'] ?? '', style: const TextStyle(fontSize: 15, height: 1.4)),
                                  ],
                                ),
                              ),
                            )).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
            child: ElevatedButton(
              onPressed: () => _showAddToPlanBottomSheet(tour),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2D44),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Add to Plan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsGrid(TourData tour) {
    return Column(
      children: [
        Row(children: [_buildDetailCell('Tour Operator:', tour.tourOperator), _buildDetailCell('Tour Code:', tour.tourCode)]),
        const SizedBox(height: 20),
        Row(children: [_buildDetailCell('Guide Type:', tour.guideType), _buildDetailCell('Group Size:', tour.groupSize)]),
        const SizedBox(height: 20),
        Row(children: [_buildDetailCell('Physical Rating:', tour.physicalRating), _buildDetailCell('Age Range:', tour.ageRange)]),
      ],
    );
  }

  Widget _buildDetailCell(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Color(0xFF0D2D44), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCheckHighlight(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildItineraryDay(String title, {bool isLast = false, bool isExpanded = false, String? description}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: isLast ? Colors.red : Colors.orange, shape: BoxShape.circle)),
            if (!isLast) Expanded(child: Container(width: 2, color: Colors.green.withOpacity(0.3))),
          ]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D2D44))),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(description ?? '', style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
