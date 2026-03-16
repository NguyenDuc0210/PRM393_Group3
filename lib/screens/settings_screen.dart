
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../notifiers/navigation_notifier.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authRepo = AuthRepository();
    final prefs = await SharedPreferences.getInstance();
    
    try {
      await authRepo.signOut();
      await prefs.remove('auth_token');
      
      if (mounted) {
        // Reset navigation to Home tab
        ref.read(navigationIndexProvider.notifier).state = 0;
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        'Profile Settings',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    if (user != null) ...[
                      _buildProfileItem(Icons.email_outlined, 'Email: ${user.email ?? "N/A"}', isEnabled: false),
                      _buildProfileItem(Icons.badge_outlined, 'Name: ${user.displayName ?? "Traveler"}', isEnabled: false),
                      
                      const Divider(indent: 24, endIndent: 24),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _handleLogout(context),
                      ),
                    ] else ...[
                       _buildFooter(context),
                    ],

                    const Divider(indent: 24, endIndent: 24),
                    _buildProfileItem(Icons.settings_outlined, 'App Settings', isEnabled: true),
                    _buildProfileItem(Icons.star_outline, 'Rate Our App', isEnabled: true),
                    _buildProfileItem(Icons.lock_outline, 'Privacy Policy', isEnabled: true),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: user?.photoURL != null 
                ? NetworkImage(user!.photoURL!) 
                : const AssetImage('assets/img_5.png') as ImageProvider,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? (user != null ? user.email!.split('@')[0] : 'Welcome Traveler!'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2D44),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user != null ? 'Dữ liệu đăng nhập đang được duy trì.' : 'Log in to explore more!',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {required bool isEnabled}) {
    return ListTile(
      leading: Icon(icon, color: isEnabled ? const Color(0xFF0D2D44) : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isEnabled ? Colors.black87 : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: isEnabled ? () {} : null,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
