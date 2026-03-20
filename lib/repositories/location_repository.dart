
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location.dart';
import 'database_helper.dart';

class LocationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Location>> fetchLocations() async {
    return await _dbHelper.getAllLocations();
  }

  Future<void> addLocation(Location location) async {
    await _dbHelper.insertLocation(location);
  }

  Future<void> updateLocation(Location location) async {
    await _dbHelper.updateLocation(location);
  }

  Future<void> deleteLocation(int locationId) async {
    await _dbHelper.deleteLocation(locationId);
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});
