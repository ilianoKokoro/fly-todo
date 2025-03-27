import "dart:convert";

import "package:fly_todo/core/constants.dart";
import "package:fly_todo/core/error_helper.dart";
import "package:fly_todo/models/tokens.dart";
import "package:http/http.dart" as http;

class AuthRepository {
  Future<String> logIn(String username, String password) async {
    final body = {"name": username, "password": password};
    final response = await http.post(
      Uri.parse(Urls.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final success = response.statusCode == 200;
    if (success) return response.body;
    throw Exception(ErrorHelper.getErrorMessage(response.body));
  }

  Future<String> signUp(String username, String email, String password) async {
    final body = {"name": username, "email": email, "password": password};
    final response = await http.post(
      Uri.parse(Urls.signup),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final success = response.statusCode == 201;
    if (success) return response.body;
    throw Exception(ErrorHelper.getErrorMessage(response.body));
  }

  void logOut() async {
    Tokens tokens = Tokens("access", "access");
    final body = {"refreshToken": tokens.refresh};
    final response = await http.delete(
      Uri.parse(Urls.logout),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer ${tokens.access}',
      },
      body: jsonEncode(body),
    );

    print(response.body);

    final success = response.statusCode == 204;
    if (success) return;
    throw Exception(ErrorHelper.getErrorMessage(response.body));
  }
}
