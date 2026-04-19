import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:get/get.dart';

/// Splash screen StormeoOS affiché à l'ouverture de StormDesk
/// pendant que le service relay se connecte.
///
/// Design : gradient sky-300 → blue-600 diagonal, logo Stormeo,
/// animation radar (3 cercles concentriques expansifs), texte
/// "Connexion au réseau StormeoRelay…" avec points animés.
///
/// Disparaît automatiquement quand :
///   - Le service est `ready` (stateGlobal.svcStatus), OU
///   - Un timeout max de 5 secondes est atteint
/// Et au minimum 1.5s affiché pour laisser le temps de voir l'anim.
class SplashPage extends StatefulWidget {
  final Widget child;
  const SplashPage({Key? key, required this.child}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  static const Duration _minVisible = Duration(milliseconds: 1500);
  static const Duration _maxVisible = Duration(milliseconds: 5000);

  bool _hidden = false;
  Timer? _maxTimer;
  Timer? _minTimer;
  bool _minElapsed = false;
  StreamSubscription<SvcStatus>? _statusSub;
  late AnimationController _radarController;
  late AnimationController _logoController;
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _minTimer = Timer(_minVisible, () {
      _minElapsed = true;
      _maybeHide();
    });
    _maxTimer = Timer(_maxVisible, () {
      _minElapsed = true;
      _hide();
    });
    // Abonnement au stream Rx<SvcStatus> de GetX
    _statusSub = stateGlobal.svcStatus.listen((status) {
      if (status == SvcStatus.ready) _maybeHide();
    });
  }

  void _maybeHide() {
    if (_minElapsed && stateGlobal.svcStatus.value == SvcStatus.ready) {
      _hide();
    }
  }

  void _hide() {
    if (_hidden) return;
    setState(() => _hidden = true);
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _minTimer?.cancel();
    _maxTimer?.cancel();
    _radarController.dispose();
    _logoController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedOpacity(
          duration: const Duration(milliseconds: 450),
          opacity: _hidden ? 0 : 1,
          onEnd: () {
            // Retire complètement le splash du tree une fois le fade-out fini
          },
          child: IgnorePointer(
            ignoring: _hidden,
            child: _buildSplash(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSplash(BuildContext context) {
    // Material + DefaultTextStyle pour éviter les soulignements jaunes du debug Flutter
    // quand un Text n'a pas de parent Material/MaterialApp.
    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
          fontFamily: '.SF Pro Text',
        ),
        child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7DD3FC), // sky-300
            Color(0xFF38BDF8), // sky-400
            Color(0xFF2563EB), // blue-600
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ─── Radar + Logo ────────────────────────────────────
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildRadarRing(delay: 0.0),
                  _buildRadarRing(delay: 0.33),
                  _buildRadarRing(delay: 0.66),
                  // Logo avec breathing
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (ctx, _) {
                      final scale = 1.0 + (_logoController.value * 0.06);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/stormeo-logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.bolt_rounded,
                                      size: 56, color: Color(0xFF2563EB)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            // ─── Titre ──────────────────────────────────────────
            const Text(
              'StormDesk',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.0,
                shadows: [
                  Shadow(
                    color: Color(0x55000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'by Stormeo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            // ─── Loading text ───────────────────────────────────
            AnimatedBuilder(
              animation: _dotsController,
              builder: (ctx, _) {
                final nbDots = ((_dotsController.value * 3).floor() % 3) + 1;
                final dots = '.' * nbDots;
                return Text(
                  'Connexion au réseau StormeoRelay$dots',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ), // Column
      ), // Center
    ), // Container
        ), // DefaultTextStyle
      ), // Material
    );
  }

  Widget _buildRadarRing({required double delay}) {
    return AnimatedBuilder(
      animation: _radarController,
      builder: (ctx, _) {
        // Offset l'animation par delay
        double t = (_radarController.value + delay) % 1.0;
        // Ease-out pour l'expansion
        final eased = 1 - math.pow(1 - t, 2);
        final size = 80.0 + (140.0 * eased);
        final opacity = (1.0 - t).clamp(0.0, 1.0) * 0.7;
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(opacity),
              width: 2.5,
            ),
          ),
        );
      },
    );
  }
}
