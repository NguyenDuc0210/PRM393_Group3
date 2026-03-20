
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour_data.dart';
import '../models/location.dart'; 
import '../notifiers/plan_notifier.dart';
import '../notifiers/navigation_notifier.dart';
import '../repositories/database_helper.dart'; 
import 'tours_screen.dart';

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

  @override
  void initState() {
    super.initState();
    // Đã đổi sang DatabaseHelper
    _tourFuture = DatabaseHelper.instance.getFullTourDetails(widget.tourId);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
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
              child: Image.asset(mapUrl, fit: BoxFit.contain),
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
      imageUrl: tour.images.isNotEmpty ? tour.images[0] : 'assets/img.png',
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

        // Xử lý logic hiển thị startingEnding và country để tránh dấu phẩy dư thừa
        String headerSub = '';
        if (tour.startingEnding.isNotEmpty && tour.country.isNotEmpty) {
          headerSub = '${tour.startingEnding}, ${tour.country}';
        } else {
          headerSub = tour.startingEnding + tour.country;
        }

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
                      child: Icon(Icons.file_download_outlined, color: Colors.black, size: 20),
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 10),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      if (tour.images.isNotEmpty)
                        PageView.builder(
                          controller: _pageController,
                          itemCount: tour.images.length,
                          onPageChanged: (index) => setState(() => _currentPage = index),
                          itemBuilder: (context, index) {
                            return Image.asset(
                              tour.images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );
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
                                child: Image.asset(tour.mapImageUrl, fit: BoxFit.cover),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tour.views, style: const TextStyle(color: Color(0xFF0D2D44), fontWeight: FontWeight.bold, fontSize: 16)),
                          Row(
                            children: [
                              Text('${tour.duration.split(' ')[0]} Days From ', style: const TextStyle(color: Color(0xFF0D2D44), fontWeight: FontWeight.bold, fontSize: 16)),
                              if (tour.oldPrice.isNotEmpty)
                                Text(tour.oldPrice, style: const TextStyle(fontSize: 16, color: Colors.red, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              Text(tour.price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        tour.name,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44), height: 1.1, letterSpacing: -1),
                      ),
                      if (headerSub.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(headerSub, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                      ],
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
                      if (tour.included.isNotEmpty) ...[
                        const Text("What's Included", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                        const SizedBox(height: 16),
                        ...tour.included.map((i) => _buildIncludedItem(i.title, i.description ?? '')),
                        const SizedBox(height: 32),
                      ],
                      if (tour.notIncluded.isNotEmpty) ...[
                        const Text("What's Not Included", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                        const SizedBox(height: 16),
                        ...tour.notIncluded.map((ni) => _buildNotIncludedItem(ni.title, ni.description ?? '')),
                        const SizedBox(height: 32),
                      ],
                      if (tour.itinerary.isNotEmpty) ...[
                        const Text('Itinerary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                        const SizedBox(height: 16),
                        ...tour.itinerary.map((day) => _buildItineraryDay(
                          day.dayTitle, 
                          isFirst: tour.itinerary.indexOf(day) == 0,
                          isLast: tour.itinerary.indexOf(day) == tour.itinerary.length - 1,
                          isExpanded: tour.itinerary.indexOf(day) == 2, 
                          description: day.description,
                          location: day.location,
                          accommodation: day.accommodation,
                        )),
                      ],
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
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('From', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(tour.price, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                  ],
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showAddToPlanBottomSheet(tour),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2D44),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Cho vào plan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
              ],
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
        Row(children: [_buildDetailCell('Guide Type:', tour.guideType, hasInfo: true), _buildDetailCell('Group Size:', tour.groupSize)]),
        const SizedBox(height: 20),
        Row(children: [_buildDetailCell('Physical Rating:', tour.physicalRating), _buildDetailCell('Age Range:', tour.ageRange)]),
        const SizedBox(height: 20),
        Row(children: [_buildDetailCell('Tour Operated In:', tour.tourOperatedIn), _buildDetailCell('Trip Styles:', tour.tripStyle)]),
      ],
    );
  }

  Widget _buildDetailCell(String label, String value, {bool hasInfo = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
            if (hasInfo) ...[const SizedBox(width: 4), const Icon(Icons.info_outline, size: 14, color: Colors.green)],
          ]),
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

  Widget _buildIncludedItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D2D44))),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 8),
            child: Text(desc, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotIncludedItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D2D44))),
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 8),
            child: Text(desc, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryDay(String title, {bool isFirst = false, bool isLast = false, bool isExpanded = false, String? description, String? location, String? accommodation}) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D2D44))),
                    Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.orange),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(description ?? '', style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
                  const SizedBox(height: 16),
                  if (location != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Location:\n$location', style: const TextStyle(fontSize: 14, color: Color(0xFF0D2D44)))),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (accommodation != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.king_bed_outlined, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Accommodation:\n$accommodation', style: const TextStyle(fontSize: 14, color: Color(0xFF0D2D44)))),
                      ],
                    ),
                  ],
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
