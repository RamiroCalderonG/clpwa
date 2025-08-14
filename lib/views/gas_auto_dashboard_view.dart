import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';

class GasAutoDashboardView extends StatefulWidget {
  final Auto auto;
  const GasAutoDashboardView({Key? key, required this.auto}) : super(key: key);

  @override
  State<GasAutoDashboardView> createState() => _GasAutoDashboardViewState();
}

class _GasAutoDashboardViewState extends State<GasAutoDashboardView> {
  String _formatFecha(dynamic fecha) {
    if (fecha is Timestamp) return fecha.toDate().toString().split(' ').first;
    if (fecha is String) return fecha;
    return '-';
  }

  ({
    Map<String, String> kpis,
    List<_SeriePunto> consumoKmL,
    List<_SeriePunto> costoPorKm
  }) calcularTodo(List<QueryDocumentSnapshot<Map<String, dynamic>>> cargas,
      {int maxPuntos = 12}) {
    if (cargas.length < 2) {
      return (
        kpis: {
          'rendUltima': '-',
          'rendTotal': '-',
          'costoKmUltima': '-',
          'costoKmTotal': '-',
          'gastoMes': '-',
          'gastoTotal': '-',
        },
        consumoKmL: const [],
        costoPorKm: const [],
      );
    }

    cargas.sort((a, b) {
      final aFecha = (a['fecha'] is Timestamp)
          ? (a['fecha'] as Timestamp).toDate()
          : DateTime.tryParse('${a['fecha']}');
      final bFecha = (b['fecha'] is Timestamp)
          ? (b['fecha'] as Timestamp).toDate()
          : DateTime.tryParse('${b['fecha']}');
      if (aFecha == null && bFecha == null) return 0;
      if (aFecha == null) return 1;
      if (bFecha == null) return -1;
      return aFecha.compareTo(bFecha);
    });

    final ult = cargas.last.data();
    final ant = cargas[cargas.length - 2].data();

    final double kmUlt = double.tryParse('${ult['km']}') ?? 0;
    final double kmAnt = double.tryParse('${ant['km']}') ?? 0;
    final double litrosUlt = double.tryParse('${ult['litros']}') ?? 0;
    final double totalUlt = double.tryParse('${ult['total']}') ?? 0;

    final double kmFirst =
        double.tryParse('${cargas.first.data()['km']}') ?? 0;
    final double kmLast = kmUlt;

    double litrosTotal = 0;
    double totalGasto = 0;
    final DateTime ahora = DateTime.now();
    double gastoMes = 0;

    final List<_SeriePunto> consumo = [];
    final List<_SeriePunto> costoKm = [];

    for (int i = 0; i < cargas.length; i++) {
      final m = cargas[i].data();
      final double l = double.tryParse('${m['litros']}') ?? 0;
      final double t = double.tryParse('${m['total']}') ?? 0;
      final double km = double.tryParse('${m['km']}') ?? 0;
      final DateTime? fecha = (m['fecha'] is Timestamp)
          ? (m['fecha'] as Timestamp).toDate()
          : DateTime.tryParse('${m['fecha']}');

      litrosTotal += l;
      totalGasto += t;

      if (fecha != null && fecha.month == ahora.month && fecha.year == ahora.year) {
        gastoMes += t;
      }

      if (i > 0 && fecha != null) {
        final mAnt = cargas[i - 1].data();
        final double kmAntI = double.tryParse('${mAnt['km']}') ?? 0;
        final double lI = l;
        final double tI = t;

        final double deltaKm = (km - kmAntI);
        final double rend = (deltaKm > 0 && lI > 0) ? (deltaKm / lI) : 0;
        final double cost = (deltaKm > 0) ? (tI / deltaKm) : 0;

        consumo.add(_SeriePunto(fecha, rend));
        costoKm.add(_SeriePunto(fecha, cost));
      }
    }

    List<_SeriePunto> _ultimos(List<_SeriePunto> s) =>
        s.length <= maxPuntos ? s : s.sublist(s.length - maxPuntos);

    final kmRecorridosTotal = kmLast - kmFirst;
    final rendUltima =
        (kmUlt - kmAnt) > 0 && litrosUlt > 0 ? ((kmUlt - kmAnt) / litrosUlt) : 0;
    final rendTotal = (kmRecorridosTotal > 0 && litrosTotal > 0)
        ? (kmRecorridosTotal / litrosTotal)
        : 0;
    final costoKmUltima =
        (kmUlt - kmAnt) > 0 ? (totalUlt / (kmUlt - kmAnt)) : 0;
    final costoKmTotal =
        kmRecorridosTotal > 0 ? (totalGasto / kmRecorridosTotal) : 0;

    String f2(num v) => v.toStringAsFixed(2);

    return (
      kpis: {
        'rendUltima': f2(rendUltima),
        'rendTotal': f2(rendTotal),
        'costoKmUltima': f2(costoKmUltima),
        'costoKmTotal': f2(costoKmTotal),
        'gastoMes': f2(gastoMes),
        'gastoTotal': f2(totalGasto),
      },
      consumoKmL: _ultimos(consumo),
      costoPorKm: _ultimos(costoKm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auto = widget.auto;

    return Stack(
      children: [
        Positioned(
          top: -140,
          right: -100,
          child: _Blob(diameter: 360, color: Colors.teal.withOpacity(0.08)),
        ),
        Positioned(
          bottom: -160,
          left: -120,
          child: _Blob(diameter: 420, color: Colors.deepPurple.withOpacity(0.07)),
        ),

        SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('autos')
                .doc(auto.id)
                .collection('gas')
                .orderBy('fecha')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snap.data?.docs ?? [];
              final all = calcularTodo(docs);
              final kpis = all.kpis;

              Map<String, dynamic>? ultima;
              if (docs.isNotEmpty) {
                try {
                  ultima = docs.last.data();
                } catch (_) {}
              }

              return LayoutBuilder(builder: (context, c) {
                final w = c.maxWidth;

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _HeroHeader(auto: auto),
                              const SizedBox(height: 12),

                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  FilledButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/gas/auto/carga',
                                        arguments: auto,
                                      );
                                    },
                                    icon: const Icon(
                                        Icons.local_gas_station_rounded),
                                    label: const Text('Nueva carga'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              GasCargasListView(auto: auto),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    child: const Text('Ver cargas'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => GasChartsView(
                                            auto: auto,
                                            consumo: all.consumoKmL,
                                            costoKm: all.costoPorKm,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.show_chart_rounded),
                                    label: const Text('Ver gráficas'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),
                              _KpiChips(kpis: kpis),
                              const SizedBox(height: 14),

                              _SparklineRow(
                                consumo: all.consumoKmL,
                                costoKm: all.costoPorKm,
                              ),

                              const SizedBox(height: 16),

                              if (ultima != null)
                                _LastFillCard(
                                    ultima,
                                    (v) => _formatFecha(v),
                                    keyColor: Colors.amber),

                              const SizedBox(height: 20),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text('Volver a autos'),
                                ),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 18,
                      bottom: 18,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/gas/auto/carga',
                            arguments: auto,
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Carga'),
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final Auto auto;
  const _HeroHeader({required this.auto});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImg = (auto.fotoUrl != null && auto.fotoUrl!.isNotEmpty);

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final twoCols = w >= 860;

      final name = '${auto.marca ?? ''} ${auto.modelo ?? ''}'
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      final year = auto.anio != null ? 'Año ${auto.anio}' : 'Año —';
      final plate = (auto.placa?.isNotEmpty ?? false) ? auto.placa! : 'S/N';

      final header = Column(
        crossAxisAlignment:
            twoCols ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            name.isEmpty ? 'Vehículo' : name,
            textAlign: twoCols ? TextAlign.left : TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: twoCols ? WrapAlignment.start : WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(icon: Icons.calendar_today_rounded, label: year),
              _Chip(icon: Icons.directions_car_rounded, label: plate),
            ],
          ),
        ],
      );

      final image = ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: twoCols ? 16 / 10 : 16 / 9,
          child: hasImg
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      auto.fotoUrl!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => _imgFallback(),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : _imgLoading(),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.22),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                )
              : _imgFallback(),
        ),
      );

      if (twoCols) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 11, child: image),
            const SizedBox(width: 14),
            Expanded(flex: 10, child: header),
          ],
        );
      } else {
        return Column(
          children: [
            image,
            const SizedBox(height: 12),
            header,
          ],
        );
      }
    });
  }

  Widget _imgFallback() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF9575CD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.directions_car_filled_rounded,
              size: 64, color: Colors.white),
        ),
      );

  Widget _imgLoading() =>
      Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator()));
}

/// ---------- KPIs compactos (centrados) ----------
class _KpiChips extends StatelessWidget {
  final Map<String, String> kpis;
  const _KpiChips({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = <(IconData, String, String)>[
      (Icons.local_gas_station_rounded, 'Consumo (última)', '${kpis['rendUltima']} km/l'),
      (Icons.timeline_rounded, 'Consumo (hist.)', '${kpis['rendTotal']} km/l'),
      (Icons.attach_money_rounded, 'Costo/km (últ.)', '\$${kpis['costoKmUltima']}'),
      (Icons.stacked_line_chart_rounded, 'Costo/km (hist.)', '\$${kpis['costoKmTotal']}'),
      (Icons.calendar_month_rounded, 'Gasto del mes', '\$${kpis['gastoMes']}'),
      (Icons.payments_rounded, 'Gasto total', '\$${kpis['gastoTotal']}'),
    ];

    // Cards/chips centradas
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      // ancho sugerido por chip (ajusta si quieres)
      final double chipW = w >= 1000 ? 220 : (w >= 680 ? 200 : 170);

      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: items.map((e) {
          return ConstrainedBox(
            constraints: BoxConstraints(minWidth: chipW, maxWidth: chipW),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(e.$1,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.9)),
                  const SizedBox(height: 8),
                  // VALOR grande, centrado
                  Text(
                    e.$3,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Etiqueta
                  Text(
                    e.$2,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

/// ---------- Minigráficas (valor centrado + min/prom/máx) ----------
class _SparklineRow extends StatelessWidget {
  final List<_SeriePunto> consumo;
  final List<_SeriePunto> costoKm;
  const _SparklineRow({required this.consumo, required this.costoKm});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final twoCols = w >= 680;
      return twoCols
          ? Row(
              children: [
                Expanded(
                  child: _SparklineCard(
                    title: 'Consumo (km/l)',
                    serie: consumo,
                    unit: 'km/l',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SparklineCard(
                    title: 'Costo por km (\$)',
                    serie: costoKm,
                    unit: '\$/km',
                  ),
                ),
              ],
            )
          : Column(
              children: [
                _SparklineCard(
                  title: 'Consumo (km/l)',
                  serie: consumo,
                  unit: 'km/l',
                ),
                const SizedBox(height: 12),
                _SparklineCard(
                  title: 'Costo por km (\$)',
                  serie: costoKm,
                  unit: '\$/km',
                ),
              ],
            );
    });
  }
}

/// Card de sparkline con número grande centrado + min/prom/máx
class _SparklineCard extends StatelessWidget {
  final String title;
  final List<_SeriePunto> serie;
  final String unit;
  const _SparklineCard({
    required this.title,
    required this.serie,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double? last;
    double? minV;
    double? maxV;
    double? avgV;

    if (serie.isNotEmpty) {
      last = serie.last.valor;
      minV = serie.map((e) => e.valor).reduce((a, b) => a < b ? a : b);
      maxV = serie.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
      avgV = serie.map((e) => e.valor).reduce((a, b) => a + b) / serie.length;
    }

    String f2(double v) => v.toStringAsFixed(2);

    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Align(
              alignment: Alignment.center,
              child: Text(
                title,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.hintColor),
              ),
            ),
            const SizedBox(height: 6),
            // VALOR grande y centrado
            Text(
              last == null ? '—' : '${f2(last!)} $unit',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            // Sparkline
            SizedBox(height: 78, child: _Sparkline(serie: serie)),
            const SizedBox(height: 6),
            // Min / Prom / Máx
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _miniStat('Min', minV == null ? '—' : f2(minV!)),
                _miniStat('Prom', avgV == null ? '—' : f2(avgV!)),
                _miniStat('Máx', maxV == null ? '—' : f2(maxV!)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String k, String v) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(k, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<_SeriePunto> serie;
  const _Sparkline({required this.serie});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(serie),
      child: const SizedBox.expand(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<_SeriePunto> serie;
  _SparklinePainter(this.serie);

  @override
  void paint(Canvas canvas, Size size) {
    if (serie.isEmpty) return;

    final minY = serie.map((e) => e.valor).reduce((a, b) => a < b ? a : b);
    final maxY = serie.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
    final dy = (maxY - minY) == 0 ? 1.0 : (maxY - minY);

    final path = Path();
    for (var i = 0; i < serie.length; i++) {
      final x = i * (size.width / (serie.length - 1));
      final y = size.height - ((serie[i].valor - minY) / dy) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFF5E35B1);
    canvas.drawPath(path, paint);

    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF5E35B1).withOpacity(0.9);
    for (var i = 0; i < serie.length; i++) {
      final x = i * (size.width / (serie.length - 1));
      final y = size.height - ((serie[i].valor - minY) / dy) * size.height;
      canvas.drawCircle(Offset(x, y), 2.4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.serie != serie;
}

class _SeriePunto {
  final DateTime fecha;
  final double valor;
  _SeriePunto(this.fecha, this.valor);
}

class _LastFillCard extends StatelessWidget {
  final Map<String, dynamic> ultima;
  final String Function(dynamic) fmt;
  final Color keyColor;
  const _LastFillCard(this.ultima, this.fmt, {this.keyColor = Colors.amber});

  @override
  Widget build(BuildContext context) {
    final litros = double.tryParse('${ultima['litros']}') ?? 0;
    final total = double.tryParse('${ultima['total']}') ?? 0;
    final km = double.tryParse('${ultima['km']}') ?? 0;
    final precioLt = (litros > 0) ? (total / litros) : 0;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(14),
        color: Theme.of(context).colorScheme.surface,
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: keyColor.withOpacity(0.2),
              child: Icon(Icons.local_gas_station_rounded,
                  color: keyColor, size: 22),
            ),
            _KeyValue('Fecha', fmt(ultima['fecha'])),
            _KeyValue('Litros',
                litros == 0 ? '-' : litros.toStringAsFixed(2)),
            _KeyValue('KM', km == 0 ? '-' : km.toStringAsFixed(0)),
            _KeyValue('Total',
                total == 0 ? '-' : '\$${total.toStringAsFixed(2)}'),
            _KeyValue('Precio/L',
                precioLt == 0 ? '-' : '\$${precioLt.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String k;
  final String v;
  const _KeyValue(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurface),
          children: [
            TextSpan(
                text: '$k: ',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: v),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double diameter;
  final Color color;
  const _Blob({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(blurRadius: 80, spreadRadius: 20, color: color)],
      ),
    );
  }
}

class GasCargasListView extends StatelessWidget {
  final Auto auto;
  const GasCargasListView({Key? key, required this.auto}) : super(key: key);

  String _formatFecha(dynamic fecha) {
    if (fecha is Timestamp) return fecha.toDate().toString().split(' ').first;
    if (fecha is String) return fecha;
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Cargas — ${auto.marca ?? ''} ${auto.modelo ?? ''}')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('autos')
            .doc(auto.id)
            .collection('gas')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No hay cargas registradas.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final m = docs[i].data();
              final litros = double.tryParse('${m['litros']}') ?? 0;
              final total = double.tryParse('${m['total']}') ?? 0;
              final km = double.tryParse('${m['km']}') ?? 0;

              return Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    child: const Icon(Icons.local_gas_station_rounded),
                  ),
                  title: Text(_formatFecha(m['fecha'])),
                  subtitle: Text(
                      'Litros: ${litros.toStringAsFixed(2)}   KM: ${km.toStringAsFixed(0)}   Total: \$${total.toStringAsFixed(2)}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class GasChartsView extends StatelessWidget {
  final Auto auto;
  final List<_SeriePunto> consumo;
  final List<_SeriePunto> costoKm;
  const GasChartsView(
      {super.key, required this.auto, required this.consumo, required this.costoKm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Gráficas — ${auto.marca ?? ''} ${auto.modelo ?? ''}')),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView(
          children: [
            _LineChartCard(
              title: 'Consumo (km/l)',
              serie: consumo,
              color: const Color(0xFF43A047),
            ),
            const SizedBox(height: 12),
            _LineChartCard(
              title: 'Costo por km (\$)',
              serie: costoKm,
              color: const Color(0xFF1E88E5),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  final String title;
  final List<_SeriePunto> serie;
  final Color color;
  const _LineChartCard(
      {required this.title, required this.serie, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: theme.colorScheme.surface,
        padding: const EdgeInsets.all(12),
        height: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(child: _LineChart(serie: serie, color: color)),
          ],
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<_SeriePunto> serie;
  final Color color;
  const _LineChart({required this.serie, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(serie, color),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<_SeriePunto> serie;
  final Color color;
  _LineChartPainter(this.serie, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (serie.isEmpty) return;

    final padding = 16.0;
    final chartRect = Rect.fromLTWH(
        padding, padding, size.width - padding * 2, size.height - padding * 2);

    final minY = serie.map((e) => e.valor).reduce((a, b) => a < b ? a : b);
    final maxY = serie.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
    final dy = (maxY - minY) == 0 ? 1.0 : (maxY - minY);

    final axisPaint = Paint()
      ..color = const Color(0x33000000)
      ..strokeWidth = 1;
    canvas.drawLine(chartRect.bottomLeft, chartRect.bottomRight, axisPaint);
    canvas.drawLine(chartRect.topLeft, chartRect.bottomLeft, axisPaint);

    final path = Path();
    for (var i = 0; i < serie.length; i++) {
      final x = chartRect.left +
          i * (chartRect.width / (serie.length - 1));
      final y = chartRect.bottom -
          ((serie[i].valor - minY) / dy) * chartRect.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = color;
    canvas.drawPath(path, stroke);

    final areaPath = Path.from(path)
      ..lineTo(chartRect.right, chartRect.bottom)
      ..lineTo(chartRect.left, chartRect.bottom)
      ..close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.35), color.withOpacity(0.04)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(chartRect);
    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.serie != serie || oldDelegate.color != color;
}


