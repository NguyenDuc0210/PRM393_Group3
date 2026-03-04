
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPlanModel {
  final String id;
  final String name;
  final int articleCount;

  MyPlanModel({required this.id, required this.name, this.articleCount = 0});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'articleCount': articleCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory MyPlanModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return MyPlanModel(
      id: snap.id,
      name: data['name'] ?? '',
      articleCount: data['articleCount'] ?? 0,
    );
  }
}

class PlanRepository {
  final CollectionReference _plansCollection =
      FirebaseFirestore.instance.collection('plans');

  // Lấy danh sách kế hoạch (Real-time)
  Stream<List<MyPlanModel>> getPlans() {
    return _plansCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MyPlanModel.fromSnapshot(doc)).toList();
    });
  }

  // Thêm kế hoạch mới
  Future<void> addPlan(String name) {
    return _plansCollection.add({
      'name': name,
      'articleCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Xóa kế hoạch
  Future<void> deletePlan(String id) {
    return _plansCollection.doc(id).delete();
  }
}
