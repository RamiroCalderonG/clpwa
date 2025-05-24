import 'package:flutter/material.dart';
import '../models/auto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GasAutoDashboardView extends StatelessWidget {
  final Auto auto;
  const GasAutoDashboardView({super.key, required this.auto});

  Future<Map<String, dynamic>> getStats({required String autoId}) async {
    final query =
        await FirebaseFirestore.instance
            .collection('autos')
            .doc(autoId)
            .collection('gas')
            .orderBy('km')
            .get();

    double total = 0.0;
    double? rendimientoUltima;
    double? rendimientoPromedio;
    final cargas = query.docs;

    // Calcular total de gasolina
    for (var doc in cargas) {
      total += (doc['total'] ?? 0).toDouble();
    }

    // Rendimiento promedio histórico (con todas las cargas)
    if (cargas.length >= 2) {
      final first = cargas.first.data();
      final last = cargas.last.data();
      final kmInicial = first['km'] ?? 0;
      final kmFinal = last['km'] ?? 0;
      double totalLitros = 0.0;
      for (var doc in cargas) {
        totalLitros += (doc['litros'] ?? 0).toDouble();
      }
      final distancia = kmFinal - kmInicial;
      if (totalLitros > 0 && distancia > 0) {
        rendimientoPromedio = distancia / totalLitros;
      }

      // Rendimiento última recarga (solo dos últimas)
      if (cargas.length >= 2) {
        final prev = cargas[cargas.length - 2].data();
        final curr = cargas.last.data();
        final kmAnterior = prev['km'] ?? 0;
        final kmActual = curr['km'] ?? 0;
        final litrosActual = curr['litros'] ?? 0;
        final distanciaUltima = kmActual - kmAnterior;
        if (litrosActual > 0 && distanciaUltima > 0) {
          rendimientoUltima = distanciaUltima / litrosActual;
        }
      }
    }

    return {
      'total': total,
      'rendimientoUltima': rendimientoUltima,
      'rendimientoPromedio': rendimientoPromedio,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getStats(autoId: auto.id),
      builder: (context, snapshot) {
        double total = snapshot.data?['total'] ?? 0.0;
        double? rendimientoUltima = snapshot.data?['rendimientoUltima'];
        double? rendimientoPromedio = snapshot.data?['rendimientoPromedio'];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  auto.modelo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Rendimiento de la última recarga:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  rendimientoUltima != null
                      ? '${rendimientoUltima.toStringAsFixed(2)} km/l'
                      : '—',
                  style: TextStyle(
                    fontSize: 22,
                    color:
                        rendimientoUltima != null ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Rendimiento promedio histórico:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  rendimientoPromedio != null
                      ? '${rendimientoPromedio.toStringAsFixed(2)} km/l'
                      : '—',
                  style: TextStyle(
                    fontSize: 22,
                    color:
                        rendimientoPromedio != null
                            ? Colors.orange
                            : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Costo total:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 36),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva carga'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/gas/auto/carga',
                      arguments: auto,
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('← Regresar a autos'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
