import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';

/// Layout general con Header, Main y Footer.
class Layout extends StatelessWidget {
  final Widget child;
  const Layout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Header(), // Parte superior
          Expanded(child: child), // Contenido central
          const Footer(), // Parte inferior
        ],
      ),
    );
  }
}
