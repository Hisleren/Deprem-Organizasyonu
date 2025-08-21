// main.dart - Enhanced Professional Design
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added this import for SystemUiOverlayStyle
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
    // Professional color scheme with emergency red accent
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B5E20), // Deep green for reliability
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF1B5E20),
      secondary: const Color(0xFF4CAF50),
      tertiary: const Color(0xFF2196F3),
      error: const Color(0xFFD32F2F),
      surface: Colors.white,
      background: const Color(0xFFF8F9FA),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF212121),
      onBackground: const Color(0xFF212121),
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4CAF50),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF4CAF50),
      secondary: const Color(0xFF81C784),
      tertiary: const Color(0xFF64B5F6),
      error: const Color(0xFFE57373),
      surface: const Color(0xFF1E1E1E),
      background: const Color(0xFF121212),
    );

    return MaterialApp(
      title: 'Emergency Response System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: lightColorScheme.onBackground,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: lightColorScheme.onBackground,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: lightColorScheme.onBackground,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            color: lightColorScheme.onBackground,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            color: lightColorScheme.onBackground,
          ),
        ),
        
        // Enhanced AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.surface,
          foregroundColor: lightColorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: lightColorScheme.shadow,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: lightColorScheme.onSurface,
          ),
          iconTheme: IconThemeData(color: lightColorScheme.onSurface),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        // Enhanced Card Theme - Fixed type
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: lightColorScheme.shadow.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: lightColorScheme.surface,
          surfaceTintColor: lightColorScheme.primary,
        ),

        // Enhanced Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightColorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightColorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightColorScheme.outline.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: lightColorScheme.error),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          labelStyle: TextStyle(color: lightColorScheme.onSurface.withOpacity(0.7)),
        ),

        // Enhanced Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightColorScheme.primary,
            foregroundColor: lightColorScheme.onPrimary,
            elevation: 2,
            shadowColor: lightColorScheme.shadow.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: lightColorScheme.primary,
            foregroundColor: lightColorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: lightColorScheme.primary,
            side: BorderSide(color: lightColorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),

        // Enhanced FAB Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightColorScheme.primary,
          foregroundColor: lightColorScheme.onPrimary,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Enhanced Bottom Sheet Theme
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: lightColorScheme.surface,
          elevation: 8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),

        // Enhanced Dialog Theme - Fixed type
        dialogTheme: DialogThemeData(
          backgroundColor: lightColorScheme.surface,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        // Similar enhanced themes for dark mode...
      ),
      
      home: const LoginPageWrapper(),
    );
  }
}

class LoginPageWrapper extends StatelessWidget {
  const LoginPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: const SafeArea(
          child: LoginPage(),
        ),
      ),
    );
  }
}