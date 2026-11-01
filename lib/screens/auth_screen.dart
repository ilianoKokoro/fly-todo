import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:fly_todo/components/button_row.dart';
import 'package:fly_todo/components/text_input_with_padding.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/core/modal.dart';
import 'package:fly_todo/repositories/auth_repository.dart';

enum AuthType { logIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _loading = false;
  String _email = "";
  String _password = "";
  String _passwordConfirm = "";
  AuthType _currentScreen = AuthType.logIn;

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed ($code).';
    }
  }

  Future<void> _executeAuthentication() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (_currentScreen == AuthType.logIn) {
        await AuthRepository.signInWithEmail(_email.trim(), _password);
      } else {
        if (_password != _passwordConfirm) {
          throw Exception("The passwords do not match");
        }
        await AuthRepository.signUpWithEmail(_email.trim(), _password);
      }
    } on FirebaseAuthException catch (err) {
      if (mounted) {
        Modal.showInfo("Authentication Error", _messageFor(err.code), context);
      }
    } on Exception catch (err) {
      if (mounted) Modal.showError(err, context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(App.title), centerTitle: true),

      body: Center(
        child:
            _loading
                ? CircularProgressIndicator()
                : ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextInputWithPadding(
                                  initialValue: _email,
                                  enabled: !_loading,
                                  placeholder: 'Email',
                                  padding: 8,
                                  onChanged:
                                      (newValue) => setState(() {
                                        _email = newValue;
                                      }),
                                  type: TextInputType.emailAddress,
                                ),
                                TextInputWithPadding(
                                  initialValue: _password,
                                  enabled: !_loading,
                                  placeholder: 'Password',
                                  padding: 8,
                                  onChanged:
                                      (newValue) => setState(() {
                                        _password = newValue;
                                      }),
                                  type: TextInputType.visiblePassword,
                                  onSubmitted:
                                      () => {
                                        if (_currentScreen == AuthType.logIn)
                                          {_executeAuthentication()},
                                      },
                                ),
                                _currentScreen == AuthType.signUp
                                    ? TextInputWithPadding(
                                      initialValue: _passwordConfirm,
                                      enabled: !_loading,
                                      placeholder: 'Confirm Password',
                                      padding: 8,
                                      onChanged:
                                          (newValue) => setState(() {
                                            _passwordConfirm = newValue;
                                          }),
                                      type: TextInputType.visiblePassword,
                                      onSubmitted:
                                          () => {
                                            if (_currentScreen ==
                                                AuthType.signUp)
                                              {_executeAuthentication()},
                                          },
                                    )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              AuthRepository.signInWithGoogle();
                            },
                            icon: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 40),
                              child: Image(
                                image: AssetImage('assets/google.png'),
                              ),
                            ),
                          ),
                          BottomButtonRow(
                            leftButtonText: 'Log In',
                            leftButtonAction: () {
                              if (_currentScreen == AuthType.logIn) {
                                _executeAuthentication();
                              } else {
                                setState(() {
                                  _currentScreen = AuthType.logIn;
                                });
                              }
                            },
                            rightButtonText: 'Sign Up',
                            rightButtonAction: () {
                              if (_currentScreen == AuthType.signUp) {
                                _executeAuthentication();
                              } else {
                                setState(() {
                                  _currentScreen = AuthType.signUp;
                                });
                              }
                            },
                            rightButtonEnabled:
                                (_currentScreen == AuthType.logIn &&
                                    !_loading) ||
                                (_password != "" && _email != ""),
                            leftButtonEnabled:
                                (_currentScreen == AuthType.signUp &&
                                    !_loading) ||
                                (_email != "" && _password != ""),
                            mainButtonIsLeft: _currentScreen == AuthType.logIn,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
