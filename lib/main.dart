import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SnakeApp());
}

class SnakeApp extends StatelessWidget {
  const SnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1628),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
