import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_background.dart';
import '../widgets/primary_button.dart';
import '../models/game_mode.dart';
import 'series_selection_screen.dart';
import 'leaderboard_screen.dart';

const _kBgImages = [
  'assets/images/gorseller/friends/central_park.jpg',
  'assets/images/gorseller/aot/devtitan.jpg',
  'assets/images/gorseller/himym/yellowumbrella.jpg',
  'assets/images/gorseller/got/iron_throne.jpg',
  'assets/images/gorseller/friends/the_routine.jpg',
  'assets/images/gorseller/aot/beasttitan.jpg',
  'assets/images/gorseller/himym/nakedman.jpg',
  'assets/images/gorseller/got/winterfell.jpg',
  'assets/images/gorseller/friends/hugsy.jpg',
  'assets/images/gorseller/aot/wallmaria.jpg',
  'assets/images/gorseller/himym/brocode_barney.jpg',
  'assets/images/gorseller/got/red_wedding.jpg',
  'assets/images/gorseller/friends/unagi.jpg',
  'assets/images/gorseller/aot/femaletitan.jpg',
  'assets/images/gorseller/himym/pumpkin.jpg',
  'assets/images/gorseller/got/battle_of_bastards.jpg',
  'assets/images/gorseller/friends/marcel.jpg',
  'assets/images/gorseller/aot/eren_key.jpg',
  'assets/images/gorseller/himym/swarley.jpg',
  'assets/images/gorseller/got/joffrey_wedding.jpg',
];

// Her emoji ekrandan geçer: sol↔sağ, yay çizerek, fade in/out
class _EmojiItem {
  final String emoji;
  final double phase;   // döngü içi faz (0–1)
  final double yFrac;   // ekran yüksekliğinin kaçta biri
  final double arcPx;   // dikey yay (pozitif = aşağı, negatif = yukarı)
  final double size;
  final bool rtl;       // sağdan sola mı geçiyor
  const _EmojiItem(this.emoji, this.phase, this.yFrac, this.arcPx, this.size, this.rtl);
}

const _kEmojiItems = [
  _EmojiItem('🍍', 0.00, 0.18,  40.0, 26.0, false), // HIMYM pineapple
  _EmojiItem('👑', 0.17, 0.12,  20.0, 22.0, true),  // GoT crown
  _EmojiItem('☕', 0.33, 0.72, -30.0, 20.0, false), // Friends coffee
  _EmojiItem('⚔️', 0.50, 0.38,  50.0, 24.0, true),  // AoT swords
  _EmojiItem('🍺', 0.67, 0.82, -20.0, 19.0, false), // HIMYM beer
  _EmojiItem('🐉', 0.83, 0.55,  35.0, 21.0, true),  // GoT dragon
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _logoEntry;
  late final Animation<double> _subtitleEntry;
  late final Animation<double> _buttonsEntry;
  late final Animation<double> _strip1Entry;
  late final Animation<double> _strip2Entry;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;

  late final AnimationController _floatCtrl;  // orbs + emoji geçişi (12s)
  late final AnimationController _stripCtrl;  // film şeridi (22s)

  String _typedText = '';
  final String _fullText = 'Dizi. Film. Karakter. Efsane.';
  bool _showCursor = true;
  Timer? _typingTimer;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _strip1Entry  = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0,  0.45, curve: Curves.easeOut));
    _strip2Entry  = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.1,  0.55, curve: Curves.easeOut));
    _logoEntry    = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.2,  0.65, curve: Curves.easeOutBack));
    _subtitleEntry= CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.35, 0.75, curve: Curves.easeOut));
    _buttonsEntry = CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.55, 1.0,  curve: Curves.easeOut));
    _entryCtrl.forward();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _pulseScale = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseCtrl.repeat(reverse: true);

    // Emoji'ler 12s'de bir tam tur → 6 emoji her 2s'de bir geçiyor gibi görünür
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12));
    _floatCtrl.repeat();

    // Film şeridi 22s'de bir tam tur
    _stripCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 22));
    _stripCtrl.repeat();

    _cursorTimer = Timer.periodic(const Duration(milliseconds: 480), (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
    Future.delayed(const Duration(milliseconds: 700), _startTyping);
    AudioService.instance.startBgMusic();
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Ayarlar', style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 22),
              _SettingRow(
                icon: Icons.music_note_rounded,
                label: 'Müzik',
                value: AudioService.instance.musicOn,
                onTap: () async {
                  await AudioService.instance.toggleMusic();
                  setSheet(() {});
                },
              ),
              const SizedBox(height: 12),
              _SettingRow(
                icon: Icons.volume_up_rounded,
                label: 'Ses Efektleri',
                value: AudioService.instance.sfxOn,
                onTap: () async {
                  await AudioService.instance.toggleSfx();
                  setSheet(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startTyping() {
    var i = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 58), (t) {
      if (!mounted) { t.cancel(); return; }
      if (i >= _fullText.length) { t.cancel(); return; }
      setState(() => _typedText = _fullText.substring(0, ++i));
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _stripCtrl.dispose();
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // ── Ayarlar butonu ────────────────────────────────────────────
              Positioned(
                top: 8,
                right: 16,
                child: GestureDetector(
                  onTap: _showSettings,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.neonPurple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // ── Film şeridi 1: soldan sağa (yazının üstü) ───────────────
              Positioned(
                top: size.height * 0.06,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _strip1Entry,
                  builder: (_, child) => Opacity(
                    opacity: (_strip1Entry.value * 0.30).clamp(0.0, 0.30),
                    child: Transform.translate(
                      offset: Offset(-60 * (1 - _strip1Entry.value), 0),
                      child: child,
                    ),
                  ),
                  child: _FilmStrip(controller: _stripCtrl, images: _kBgImages, rtl: false),
                ),
              ),

              // ── Film şeridi 2: sağdan sola (yazının altı) ───────────────
              Positioned(
                top: size.height * 0.58,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _strip2Entry,
                  builder: (_, child) => Opacity(
                    opacity: (_strip2Entry.value * 0.25).clamp(0.0, 0.25),
                    child: Transform.translate(
                      offset: Offset(60 * (1 - _strip2Entry.value), 0),
                      child: child,
                    ),
                  ),
                  child: _FilmStrip(controller: _stripCtrl, images: _kBgImages, rtl: true),
                ),
              ),

              // ── Glow orbs + emoji'ler ──────────────────────────────────
              AnimatedBuilder(
                animation: _floatCtrl,
                builder: (context, _) {
                  final t = _floatCtrl.value;

                  return Stack(
                    children: [
                      // Glow orbs (hafif dalgalanma)
                      Positioned(
                        top: 40 + sin(t * 2 * pi) * 22,
                        right: -55,
                        child: const _GlowOrb(color: AppColors.neonPurple, size: 220),
                      ),
                      Positioned(
                        bottom: 90 + sin((t + 0.4) * 2 * pi) * 18,
                        left: -60,
                        child: const _GlowOrb(color: AppColors.neonPink, size: 170),
                      ),
                      Positioned(
                        top: 280 + sin((t + 0.7) * 2 * pi) * 28,
                        left: -20,
                        child: const _GlowOrb(color: AppColors.neonBlue, size: 100),
                      ),
                      Positioned(
                        bottom: 280 + sin((t + 0.2) * 2 * pi) * 14,
                        right: 20,
                        child: const _GlowOrb(color: AppColors.neonCyan, size: 70),
                      ),

                      // Floating emoji'ler — ekrandan geçer
                      for (final item in _kEmojiItems)
                        Builder(builder: (context) {
                          // Her emoji kendi fazını kullanır (0–1 döngü)
                          final local = ((t + item.phase) % 1.0);

                          // x: sol→sağ veya sağ→sol
                          final x = item.rtl
                              ? size.width * (1.0 - local) - 30
                              : size.width * local - 20;

                          // y: sabit başlangıç + yay (sin ile doğal eğri)
                          final y = size.height * item.yFrac +
                              item.arcPx * sin(local * pi);

                          // Opacity: ortada tam görünür, kenarlarda solar
                          final opacity = (sin(local * pi) * 0.22).clamp(0.0, 0.22);

                          return Positioned(
                            left: x,
                            top: y,
                            child: Opacity(
                              opacity: opacity,
                              child: Text(
                                item.emoji,
                                style: TextStyle(fontSize: item.size),
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),

              // ── Ana içerik ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo
                    AnimatedBuilder(
                      animation: Listenable.merge([_logoEntry, _pulseScale]),
                      builder: (context, child) => Opacity(
                        opacity: _logoEntry.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - _logoEntry.value)),
                          child: Transform.scale(scale: _pulseScale.value, child: child),
                        ),
                      ),
                      child: const _Logo(),
                    ),

                    const SizedBox(height: 22),

                    // Typing subtitle
                    AnimatedBuilder(
                      animation: _subtitleEntry,
                      builder: (context, _) => Opacity(
                        opacity: _subtitleEntry.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - _subtitleEntry.value)),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _typedText,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                    letterSpacing: 0.8,
                                    height: 1.4,
                                  ),
                                ),
                                TextSpan(
                                  text: (_showCursor && _typedText.length < _fullText.length) ? '|' : '',
                                  style: const TextStyle(
                                    color: AppColors.neonPurple,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Butonlar
                    AnimatedBuilder(
                      animation: _buttonsEntry,
                      builder: (context, child) => Opacity(
                        opacity: _buttonsEntry.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 35 * (1 - _buttonsEntry.value)),
                          child: child,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  label: '▶  Normal',
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SeriesSelectionScreen(
                                        gameMode: GameMode.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PrimaryButton(
                                  label: '⚡ Time Attack',
                                  gradient: AppColors.pinkGradient,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SeriesSelectionScreen(
                                        gameMode: GameMode.timeAttack,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          PrimaryButton(
                            label: 'Skor Tablosu',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00BCD4), Color(0xFF3498DB)],
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Film şeridi ───────────────────────────────────────────────────────────────
class _FilmStrip extends StatelessWidget {
  final AnimationController controller;
  final List<String> images;
  final bool rtl;

  static const double _imgW = 92.0;
  static const double _imgH = 68.0;
  static const double _gap  = 6.0;
  static const double _itemW = _imgW + _gap;

  const _FilmStrip({required this.controller, required this.images, required this.rtl});

  @override
  Widget build(BuildContext context) {
    final stripW = images.length * _itemW;

    return SizedBox(
      height: _imgH,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final t = rtl ? (1.0 - controller.value) : controller.value;
            final dx = -(t * stripW);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (int i = 0; i < images.length * 2; i++)
                  Positioned(
                    left: dx + i * _itemW,
                    top: 0,
                    width: _imgW,
                    height: _imgH,
                    child: _StripFrame(path: images[i % images.length]),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StripFrame extends StatelessWidget {
  final String path;
  const _StripFrame({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _FilmStrip._imgW,
      height: _FilmStrip._imgH,
      margin: const EdgeInsets.only(right: _FilmStrip._gap),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: AppColors.card),
          ),
        ),
      ),
    );
  }
}

// ── Logo ─────────────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50, height: 3,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
            boxShadow: const [BoxShadow(color: AppColors.neonPurple, blurRadius: 12)],
          ),
        ),
        const SizedBox(height: 14),
        ShaderMask(
          shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
          child: const Text(
            'SAHNE',
            style: TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.w900, letterSpacing: 9, height: 1.0),
          ),
        ),
        ShaderMask(
          shaderCallback: (b) => AppColors.pinkGradient.createShader(b),
          child: const Text(
            'RUSH',
            style: TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.w900, letterSpacing: 9, height: 1.0),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 50, height: 3,
          decoration: BoxDecoration(
            gradient: AppColors.pinkGradient,
            borderRadius: BorderRadius.circular(2),
            boxShadow: const [BoxShadow(color: AppColors.neonPink, blurRadius: 12)],
          ),
        ),
      ],
    );
  }
}

// ── Ayar satırı ──────────────────────────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? AppColors.neonPurple.withValues(alpha: 0.5)
                : AppColors.textMuted.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: value ? AppColors.neonPurple : AppColors.textMuted, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(
                color: value ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              )),
            ),
            Container(
              width: 44, height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: value
                    ? AppColors.neonPurple.withValues(alpha: 0.25)
                    : AppColors.textMuted.withValues(alpha: 0.12),
                border: Border.all(
                  color: value
                      ? AppColors.neonPurple.withValues(alpha: 0.6)
                      : AppColors.textMuted.withValues(alpha: 0.3),
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? AppColors.neonPurple : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glow orb ─────────────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}
