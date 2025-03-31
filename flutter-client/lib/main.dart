import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightScheme =
            lightDynamic ??
            ColorScheme.fromSeed(seedColor: App.fallbackPrimary);
        final ColorScheme darkScheme =
            darkDynamic ??
            ColorScheme.fromSeed(
              seedColor: App.fallbackPrimary,
              brightness: Brightness.dark,
            );

        return MaterialApp(
          theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
          themeMode: ThemeMode.system,
          home: HomeScreen(),
        );
      },
    );
  }
}
