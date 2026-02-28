import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/CategoryLocation.dart';
import '../models/location.dart';
import '../notifiers/location_notifier.dart';
import '../repositories/location_repository.dart';

class AddEditLocationPage extends ConsumerStatefulWidget {
  final int? locationId;

  const AddEditLocationPage({super.key, this.locationId});

  @override
  ConsumerState<AddEditLocationPage> createState() => _AddEditLocationPageState();
}

class _AddEditLocationPageState extends ConsumerState<AddEditLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String? _selectedContinent;

  bool get _isEditMode => widget.locationId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingLocation();
      });
    }
  }

  Future<void> _loadExistingLocation() async {
    final allLocations = await ref.read(locationRepositoryProvider).fetchLocations();
    try {
      final location = allLocations.firstWhere((loc) => loc.id == widget.locationId);
      setState(() {
        _nameController.text = location.name;
        _addressController.text = location.address;
        _descriptionController.text = location.description;
        _imageUrlController.text = location.imageUrl;
        _selectedContinent = location.continent;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Location not found.')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedContinent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a continent')),
      );
      return;
    }

    final notifier = ref.read(locationNotifierProvider.notifier);
    final id = widget.locationId ?? DateTime.now().millisecondsSinceEpoch;
    final locationData = await ref.read(locationRepositoryProvider).fetchLocations();
    final existingLocation = _isEditMode ? locationData.firstWhere((loc) => loc.id == widget.locationId) : null;

    final location = Location(
      id: id,
      name: _nameController.text,
      address: _addressController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      continent: _selectedContinent!,
      countStar: existingLocation?.countStar ?? 0,
      isStarred: existingLocation?.isStarred ?? false,
    );

    try {
      if (_isEditMode) {
        await notifier.updateLocation(location);
      } else {
        await notifier.addLocation(location);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final continents = CategoryLocation.getCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Location' : 'Add Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Please enter an address' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                 validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (e.g., assets/img.png)'),
                 validator: (value) => (value?.isEmpty ?? true) ? 'Please enter an image URL' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedContinent,
                hint: const Text('Select Continent'),
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedContinent = newValue;
                  });
                },
                items: continents.map<DropdownMenuItem<String>>((CategoryLocation category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a continent' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
