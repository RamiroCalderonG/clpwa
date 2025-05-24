import 'package:flutter/material.dart';
import '../layout/layout.dart';

/// Pantalla principal que usa el layout base.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Layout(child: Center(child: Text('Bienvenido a CL PWA')));
  }
}
