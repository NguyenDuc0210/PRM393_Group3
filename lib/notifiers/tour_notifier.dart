import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour_data.dart';
import '../repositories/database_helper.dart';

class TourNotifier extends StateNotifier<AsyncValue<List<TourData>>> {
  TourNotifier() : super(const AsyncLoading()) {
    loadTours();
  }

  Future<void> loadTours() async {
    state = const AsyncLoading();
    try {
      final tours = await DatabaseHelper.instance.getAllTours();
      state = AsyncValue.data(tours);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> searchTours(String query) async {
    state = const AsyncLoading();
    try {
      final tours = await DatabaseHelper.instance.searchTours(query);
      state = AsyncValue.data(tours);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTour(TourData tour) async {
    try {
      await DatabaseHelper.instance.insertTour(tour);
      await loadTours();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateTour(TourData tour) async {
    try {
      await DatabaseHelper.instance.updateTour(tour);
      await loadTours();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteTour(int id) async {
    try {
      await DatabaseHelper.instance.deleteTour(id);
      await loadTours();
    } catch (e) {
      // Handle error
    }
  }
}

final tourNotifierProvider = StateNotifierProvider<TourNotifier, AsyncValue<List<TourData>>>((ref) {
  return TourNotifier();
});
