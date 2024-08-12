import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithGoogle() async {
    // Check if running on web
    if (kIsWeb) {
      // Use Firebase Auth's signInWithPopup for web
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final userCredential =
            await _firebaseAuth.signInWithPopup(authProvider);
        return userCredential;
      } catch (e) {
        print("Error signing in with Google: $e");
        return null;
      }
    } else {
      // Use Google Sign-In for mobile
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // Handle user cancellation

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      if (googleAuth == null) return null; // Handle error

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      try {
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        return userCredential;
      } catch (e) {
        print("Error signing in with Google: $e");
        return null;
      }
    }
  }


   
  
}
