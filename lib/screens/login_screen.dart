
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../main.dart'; 
import '../notifiers/navigation_notifier.dart';
import 'register_screen.dart';
import 'main_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _showNotification() async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'login_id', 'Login channel',
        importance: Importance.max, priority: Priority.high,
      );
      const NotificationDetails details = NotificationDetails(android: androidDetails);
      await flutterLocalNotificationsPlugin.show(
        0, 'Đăng nhập thành công', 'Chào mừng bạn đến với Travel App!', details,
      );
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  Future<void> _handleLogin(String type) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (type != 'GOOGLE' && (email.isEmpty || password.isEmpty)) {
      _showStatus('Vui lòng nhập Email và Mật khẩu', Colors.orange);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    _showStatus('Đang kết nối hệ thống ($type)...', Colors.blue);

    try {
      String? token;
      if (type == 'MOCK') {
        token = await _authRepository.mockLogin(email, password);
      } else if (type == 'REAL_API') {
        token = await _authRepository.loginWithRealAPI(email, password);
      } else if (type == 'FIREBASE') {
        final user = await _authRepository.loginWithFirebase(email, password);
        token = user?.uid;
      } else if (type == 'GOOGLE') {
        final user = await _authRepository.signInWithGoogle();
        token = user?.uid;
      }

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (mounted) {
          _showStatus('Đăng nhập $type thành công!', Colors.green);
          setState(() => _isLoading = false);
          ref.read(navigationIndexProvider.notifier).state = 0;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            _showNotification();
          });
        }
      } else {
        throw 'Không nhận được Token từ máy chủ.';
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showStatus('Lỗi: ${e.toString().replaceAll('Exception: ', '')}', Colors.red);
      }
    }
  }

  void _showStatus(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img_6.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.travel_explore, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text('Travel App Demo', 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                  const SizedBox(height: 40),
                  _buildTextField(_emailController, 'Email / Username', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _passwordController, 
                    'Mật khẩu', 
                    Icons.lock_outline,
                    isPassword: true,
                    obscure: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword)
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                      child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading) 
                    const CircularProgressIndicator(color: Colors.white)
                  else ...[
                    _buildButton('LOGIN FIREBASE', Colors.green, () => _handleLogin('FIREBASE')),
                    const SizedBox(height: 12),
                    _buildButton('GOOGLE SIGN-IN', Colors.blue, () => _handleLogin('GOOGLE')),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(color: Colors.white38),
                    ),
                    Row(
                      children: [
                        Expanded(child: _buildButton('10.1 MOCK', Colors.white24, () => _handleLogin('MOCK'), small: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildButton('10.1.R API', Colors.white24, () => _handleLogin('REAL_API'), small: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildButton('TIẾP TỤC KHÔNG ĐĂNG NHẬP', Colors.orange, () {
                      ref.read(navigationIndexProvider.notifier).state = 0;
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainScreen()), (route) => false);
                    }, small: true),
                  ],
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                    child: const Text('Chưa có tài khoản? Đăng ký ngay', 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool obscure = false, VoidCallback? onToggle}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white), onPressed: onToggle) : null,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }

  Widget _buildButton(String title, Color color, VoidCallback onPressed, {bool small = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, small ? 44 : 54),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(title, style: TextStyle(fontSize: small ? 13 : 15, fontWeight: FontWeight.bold)),
    );
  }
}
