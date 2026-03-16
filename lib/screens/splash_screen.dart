import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNext();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  Future<void> _navigateToNext() async {
    // 1. Đợi tối thiểu 3 giây để hiệu ứng logo chạy xong và Firebase kịp khôi phục session
    await Future.delayed(const Duration(milliseconds: 3000));
    
    if (!mounted) return;

    // 2. Kiểm tra SharedPreferences (Dành cho Mock login)
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    // 3. Kiểm tra Firebase (Dành cho Firebase/Google login)
    // Dùng currentUser sau 3s chờ đợi là cách an toàn nhất
    final User? user = FirebaseAuth.instance.currentUser;

    debugPrint("SPLASH CHECK: Firebase User: ${user?.email}, Token: $token");

    Widget nextScreen;
    if (user != null || (token != null && token.isNotEmpty)) {
      nextScreen = const MainScreen();
    } else {
      nextScreen = const LoginScreen();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/img_5.png', width: 120,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.travel_explore, size: 100, color: Colors.green),
                ),
                const SizedBox(height: 20),
                const Text('culture trip', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0D2D44))),
                const SizedBox(height: 8),
                const Text('Book Good • Travel Good • Feel Good', style: TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
