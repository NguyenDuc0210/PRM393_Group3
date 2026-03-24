
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tour_data.dart';
import '../repositories/database_helper.dart';
import '../notifiers/tour_notifier.dart';

class AddEditTourScreen extends ConsumerStatefulWidget {
  final TourData? tour;
  const AddEditTourScreen({super.key, this.tour});

  @override
  ConsumerState<AddEditTourScreen> createState() => _AddEditTourScreenState();
}

class _AddEditTourScreenState extends ConsumerState<AddEditTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _providerController;
  late TextEditingController _overviewController;
  late TextEditingController _visitingController;
  late TextEditingController _priceController; // Thêm controller cho giá

  String? _selectedDuration;
  String? _selectedContinent;
  String? _mainImageUrl;
  List<String> _galleryImages = [];
  List<TourFeature> _highlights = [];
  List<TourItinerary> _itinerary = [];

  final List<String> _durations = ['3 days', '5 days', '7 days', '8 days', '10 days', '15 days', '20 days', '30 days', '41 days', '48 days', '65 days'];
  final List<String> _continents = ['Europe', 'Asia', 'Africa', 'South America', 'Australia', 'North America', 'Antarctica'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tour?.name ?? '');
    _providerController = TextEditingController(text: widget.tour?.provider ?? '');
    _overviewController = TextEditingController(text: widget.tour?.overview ?? '');
    _visitingController = TextEditingController(text: widget.tour?.visiting ?? '');
    _priceController = TextEditingController(text: widget.tour?.price ?? 'From \$');

    _selectedDuration = widget.tour?.duration;
    _selectedContinent = widget.tour?.continent;
    _mainImageUrl = widget.tour?.mainImageUrl ?? 'assets/img.png';

    if (widget.tour != null) {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    final fullTour = await DatabaseHelper.instance.getFullTourDetails(widget.tour!.id!);
    setState(() {
      _galleryImages = List.from(fullTour.images);
      _highlights = List.from(fullTour.highlights);
      _itinerary = List.from(fullTour.itinerary);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _overviewController.dispose();
    _visitingController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _mainImageUrl = image.path);
    }
  }

  Future<void> _pickGalleryImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _galleryImages.add(image.path));
    }
  }

  void _saveTour() async {
    if (_formKey.currentState!.validate()) {
      final tourData = TourData(
        id: widget.tour?.id,
        name: _nameController.text,
        provider: _providerController.text,
        duration: _selectedDuration ?? '7 days',
        continent: _selectedContinent ?? 'Asia',
        views: widget.tour?.views ?? '0 Views',
        startingEnding: widget.tour?.startingEnding ?? '',
        country: widget.tour?.country ?? '',
        visiting: _visitingController.text,
        tourOperator: _providerController.text,
        tourCode: widget.tour?.tourCode ?? 'TOUR-${DateTime.now().millisecond}',
        guideType: widget.tour?.guideType ?? 'Fully Guided',
        groupSize: widget.tour?.groupSize ?? '1 - 20',
        physicalRating: widget.tour?.physicalRating ?? 'Medium',
        ageRange: widget.tour?.ageRange ?? '12+',
        tourOperatedIn: widget.tour?.tourOperatedIn ?? 'English',
        tripStyle: widget.tour?.tripStyle ?? 'Adventure',
        overview: _overviewController.text,
        mapImageUrl: widget.tour?.mapImageUrl ?? 'assets/img_6.png',
        mainImageUrl: _mainImageUrl ?? 'assets/img.png',
        price: _priceController.text, // Truyền giá vào đây
      );

      int tourId;
      if (widget.tour == null) {
        tourId = await DatabaseHelper.instance.insertTour(tourData);
      } else {
        tourId = widget.tour!.id!;
        await DatabaseHelper.instance.updateTour(tourData);
        final db = await DatabaseHelper.instance.database;
        await db.delete('tour_features', where: 'tourId = ?', whereArgs: [tourId]);
        await db.delete('tour_itinerary', where: 'tourId = ?', whereArgs: [tourId]);
        await DatabaseHelper.instance.deleteTourImages(tourId);
      }

      for (var img in _galleryImages) {
        await DatabaseHelper.instance.insertTourImage(tourId, img);
      }
      for (var h in _highlights) {
        await DatabaseHelper.instance.insertTourFeature(TourFeature(tourId: tourId, title: h.title, type: 'highlight'));
      }
      for (var i in _itinerary) {
        await DatabaseHelper.instance.insertTourItinerary(TourItinerary(
            tourId: tourId, dayTitle: i.dayTitle, description: i.description,
            location: i.location, accommodation: i.accommodation
        ));
      }

      ref.read(tourNotifierProvider.notifier).loadTours();
      if (mounted) Navigator.pop(context, true);
    }
  }

  Widget _displayImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: width, height: height, fit: fit);
    } else {
      return Image.file(File(path), width: width, height: height, fit: fit);
    }
  }

  void _addHighlight() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Highlight'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() => _highlights.add(TourFeature(title: controller.text, type: 'highlight')));
              Navigator.pop(context);
            }
          }, child: const Text('Add')),
        ],
      ),
    );
  }

  void _addItinerary() {
    final dayController = TextEditingController();
    final descController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Itinerary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: dayController, decoration: const InputDecoration(labelText: 'Day (e.g. Day 1)')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            if (dayController.text.isNotEmpty) {
              setState(() => _itinerary.add(TourItinerary(dayTitle: dayController.text, description: descController.text, location: '', accommodation: '')));
              Navigator.pop(context);
            }
          }, child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tour == null ? 'Add Tour' : 'Edit Tour'),
        backgroundColor: const Color(0xFFC8F2C2),
        actions: [IconButton(onPressed: _saveTour, icon: const Icon(Icons.check))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Main Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickMainImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[400]!)),
                child: _mainImageUrl != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: _displayImage(_mainImageUrl!))
                    : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tour Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _providerController, decoration: const InputDecoration(labelText: 'Provider'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price (e.g. From \$1,200)'), validator: (v) => v!.isEmpty ? 'Required' : null),

            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDuration,
              decoration: const InputDecoration(labelText: 'Duration'),
              items: _durations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) => setState(() => _selectedDuration = val),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedContinent,
              decoration: const InputDecoration(labelText: 'Continent'),
              items: _continents.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedContinent = val),
              validator: (v) => v == null ? 'Required' : null,
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gallery Images', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: _pickGalleryImage, icon: const Icon(Icons.add_photo_alternate, color: Colors.blue)),
              ],
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _galleryImages.length,
                itemBuilder: (context, index) => Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _displayImage(_galleryImages[index])),
                    ),
                    Positioned(
                      top: 0, right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _galleryImages.removeAt(index)),
                        child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(controller: _visitingController, decoration: const InputDecoration(labelText: 'Visiting'), maxLines: 2),
            TextFormField(controller: _overviewController, decoration: const InputDecoration(labelText: 'Overview'), maxLines: 3),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Highlights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: _addHighlight, icon: const Icon(Icons.add_circle, color: Colors.green)),
              ],
            ),
            ..._highlights.map((h) => ListTile(
              title: Text(h.title),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _highlights.remove(h))),
            )),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Itinerary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: _addItinerary, icon: const Icon(Icons.add_circle, color: Colors.orange)),
              ],
            ),
            ..._itinerary.map((i) => ListTile(
              title: Text(i.dayTitle),
              subtitle: Text(i.description),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => _itinerary.remove(i))),
            )),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
