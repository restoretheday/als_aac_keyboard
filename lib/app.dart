import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart';

class AlsBinaryKeyboardApp extends StatelessWidget {
  const AlsBinaryKeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALS Binary Keyboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2), // Soft blue
          brightness: Brightness.light,
        ).copyWith(
          primary: const Color(0xFF4A90E2), // Soft blue
          onPrimary: Colors.white,
          secondary: const Color(0xFF6BA3D8), // Lighter blue
          onSecondary: Colors.white,
          tertiary: const Color(0xFF9BB5D1), // Very light blue
          onTertiary: const Color(0xFF2C3E50), // Dark blue-gray for contrast
          error: const Color(0xFFD4A5A5), // Soft muted coral/rose
          onError: const Color(0xFF6B3E3E), // Dark muted red for contrast
          surface: Colors.white,
          onSurface: const Color(0xFF2C3E50), // Dark blue-gray for readability
          background: const Color(0xFFF8F9FA), // Very light gray-blue
          secondaryContainer: const Color(0xFFE8F0F7), // Very light blue tint
          onSecondaryContainer: const Color(0xFF2C3E50),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
