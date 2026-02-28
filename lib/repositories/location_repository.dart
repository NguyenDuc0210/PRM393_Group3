import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location.dart';

class LocationRepository {
  final List<Location> _locations = List.from(Location.sampleLocations);
  int _nextId = 11;

  Future<List<Location>> fetchLocations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_locations);
  }

  Future<void> addLocation(Location location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _locations.add(location.copyWith(id: _nextId++));
  }

  Future<void> updateLocation(Location location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _locations.indexWhere((loc) => loc.id == location.id);
    if (index != -1) {
      _locations[index] = location;
    }
  }

  Future<void> deleteLocation(int locationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _locations.removeWhere((loc) => loc.id == locationId);
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});
