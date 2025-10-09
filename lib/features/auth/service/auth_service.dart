import 'package:firebase_auth/firebase_auth.dart';
import 'package:soundtotext/core/service/guest_mode_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Sign up with email and password
  static Future<String?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Disable guest mode on successful sign up
      await GuestModeService.disableGuestMode();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'كلمة المرور ضعيفة';
        case 'email-already-in-use':
          return 'هذا الإيميل مستخدم بالفعل';
        case 'invalid-email':
          return 'الإيميل غير صحيح';
        default:
          return 'حدث خطأ: ${e.message}';
      }
    } catch (e) {
      return 'حدث خطأ غير متوقع';
    }
  }
  
  // Sign in with email and password
  static Future<String?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Disable guest mode on successful sign in
      await GuestModeService.disableGuestMode();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'لا يوجد حساب بهذا الإيميل';
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة';
        case 'invalid-email':
          return 'الإيميل غير صحيح';
        case 'user-disabled':
          return 'هذا الحساب معطل';
        default:
          return 'حدث خطأ: ${e.message}';
      }
    } catch (e) {
      return 'حدث خطأ غير متوقع';
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
    
  }
  
  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}