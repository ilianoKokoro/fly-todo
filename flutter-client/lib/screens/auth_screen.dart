import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fly_todo/components/button_row.dart';
import 'package:fly_todo/components/text_input_with_padding.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/core/modal.dart';
import 'package:fly_todo/models/tokens.dart';
import 'package:fly_todo/models/user.dart';
import 'package:fly_todo/repositories/auth_repository.dart';
import 'package:fly_todo/repositories/datastore_repository.dart';
import 'package:fly_todo/screens/home_screen.dart';

enum AuthType { logIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _loading = false;
  String _username = "";
  String _email = "";
  String _password = "";
  String _passwordConfirm = "";
  AuthType _currentScreen = AuthType.logIn;

  final AuthRepository _authRepository = AuthRepository();
  final DatastoreRepository _datastoreRepository = DatastoreRepository();

  void _executeAuthentication() async {
    try {
      if (_loading == true) {
        return;
      }
      setState(() {
        _loading = true;
      });
      String bodyResult;
      if (_currentScreen == AuthType.logIn) {
        bodyResult = await _authRepository.logIn(_username, _password);
      } else {
        if (_password != _passwordConfirm) {
          throw Exception("The passwords do not match");
        }
        bodyResult = await _authRepository.signUp(_username, _email, _password);
      }

      var decodedBody = jsonDecode(bodyResult);

      User user = User.fromJson(decodedBody["user"]);
      Tokens tokens = Tokens.fromJson(decodedBody["tokens"]);

      _datastoreRepository.saveTokens(tokens);
      _datastoreRepository.saveUser(user);

      _goToHomeScreen();
    } on Exception catch (err) {
      if (context.mounted) {
        Modal.showError(err, context);
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _goToHomeScreen() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
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
                                  enabled: !_loading,
                                  placeholder: 'Username',
                                  padding: 8,
                                  onChanged:
                                      (newValue) => setState(() {
                                        _username = newValue;
                                      }),
                                ),
                                _currentScreen == AuthType.signUp
                                    ? TextInputWithPadding(
                                      enabled: !_loading,
                                      placeholder: 'Email',
                                      padding: 8,
                                      onChanged:
                                          (newValue) => setState(() {
                                            _email = newValue;
                                          }),
                                      type: TextInputType.emailAddress,
                                    )
                                    : SizedBox.shrink(),
                                TextInputWithPadding(
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
                    (_username != "" && _password != "" && _email != ""),
                leftButtonEnabled:
                    (_currentScreen == AuthType.signUp && !_loading) ||
                    (_username != "" && _password != ""),
                mainButtonIsLeft: _currentScreen == AuthType.logIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
