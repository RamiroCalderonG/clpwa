import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';

class MantAutoDashboardView extends StatelessWidget {
  final Auto auto;
  const MantAutoDashboardView({Key? key, required this.auto}) : super(key: key);

  static const Map<String, int> primerServicio = {'plan1': 6000, 'plan2': 7500};
  static const Map<String, int> intervalo = {'plan1': 12000, 'plan2': 15000};

  String _formateaFecha(DateTime fecha) {
    // Ejemplo: martes, 12 de enero del 2026
    const meses = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    const dias = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    return '${dias[fecha.weekday - 1]}, ${fecha.day} de ${meses[fecha.month]} del ${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mantenimiento - ${auto.marca} ${auto.modelo}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('autos')
                .doc(auto.id)
                .collection('gas')
                .orderBy('fecha', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Sin historial de gasolina.'));
          }
          final cargas = snapshot.data!.docs;
          final kmActual =
              double.tryParse(
                '${(cargas.first.data() as Map<String, dynamic>)['km']}',
              ) ??
              0;
          final fechaUltima =
              (cargas.first.data() as Map<String, dynamic>)['fecha'];
          DateTime fechaUltimaCarga;
          if (fechaUltima is Timestamp) {
            fechaUltimaCarga = fechaUltima.toDate();
          } else {
            fechaUltimaCarga =
                DateTime.tryParse('$fechaUltima') ?? DateTime.now();
          }

          // Obtener historial para calcular promedio diario
          final kmInicial =
              double.tryParse(
                '${(cargas.last.data() as Map<String, dynamic>)['km']}',
              ) ??
              0;
          final fechaInicial =
              (cargas.last.data() as Map<String, dynamic>)['fecha'];
          DateTime fechaPrimeraCarga;
          if (fechaInicial is Timestamp) {
            fechaPrimeraCarga = fechaInicial.toDate();
          } else {
            fechaPrimeraCarga =
                DateTime.tryParse('$fechaInicial') ?? fechaUltimaCarga;
          }
          final dias = fechaUltimaCarga.difference(fechaPrimeraCarga).inDays;
          final promedioDiario = dias > 0 ? (kmActual - kmInicial) / dias : 0;

          // Cálculo del próximo servicio
          final plan = auto.tipoMantenimiento;
          final primer = primerServicio[plan] ?? 6000;
          final inter = intervalo[plan] ?? 12000;

          int siguienteServicio;
          if (kmActual < primer) {
            siguienteServicio = primer;
          } else {
            siguienteServicio =
                ((kmActual - primer) / inter).ceil() * inter + primer;
          }
          final faltanKm = siguienteServicio - kmActual;
          final diasFaltantes =
              (promedioDiario > 0) ? (faltanKm / promedioDiario) : 9999;
          final fechaEstimada = fechaUltimaCarga.add(
            Duration(days: diasFaltantes.round()),
          );

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kilometraje actual: ${kmActual.toStringAsFixed(0)} km',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Próximo servicio en: $siguienteServicio km',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Faltan: ${faltanKm.toStringAsFixed(0)} km',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Fecha estimada: ${_formateaFecha(fechaEstimada)}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('← Volver a autos'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
