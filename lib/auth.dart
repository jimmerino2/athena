import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  String? uid;
  bool _isAuthenticated = false;

  AuthService() {
    _authStateListener();
  }

  bool get isAuthenticated => _isAuthenticated;

  void _authStateListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      uid = user?.uid;
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  Future<void> _storeUserData(User user) async {
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "name": user.displayName,
      "email": user.email,
      "auth_provider": "google.com" // for now
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
      
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);

      notifyListeners();

      // First time sign up.
      if (userCred.additionalUserInfo?.isNewUser ?? false) {
        await _storeUserData(userCred.user!);
      }

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

