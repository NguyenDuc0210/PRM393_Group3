
import 'package:flutter/material.dart';
import '../repositories/plan_repository.dart';

class MyPlansScreen extends StatefulWidget {
  const MyPlansScreen({super.key});

  @override
  State<MyPlansScreen> createState() => _MyPlansScreenState();
}

class _MyPlansScreenState extends State<MyPlansScreen> {
  final PlanRepository _repository = PlanRepository();
  bool _isEditing = false;
  final TextEditingController _planNameController = TextEditingController();

  void _showDeleteConfirmation(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Remove this plan?', style: TextStyle(fontWeight: FontWeight.bold))),
        content: Text(name, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _repository.deletePlan(id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plan removed.'), backgroundColor: Color(0xFF0D2D44)),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCreatePlanDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create New Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _planNameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Plan Name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Divider(),
              InkWell(
                onTap: () {
                  if (_planNameController.text.trim().isNotEmpty) {
                    _repository.addPlan(_planNameController.text.trim());
                    _planNameController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  color: const Color(0xFFC8F2C2),
                  alignment: Alignment.center,
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2D44))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8F2C2),
      body: StreamBuilder<List<MyPlanModel>>(
        stream: _repository.getPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = snapshot.data ?? [];

          return Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      _buildSubHeader(plans),
                      Expanded(
                        child: plans.isEmpty
                            ? _buildEmptyState()
                            : _buildPlansList(plans),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('My Plans', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44))),
                SizedBox(height: 10),
                Text('Your adventures start here. Save articles, build itineraries, and make every journey unforgettable.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF0D2D44))),
              ],
            ),
          ),
          const Icon(Icons.map, size: 60, color: Color(0xFF0D2D44)),
        ],
      ),
    );
  }

  Widget _buildSubHeader(List<MyPlanModel> plans) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('My Plans', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44))),
          if (plans.isNotEmpty)
            IconButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.blue),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'You don\'t have any plans yet? Let\'s change that!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _showCreatePlanDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D2D44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Let\'s Start Planning!', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPlansList(List<MyPlanModel> plans) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Nút thêm mới luôn ở trên cùng
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            onTap: _showCreatePlanDialog,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: const Text('Create New Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            trailing: const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 15,
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ),
        ...plans.map((plan) => Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${plan.articleCount} articles', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 40),
                Text(plan.name, style: const TextStyle(fontSize: 14)),
              ],
            ),
            trailing: _isEditing
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(plan.id, plan.name)
                )
              : const CircleAvatar(
                  backgroundColor: Color(0xFFF1F3F4),
                  radius: 18,
                  child: Icon(Icons.arrow_forward, color: Color(0xFF0D2D44), size: 18),
                ),
          ),
        )).toList(),
      ],
    );
  }
}
