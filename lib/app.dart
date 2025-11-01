import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart';

class AlsBinaryKeyboardApp extends StatelessWidget {
  const AlsBinaryKeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALS Binary Keyboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
