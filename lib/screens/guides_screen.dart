
import 'package:flutter/material.dart';
import 'the_100_screen.dart';
import 'guide_detail_screen.dart';

class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Header màu xanh (Không cố định)
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: const BoxDecoration(color: Color(0xFFC8F2C2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Hello, Culture\nTripper!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      color: Color(0xFF0D2D44),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Let's start making travel\nplans with expert local help.",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),

          // 2. Thanh Search Cố định
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickySearchBarDelegate(),
          ),

          // 3. Danh sách 5 Châu lục
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    _buildContinentItem('Asia', 'assets/img_5.png'),
                    _buildContinentItem('Europe', 'assets/img_5.png'),
                    _buildContinentItem('Africa', 'assets/img_5.png'),
                    _buildContinentItem('Americas', 'assets/img_5.png'),
                    _buildContinentItem('Oceania', 'assets/img_5.png'),
                  ],
                ),
              ),
            ),
          ),

          // 4. Các Section tin tức
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionTitle('Tales From Culture Trippers'),
              _buildHorizontalList(context, categoryLabel: 'Culture'),
              _buildSectionTitle('Foodie Guides'),
              _buildHorizontalList(context, categoryLabel: 'Foodie Inspiration'),
              _buildSectionTitle('Day Trips To Escape The City'),
              _buildHorizontalList(context, categoryLabel: 'Things To Do'),
            ]),
          ),

          // 5. Phần "The 100" ở cuối cùng
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    const Color(0xFFC8F2C2).withOpacity(0.3),
                    const Color(0xFFC8F2C2),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'The 100',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D2D44),
                      letterSpacing: -2,
                    ),
                  ),
                  const Text(
                    '2026 Official Selection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2D44),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    child: Text(
                      "Culture Trip's curated list of unique destinations to visit this year.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Chuyển sang màn hình The 100
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const The100Screen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2D44),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Explore The 100',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Logo "The 100"
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/img_5.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.brightness_7, size: 200, color: Colors.green.withOpacity(0.2)),
                          const Text(
                            'THE\n100',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D2D44),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildContinentItem(String title, String assetPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[200],
            backgroundImage: AssetImage(assetPath),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, {required String categoryLabel}) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: 3,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GuideDetailScreen()),
              );
            },
            child: Container(
              width: 260,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.asset('assets/img_5.png', height: 160, width: double.infinity, fit: BoxFit.cover),
                        ),
                        // Category Label (Nhãn danh mục)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              categoryLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: Icon(Icons.bookmark_border, size: 20, color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'In Search of the Grandest Hotel that Never Existed',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Read More →',
                            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 80.0;
  @override
  double get maxExtent => 80.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: Material(
        elevation: overlapsContent ? 4 : 0,
        color: overlapsContent ? Colors.white : const Color(0xFFC8F2C2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.location_on_outlined, color: Colors.blueAccent),
                  hintText: 'Find a guide you love',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickySearchBarDelegate oldDelegate) => false;
}
