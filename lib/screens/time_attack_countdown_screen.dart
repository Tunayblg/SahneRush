import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_background.dart';
import 'time_attack_screen.dart';

class TimeAttackCountdownScreen extends StatefulWidget {
  final List<String> selectedSeriesIds;
  const TimeAttackCountdownScreen({super.key, required this.selectedSeriesIds});

  @override
  State<TimeAttackCountdownScreen> createState() => _TimeAttackCountdownScreenState();
}

class _TimeAttackCountdownScreenState extends State<TimeAttackCountdownScreen>
    with TickerProviderStateMixin {
  int _count = 3;
  bool _showGo = false;
  Timer? _timer;

  late final AnimationController _bgCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _numberCtrl;
  late final Animation<double> _numberScale;
  late final Animation<double> _numberFade;
  late final AnimationController _ringCtrl;
  late final AnimationController _glowCtrl;
  // "TIME ATTACK!" patlama animasyonu — sadece GO! anında
  late final AnimationController _goLabelCtrl;
  late final Animation<double> _goLabelScale;
  late final Animation<double> _goLabelFade;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();

    _titleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();

    _numberCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _numberScale = Tween<double>(begin: 1.9, end: 1.0).animate(
      CurvedAnimation(parent: _numberCtrl, curve: Curves.easeOutBack));
    _numberFade = CurvedAnimation(parent: _numberCtrl, curve: Curves.easeOut);
    _numberCtrl.forward();

    _ringCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);

    _goLabelCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _goLabelScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _goLabelCtrl, curve: Curves.elasticOut));
    _goLabelFade = CurvedAnimation(parent: _goLabelCtrl, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _ringCtrl.forward();
      _startCountdown();
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_count <= 1) {
        _timer?.cancel();
        setState(() => _showGo = true);
        _numberCtrl.reset();
        _numberCtrl.forward();
        _goLabelCtrl.forward(); // "TIME ATTACK!" patlıyor
        Future.delayed(const Duration(milliseconds: 800), _navigate);
        return;
      }
      setState(() => _count--);
      _numberCtrl.reset();
      _numberCtrl.forward();
      _ringCtrl.reset();
      _ringCtrl.forward();
    });
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TimeAttackScreen(selectedSeriesIds: widget.selectedSeriesIds),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgCtrl.dispose();
    _titleCtrl.dispose();
    _numberCtrl.dispose();
    _ringCtrl.dispose();
    _glowCtrl.dispose();
    _goLabelCtrl.dispose();
    super.dispose();
  }

  Color get _countColor {
    if (_showGo) return Colors.white;
    if (_count <= 1) return AppColors.neonRed;
    if (_count == 2) return const Color(0xFFFFD700);
    return AppColors.neonGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SizedBox.expand(
          child: SafeArea(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut),
              child: Column(
                children: [
                  // ── Üst başlık (countdown sırasında göster) ─────────────
                  const SizedBox(height: 60),
                  AnimatedBuilder(
                    animation: _titleCtrl,
                    builder: (_, child) {
                      final slide = Tween<double>(begin: -40, end: 0)
                          .animate(CurvedAnimation(
                              parent: _titleCtrl, curve: Curves.easeOutCubic))
                          .value;
                      final fade = CurvedAnimation(
                              parent: _titleCtrl, curve: Curves.easeOut)
                          .value;
                      return Opacity(
                        opacity: (_showGo ? 0.0 : fade).clamp(0.0, 1.0),
                        child: Transform.translate(
                            offset: Offset(0, slide), child: child),
                      );
                    },
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.pinkGradient.createShader(b),
                          child: const Text(
                            'TIME ATTACK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Hazır mısın?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Orta: ring + sayı (veya GO!) ─────────────────────────
                  const Spacer(),
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_numberCtrl, _ringCtrl, _glowCtrl, _goLabelCtrl]),
                    builder: (_, _) {
                      final color = _countColor;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // "TIME ATTACK!" — sadece GO! anında patlar
                          if (_showGo)
                            Opacity(
                              opacity: _goLabelFade.value.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: _goLabelScale.value,
                                child: ShaderMask(
                                  shaderCallback: (b) =>
                                      AppColors.pinkGradient.createShader(b),
                                  child: const Text(
                                    'TIME ATTACK!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_showGo) const SizedBox(height: 28),

                          // Ring + sayı
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow
                              Container(
                                width: 240 + _glowCtrl.value * 20,
                                height: 240 + _glowCtrl.value * 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(
                                          alpha: 0.10 + _glowCtrl.value * 0.12),
                                      blurRadius: 80,
                                      spreadRadius: 28,
                                    ),
                                  ],
                                ),
                              ),

                              // Halka
                              SizedBox(
                                width: 220,
                                height: 220,
                                child: CustomPaint(
                                  painter: _RingPainter(
                                    progress: _showGo ? 1.0 : 1 - _ringCtrl.value,
                                    color: color,
                                  ),
                                ),
                              ),

                              // Sayı veya GO!
                              Transform.scale(
                                scale: _numberScale.value,
                                child: Opacity(
                                  opacity: _numberFade.value.clamp(0.0, 1.0),
                                  child: _showGo
                                      ? ShaderMask(
                                          shaderCallback: (b) =>
                                              AppColors.pinkGradient.createShader(b),
                                          child: const Text(
                                            'GO!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 76,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 4,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          '$_count',
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 140,
                                            fontWeight: FontWeight.w900,
                                            height: 1,
                                            shadows: [
                                              Shadow(color: color, blurRadius: 40),
                                              Shadow(color: color, blurRadius: 80),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(),

                  // ── Alt bilgi ─────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _titleCtrl,
                    builder: (_, child) => Opacity(
                      opacity: (_showGo
                              ? 0.0
                              : CurvedAnimation(
                                      parent: _titleCtrl, curve: Curves.easeOut)
                                  .value)
                          .clamp(0.0, 1.0),
                      child: child,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bolt_rounded,
                              color: AppColors.neonCyan, size: 15),
                          SizedBox(width: 6),
                          Text(
                            '8 saniye ile başlıyorsun',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
