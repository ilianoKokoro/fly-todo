import 'package:flutter/material.dart';

enum Environment { dev, prod }

abstract class App {
  static const String title = "Fly TODO";
  static const Color fallbackPrimary = Colors.blue;
  static const int debounceMs = 200;
  static const int animation = 200;
  static const Environment currentEnvironment = Environment.prod;
}

abstract class Collections {
  static const String tasks = "tasks";
}

abstract class Transitions {
  static const int duration = 200;
}
