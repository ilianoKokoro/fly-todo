import 'dart:convert';

import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/tokens.dart';
import 'package:fly_todo/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatastoreRepository {
  void saveUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(Datastore.user, user.toJson().toString());
  }

  Future<User> getUser() async {
    final preferences = await SharedPreferences.getInstance();

    String? user = await preferences.getString(Datastore.user);

    if (user == null) {
      throw Exception("No saved user");
    }

    return User.fromJson(jsonDecode(user));
  }

  void saveTokens(Tokens user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(Datastore.user, user.toJson().toString());
  }

  Future<Tokens> getTokens() async {
    final preferences = await SharedPreferences.getInstance();

    String? tokens = await preferences.getString(Datastore.jwt);

    if (tokens == null) {
      throw Exception("No saved JWT");
    }

    return Tokens.fromJson(jsonDecode(tokens));
  }
}
