import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fly_todo/components/button_row.dart';
import 'package:fly_todo/components/text_input_with_padding.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/core/modal.dart';

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

  void _executeAuthentication() async {
    try {
      if (_loading == true) {
        return;
      }
      setState(() {
        _loading = true;
      });
      UserCredential userCredentials;
      if (_currentScreen == AuthType.logIn) {
        userCredentials = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _email.trim(),
              password: _password.trim(),
            );
      } else {
        if (_password != _passwordConfirm) {
          throw Exception("The passwords do not match");
        }
        userCredentials = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _email.trim(),
              password: _password.trim(),
            );
      }
      debugPrint(userCredentials.toString());
    } on FirebaseAuthException catch (err) {
      if (mounted) {
        Modal.showInfo(
          "Authentication Error",
          err.message ?? "Unknown error",
          context,
        );
      }
    } on Exception catch (err) {
      if (mounted) {
        Modal.showError(err, context);
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(App.title), centerTitle: true),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child:
                      _loading
                          ? CircularProgressIndicator()
                          : SingleChildScrollView(
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
                      FirebaseAuth.instance.signInWithProvider(
                        GoogleAuthProvider(),
                      );
                    },
                    icon: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 40),
                      child: Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png",
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
                        (_currentScreen == AuthType.logIn && !_loading) ||
                        (_password != "" && _email != ""),
                    leftButtonEnabled:
                        (_currentScreen == AuthType.signUp && !_loading) ||
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
