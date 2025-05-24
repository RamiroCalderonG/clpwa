import 'package:flutter/material.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Widget principal de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CL PWA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(), // Pantalla principal
    );
  }
}
