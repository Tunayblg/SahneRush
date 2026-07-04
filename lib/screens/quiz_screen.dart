import 'dart:async';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../data/series_data.dart';
import '../models/quiz_question.dart';
import '../services/audio_service.dart';
import '../services/quiz_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_button.dart';
import '../widgets/neon_background.dart';
import '../widgets/quiz_image_card.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<String> selectedSeriesIds;

  const QuizScreen({
    super.key,
    required this.selectedSeriesIds,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizEngine _engine;
  Timer? _timer;
  int _remainingSeconds = secondsPerQuestion;
  int? _selectedIndex;
  bool _answered = false;
  bool _transitioning = false;

  // Cevap sonrası eski soruyu kilitleyerek 'bleed-through' bug'ını engeller.
  QuizQuestion? _displayedQuestion;

  // Görüntülenen soru numarası (1-indexed). Engine index'ten bağımsız takip edilir.
  int _questionNumber = 1;

  double _flashOpacity = 0.0;
  Color _flashColor = AppColors.neonGreen;
  int _earnedPoints = 0;
  bool _showPointsPopup = false;

  @override
  void initState() {
    super.initState();
    _engine = QuizEngine(selectedSeriesIds: widget.selectedSeriesIds);
    if (_engine.totalQuestions == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showNoQuestionsDialog());
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        _handleTimeout();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _handleTimeout() {
    if (_answered || _transitioning) return;
    final locked = _engine.currentQuestion;
    _engine.submitAnswer(-1, 0);
    setState(() {
      _displayedQuestion = locked;
      _answered = true;
      _selectedIndex = -1;
      _earnedPoints = 0;
      _showPointsPopup = false;
    });
    _doTransition(isCorrect: false);
  }

  void _onAnswer(int index) {
    if (_answered || _transitioning) return;
    _timer?.cancel();

    // Mevcut soruyu kilitle — engine index'i hemen artırıyor.
    final locked = _engine.currentQuestion;
    final isCorrect = index == locked.correctIndex;
    final earned = _engine.submitAnswer(index, _remainingSeconds);

    setState(() {
      _displayedQuestion = locked;
      _answered = true;
      _selectedIndex = index;
      _earnedPoints = earned;
      _showPointsPopup = isCorrect;
    });
    if (isCorrect) {
      AudioService.instance.playCorrect();
    } else {
      AudioService.instance.playWrong();
    }
    _doTransition(isCorrect: isCorrect);
  }

  void _doTransition({required bool isCorrect}) {
    _transitioning = true;
    _flashColor = isCorrect ? AppColors.neonGreen : AppColors.neonRed;

    // 750ms feedback → neon flash → yeni soru
    Future.delayed(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      setState(() => _flashOpacity = 1.0);

      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        setState(() => _flashOpacity = 0.0);

        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          _transitioning = false;
          if (_engine.isFinished) {
            _goToResult();
            return;
          }
          setState(() {
            _displayedQuestion = null;
            _answered = false;
            _selectedIndex = null;
            _showPointsPopup = false;
            _earnedPoints = 0;
            _remainingSeconds = secondsPerQuestion;
            _questionNumber++;
          });
          _startTimer();
        });
      });
    });
  }

  void _goToResult() {
    final titles = widget.selectedSeriesIds.map((id) {
      return allSeries.firstWhere((s) => s.id == id).title;
    }).toList();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: _engine.score,
          correctAnswers: _engine.correctCount,
          totalQuestions: _engine.totalQuestions,
          selectedSeriesTitles: titles,
        ),
      ),
    );
  }

  void _showNoQuestionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Yeterli Soru Yok',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Seçilen dizilerde yeterli soru bulunamadı.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Geri Dön',
                style: TextStyle(color: AppColors.neonPurple)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_engine.totalQuestions == 0) {
      return const Scaffold(body: NeonBackground(child: SizedBox.shrink()));
    }

    final question = _displayedQuestion ?? _engine.currentQuestion;
    final progress = _remainingSeconds / secondsPerQuestion;

    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // ── Ana içerik ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _TopBar(
                      current: _questionNumber,
                      total: _engine.totalQuestions,
                      score: _engine.score,
                      streak: _engine.streak,
                    ),
                    const SizedBox(height: 10),
                    _TimerBar(progress: progress, remaining: _remainingSeconds),
                    const SizedBox(height: 18),
                    // Görsel + soru metni — geçişte fade
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: _QuestionContent(
                        key: ValueKey(question.id),
                        imagePath: question.imagePath,
                        questionText: question.questionText,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Şıklar — geçişte fade
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: _AnswerList(
                          key: ValueKey('answers_${question.id}'),
                          options: question.options,
                          correctIndex: question.correctIndex,
                          selectedIndex: _selectedIndex,
                          answered: _answered,
                          onAnswer: _onAnswer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // ── Neon flash overlay ──────────────────────────────────────
              AnimatedOpacity(
                opacity: _flashOpacity,
                duration: const Duration(milliseconds: 120),
                child: IgnorePointer(
                  child: Container(
                    color: _flashColor.withValues(alpha: 0.2),
                  ),
                ),
              ),

              // ── Floating puan popup ─────────────────────────────────────
              if (_showPointsPopup && _earnedPoints > 0)
                Positioned(
                  bottom: 220,
                  left: 0,
                  right: 0,
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('popup_$_questionNumber'),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (_, t, _) {
                      final dy = -65.0 * Curves.easeOut.transform(t);
                      final opacity =
                          (t < 0.5 ? 1.0 : (1.0 - t) * 2.0).clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: Opacity(
                          opacity: opacity,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.neonGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: AppColors.neonGreen
                                        .withValues(alpha: 0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonGreen
                                        .withValues(alpha: 0.3),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                '+$_earnedPoints',
                                style: const TextStyle(
                                  color: AppColors.neonGreen,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.neonGreen,
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Soru görseli + metni ──────────────────────────────────────────────────────
class _QuestionContent extends StatelessWidget {
  final String imagePath;
  final String questionText;

  const _QuestionContent({
    super.key,
    required this.imagePath,
    required this.questionText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuizImageCard(imagePath: imagePath),
        const SizedBox(height: 14),
        Text(
          questionText,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Şık listesi ───────────────────────────────────────────────────────────────
class _AnswerList extends StatelessWidget {
  final List<String> options;
  final int correctIndex;
  final int? selectedIndex;
  final bool answered;
  final void Function(int) onAnswer;

  const _AnswerList({
    super.key,
    required this.options,
    required this.correctIndex,
    required this.selectedIndex,
    required this.answered,
    required this.onAnswer,
  });

  AnswerState _stateFor(int i) {
    if (!answered) return AnswerState.idle;
    if (i == correctIndex) return AnswerState.correct;
    if (i == selectedIndex) return AnswerState.wrong;
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          AnswerButton(
            index: i,
            label: options[i],
            state: _stateFor(i),
            onPressed: answered ? null : () => onAnswer(i),
          ),
        ],
      ],
    );
  }
}

// ── Üst bar ───────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int current;
  final int total;
  final int score;
  final int streak;

  const _TopBar({
    required this.current,
    required this.total,
    required this.score,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Soru sayacı — pill badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.neonPurple.withValues(alpha: 0.35)),
          ),
          child: Text(
            '${current.toString().padLeft(2, '0')} / $total',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),

        // Streak badge
        if (streak >= 2)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.neonPink.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neonPink.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPink.withValues(alpha: 0.25),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              '🔥 $streak',
              style: const TextStyle(
                color: AppColors.neonPink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

        // Skor — animasyonlu geçiş
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, -0.5), end: Offset.zero)
                .animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Text(
            '$score',
            key: ValueKey(score),
            style: const TextStyle(
              color: AppColors.neonCyan,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              shadows: [Shadow(color: AppColors.neonCyan, blurRadius: 10)],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Timer bar ─────────────────────────────────────────────────────────────────
class _TimerBar extends StatelessWidget {
  final double progress;
  final int remaining;

  const _TimerBar({required this.progress, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final isLow = remaining <= 4;
    final isMid = remaining <= 8 && remaining > 4;
    final color = isLow
        ? AppColors.neonRed
        : isMid
            ? const Color(0xFFFFD700)
            : AppColors.neonGreen;

    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: isLow
                ? [
                    BoxShadow(
                      color: AppColors.neonRed.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.card,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: color,
              fontSize: isLow ? 15 : 12,
              fontWeight: isLow ? FontWeight.w800 : FontWeight.w600,
              shadows: isLow
                  ? [Shadow(color: color, blurRadius: 8)]
                  : null,
            ),
            child: Text('${remaining}s'),
          ),
        ),
      ],
    );
  }
}
