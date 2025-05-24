import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // Este método es compatible para Web
      await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al iniciar sesión: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.login),
        label: const Text('Iniciar sesión con Google'),
        onPressed: () => _signInWithGoogle(context),
      ),
    );
  }
}
