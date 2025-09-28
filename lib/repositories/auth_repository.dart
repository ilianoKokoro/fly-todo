import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  static void init() {
    final GoogleSignIn signIn = GoogleSignIn.instance;
    unawaited(
      signIn.initialize().then((_) {
        signIn.authenticationEvents
            .listen(_handleAuthenticationEvent)
            .onError(_handleAuthenticationError);

        signIn.attemptLightweightAuthentication();
      }),
    );
  }

  static Future<void> signInWithGoogle() async {
    await GoogleSignIn.instance.authenticate();
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

  static void _handleAuthenticationEvent(dynamic event) async {
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

  static void _handleAuthenticationError(dynamic error) {
    // Silent fail for now
    debugPrint('Authentication error: $error');
  }
}
