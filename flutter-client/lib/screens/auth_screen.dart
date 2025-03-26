import 'package:flutter/material.dart';
import 'package:fly_todo/components/button_row.dart';
import 'package:fly_todo/components/text_input_with_padding.dart';
import 'package:fly_todo/core/extensions.dart';
import 'package:fly_todo/repositories/auth_repository.dart';
import 'package:fly_todo/screens/home_screen.dart';

enum AuthType { logIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool loading = false;
  String username = "";
  String email = "";
  String password = "";
  String passwordConfirm = "";
  AuthType currentScreen = AuthType.logIn;

  void showError(String message) {
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

  void executeAuthentication() async {
    try {
      if (loading == true) {
        return;
      }
      loading = true;
      if (currentScreen == AuthType.logIn) {
        await logIn(username, password);
      } else {
        if (password != passwordConfirm) {
          throw Exception("The passwords do not match");
        }
        await signUp(username, email, password);
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on Exception catch (err) {
      showError(err.getMessage);
    } finally {
      loading = false;
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
                currentScreen == AuthType.logIn ? 'Log In' : "Sign Up",
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
                          enabled: !loading,
                          placeholder: 'Username',
                          padding: 8,
                          onChanged:
                              (newValue) => setState(() {
                                username = newValue;
                              }),
                        ),
                        currentScreen == AuthType.signUp
                            ? TextInputWithPadding(
                              enabled: !loading,
                              placeholder: 'Email',
                              padding: 8,
                              onChanged:
                                  (newValue) => setState(() {
                                    email = newValue;
                                  }),
                              type: TextInputType.emailAddress,
                            )
                            : SizedBox.shrink(),
                        TextInputWithPadding(
                          enabled: !loading,
                          placeholder: 'Password',
                          padding: 8,
                          onChanged:
                              (newValue) => setState(() {
                                password = newValue;
                              }),
                          type: TextInputType.visiblePassword,
                        ),
                        currentScreen == AuthType.signUp
                            ? TextInputWithPadding(
                              enabled: !loading,
                              placeholder: 'Confirm Password',
                              padding: 8,
                              onChanged:
                                  (newValue) => setState(() {
                                    passwordConfirm = newValue;
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
                  if (currentScreen == AuthType.logIn) {
                    executeAuthentication();
                  } else {
                    setState(() {
                      currentScreen = AuthType.logIn;
                    });
                  }
                },
                rightButtonText: 'Sign Up',
                rightButtonAction: () {
                  if (currentScreen == AuthType.signUp) {
                    executeAuthentication();
                  } else {
                    setState(() {
                      currentScreen = AuthType.signUp;
                    });
                  }
                },
                rightButtonEnabled:
                    (currentScreen == AuthType.logIn && !loading) ||
                    (username != "" && password != "" && email != ""),
                leftButtonEnabled:
                    (currentScreen == AuthType.signUp && !loading) ||
                    (username != "" && password != ""),
                mainButtonIsLeft: currentScreen == AuthType.logIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
