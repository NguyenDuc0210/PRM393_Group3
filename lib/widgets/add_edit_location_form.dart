import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/CategoryLocation.dart';
import '../models/location.dart';
import '../notifiers/location_notifier.dart';
import '../repositories/location_repository.dart';

class AddEditLocationForm extends ConsumerStatefulWidget {
  final int? locationId;

  const AddEditLocationForm({super.key, this.locationId});

  @override
  ConsumerState<AddEditLocationForm> createState() => _AddEditLocationFormState();
}

class _AddEditLocationFormState extends ConsumerState<AddEditLocationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController(text: 'assets/img.png');
  String? _selectedContinent;

  bool get _isEditMode => widget.locationId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingLocation());
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedContinent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a continent'), backgroundColor: Colors.red),
      );
      return;
    }

    final id = widget.locationId ?? DateTime.now().millisecondsSinceEpoch;
    final locationData = await ref.read(locationRepositoryProvider).fetchLocations();
    Location? existingLocation;
    if(_isEditMode) {
        try {
            existingLocation = locationData.firstWhere((loc) => loc.id == widget.locationId);
        } catch(e) {
            existingLocation = null;
        }
    }

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

    final notifier = ref.read(locationNotifierProvider.notifier);
    if (_isEditMode) {
      await notifier.updateLocation(location);
    } else {
      await notifier.addLocation(location);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTextField(_nameController, 'Name'),
            _buildTextField(_addressController, 'Address'),
            _buildTextField(_descriptionController, 'Description', maxLines: 3),
            _buildTextField(_imageUrlController, 'Image URL'),
            const SizedBox(height: 16),
            Text('Continent', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildContinentSelector(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Location'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.black.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a $label' : null,
      ),
    );
  }

  Widget _buildContinentSelector() {
    final continents = CategoryLocation.getCategories();
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: continents.map((category) {
        final isSelected = _selectedContinent == category.id;
        return ChoiceChip(
          label: Text(category.name),
          avatar: Icon(category.icon, color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedContinent = category.id;
              }
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}
