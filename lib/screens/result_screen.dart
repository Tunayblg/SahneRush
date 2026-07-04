import 'package:flutter/material.dart';
import '../models/player_score.dart';
import '../services/audio_service.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/score_card.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';
import 'series_selection_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final List<String> selectedSeriesTitles;

  const ResultScreen({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.selectedSeriesTitles,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _nameController = TextEditingController();
  bool _saved = false;
  bool _saving = false;
  bool _hasName = false;

  @override
  void initState() {
    super.initState();
    AudioService.instance.playWin();
    _nameController.addListener(() {
      setState(() => _hasName = _nameController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveScore() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    await LeaderboardService().saveScore(PlayerScore(
      playerName: name,
      score: widget.score,
      correctAnswers: widget.correctAnswers,
      totalQuestions: widget.totalQuestions,
      selectedSeriesTitles: widget.selectedSeriesTitles,
      dateTime: DateTime.now(),
    ));
    if (mounted) setState(() { _saving = false; _saved = true; });
  }

  String get _grade {
    final ratio = widget.correctAnswers / widget.totalQuestions;
    if (ratio >= 0.9) return '🏆 Efsane!';
    if (ratio >= 0.7) return '⭐ Harika!';
    if (ratio >= 0.5) return '👍 İyi!';
    return '💪 Daha iyi olacak!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  _grade,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Büyük skor kartı ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.neonPurple.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPurple.withValues(alpha: 0.2),
                        blurRadius: 24,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (b) =>
                            AppColors.primaryGradient.createShader(b),
                        child: Text(
                          '${widget.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 68,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Text(
                        'PUAN',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── İstatistik satırı ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ScoreCard(
                        label: 'Doğru',
                        value: '${widget.correctAnswers}',
                        accentColor: AppColors.neonGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ScoreCard(
                        label: 'Yanlış',
                        value:
                            '${widget.totalQuestions - widget.correctAnswers}',
                        accentColor: AppColors.neonRed,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ScoreCard(
                        label: 'Toplam',
                        value: '${widget.totalQuestions}',
                        accentColor: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SeriesChips(titles: widget.selectedSeriesTitles),

                // ── Skor kaydetme bölümü ───────────────────────────────
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _saved
                      ? _SavedBanner(key: const ValueKey('saved'))
                      : _SaveSection(
                          key: const ValueKey('save'),
                          controller: _nameController,
                          hasName: _hasName,
                          saving: _saving,
                          onSave: _saveScore,
                        ),
                ),

                // ── Aksiyon butonları ──────────────────────────────────
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Tekrar Oyna',
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (r) => false,
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Dizi Seçimine Dön',
                  gradient: AppColors.pinkGradient,
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const SeriesSelectionScreen()),
                    (r) => r.isFirst,
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Skor Tablosu',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00BCD4), Color(0xFF3498DB)],
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen()),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Kaydetme formu ────────────────────────────────────────────────────────────
class _SaveSection extends StatelessWidget {
  final TextEditingController controller;
  final bool hasName;
  final bool saving;
  final VoidCallback onSave;

  const _SaveSection({
    super.key,
    required this.controller,
    required this.hasName,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skoru Kaydet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'İsim girerek skor tablosuna ekle.',
            style:
                TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.neonPurple.withValues(alpha: 0.4)),
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onSave(),
                    decoration: const InputDecoration(
                      hintText: 'Adın...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppColors.neonPurple, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: (hasName && !saving) ? onSave : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: (hasName && !saving)
                        ? AppColors.primaryGradient
                        : const LinearGradient(
                            colors: [Color(0xFF3A3A5C), Color(0xFF2A2A4A)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: (hasName && !saving)
                        ? [
                            BoxShadow(
                              color: AppColors.neonPurple.withValues(alpha: 0.4),
                              blurRadius: 16,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_rounded,
                            color: Colors.white, size: 22),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Kaydedildi banner ─────────────────────────────────────────────────────────
class _SavedBanner extends StatelessWidget {
  const _SavedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.neonGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.neonGreen.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.12),
            blurRadius: 16,
          )
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              color: AppColors.neonGreen, size: 22),
          SizedBox(width: 8),
          Text(
            'Skor tablosuna kaydedildi!',
            style: TextStyle(
              color: AppColors.neonGreen,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dizi chip'leri ────────────────────────────────────────────────────────────
class _SeriesChips extends StatelessWidget {
  final List<String> titles;

  const _SeriesChips({required this.titles});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: titles
          .map(
            (t) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neonPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.neonPurple.withValues(alpha: 0.35)),
              ),
              child: Text(
                t,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
