import 'package:flutter/material.dart';

class Urls {
  static const String base = "https://fly-todo-api.vercel.app";
  static final String users = "$base/users";
  static final String usersActions = "$users/actions";
  static final String login = "$usersActions/login";
  static final String refresh = "$usersActions/refresh";
  static final String logout = "$usersActions/logout";
  static final String signup = "$base/users";
}

class Datastore {
  static const String user = "user";
  static const String jwt = "jwt";
}

class Transitions {
  static const int duration = 200;
}

class App {
  static const String title = "Fly TODO";
  static const Color fallbackPrimary = Colors.blue;
  static const int debounceMs = 300;
}
