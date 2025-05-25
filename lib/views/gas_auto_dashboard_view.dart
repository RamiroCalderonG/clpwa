import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';

class GasAutoDashboardView extends StatelessWidget {
  final Auto auto;
  const GasAutoDashboardView({Key? key, required this.auto}) : super(key: key);

  String _formatFecha(dynamic fecha) {
    if (fecha is Timestamp) return fecha.toDate().toString().split(' ')[0];
    if (fecha is String) return fecha;
    return '-';
  }

  Map<String, dynamic> calcularEstadisticas(
    List<QueryDocumentSnapshot> cargas,
  ) {
    if (cargas.length < 2) {
      return {
        'rendUltima': '-',
        'rendTotal': '-',
        'costoKmUltima': '-',
        'costoKmTotal': '-',
        'gastoMes': '-',
        'gastoTotal': '-',
      };
    }

    // ------ Corrección aquí -------
    cargas.sort((a, b) {
      final aFecha =
          (a['fecha'] is Timestamp)
              ? (a['fecha'] as Timestamp).toDate()
              : DateTime.tryParse('${a['fecha']}');
      final bFecha =
          (b['fecha'] is Timestamp)
              ? (b['fecha'] as Timestamp).toDate()
              : DateTime.tryParse('${b['fecha']}');
      if (aFecha == null && bFecha == null) return 0;
      if (aFecha == null) return 1;
      if (bFecha == null) return -1;
      return aFecha.compareTo(bFecha);
    });

    final ult = cargas.last.data() as Map<String, dynamic>;
    final ant = cargas[cargas.length - 2].data() as Map<String, dynamic>;

    double kmUlt = double.tryParse('${ult['km']}') ?? 0;
    double kmAnt = double.tryParse('${ant['km']}') ?? 0;
    double litrosUlt = double.tryParse('${ult['litros']}') ?? 0;
    double totalUlt = double.tryParse('${ult['total']}') ?? 0;

    double kmFirst =
        double.tryParse(
          '${(cargas.first.data() as Map<String, dynamic>)['km']}',
        ) ??
        0;
    double kmLast = kmUlt;
    double litrosTotal = 0;
    double totalGasto = 0;
    DateTime now = DateTime.now();
    double gastoMes = 0;

    for (var carga in cargas) {
      final m = carga.data() as Map<String, dynamic>;
      double l = double.tryParse('${m['litros']}') ?? 0;
      double t = double.tryParse('${m['total']}') ?? 0;
      litrosTotal += l;
      totalGasto += t;
      final fechaCarga =
          (m['fecha'] is Timestamp)
              ? (m['fecha'] as Timestamp).toDate()
              : DateTime.tryParse('${m['fecha']}');
      if (fechaCarga != null &&
          fechaCarga.month == now.month &&
          fechaCarga.year == now.year) {
        gastoMes += t;
      }
    }

    final kmRecorridosTotal = kmLast - kmFirst;
    final rendUltima =
        (kmUlt - kmAnt) > 0 && litrosUlt > 0
            ? ((kmUlt - kmAnt) / litrosUlt)
            : 0;
    final rendTotal =
        kmRecorridosTotal > 0 && litrosTotal > 0
            ? (kmRecorridosTotal / litrosTotal)
            : 0;
    final costoKmUltima =
        (kmUlt - kmAnt) > 0 ? (totalUlt / (kmUlt - kmAnt)) : 0;
    final costoKmTotal =
        kmRecorridosTotal > 0 ? (totalGasto / kmRecorridosTotal) : 0;

    return {
      'rendUltima': rendUltima.toStringAsFixed(2),
      'rendTotal': rendTotal.toStringAsFixed(2),
      'costoKmUltima': costoKmUltima.toStringAsFixed(2),
      'costoKmTotal': costoKmTotal.toStringAsFixed(2),
      'gastoMes': gastoMes.toStringAsFixed(2),
      'gastoTotal': totalGasto.toStringAsFixed(2),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            '${auto.marca} ${auto.modelo}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('autos')
                      .doc(auto.id)
                      .collection('gas')
                      .orderBy('fecha')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay cargas registradas.'),
                  );
                }
                final cargas = snapshot.data!.docs;
                final stats = calcularEstadisticas(cargas);

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Consumo promedio (última): ${stats['rendUltima']} km/l',
                              ),
                              Text(
                                'Consumo promedio total: ${stats['rendTotal']} km/l',
                              ),
                              Text(
                                'Costo por km (última): \$${stats['costoKmUltima']}',
                              ),
                              Text(
                                'Costo por km histórico: \$${stats['costoKmTotal']}',
                              ),
                              Text('Total gasto mes: \$${stats['gastoMes']}'),
                              Text('Total histórico: \$${stats['gastoTotal']}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.local_gas_station),
                        label: const Text('Nueva carga'),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/gas/auto/carga',
                            arguments: auto,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        child: const Text('Ver todas las cargas'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GasCargasListView(auto: auto),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('← Volver a autos'),
          ),
        ],
      ),
    );
  }
}

// --- Vista simple para ver todas las cargas ---
class GasCargasListView extends StatelessWidget {
  final Auto auto;
  const GasCargasListView({Key? key, required this.auto}) : super(key: key);

  String _formatFecha(dynamic fecha) {
    if (fecha is Timestamp) return fecha.toDate().toString().split(' ')[0];
    if (fecha is String) return fecha;
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cargas de ${auto.marca} ${auto.modelo}')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('autos')
                .doc(auto.id)
                .collection('gas')
                .orderBy('fecha', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay cargas registradas.'));
          }
          final cargas = snapshot.data!.docs;
          return ListView.builder(
            itemCount: cargas.length,
            itemBuilder: (context, index) {
              final carga = cargas[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Fecha: ${_formatFecha(carga['fecha'])}'),
                subtitle: Text(
                  'Litros: ${carga['litros']} | KM: ${carga['km']} | \$${carga['total']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
