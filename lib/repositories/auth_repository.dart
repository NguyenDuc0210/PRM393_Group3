
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> mockLogin(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'admin@gmail.com' && password == '123456') {
      return "fake-jwt-token-12345";
    } else {
      throw Exception('Sai email hoặc mật khẩu demo');
    }
  }

  Future<String?> loginWithRealAPI(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://dummyjson.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('SERVER RESPONSE: $data');
        }

        return data['accessToken'] ?? data['token'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Sai tài khoản hoặc mật khẩu API');
      }
    } on TimeoutException catch (_) {
      throw Exception('Kết nối mạng quá chậm');
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> loginWithFirebase(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid, 'email': email, 'name': name, 'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try { await _auth.sendPasswordResetEmail(email: email); } catch (e) { throw Exception(_getAuthErrorMessage(e)); }
  }

  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) await googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  String _getAuthErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found': return 'Không tìm thấy người dùng.';
        case 'wrong-password': return 'Mật khẩu không chính xác.';
        default: return e.message ?? 'Đã xảy ra lỗi';
      }
    }
    return e.toString();
  }
}
