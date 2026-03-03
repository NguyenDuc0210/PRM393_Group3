
import 'package:flutter/material.dart';

class The100Screen extends StatefulWidget {
  const The100Screen({super.key});

  @override
  State<The100Screen> createState() => _The100ScreenState();
}

class _The100ScreenState extends State<The100Screen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Chỉ giữ lại 5 tab (Overview + 4 danh mục)
  final List<String> _tabs = [
    'Overview',
    'Unique Food Cities',
    'Otherworldly Landscapes',
    'Influencer-Free',
    'Magical Journeys',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _jumpToTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Back', style: TextStyle(color: Colors.black, fontSize: 16)),
        titleSpacing: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCategoryContent('Unique Food Cities'),
          _buildCategoryContent('Otherworldly Landscapes'),
          _buildCategoryContent('Influencer-Free'),
          _buildCategoryContent('Magical Journeys'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Guides'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Tours'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'My Plans'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (index) {
          if (index != 0) {
             Navigator.pop(context);
          }
        },
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
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Text('The 100', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  const Text("Culture Trip's best of the best for 2026", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'What is The 100?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "It's simple. We're fed up of the same-old top 10s... So we created unique categories to inspire your next adventure.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
            ),
          ),

          const SizedBox(height: 20),

          // 4 thẻ điều hướng tương ứng với 4 tab nội dung
          _buildNavigationCard(1, 'Unique Food Cities', 'assets/img_5.png'),
          _buildNavigationCard(2, 'Otherworldly Landscapes', 'assets/img_5.png'),
          _buildNavigationCard(3, 'Influencer-Free', 'assets/img_5.png'),
          _buildNavigationCard(4, 'Magical Journeys', 'assets/img_5.png'),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(String title) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset('assets/img_5.png', height: 250, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text(
                  "Explore the most incredible destinations in this category...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(int index, String title, String assetPath) {
    return GestureDetector(
      onTap: () => _jumpToTab(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.6)]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Expanded(child: Text('Explore this category...', style: TextStyle(color: Colors.white70))),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward, size: 18, color: Colors.black),
                      ),
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
