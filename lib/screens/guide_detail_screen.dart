
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/author.dart';
import '../models/location.dart';
import '../notifiers/plan_notifier.dart';
import '../notifiers/navigation_notifier.dart';
import 'author_detail_screen.dart';

class GuideDetailScreen extends ConsumerStatefulWidget {
  final Location? location;
  const GuideDetailScreen({super.key, this.location});

  @override
  ConsumerState<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends ConsumerState<GuideDetailScreen> {
  final TextEditingController _newPlanController = TextEditingController();

  @override
  void dispose() {
    _newPlanController.dispose();
    super.dispose();
  }

  void _showAddToPlanBottomSheet(Location location) async {
    final plans = await ref.read(planNotifierProvider.future);
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text('Add to Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  GestureDetector(
                    onTap: () => _showCreatePlanDialog(location),
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add, size: 30),
                        ),
                        const SizedBox(height: 8),
                        const Text('New Plan', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ...plans.map((plan) => Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () async {
                        final success = await ref.read(planNotifierProvider.notifier).addLocationToPlan(plan.id, location.id);
                        if (!mounted) return;
                        Navigator.pop(context);
                        if (success) {
                          ref.read(navigationIndexProvider.notifier).state = 3;
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Already in this plan.'), backgroundColor: Color(0xFF0D2D44)),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 8),
                          Text(plan.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCreatePlanDialog(Location location) {
    Navigator.pop(context);
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
                  controller: _newPlanController,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Plan Name', border: InputBorder.none),
                ),
              ),
              const Divider(),
              InkWell(
                onTap: () async {
                  if (_newPlanController.text.trim().isNotEmpty) {
                    await ref.read(planNotifierProvider.notifier).addPlan(_newPlanController.text.trim());
                    final plans = await ref.read(planNotifierProvider.future);
                    final newPlan = plans.first;
                    await ref.read(planNotifierProvider.notifier).addLocationToPlan(newPlan.id, location.id);
                    
                    _newPlanController.clear();
                    if (mounted) {
                      Navigator.pop(context);
                      ref.read(navigationIndexProvider.notifier).state = 3;
                      Navigator.pop(context);
                    }
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
    final author = Author.sampleAuthor;
    final item = widget.location ?? Location.sampleLocations.firstWhere((l) => l.id == 116); // Fallback to "The Castro" content if none provided

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
          Consumer(
            builder: (context, ref, child) {
              final isInPlanAsync = ref.watch(isLocationInAnyPlanProvider(item.id));
              return isInPlanAsync.when(
                data: (isInPlan) => IconButton(
                  icon: Icon(
                    isInPlan ? Icons.bookmark : Icons.bookmark_border, 
                    color: const Color(0xFF0D2D44)
                  ),
                  onPressed: () => _showAddToPlanBottomSheet(item),
                ),
                loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
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
              item.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2D44),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Author Info - Clickable
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthorDetailScreen(author: author)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(author.imageUrl),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              author.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              author.role,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Article Content
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'When you’re a travel writer who loves film, its hard not to come up with a Mount Rushmore of movie locations you want to visit in your lifetime. I’ve been fortunate to see dozens of contenders for the top spot during my travels, but arguably the most memorable was in a small German town a few days before everything ground to a halt.',
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      item.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Center(
                    child: Text(
                      'About the Author',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Author Card - Clickable
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthorDetailScreen(author: author)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(author.imageUrl),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      author.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      author.role,
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.link, color: Colors.blue),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            author.bio,
                            style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
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
                          'assets/img_1.png',
                        ),
                        _buildReadNextCard(
                          'See & Do',
                          '19 Eco-Friendly Spots Around the World',
                          'assets/img_2.png',
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
