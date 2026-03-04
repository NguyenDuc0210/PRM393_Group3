
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Đăng ký và lưu thông tin người dùng vào Firestore
  Future<User?> registerWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      
      User? user = result.user;
      
      if (user != null) {
        // Lưu thông tin bổ sung vào Firestore
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  // Đăng nhập
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  // Gửi email khôi phục mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Lấy thông tin user hiện tại
  User? get currentUser => _auth.currentUser;

  // Stream theo dõi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Helper để dịch lỗi Firebase sang tiếng Việt dễ hiểu
  String _getAuthErrorMessage(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found': return 'Không tìm thấy người dùng với email này.';
        case 'wrong-password': return 'Mật khẩu không chính xác.';
        case 'email-already-in-use': return 'Email này đã được sử dụng.';
        case 'weak-password': return 'Mật khẩu quá yếu.';
        case 'invalid-email': return 'Email không hợp lệ.';
        default: return 'Đã xảy ra lỗi: ${e.message}';
      }
    }
    return e.toString();
  }
}
