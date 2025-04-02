import 'dart:convert';

import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/tokens.dart';
import 'package:fly_todo/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatastoreRepository {
  final SharedPreferencesAsync preferences = SharedPreferencesAsync();

  Future<void> saveUser(User user) async {
    await preferences.setString(Datastore.user, user.toJsonString());
  }

  Future<User> getUser() async {
    String? user = await preferences.getString(Datastore.user);

    if (user == null) {
      throw Exception("No saved user");
    }

    return User.fromJson(jsonDecode(user));
  }

  Future<void> saveTokens(Tokens tokens) async {
    await preferences.setString(Datastore.jwt, jsonEncode(tokens.toJson()));
  }

  Future<Tokens> getTokens() async {
    String? tokens = await preferences.getString(Datastore.jwt);

    if (tokens == null) {
      throw Exception("No saved JWT");
    }

    return Tokens.fromJson(jsonDecode(tokens));
  }

  Future<void> clearTokens() async {
    await preferences.remove(Datastore.jwt);
  }

  Future<void> clearUser() async {
    await preferences.remove(Datastore.user);
  }

  Future<void> clearDatastore() async {
    await preferences.clear();
  }
}
