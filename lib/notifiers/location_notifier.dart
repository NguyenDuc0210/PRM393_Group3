import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location.dart';
import '../repositories/location_repository.dart';

// 1. Quản lý châu lục được chọn
final selectedContinentProvider = StateProvider<String?>((ref) => null);

// 2. Provider lấy TOÀN BỘ danh sách địa điểm (Dùng để hiển thị San Francisco)
final allLocationsProvider = FutureProvider<List<Location>>((ref) async {
  final repo = ref.watch(locationRepositoryProvider);
  return await repo.fetchLocations();
});

// 3. Provider chính cho danh sách (có lọc theo châu lục)
final locationNotifierProvider = AsyncNotifierProvider<LocationNotifier, List<Location>>(LocationNotifier.new);

class LocationNotifier extends AsyncNotifier<List<Location>> {
  @override
  Future<List<Location>> build() async {
    final selectedContinent = ref.watch(selectedContinentProvider);
    final allLocs = await ref.watch(allLocationsProvider.future);

    if (selectedContinent == null) {
      return allLocs;
    } else {
      return allLocs.where((loc) => loc.continent == selectedContinent).toList();
    }
  }

  void filterByContinent(String? continentId) {
    ref.read(selectedContinentProvider.notifier).state = continentId;
  }

  // Hàm làm mới dữ liệu chuẩn xác
  Future<void> _refreshData() async {
    ref.invalidate(allLocationsProvider);
    final updatedList = await build();
    state = AsyncValue.data(updatedList);
  }

  Future<void> addLocation(Location location) async {
    state = const AsyncValue.loading();
    await ref.read(locationRepositoryProvider).addLocation(location);
    await _refreshData();
  }

  Future<void> updateLocation(Location location) async {
    state = const AsyncValue.loading();
    await ref.read(locationRepositoryProvider).updateLocation(location);
    await _refreshData();
  }

  Future<void> deleteLocation(int locationId) async {
    state = const AsyncValue.loading();
    await ref.read(locationRepositoryProvider).deleteLocation(locationId);
    await _refreshData();
  }

  Future<void> toggleStar(int locationId) async {
    final repo = ref.read(locationRepositoryProvider);
    final allLocs = await ref.read(allLocationsProvider.future);
    try {
      final locationToUpdate = allLocs.firstWhere((loc) => loc.id == locationId);
      final updatedLocation = locationToUpdate.copyWith(
        isStarred: !locationToUpdate.isStarred,
        countStar: locationToUpdate.isStarred ? locationToUpdate.countStar - 1 : locationToUpdate.countStar + 1,
      );
      await repo.updateLocation(updatedLocation);
      await _refreshData();
    } catch (e) {
      // Ignored
    }
  }
}

// 4. Provider lấy địa điểm có sao cao nhất
final topStarredLocationProvider = Provider<AsyncValue<Location?>>((ref) {
  final locationsAsync = ref.watch(locationNotifierProvider);
  return locationsAsync.whenData((locations) {
    if (locations.isEmpty) return null;
    return locations.reduce((curr, next) => curr.countStar > next.countStar ? curr : next);
  });
});
