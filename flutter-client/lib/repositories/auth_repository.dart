import "dart:convert";

import "package:fly_todo/core/constants.dart";
import "package:http/http.dart" as http;

Future<bool> logIn(String username, String password) async {
  try {
    final body = {"name": username, "password": password};
    final response = await http.post(
      Uri.parse(Urls.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    // TODO : SAVE JWT

    final success = response.statusCode == 200;
    if (success) return true;

    throw Exception(response.body);
  } catch (err) {
    print(err);
    return false;
  }
}

Future<bool> signUp(String username, String email, String password) async {
  try {
    final body = {"name": username, "email": email, "password": password};
    final response = await http.post(
      Uri.parse(Urls.signup),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    // TODO : SAVE JWT

    final success = response.statusCode == 201;
    if (success) return true;
    throw Exception(response.body);
  } catch (err) {
    //print(err);
    return false;
  }
}
