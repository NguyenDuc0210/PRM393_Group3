
import 'package:flutter/material.dart';

class MyPlan {
  final String name;
  final int articleCount;

  MyPlan({required this.name, this.articleCount = 0});
}

class MyPlansScreen extends StatefulWidget {
  const MyPlansScreen({super.key});

  @override
  State<MyPlansScreen> createState() => _MyPlansScreenState();
}

class _MyPlansScreenState extends State<MyPlansScreen> {
  final List<MyPlan> _plans = [];
  bool _isEditing = false;
  final TextEditingController _planNameController = TextEditingController();

  void _addPlan(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      _plans.add(MyPlan(name: name));
    });
    _planNameController.clear();
  }

  void _removePlan(int index) {
    final removedPlan = _plans[index];
    setState(() {
      _plans.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Plan removed.'),
        backgroundColor: const Color(0xFF0D2D44),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFFC8F2C2),
          onPressed: () {
            setState(() {
              _plans.insert(index, removedPlan);
            });
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Remove this plan?', style: TextStyle(fontWeight: FontWeight.bold))),
        content: Text(_plans[index].name, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removePlan(index);
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
                  _addPlan(_planNameController.text);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'My Plans',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D2D44),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Your adventures start here. Save articles, build itineraries, and make every journey unforgettable.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF0D2D44)),
                      ),
                    ],
                  ),
                ),
                // Simple illustration placeholder
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Icon(Icons.person, size: 80, color: const Color(0xFF0D2D44).withOpacity(0.5)),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 20,
                        child: Icon(Icons.map, size: 40, color: Colors.green[800]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Plans',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
                        ),
                        if (_plans.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                            icon: Text(
                              _isEditing ? 'Done' : '',
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                            label: Icon(
                              _isEditing ? Icons.check : Icons.edit,
                              color: Colors.blue,
                              size: 20,
                            ),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _plans.isEmpty ? _buildEmptyState() : _buildPlansList(),
                  ),
                ],
              ),
            ),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ElevatedButton(
            onPressed: _showCreatePlanDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D2D44),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Let\'s Start Planning!',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlansList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Create New Plan Card
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9).withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: const Text('Create New Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text('Organize your favorite articles into a custom travel plan.', style: TextStyle(fontSize: 12)),
            trailing: InkWell(
              onTap: _showCreatePlanDialog,
              child: const CircleAvatar(
                backgroundColor: Colors.green,
                radius: 15,
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        // Plans Items
        ..._plans.asMap().entries.map((entry) {
          int index = entry.key;
          MyPlan plan = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Dismissible(
              key: Key(plan.name + index.toString()),
              direction: _isEditing ? DismissDirection.endToStart : DismissDirection.none,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.black),
              ),
              confirmDismiss: (direction) async {
                _showDeleteConfirmation(index);
                return false;
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                          icon: const Icon(Icons.delete_outline, color: Colors.black),
                          onPressed: () => _showDeleteConfirmation(index),
                        )
                      : const CircleAvatar(
                          backgroundColor: Color(0xFFF1F3F4),
                          radius: 18,
                          child: Icon(Icons.arrow_forward, color: Color(0xFF0D2D44), size: 20),
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
