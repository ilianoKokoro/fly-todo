import 'package:flutter/material.dart';
import 'package:fly_todo/components/button_row.dart';
import 'package:fly_todo/components/text_input_with_padding.dart';

enum AuthType { logIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String username = "";
  String email = "";
  String password = "";
  String passwordConfirm = "";
  AuthType currentScreen = AuthType.logIn;

  void executeAuthentication() {
    if (currentScreen == AuthType.logIn) {}
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
                          placeholder: 'Username',
                          padding: 8,
                          onChanged:
                              (newValue) => setState(() {
                                username = newValue;
                              }),
                        ),
                        currentScreen == AuthType.signUp
                            ? TextInputWithPadding(
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
                mainButtonIsLeft: currentScreen == AuthType.logIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
