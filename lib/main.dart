import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp();
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  runApp(const ESahaytaApp());
}

class ESahaytaApp extends StatelessWidget {
  const ESahaytaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "eSahayta",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Poppins",
        primaryColor: const Color(0xff0F2A44),
        scaffoldBackgroundColor: const Color(0xffF5F7FA),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0F2A44),
          primary: const Color(0xff0F2A44),
          secondary: const Color(0xffC68A2E),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffC68A2E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
