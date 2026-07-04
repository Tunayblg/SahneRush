import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/time_attack_score_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_background.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';
import 'series_selection_screen.dart';
import '../models/game_mode.dart';

class TimeAttackResultScreen extends StatefulWidget {
  final int score;
  final int correctCount;
  final int totalAnswered;
  final int totalQuestions;
  final bool allDone;
  final List<String> selectedSeriesIds;

  const TimeAttackResultScreen({
    super.key,
    required this.score,
    required this.correctCount,
    required this.totalAnswered,
    required this.totalQuestions,
    required this.allDone,
    required this.selectedSeriesIds,
  });

  @override
  State<TimeAttackResultScreen> createState() => _TimeAttackResultScreenState();
}

class _TimeAttackResultScreenState extends State<TimeAttackResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double>   _scaleAnim;
  late final Animation<double>   _fadeAnim;

  final _nameCtrl = TextEditingController();
  bool _hasName   = false;
  bool _saved     = false;
  bool _saving    = false;

  List<TAScore> _topScores  = [];
  bool _scoresLoaded        = false;

  static const _medals = ['🥇', '🥈', '🥉', '4.', '5.'];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack);
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entryCtrl.forward();

    if (widget.allDone) AudioService.instance.playWin();

    _nameCtrl.addListener(
        () => setState(() => _hasName = _nameCtrl.text.trim().isNotEmpty));

    _loadName();
    _loadLeaderboard();
  }

  Future<void> _loadName() async {
    final saved = await TimeAttackScoreService.getSavedName();
    if (saved != null && saved.isNotEmpty && mounted) {
      _nameCtrl.text = saved;
    }
  }

  Future<void> _loadLeaderboard() async {
    final top = await TimeAttackScoreService.getTop();
    if (mounted) setState(() { _topScores = top; _scoresLoaded = true; });
  }

  Future<void> _saveScore() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _saved) return;
    setState(() => _saving = true);
    final top = await TimeAttackScoreService.saveAndGetTop(name, widget.score);
    if (mounted) {
      setState(() { _saving = false; _saved = true; _topScores = top; });
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  String get _headline =>
      widget.allDone ? '🎉 Tebrikler!' : '⏱ Süre Bitti!';
  Color get _headlineColor =>
      widget.allDone ? AppColors.neonGreen : AppColors.neonRed;

  bool get _isNewRecord =>
      _saved &&
      _topScores.isNotEmpty &&
      _topScores.first.score == widget.score &&
      _topScores.first.name == _nameCtrl.text.trim();

  @override
  Widget build(BuildContext context) {
    final wrongCount = widget.totalAnswered - widget.correctCount;

    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: AnimatedBuilder(
              animation: _entryCtrl,
              builder: (_, child) => Opacity(
                opacity: _fadeAnim.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.88 + 0.12 * _scaleAnim.value,
                  child: child,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 6),

                  // ── Mod etiketi ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neonPink.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.neonPink.withValues(alpha: 0.45)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: AppColors.neonPink, size: 14),
                        SizedBox(width: 5),
                        Text('TIME ATTACK', style: TextStyle(
                          color: AppColors.neonPink,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Başlık ─────────────────────────────────────────────
                  Text(_headline, style: TextStyle(
                    color: _headlineColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: _headlineColor, blurRadius: 20)],
                  )),
                  if (_isNewRecord) ...[
                    const SizedBox(height: 3),
                    const Text('🔥 Yeni rekor!', style: TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
                  ],

                  const SizedBox(height: 16),

                  // ── Skor — sol hizalı ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.neonPink.withValues(alpha: 0.4)),
                      boxShadow: [BoxShadow(
                        color: AppColors.neonPink.withValues(alpha: 0.18),
                        blurRadius: 28,
                      )],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.pinkGradient.createShader(b),
                          child: Text('${widget.score}', style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          )),
                        ),
                        const SizedBox(width: 12),
                        const Text('PUAN', style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Stat kartları ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        value: '${widget.correctCount}',
                        label: 'Doğru',
                        color: AppColors.neonGreen,
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(
                        value: '$wrongCount',
                        label: 'Yanlış',
                        color: AppColors.neonRed,
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(
                        value: '${widget.totalAnswered}',
                        subValue: '/ ${widget.totalQuestions}',
                        label: 'Cevaplanan',
                        color: AppColors.neonCyan,
                      )),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── İsim girişi + Kaydet ───────────────────────────────
                  if (!_saved) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.neonPurple.withValues(alpha: 0.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Skoru kaydet', style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          )),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameCtrl,
                                  maxLength: 16,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Adın...',
                                    hintStyle: const TextStyle(
                                        color: AppColors.textMuted),
                                    counterText: '',
                                    filled: true,
                                    fillColor: AppColors.background
                                        .withValues(alpha: 0.6),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: _hasName && !_saving ? _saveScore : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 13),
                                  decoration: BoxDecoration(
                                    gradient: _hasName
                                        ? AppColors.pinkGradient
                                        : const LinearGradient(colors: [
                                            Color(0xFF3A3A5C),
                                            Color(0xFF2A2A4A)
                                          ]),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: _saving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ))
                                      : Text('Kaydet', style: TextStyle(
                                          color: _hasName
                                              ? Colors.white
                                              : AppColors.textMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        )),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Leaderboard ────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: AppColors.neonPurple.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.emoji_events_rounded,
                                color: AppColors.neonCyan, size: 16),
                            SizedBox(width: 7),
                            Text('EN İYİ 5 SKOR', style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (!_scoresLoaded)
                          const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)))
                        else if (_topScores.isEmpty)
                          const Text('Henüz kayıtlı skor yok.',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13))
                        else
                          ...List.generate(_topScores.length, (i) {
                            final s = _topScores[i];
                            final isCurrent = _saved &&
                                s.score == widget.score &&
                                s.name == _nameCtrl.text.trim() &&
                                _topScores.indexWhere((x) =>
                                        x.score == widget.score &&
                                        x.name == _nameCtrl.text.trim()) ==
                                    i;
                            return _ScoreRow(
                              medal: _medals[i],
                              name: s.name,
                              score: s.score,
                              isCurrent: isCurrent,
                            );
                          }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Butonlar ───────────────────────────────────────────
                  PrimaryButton(
                    label: '⚡  Tekrar Oyna',
                    gradient: AppColors.pinkGradient,
                    onPressed: () =>
                        Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => SeriesSelectionScreen(
                              gameMode: GameMode.timeAttack)),
                      (r) => false,
                    ),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Ana Sayfa',
                    onPressed: () =>
                        Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const HomeScreen()),
                      (r) => false,
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

class _StatCard extends StatelessWidget {
  final String value;
  final String? subValue;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    this.subValue,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1,
          )),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(subValue!, style: TextStyle(
              color: color.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            )),
          ],
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          )),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String medal;
  final String name;
  final int score;
  final bool isCurrent;

  const _ScoreRow({
    required this.medal,
    required this.name,
    required this.score,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.neonPink.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? AppColors.neonPink.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
              width: 30,
              child: Text(medal, style: const TextStyle(fontSize: 15))),
          Expanded(
            child: Text(name, style: TextStyle(
              color: isCurrent ? AppColors.neonPink : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
            )),
          ),
          Text('$score puan', style: TextStyle(
            color: isCurrent ? AppColors.neonPink : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          )),
        ],
      ),
    );
  }
}
