import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/screens/dashboard.dart';
import 'package:my_app/screens/login_page.dart';
import 'package:my_app/services/firebase_service.dart';

// Global notifier for Dark Mode toggle
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyB5ecOPpOY9dXWVs_HswLzavrGN_tsdoGc",
          appId: "1:168016421810:android:b97ae2dc364602067d3aab",
          messagingSenderId: "168016421810",
          projectId: "smartenergyoptimization",
          databaseURL: "https://smartenergyoptimization-default-rtdb.asia-southeast1.firebasedatabase.app",
        ),
      );
      debugPrint("Firebase Initialized Successfully");
    }
  } catch (e) {
    debugPrint("Firebase already exists, skipping initialization: $e");
  }

  runApp(const SmartEnergyApp());
}

class SmartEnergyApp extends StatelessWidget {
  const SmartEnergyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // Light Theme Configuration
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: const Color(0xff6C63FF),
            scaffoldBackgroundColor: const Color(0xffF8F9FE),
          ),
          // Dark Theme Configuration
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xff6C63FF),
            scaffoldBackgroundColor: const Color(0xff121212),
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseService().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasData) return const DashboardPage();
              return const LoginPage();
            },
          ),
        );
      }
    );
  }
}