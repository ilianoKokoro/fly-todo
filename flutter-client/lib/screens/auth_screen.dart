import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fly_todo/components/button_row.dart';
import 'package:fly_todo/components/text_input_with_padding.dart';
import 'package:fly_todo/core/extensions.dart';
import 'package:fly_todo/models/tokens.dart';
import 'package:fly_todo/models/user.dart';
import 'package:fly_todo/repositories/auth_repository.dart';
import 'package:fly_todo/repositories/datastore_repository.dart';
import 'package:fly_todo/repositories/task_repository.dart';
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

  AuthRepository _authRepository = AuthRepository();
  DatastoreRepository _datastoreRepository = DatastoreRepository();
  TaskRepository _taskRepository = TaskRepository();

  Future<void> tryAutomaticAuth() async {
    try {
      User savedUser = await _datastoreRepository.getUser();
      await _taskRepository.getUserTasks(savedUser);
    } catch (_) {
      // Do nothing
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await tryAutomaticAuth();
    });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _executeAuthentication() async {
    try {
      if (_loading == true) {
        return;
      }
      _loading = true;
      String bodyResult;
      if (_currentScreen == AuthType.logIn) {
        bodyResult = await _authRepository.logIn(_username, _password);
      } else {
        if (_password != _passwordConfirm) {
          throw Exception("The passwords do not match");
        }
        bodyResult = await _authRepository.signUp(_username, _email, _password);
      }

      User user = User.fromJson(jsonDecode(bodyResult)["user"]);
      Tokens tokens = Tokens.fromJson(jsonDecode(bodyResult)["tokens"]);

      _datastoreRepository.saveTokens(tokens);
      _datastoreRepository.saveUser(user);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on Exception catch (err) {
      _showError(err.getMessage);
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fly TODO')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _currentScreen == AuthType.logIn ? 'Log In' : "Sign Up",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
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
