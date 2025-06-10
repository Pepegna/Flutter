import 'package:flutter/material.dart';
import 'package:par_impar_game/arena_screen.dart';
import 'package:par_impar_game/entry_screen.dart';
import '/user_profile.dart';
import 'app_routes.dart';

void main() {
  runApp(const OddEvenArenaApp());
}

class OddEvenArenaApp extends StatelessWidget {
  const OddEvenArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OddEven Arena',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(secondary: Colors.amber),
        fontFamily: 'Roboto',
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(64, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.deepPurple.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.deepPurple.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      initialRoute: AppRoutes.entry,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.entry:
            return MaterialPageRoute(builder: (_) => const EntryScreen());
          case AppRoutes.arena:
            if (settings.arguments is UserProfile) {
              final user = settings.arguments as UserProfile;
              return MaterialPageRoute(
                builder: (_) => ArenaScreen(currentUser: user),
              );
            }
            return MaterialPageRoute(builder: (_) => const EntryScreen());
          default:
            return MaterialPageRoute(builder: (_) => const EntryScreen());
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
