import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  static final GoogleSignIn _google = GoogleSignIn.instance;
  static Future<void>? _initFuture;
  static StreamSubscription<GoogleSignInAuthenticationEvent>? _sub;

  static Future<void> init() {
    return _initFuture ??= _google
        .initialize(
          serverClientId:
              '252245842703-qbmknbottesqerllleo3nkqrd2mlecos.apps.googleusercontent.com',
        )
        .then((_) {
      _sub = _google.authenticationEvents.listen(
        _handleGoogleAuthenticationEvent,
        onError: _handleGoogleAuthenticationError,
      );
    });
  }

  static Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      return;
    }
    await init();
    try {
      await _google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return;
      };
      rethrow;
    }
  }

  static Future<void> signInWithEmail(String email, String password) =>
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  static Future<void> signUpWithEmail(String email, String password) =>
      FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb) {
      await init();
      await _google.signOut();
    }
  }

  static Future<void> _handleGoogleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event is! GoogleSignInAuthenticationEventSignIn) return;
    try {
      await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: event.user.authentication.idToken,
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Google sign-in failed: ${e.code}');
    }
  }

  static void _handleGoogleAuthenticationError(Object error) {
    debugPrint('Authentication error: $error');
  }
}
