
import '../models/location.dart';
import 'database_helper.dart';

class MyPlanModel {
  final int id;
  final String name;
  final int articleCount;
  final DateTime createdAt;

  MyPlanModel({
    required this.id,
    required this.name,
    this.articleCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'articleCount': articleCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MyPlanModel.fromMap(Map<String, dynamic> map) {
    return MyPlanModel(
      id: map['id'] as int,
      name: map['name'] ?? '',
      articleCount: map['articleCount'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class PlanRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Lấy danh sách kế hoạch
  Future<List<MyPlanModel>> getPlans() async {
    final List<Map<String, dynamic>> maps = await _dbHelper.getAllPlans();
    return maps.map((map) => MyPlanModel.fromMap(map)).toList();
  }

  // Thêm kế hoạch mới
  Future<void> addPlan(String name) async {
    await _dbHelper.insertPlan(name);
  }

  // Cập nhật tên kế hoạch
  Future<void> updatePlanName(int id, String newName) async {
    await _dbHelper.updatePlanName(id, newName);
  }

  // Xóa kế hoạch
  Future<void> deletePlan(int id) async {
    await _dbHelper.deletePlan(id);
  }

  // Thêm địa điểm vào kế hoạch
  Future<bool> addLocationToPlan(int planId, int locationId) async {
    final result = await _dbHelper.addItemToPlan(planId, locationId);
    return result != -1;
  }

  // Lấy các địa điểm trong một kế hoạch
  Future<List<Location>> getPlanLocations(int planId) async {
    return await _dbHelper.getLocationsByPlanId(planId);
  }

  // Xóa địa điểm khỏi kế hoạch
  Future<void> removeLocationFromPlan(int planId, int locationId) async {
    await _dbHelper.removeItemFromPlan(planId, locationId);
  }
}
