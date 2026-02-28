import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location.dart';
import '../notifiers/location_notifier.dart';
import '../widgets/add_edit_location_form.dart';
import '../widgets/button_section.dart';

class LocationPage extends ConsumerStatefulWidget {
  final int locationId;

  const LocationPage({super.key, required this.locationId});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Location'),
          content: AddEditLocationForm(locationId: widget.locationId),
        );
      },
    );
  }

  Future<void> _deleteLocation() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location?'),
        content: const Text('Are you sure you want to delete this location?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      await ref.read(locationNotifierProvider.notifier).deleteLocation(widget.locationId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsyncValue = ref.watch(locationNotifierProvider);

    return locationsAsyncValue.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (locations) {
        Location? location;
        try {
          location = locations.firstWhere((loc) => loc.id == widget.locationId);
        } catch (e) {
          location = null;
        }

        if (location == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Location Details', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            actions: [
              IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
              IconButton(icon: const Icon(Icons.delete), onPressed: _deleteLocation),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'location-image-${location.id}',
                  child: Image.asset(
                    location.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 250, color: Colors.grey[300]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(location.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 8),
                            Text(location.address, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => ref.read(locationNotifierProvider.notifier).toggleStar(widget.locationId),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(location.isStarred ? Icons.star : Icons.star_border, color: Colors.red, size: 26),
                              const SizedBox(width: 4),
                              Text(location.countStar.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: ButtonSection(),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(location.description, style: const TextStyle(fontSize: 15, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
