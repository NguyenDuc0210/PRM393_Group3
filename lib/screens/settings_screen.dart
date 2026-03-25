
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';
import '../notifiers/navigation_notifier.dart';
import '../notifiers/settings_notifier.dart';
import '../notifiers/plan_notifier.dart';
import '../notifiers/download_notifier.dart';
import 'login_screen.dart';
import 'downloaded_articles_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _authToken;
  bool _isRated = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token');
      _isRated = prefs.getBool('is_app_rated') ?? false;
    });
  }

  Future<void> _toggleRate() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá ứng dụng!')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRated = !_isRated;
      prefs.setBool('is_app_rated', _isRated);
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authRepo = AuthRepository();
    final prefs = await SharedPreferences.getInstance();
    
    try {
      await authRepo.signOut();
      await prefs.remove('auth_token');
      
      ref.invalidate(planNotifierProvider);
      ref.invalidate(downloadProvider);
      
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
    final downloadState = ref.watch(downloadProvider);
    final settings = ref.watch(settingsProvider);
    final isVi = settings.locale.languageCode == 'vi';

    final Map<String, String> texts = {
      'profile': isVi ? 'Hồ sơ' : 'Profile',
      'account': isVi ? 'Tài khoản' : 'Account',
      'settings': isVi ? 'Cài đặt' : 'Settings',
      'downloads': isVi ? 'Bài viết đã tải' : 'Downloaded Articles',
      'saved': isVi ? 'bài viết đã lưu' : 'articles saved',
      'rate': isVi ? 'Đánh giá ứng dụng' : 'Rate Our App',
      'logout': isVi ? 'Đăng xuất' : 'Logout',
      'change_pass': isVi ? 'Đổi mật khẩu' : 'Change Password',
      'welcome_guest': isVi ? 'Chào mừng bạn đến với\nCulture Trip!' : 'Welcome to The\nCulture Trip!',
      'welcome_user': isVi ? 'Chào, ${user?.displayName ?? 'Người khám phá'}!' : 'Hello, ${user?.displayName ?? 'Explorer'}!',
      'desc_user': isVi 
          ? 'Bạn đã là một phần của cộng đồng. Hãy bắt đầu lên kế hoạch cho chuyến đi tiếp theo!' 
          : 'You are now part of our community. Start planning your next journey!',
      'desc_guest': isVi
          ? 'Đăng nhập để mở khóa khả năng tạo kế hoạch du lịch, khám phá các bài hướng dẫn và nhiều hơn thế nữa!'
          : 'Log in to unlock the ability to create travel plans, explore local guide articles, and so much more!',
      'login': isVi ? 'Đăng nhập' : 'Log In',
      'signup': isVi ? 'Đăng ký' : 'Sign Up',
      'dark_mode': isVi ? 'Chế độ tối' : 'Dark Mode',
      'language': isVi ? 'Ngôn ngữ' : 'Language',
    };

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey[900] 
          : const Color(0xFFC8F2C2),
      body: Column(
        children: [
          _buildHeader(context, user, texts),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(
                        texts['profile']!,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildMenuItem(Icons.person_outline, texts['account']!, 
                      subtitle: user?.email,
                      onTap: user != null ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen())) : null,
                      trailing: user != null ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey) : null,
                    ),
                    _buildMenuItem(Icons.settings_outlined, texts['settings']!, 
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => _showSettingsOptions(context, texts),
                    ),
                    _buildMenuItem(
                      Icons.file_download_outlined, 
                      texts['downloads']!, 
                      subtitle: '${downloadState.downloadedArticles.length} ${texts['saved']}',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DownloadedArticlesScreen())),
                    ),
                    
                    _buildMenuItem(
                      _isRated ? Icons.star : Icons.star_outline, 
                      texts['rate']!,
                      trailing: _isRated ? const Icon(Icons.star, color: Colors.amber) : null,
                      onTap: _toggleRate,
                    ),

                    if (user != null) ...[
                      const Divider(indent: 24, endIndent: 24, height: 32),
                      if (_authToken != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Auth Token:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 4),
                              SelectableText(
                                _authToken!,
                                style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: Text(texts['logout']!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        onTap: () => _handleLogout(context),
                      ),
                    ],
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

  Widget _buildHeader(BuildContext context, User? user, Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 45,
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
                      user != null ? texts['welcome_user']! : texts['welcome_guest']!,
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0D2D44), 
                        height: 1.2
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user != null ? texts['desc_user']! : texts['desc_guest']!,
                      style: TextStyle(
                        fontSize: 13, 
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87
                      ),
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
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2D44),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(texts['login']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {}, // Navigate to sign up
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(texts['signup']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? subtitle, Widget? trailing, bool isEnabled = true, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Theme.of(context).iconTheme.color, size: 28),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: isEnabled ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey[400],
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: trailing,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          onTap: isEnabled ? onTap : null,
        ),
        const Divider(indent: 64, height: 1),
      ],
    );
  }

  void _showSettingsOptions(BuildContext context, Map<String, String> texts) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(settingsProvider);
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(texts['settings']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(texts['dark_mode']!),
                    secondary: const Icon(Icons.brightness_4),
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).toggleTheme(val);
                    },
                  ),
                  ListTile(
                    title: Text(texts['language']!),
                    leading: const Icon(Icons.language),
                    trailing: Text(
                      settings.locale.languageCode == 'en' ? 'English' : 'Tiếng Việt', 
                      style: const TextStyle(color: Colors.blue)
                    ),
                    onTap: () {
                      final newLang = settings.locale.languageCode == 'en' ? 'vi' : 'en';
                      ref.read(settingsProvider.notifier).setLanguage(newLang);
                    },
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
