
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location.dart';
import '../repositories/plan_repository.dart';
import '../repositories/database_helper.dart';

class PlanNotifier extends AsyncNotifier<List<MyPlanModel>> {
  final PlanRepository _repository = PlanRepository();

  @override
  Future<List<MyPlanModel>> build() async {
    return await _repository.getPlans();
  }

  Future<void> addPlan(String name) async {
    state = const AsyncValue.loading();
    await _repository.addPlan(name);
    state = AsyncValue.data(await _repository.getPlans());
  }

  Future<void> updatePlanName(int id, String newName) async {
    state = const AsyncValue.loading();
    await _repository.updatePlanName(id, newName);
    state = AsyncValue.data(await _repository.getPlans());
  }

  Future<void> deletePlan(int id) async {
    state = const AsyncValue.loading();
    await _repository.deletePlan(id);
    state = AsyncValue.data(await _repository.getPlans());
  }

  Future<bool> addLocationToPlan(int planId, int locationId) async {
    final success = await _repository.addLocationToPlan(planId, locationId);
    if (success) {
      ref.invalidateSelf(); 
      ref.invalidate(planLocationsProvider);
      ref.invalidate(isLocationInAnyPlanProvider(locationId));
    }
    return success;
  }

  Future<void> removeLocationFromPlan(int planId, int locationId) async {
    await _repository.removeLocationFromPlan(planId, locationId);
    ref.invalidateSelf();
    ref.invalidate(planLocationsProvider);
    ref.invalidate(isLocationInAnyPlanProvider(locationId));
  }
}

final planNotifierProvider = AsyncNotifierProvider<PlanNotifier, List<MyPlanModel>>(PlanNotifier.new);

final planLocationsProvider = FutureProvider.family<List<Location>, int>((ref, planId) async {
  final repository = PlanRepository();
  return await repository.getPlanLocations(planId);
});

final isLocationInAnyPlanProvider = FutureProvider.family<bool, int>((ref, locationId) async {
  return await DatabaseHelper.instance.isLocationInAnyPlan(locationId);
});
