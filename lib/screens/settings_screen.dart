
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theo dõi trạng thái đăng nhập để hiển thị header phù hợp
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFC8F2C2),
      body: Column(
        children: [
          _buildHeader(context, user),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildProfileItem(Icons.person_outline, 'Account', isEnabled: user != null),
                    _buildProfileItem(Icons.settings_outlined, 'Settings', isEnabled: true),
                    const Divider(indent: 60),
                    _buildProfileItem(Icons.file_download_outlined, 'Downloaded Articles', isEnabled: false),
                    const Divider(indent: 60),
                    _buildProfileItem(Icons.star_outline, 'Rate Our App', isEnabled: true),
                    _buildProfileItem(Icons.chat_bubble_outline, 'Send Us Feedback', isEnabled: true),
                    _buildProfileItem(Icons.lock_outline, 'Privacy & Legal', isEnabled: true),
                    
                    if (user != null) ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Log Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 30),
                    if (user == null) _buildFooter(context),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/img_5.png'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null ? 'Hello, ${user.email}!' : 'Welcome to The Culture Trip!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D2D44),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user != null 
                        ? 'Great to have you back. Ready for your next adventure?' 
                        : 'Log in to unlock the ability to create travel plans, explore local guide articles, and so much more!',
                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (user == null) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2D44),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0D2D44)),
                      foregroundColor: const Color(0xFF0D2D44),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {required bool isEnabled}) {
    return ListTile(
      leading: Icon(icon, color: isEnabled ? const Color(0xFF0D2D44) : Colors.grey[400]),
      title: Text(
        title,
        style: TextStyle(
          color: isEnabled ? Colors.black87 : Colors.grey[400],
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: isEnabled ? () {} : null,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to explore the world?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: const Text(
                  'Log in',
                  style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(' or '),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                child: const Text(
                  'sign up',
                  style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(' to save plans, access local guides, and more!'),
            ],
          ),
        ],
      ),
    );
  }
}
