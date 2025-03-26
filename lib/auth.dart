import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;

  AuthService() {
    _authStateListener();
  }

  bool get isAuthenticated => _isAuthenticated;

  void _authStateListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  Future<UserCredential?> login() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // ignore: avoid_print
        print("Google Sign in Cancelled.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCred =  await FirebaseAuth.instance.signInWithCredential(credential);

      notifyListeners();

      return userCred;
    } catch (e) {
      // ignore: avoid_print
      print("Login Failed: $e");
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      notifyListeners();
    } catch (e) {
      // ignore: avoid_print
      print("Logout Failed: $e");
    }
  }
}

