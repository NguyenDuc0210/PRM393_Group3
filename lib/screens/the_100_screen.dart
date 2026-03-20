
import 'package:flutter/material.dart';
import '../repositories/database_helper.dart';
import 'the_100_read_more_screen.dart';

class The100Screen extends StatefulWidget {
  const The100Screen({super.key});

  @override
  State<The100Screen> createState() => _The100ScreenState();
}

class _The100ScreenState extends State<The100Screen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await DatabaseHelper.instance.getThe100Categories();
    setState(() {
      _categories = categories;
      _tabController = TabController(length: _categories.length + 1, vsync: this);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _jumpToTab(int index) {
    _tabController?.animateTo(index);
  }

  // --- CRUD Category ---
  void _showCategoryForm({Map<String, dynamic>? category}) {
    final titleController = TextEditingController(text: category?['title']);
    final shortIntroController = TextEditingController(text: category?['shortIntro']);
    final longIntroController = TextEditingController(text: category?['longIntro']);
    final imageController = TextEditingController(text: category?['imageUrl'] ?? 'assets/img_1.png');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: shortIntroController, decoration: const InputDecoration(labelText: 'Short Intro')),
              TextField(controller: longIntroController, decoration: const InputDecoration(labelText: 'Long Intro'), maxLines: 3),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image Path')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final row = {
                'title': titleController.text,
                'shortIntro': shortIntroController.text,
                'longIntro': longIntroController.text,
                'imageUrl': imageController.text,
              };
              if (category == null) {
                await DatabaseHelper.instance.insertThe100Category(row);
              } else {
                await DatabaseHelper.instance.updateThe100Category({...row, 'id': category['id']});
              }
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int id) async {
    await DatabaseHelper.instance.deleteThe100Category(id);
    _loadData();
  }

  // --- CRUD Items ---
  void _showItemForm(int categoryId, {Map<String, dynamic>? item}) {
    final nameController = TextEditingController(text: item?['name']);
    final descController = TextEditingController(text: item?['description']);
    final contentController = TextEditingController(text: item?['fullContent']);
    final imageController = TextEditingController(text: item?['imageUrl'] ?? 'assets/img_1.png');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Destination' : 'Edit Destination'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name (City, Country)')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Summary')),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Full Detail Content'), maxLines: 5),
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'Image Path')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final row = {
                'categoryId': categoryId,
                'name': nameController.text,
                'description': descController.text,
                'fullContent': contentController.text,
                'imageUrl': imageController.text,
              };
              if (item == null) {
                await DatabaseHelper.instance.insertThe100Item(row);
              } else {
                await DatabaseHelper.instance.updateThe100Item({...row, 'id': item['id']});
              }
              Navigator.pop(context);
              setState(() {}); // Refresh list
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('The 100', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.green), onPressed: () => _showCategoryForm()),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.black54,
          tabs: [
            const Tab(text: 'Overview'),
            ..._categories.map((cat) => Tab(text: cat['title'])),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          ..._categories.map((cat) => _buildCategoryTab(cat)),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset('assets/img_5.png', height: 280, width: double.infinity, fit: BoxFit.cover),
              Container(height: 280, color: Colors.black26),
              const Text("Culture Trip's best for 2026", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text('What is The 100?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44))),
          ),
          ..._categories.asMap().entries.map((entry) => _buildNavigationCard(entry.key + 1, entry.value)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(Map<String, dynamic> cat) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showCategoryForm(category: cat)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCategory(cat['id'])),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: () => _showItemForm(cat['id']),
              )
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelper.instance.getThe100ItemsByCategoryId(cat['id']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final items = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat['title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(cat['longIntro'], style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
                    const Divider(height: 40),
                    ...items.map((item) => _buildItemCard(cat['id'], item)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(int catId, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset(item['imageUrl'])),
              Positioned(
                right: 8, top: 8,
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showItemForm(catId, item: item))),
                    const SizedBox(width: 8),
                    CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () async {
                      await DatabaseHelper.instance.deleteThe100Item(item['id']);
                      setState(() {});
                    })),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(item['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(item['description'], style: const TextStyle(fontSize: 15, color: Colors.black87)),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => The100ReadMoreScreen(item: item)));
            },
            child: const Text('Read more →', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(int index, Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () => _jumpToTab(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(cat['imageUrl']), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.6)]))),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat['title'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: Text(cat['shortIntro'], style: const TextStyle(color: Colors.white70))),
                      Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.arrow_forward, size: 18, color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
