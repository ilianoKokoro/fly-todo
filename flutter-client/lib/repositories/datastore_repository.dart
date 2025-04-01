import 'dart:convert';

import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/models/tokens.dart';
import 'package:fly_todo/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatastoreRepository {
  SharedPreferencesWithCache? controller;
  bool _isInitialized = false;

  Future<void> initialize() async {
    controller = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: <String>{Datastore.jwt, Datastore.user},
      ),
    );
  }

  Future<SharedPreferencesWithCache> getInstance() async {
    if (!_isInitialized) {
      await initialize();
      _isInitialized = true;
    }

    return controller!;
  }

  Future<void> saveUser(User user) async {
    final preferences = await getInstance();
    await preferences.setString(Datastore.user, user.toJsonString());
  }

  Future<User> getUser() async {
    final preferences = await getInstance();

    String? user = preferences.getString(Datastore.user);

    if (user == null) {
      throw Exception("No saved user");
    }

    return User.fromJson(jsonDecode(user));
  }

  Future<void> saveTokens(Tokens tokens) async {
    final preferences = await getInstance();
    await preferences.setString(Datastore.jwt, jsonEncode(tokens.toJson()));
  }

  Future<Tokens> getTokens() async {
    final preferences = await getInstance();

    String? tokens = preferences.getString(Datastore.jwt);

    if (tokens == null) {
      throw Exception("No saved JWT");
    }

    return Tokens.fromJson(jsonDecode(tokens));
  }

  Future<void> clearTokens() async {
    final preferences = await getInstance();
    await preferences.remove(Datastore.jwt);
  }

  Future<void> clearUser() async {
    final preferences = await getInstance();
    await preferences.remove(Datastore.user);
  }

  Future<void> clearDatastore() async {
    final preferences = await getInstance();
    preferences.clear();
  }
}
