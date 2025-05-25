import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'views/home_view.dart';
import 'views/config_view.dart';
import 'views/autos_view.dart';
import 'views/auto_form_view.dart';
import 'views/auto_edit_form_view.dart';
import 'views/gas_autos_view.dart';
import 'views/gas_auto_dashboard_view.dart';
import 'views/gas_carga_form_view.dart';
import 'views/mant_autos_view.dart';
import 'views/mant_auto_dashboard_view.dart';
// Si tienes una vista individual de mantenimiento por auto, impórtala aquí.
// import 'views/mant_auto_dashboard_view.dart';
import 'models/auto.dart';

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
      routes: {
        '/': (context) => const MainLayout(child: HomeView()),
        '/config': (context) => const MainLayout(child: ConfigView()),
        '/autos': (context) => const MainLayout(child: AutosView()),
        '/autos/form': (context) => const MainLayout(child: AutoFormView()),
        '/autos/edit': (context) {
          final auto = ModalRoute.of(context)!.settings.arguments as Auto;
          return MainLayout(child: AutoEditFormView(auto: auto));
        },
        // Gasolina
        '/gas': (context) => const MainLayout(child: GasAutosView()),
        '/gas/auto/dashboard': (context) {
          final auto = ModalRoute.of(context)!.settings.arguments as Auto;
          return MainLayout(child: GasAutoDashboardView(auto: auto));
        },
        '/gas/auto/carga': (context) {
          final auto = ModalRoute.of(context)!.settings.arguments as Auto;
          return MainLayout(child: GasCargaFormView(auto: auto));
        },
        // Mantenimientos
        '/mant': (context) => const MainLayout(child: MantAutosView()),
        //Si tienes un dashboard por auto para mantenimientos, descomenta y usa este ejemplo:
        '/mant/auto/dashboard': (context) {
          final auto = ModalRoute.of(context)!.settings.arguments as Auto;
          return MainLayout(child: MantAutoDashboardView(auto: auto));
        },
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
