import 'package:flutter/material.dart';

enum Environment { dev, prod }

abstract class App {
  static const String title = "Fly TODO";
  static const Color fallbackPrimary = Colors.blue;
  static const int debounceMs = 500;
  static const Environment currentEnvironment = Environment.dev;
}

abstract class Urls {
  static const String base =
      App.currentEnvironment == Environment.prod
          ? "https://fly-todo-api.vercel.app"
          : "http://localhost:7187";
  static final String users = "$base/users";
  static final String usersActions = "$users/actions";
  static final String login = "$usersActions/login";
  static final String refresh = "$usersActions/refresh";
  static final String logout = "$usersActions/logout";
  static final String signup = "$base/users";
}

abstract class Datastore {
  static const String user = "user";
  static const String jwt = "jwt";
}

abstract class Transitions {
  static const int duration = 200;
}
