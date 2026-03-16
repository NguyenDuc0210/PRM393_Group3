
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../notifiers/navigation_notifier.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _savedToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _savedToken = prefs.getString('auth_token');
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authRepo = AuthRepository();
    final prefs = await SharedPreferences.getInstance();
    
    try {
      await authRepo.signOut();
      await prefs.remove('auth_token');
      
      if (mounted) {
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
                  _buildProfileItem(Icons.email_outlined, 'Email: ${user?.email ?? "N/A"}', isEnabled: false),
                  _buildProfileItem(Icons.badge_outlined, 'Name: ${user?.displayName ?? "Traveler"}', isEnabled: false),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueGrey[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.vpn_key_outlined, size: 16, color: Colors.blueGrey),
                              SizedBox(width: 8),
                              Text(
                                'SESSION TOKEN (Demo 10.3)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _savedToken ?? 'Chưa có Token (Chưa đăng nhập)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(indent: 24, endIndent: 24),

                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout (Clear Session)',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _handleLogout(context),
                  ),
                  
                  const Divider(indent: 24, endIndent: 24),
                  _buildProfileItem(Icons.settings_outlined, 'App Settings', isEnabled: true),
                  _buildProfileItem(Icons.star_outline, 'Rate Our App', isEnabled: true),
                  _buildProfileItem(Icons.lock_outline, 'Privacy Policy', isEnabled: true),
                  const SizedBox(height: 50),
                ],
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
                : const NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Welcome Traveler!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2D44),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dữ liệu đăng nhập đang được duy trì.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
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
    );
  }
}
