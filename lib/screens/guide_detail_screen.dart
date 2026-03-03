
import 'package:flutter/material.dart';

class GuideDetailScreen extends StatelessWidget {
  const GuideDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Row(
            children: [
              Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
              Text('Back', style: TextStyle(color: Colors.black, fontSize: 16)),
            ],
          ),
          onPressed: () => Navigator.pop(context),
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Color(0xFF0D2D44)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Color(0xFF0D2D44)),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image
            Image.asset(
              'assets/img_5.png', // Placeholder
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'In Search of the Grandest Hotel that Never Existed',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2D44),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Author Info
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/img_5.png'), // Placeholder
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cassam Looch',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Editorial Manager',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Article Content
                  const Text(
                    'When you’re a travel writer who loves film, its hard not to come up with a Mount Rushmore of movie locations you want to visit in your lifetime. I’ve been fortunate to see dozens of contenders for the top spot during my travels, but arguably the most memorable was in a small German town a few days before everything ground to a halt.',
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'This is the story of two intrepid travellers who embarked on a journey to find the real-life Grand Budapest Hotel mere days before the world changed forever.',
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/img_5.png', // Placeholder
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Joining me on this cinematic adventure was my colleague Adu Lalouscheck, with whom I had made the award-winning video series Beyond Hollywood. We travelled in February 2020 – yes the month before all travel was paused – and now more than five years later I still think this was one of the best trips I have ever taken.',
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'About the Author',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Author Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage('assets/img_5.png'),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Cassam Looch',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'Editorial Manager',
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.link, color: Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Cassam Looch has been working within travel for more than a decade. An expert on film locations and set jetting destinations, Cassam is also a keen advocate of the many unique things to do in his home city of London. With more than 50 countries visited (so far), Cassam also has a great take on the rest of the world.',
                          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Read Next',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Read Next Cards
                  SizedBox(
                    height: 300,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildReadNextCard(
                          'Guides & Tips',
                          'The 10 Most Beautiful Castles in Germany',
                          'assets/img_5.png',
                        ),
                        _buildReadNextCard(
                          'See & Do',
                          '19 Eco-Friendly Spots Around the World',
                          'assets/img_5.png',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadNextCard(String tag, String title, String image) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(image, height: 140, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Read More →',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
