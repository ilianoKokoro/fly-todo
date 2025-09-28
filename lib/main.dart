import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fly_todo/core/constants.dart';
import 'package:fly_todo/firebase_options.dart';
import 'package:fly_todo/repositories/auth_repository.dart';
import 'package:fly_todo/root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AuthRepository.init();
  runApp(const MyApp());
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
          locale: Locale("en"),
          title: App.title,
          theme: ThemeData(
            colorScheme: lightScheme,
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android:
                    PredictiveBackPageTransitionsBuilder(), // Predictive back gesture
              },
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android:
                    PredictiveBackPageTransitionsBuilder(), // Predictive back gesture
              },
            ),
          ),
          themeMode: ThemeMode.system,
          home: Root(),
        );
      },
    );
  }
}
