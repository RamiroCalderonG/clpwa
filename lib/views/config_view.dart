import 'package:flutter/material.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Configuración',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/autos',
            ); // Aquí luego navegaremos a la sección "Autos"
          },
          icon: const Icon(Icons.directions_car),
          label: const Text('Autos'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('← Volver al inicio'),
        ),
      ],
    );
  }
}
