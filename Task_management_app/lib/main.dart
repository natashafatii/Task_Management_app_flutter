import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/task_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'themes/light_dart_theme.dart';

// Global SharedPreferences instance
late SharedPreferences sharedPreferences;

void main() async {
  // Ensure Flutter's widget binding is initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize SharedPreferences
    sharedPreferences = await SharedPreferences.getInstance();

    // Initialize Firebase
    await Firebase.initializeApp();

    runApp(const MyApp());
  } catch (error) {
    // Fallback: Run app without SharedPreferences/Firebase if initialization fails
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TaskProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => AppAuthProvider(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Task Management App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false, // This removes the debug banner
      ),
    );
  }
}