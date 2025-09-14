import 'package:flutter/material.dart';
import 'package:fly_todo/core/extensions.dart';

class Modal {
  static void showError(Exception error, BuildContext context) {
    showInfo("Error", error.getMessage, context);
  }

  static void showInfo(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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
}
