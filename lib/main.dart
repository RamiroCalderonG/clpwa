import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'views/home_view.dart';
import 'views/config_view.dart';
import 'views/autos_view.dart';
import 'views/auto_form_view.dart';
import 'views/auto_edit_form_view.dart';
import 'models/auto.dart';
import 'views/login_view.dart'; // Nueva vista de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CL PWA',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(), // Cambia routes por home con AuthGate
      routes: {
        '/config': (context) => const MainLayout(child: ConfigView()),
        '/autos': (context) => const MainLayout(child: AutosView()),
        '/autos/form': (context) => const MainLayout(child: AutoFormView()),
        '/autos/edit': (context) {
          final auto = ModalRoute.of(context)!.settings.arguments as Auto;
          return MainLayout(child: AutoEditFormView(auto: auto));
        },
        // Puedes agregar tus otras rutas aquí
      },
    );
  }
}

/// Revisa si el usuario está autenticado, y si no, muestra la pantalla de login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const LoginView();
        }
        // Usuario autenticado, muestra el home normal
        return MainLayout(child: HomeView());
      },
    );
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 27, 27, 28),
            padding: const EdgeInsets.all(16),
            child: const Text(
              'CL PWA',
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(child: Center(child: child)),
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: const Text(
              '© 2025 CalderonLuna. Todos los derechos reservados.',
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
