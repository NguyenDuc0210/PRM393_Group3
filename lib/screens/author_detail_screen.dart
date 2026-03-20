
import 'package:flutter/material.dart';
import '../models/author.dart';

class AuthorDetailScreen extends StatelessWidget {
  final Author author;

  const AuthorDetailScreen({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(author.imageUrl),
            ),
            const SizedBox(height: 24),
            // Name & Role
            Text(
              author.name,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
            ),
            const SizedBox(height: 8),
            Text(
              author.role.toUpperCase(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 32),
            
            // Basic Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoColumn('Age', '${author.age}'),
                _buildInfoColumn('Country', author.country),
                _buildInfoColumn('Visited', '${author.countriesVisited} Countries'),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Bio Section
            _buildSectionTitle('About Me'),
            const SizedBox(height: 12),
            Text(
              author.bio,
              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Hobbies Section
            _buildSectionTitle('Hobbies'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: author.hobbies.map((hobby) => _buildHobbyChip(hobby)).toList(),
            ),
            
            const SizedBox(height: 40),
            
            // Life View Section (Quote)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.format_quote, color: Color(0xFF42868E), size: 40),
                  const SizedBox(height: 12),
                  Text(
                    author.lifeView,
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0D2D44),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D2D44)),
    );
  }

  Widget _buildHobbyChip(String hobby) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(hobby, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}
