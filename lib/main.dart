import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'sayfalar/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Seeded teal scheme, with redAccent for your help button
    final cs = ColorScheme.fromSeed(seedColor: Colors.teal).copyWith(
      secondary: Colors.teal.shade300,
      error: Colors.redAccent,
    );

    return MaterialApp(
      title: 'Life Count',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        scaffoldBackgroundColor: cs.background,
        textTheme: GoogleFonts.poppinsTextTheme(),

        // Global AppBar styling: teal background + white text/icons
        appBarTheme: AppBarTheme(
          backgroundColor: cs.primary,           // teal background
          foregroundColor: cs.onPrimary,          // white title & icons
          elevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            color: cs.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: cs.onPrimary),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cs.primary.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: const LoginPageWrapper(),
    );
  }
}

/// Wraps LoginPage with a subtle background gradient
class LoginPageWrapper extends StatelessWidget {
  const LoginPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primaryContainer, cs.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const SafeArea(
          child: LoginPage(),
        ),
      ),
    );
  }
}
