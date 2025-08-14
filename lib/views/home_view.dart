import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // --- Fondo "fresco" con blobs suaves ---
        Positioned(
          top: -140,
          right: -100,
          child: _Blob(
            diameter: 360,
            color: (isDark ? Colors.tealAccent : Colors.teal)
                .withOpacity(isDark ? 0.10 : 0.08),
          ),
        ),
        Positioned(
          bottom: -160,
          left: -120,
          child: _Blob(
            diameter: 420,
            color:
                (isDark ? Colors.purpleAccent : Colors.deepPurple).withOpacity(
              isDark ? 0.10 : 0.07,
            ),
          ),
        ),

        // --- Contenido ---
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  
                  
                  const SizedBox(height: 28),

                  // Grid responsivo
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final crossAxisCount = w >= 900
                          ? 3
                          : w >= 620
                              ? 2
                              : 1;
                      // Tarjetas
                      final items = <_ActionData>[
                        _ActionData(
                          title: 'Gasolina',
                          subtitle: 'Registros y métricas',
                          icon: Icons.local_gas_station_rounded,
                          gradient: const [
                            Color(0xFF43A047),
                            Color(0xFF66BB6A),
                          ],
                          onTap: () => Navigator.pushNamed(context, '/gas'),
                        ),
                        _ActionData(
                          title: 'Mantenimientos',
                          subtitle: 'Bitácora y próximos servicios',
                          icon: Icons.build_rounded,
                          gradient: const [
                            Color(0xFFF57C00),
                            Color(0xFFFFB74D),
                          ],
                          onTap: () => Navigator.pushNamed(context, '/mant'),
                        ),
                        _ActionData(
                          title: 'Configuración',
                          subtitle: 'Preferencias de la app',
                          icon: Icons.settings_rounded,
                          gradient: const [
                            Color(0xFF6A1B9A),
                            Color(0xFF9575CD),
                          ],
                          onTap: () => Navigator.pushNamed(context, '/config'),
                        ),
                      ];

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          // Tarjeta panorámica, se ve bien en web y móvil
                          childAspectRatio: w >= 900
                              ? 2.6
                              : w >= 620
                                  ? 2.4
                                  : 2.8,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) => _ActionCard(data: items[i]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ------------------ Widgets de apoyo ------------------

class _ActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  _ActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}

class _ActionCard extends StatefulWidget {
  final _ActionData data;
  const _ActionCard({required this.data});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      scale: _hovering ? 1.02 : 1.0,
      child: Material(
        elevation: _hovering ? 8 : 3,
        shadowColor: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.data.onTap,
          onHover: (v) => setState(() => _hovering = v),
          splashColor: Colors.white.withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.data.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Row(
                children: [
                  // Icono en "chip" translúcido
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.data.icon,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Textos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.data.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.data.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
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
        // blur sutil tipo "frosted"
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
