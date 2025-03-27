import 'dart:convert';

import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/tokens.dart';
import 'package:fly_todo/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatastoreRepository {
  void saveUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(Datastore.user, jsonEncode(user.toJson()));
  }

  Future<User> getUser() async {
    final preferences = await SharedPreferences.getInstance();

    String? user = preferences.getString(Datastore.user);

    if (user == null) {
      throw Exception("No saved user");
    }

    return User.fromJson(jsonDecode(user));
  }

  void saveTokens(Tokens tokens) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(Datastore.jwt, jsonEncode(tokens.toJson()));
  }

  Future<Tokens> getTokens() async {
    final preferences = await SharedPreferences.getInstance();

    String? tokens = preferences.getString(Datastore.jwt);

    if (tokens == null) {
      throw Exception("No saved JWT");
    }

    return Tokens.fromJson(jsonDecode(tokens));
  }
}
