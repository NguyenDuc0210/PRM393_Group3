
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_role.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      
      final userDoc = await _db.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? 'User',
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
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
          'uid': user.uid,
          'email': email,
          'name': name,
          'role': 'customer', 
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
  }

  Future<UserRole> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return UserRole.guest;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        if (role == 'admin') return UserRole.admin;
        return UserRole.customer;
      }
    } catch (e) {
      print('Error getting user role: $e');
    }
    return UserRole.customer;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try { await _auth.sendPasswordResetEmail(email: email); } catch (e) { throw Exception(_getAuthErrorMessage(e)); }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception('Người dùng chưa đăng nhập.');

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    }
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
        case 'wrong-password': return 'Mật khẩu cũ không chính xác.';
        case 'weak-password': return 'Mật khẩu mới quá yếu.';
        case 'requires-recent-login': return 'Vui lòng đăng nhập lại trước khi đổi mật khẩu.';
        default: return e.message ?? 'Đã xảy ra lỗi';
      }
    }
    return e.toString();
  }
}
