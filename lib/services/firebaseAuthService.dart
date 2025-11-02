import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yolo/screens/viewPostsScreen.dart';

class FirebaseGoogleAuthService {
  static Future<void> loginWithGoogle(
    BuildContext context,
    Function setSigningIn,
  ) async {
    setSigningIn(true);

    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;

      await signIn.initialize();

      final account = await signIn.authenticate();

      if (account != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome, ${account.displayName ?? 'User'}!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeFeedPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sign in cancelled."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In failed: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setSigningIn(false);
    }
  }
}
