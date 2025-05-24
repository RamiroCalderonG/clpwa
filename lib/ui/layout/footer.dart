import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: const Text(
        '© 2025 CL PWA. Todos los derechos reservados.',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
