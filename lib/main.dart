import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'models/auto.dart';

import 'views/home_view.dart';
import 'views/config_view.dart';
import 'views/autos_view.dart';
import 'views/auto_form_view.dart';
import 'views/auto_edit_form_view.dart';
import 'views/gas_autos_view.dart';
import 'views/gas_auto_dashboard_view.dart';
import 'views/gas_carga_form_view.dart';
import 'views/login_view.dart'; // <-- Nuevo

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
      // Quitamos routes porque necesitamos lógica de auth antes
      home: AuthGate(),
    );
  }
}

// Widget que controla el acceso y la whitelist
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Si no está logueado, muestra login
        if (!snapshot.hasData) return const LoginView();

        final user = snapshot.data!;
        final email = user.email ?? '';

        // Verifica whitelist en Firestore
        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('whitelist')
                  .doc(email)
                  .get(),
          builder: (context, whitelistSnap) {
            if (whitelistSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!whitelistSnap.hasData || !whitelistSnap.data!.exists) {
              // Si no está autorizado, cierra sesión y muestra mensaje
              FirebaseAuth.instance.signOut();
              return const Scaffold(
                body: Center(child: Text('No autorizado para acceder.')),
              );
            }
            // Si está autorizado, muestra la app normal con rutas
            return AppRouter();
          },
        );
      },
    );
  }
}

// El router de tu app, igual que antes pero en un widget aparte
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CL PWA',
      debugShowCheckedModeBanner: false,
      routes: {
        '/gas/auto': (context) {
          final auto = ModalRoute.of(context)!.settings.arguments as Auto;
          return MainLayout(child: GasAutoDashboardView(auto: auto));
        },
        '/gas/auto/carga': (context) {
          final auto = ModalRoute.of(context)!.settings.arguments as Auto;
          return MainLayout(child: GasCargaFormView(auto: auto));
        },
        '/': (context) => const MainLayout(child: HomeView()),
        '/gas': (context) => const MainLayout(child: GasAutosView()),
        '/config': (context) => const MainLayout(child: ConfigView()),
        '/autos': (context) => const MainLayout(child: AutosView()),
        '/autos/form': (context) => const MainLayout(child: AutoFormView()),
        '/autos/edit': (context) {
          final auto = ModalRoute.of(context)!.settings.arguments as Auto;
          return MainLayout(child: AutoEditFormView(auto: auto));
        },
      },
      initialRoute: '/',
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
              'CL PWA1',
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
