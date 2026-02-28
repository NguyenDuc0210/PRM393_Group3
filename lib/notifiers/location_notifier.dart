import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/location.dart';
import '../repositories/location_repository.dart';

part 'location_notifier.g.dart';

final selectedContinentProvider = StateProvider<String?>((ref) => null);

@Riverpod(keepAlive: true)
class LocationNotifier extends _$LocationNotifier {
  @override
  Future<List<Location>> build() async {
    final selectedContinent = ref.watch(selectedContinentProvider);
    final allLocations = await ref.watch(locationRepositoryProvider).fetchLocations();

    if (selectedContinent == null) {
      return allLocations;
    } else {
      return allLocations.where((loc) => loc.continent == selectedContinent).toList();
    }
  }

  void filterByContinent(String? continentId) {
    ref.read(selectedContinentProvider.notifier).state = continentId;
  }

  Future<void> addLocation(Location location) async {
    await ref.read(locationRepositoryProvider).addLocation(location);
    ref.invalidateSelf();
  }

  Future<void> updateLocation(Location location) async {
    await ref.read(locationRepositoryProvider).updateLocation(location);
    ref.invalidateSelf();
  }

  Future<void> deleteLocation(int locationId) async {
    await ref.read(locationRepositoryProvider).deleteLocation(locationId);
    ref.invalidateSelf();
  }

  Future<void> toggleStar(int locationId) async {
    final repo = ref.read(locationRepositoryProvider);
    final allLocations = await repo.fetchLocations();
    try {
      final locationToUpdate = allLocations.firstWhere((loc) => loc.id == locationId);
      final updatedLocation = locationToUpdate.copyWith(
        isStarred: !locationToUpdate.isStarred,
        countStar: locationToUpdate.isStarred ? locationToUpdate.countStar - 1 : locationToUpdate.countStar + 1,
      );
      await repo.updateLocation(updatedLocation);
      ref.invalidateSelf();
    } catch (e) {
    }
  }
}

final topStarredLocationProvider = Provider<AsyncValue<Location?>>((ref) {
  final locationsAsync = ref.watch(locationNotifierProvider);
  return locationsAsync.whenData((locations) {
    if (locations.isEmpty) {
      return null;
    }
    return locations.reduce((curr, next) => curr.countStar > next.countStar ? curr : next);
  });
});
