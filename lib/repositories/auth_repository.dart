import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  static final GoogleSignIn googleAuthInstance = GoogleSignIn.instance;

  static void init() {
    unawaited(
      googleAuthInstance.initialize().then((_) {
        googleAuthInstance.authenticationEvents
            .listen(_handleGoogleAuthenticationEvent)
            .onError(_handleGoogleAuthenticationError);
      }),
    );
  }

  static Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } else {
      await GoogleSignIn.instance.authenticate();
    }
  }

  static Future<void> signInWithEmail(
    final String email,
    final String password,
  ) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signUpWithEmail(
    final String email,
    final String password,
  ) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static void _handleGoogleAuthenticationEvent(dynamic event) async {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: event.user.authentication.idToken,
          // Access token if needed
        ),
      );
      return;
    }
  }

  static void _handleGoogleAuthenticationError(dynamic error) {
    // Silent fail for now
    debugPrint('Authentication error: $error');
  }
}
