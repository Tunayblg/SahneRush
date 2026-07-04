import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_background.dart';
import 'time_attack_countdown_screen.dart';

class TimeAttackIntroScreen extends StatefulWidget {
  final List<String> selectedSeriesIds;

  const TimeAttackIntroScreen({super.key, required this.selectedSeriesIds});

  @override
  State<TimeAttackIntroScreen> createState() => _TimeAttackIntroScreenState();
}

class _TimeAttackIntroScreenState extends State<TimeAttackIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _start() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            TimeAttackCountdownScreen(selectedSeriesIds: widget.selectedSeriesIds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => Opacity(
              opacity: _fade.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - _slide.value)),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Geri butonu
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color:
                                  AppColors.neonPurple.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: AppColors.textPrimary, size: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // İkon + başlık
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.pinkGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPink.withValues(alpha: 0.5),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 30),
                  ),

                  const SizedBox(height: 10),

                  ShaderMask(
                    shaderCallback: (b) =>
                        AppColors.pinkGradient.createShader(b),
                    child: const Text(
                      'TIME ATTACK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                  const Text(
                    'Zamanla yarış, doğrularla kazan!',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 18),

                  // Kural kartları
                  _RuleCard(
                    icon: Icons.timer_outlined,
                    iconColor: AppColors.neonCyan,
                    title: 'Başlangıç süresi: 8s',
                    desc: 'Süre bitmeden doğru cevapla, ilerle.',
                  ),
                  const SizedBox(height: 8),
                  _RuleCard(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.neonGreen,
                    title: 'Doğru cevap → +3 saniye',
                    desc: 'Her doğru cevap süreye 3 saniye ekler.',
                  ),
                  const SizedBox(height: 8),
                  _RuleCard(
                    icon: Icons.cancel_outlined,
                    iconColor: AppColors.neonRed,
                    title: 'Yanlış cevap → −1 saniye',
                    desc: 'Yanlış cevap 1 saniye götürür, dikkatli ol.',
                  ),
                  const SizedBox(height: 8),
                  _RuleCard(
                    icon: Icons.emoji_events_outlined,
                    iconColor: const Color(0xFFFFD700),
                    title: 'Tüm soruları bitir',
                    desc: 'Süre dolmadan tümünü tamamlarsan kazanırsın!',
                  ),

                  const SizedBox(height: 20),

                  // Başla butonu
                  GestureDetector(
                    onTap: _start,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.pinkGradient,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonPink.withValues(alpha: 0.45),
                            blurRadius: 18,
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 7),
                          Text(
                            'Başla',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;

  const _RuleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: iconColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
