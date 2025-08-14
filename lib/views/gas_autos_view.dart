import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';

class GasAutosView extends StatelessWidget {
  const GasAutosView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // --- Fondo con blobs (suave) ---
        Positioned(
          top: -140,
          right: -100,
          child: _Blob(
            diameter: 320,
            color: Colors.teal.withOpacity(0.08),
          ),
        ),
        Positioned(
          bottom: -160,
          left: -120,
          child: _Blob(
            diameter: 420,
            color: Colors.deepPurple.withOpacity(0.07),
          ),
        ),

        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado
                    Text(
                      'Selecciona un auto',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elige el vehículo para registrar gasolina o consultar métricas.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Lista desde Firestore
                    Expanded(
                      child: StreamBuilder<
                          QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('autos')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const _EmptyState();
                          }

                          final autos = snapshot.data!.docs
                              .map((doc) => Auto.fromMap(
                                    doc.id,
                                    doc.data(),
                                  ))
                              .toList();

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              final cross = w >= 1000
                                  ? 3
                                  : w >= 680
                                      ? 2
                                      : 1;

                              return GridView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cross,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                  childAspectRatio:
                                      w >= 1000 ? 2.2 : (w >= 680 ? 2.0 : 1.9),
                                ),
                                itemCount: autos.length,
                                itemBuilder: (context, i) {
                                  final auto = autos[i];
                                  return _CarCard(
                                    auto: auto,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/gas/auto/dashboard',
                                        arguments: auto,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Volver al Menú'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Tarjeta del Auto (nombre en 2 líneas, chips Año + Placa) ----------
class _CarCard extends StatefulWidget {
  final Auto auto;
  final VoidCallback onTap;

  const _CarCard({required this.auto, required this.onTap});

  @override
  State<_CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<_CarCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.auto;

    const fallbackGradient = LinearGradient(
      colors: [Color(0xFF6A1B9A), Color(0xFF9575CD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // Imagen responsiva: más espacio al texto
        final double imgW = (w * 0.32).clamp(110.0, 190.0);
        const double cardH = 140;

        final bool compact = w < 420;

        return AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _hover ? 1.02 : 1.0,
          child: Material(
            elevation: _hover ? 8 : 3,
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              onHover: (v) => setState(() => _hover = v),
              splashColor: Colors.white.withOpacity(0.08),
              highlightColor: Colors.transparent,
              child: SizedBox(
                height: cardH,
                child: Row(
                  children: [
                    // Imagen / fallback
                    SizedBox(
                      width: imgW,
                      height: double.infinity,
                      child: (a.fotoUrl != null && a.fotoUrl!.isNotEmpty)
                          ? _CarImage(url: a.fotoUrl!)
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: fallbackGradient,
                              ),
                              child: const Center(
                                child: Icon(Icons.directions_car_rounded,
                                    size: 52, color: Colors.white),
                              ),
                            ),
                    ),

                    // Panel derecho
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1F1F1F), Color(0xFF2C2C2C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Contenido (nombre + chips)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Nombre hasta 2 líneas (mejor legibilidad)
                                  Text(
                                    _fullName(a.marca, a.modelo),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          fontSize: compact ? 19 : null,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Chips: Año + Placa (compactos, en Wrap)
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 8,
                                    children: [
                                      _InfoChip(
                                        icon: Icons.calendar_today_rounded,
                                        label: a.anio != null
                                            ? 'Año ${a.anio}'
                                            : 'Año —',
                                      ),
                                      _InfoChip(
                                        icon: Icons.directions_car_filled_rounded,
                                        label: (a.placa?.isNotEmpty ?? false)
                                            ? a.placa!
                                            : 'S/N',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded,
                                color: Colors.white, size: 28),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _fullName(String? marca, String? modelo) {
    final name =
        '${marca ?? ''} ${modelo ?? ''}'.trim().replaceAll(RegExp(r'\s+'), ' ');
    return name.isEmpty ? 'Vehículo' : name;
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarImage extends StatelessWidget {
  final String url;
  const _CarImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF9575CD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.directions_car_rounded,
                  size: 52, color: Colors.white),
            ),
          ),
        ),
        // Degradado inferior para legibilidad sobre la imagen
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 60,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
        boxShadow: [
          BoxShadow(
            blurRadius: 80,
            spreadRadius: 20,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_car_filled_rounded,
              size: 56, color: theme.colorScheme.primary.withOpacity(0.7)),
          const SizedBox(height: 10),
          Text(
            'Aún no hay autos registrados.',
            style: theme.textTheme.titleMedium,
          ),
          Text(
            'Agrega un auto para empezar a registrar gasolina.',
            style:
                theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}
