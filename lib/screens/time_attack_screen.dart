import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/question_data.dart';
import '../models/quiz_question.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_button.dart';
import '../widgets/neon_background.dart';
import '../widgets/quiz_image_card.dart';
import 'time_attack_result_screen.dart';

class TimeAttackScreen extends StatefulWidget {
  final List<String> selectedSeriesIds;

  const TimeAttackScreen({super.key, required this.selectedSeriesIds});

  @override
  State<TimeAttackScreen> createState() => _TimeAttackScreenState();
}

class _TimeAttackScreenState extends State<TimeAttackScreen>
    with SingleTickerProviderStateMixin {
  static const double _startSeconds   = 8.0;
  static const double _correctBonus  = 3.0;
  static const double _wrongPenalty  = 1.0;
  static const int    _pointsCorrect = 10;

  late final List<QuizQuestion> _questions;
  int    _currentIndex    = 0;
  double _remainingSeconds = _startSeconds;
  int    _score           = 0;
  int    _correctCount    = 0;
  bool   _answered        = false;
  int?   _selectedIndex;
  Timer? _timer;
  bool   _dead            = false;

  // bonus popup
  String _bonusText  = '';
  Color  _bonusColor = AppColors.neonGreen;
  bool   _showBonus  = false;

  // shake animation when low time
  late final AnimationController _shakeCtrl;
  late final Animation<double>   _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );

    final pool = allQuestions
        .where((q) => widget.selectedSeriesIds.contains(q.seriesId))
        .toList()
      ..shuffle();
    _questions = pool;

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _dead) return;
      setState(() {
        _remainingSeconds = (_remainingSeconds - 0.1).clamp(0.0, 99.9);
        if (_remainingSeconds <= 0) _end(allDone: false);
      });
    });
  }

  void _onAnswer(int index) {
    if (_answered || _dead) return;
    final q = _questions[_currentIndex];
    final isCorrect = index == q.correctIndex;

    if (isCorrect) {
      AudioService.instance.playCorrect();
    } else {
      AudioService.instance.playWrong();
    }
    setState(() {
      _answered      = true;
      _selectedIndex = index;
      if (isCorrect) {
        _score          += _pointsCorrect;
        _correctCount   += 1;
        _remainingSeconds = min(_remainingSeconds + _correctBonus, 99.9);
        _bonusText  = '+${_correctBonus.toStringAsFixed(0)}s';
        _bonusColor = AppColors.neonGreen;
      } else {
        _remainingSeconds = max(_remainingSeconds - _wrongPenalty, 0.0);
        _bonusText  = '-${_wrongPenalty.toStringAsFixed(0)}s';
        _bonusColor = AppColors.neonRed;
        if (_remainingSeconds <= 0) {
          _showBonus = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _end(allDone: false);
          });
          return;
        }
      }
      _showBonus = true;
    });

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted || _dead) return;
      if (_currentIndex >= _questions.length - 1) {
        _end(allDone: true);
        return;
      }
      setState(() {
        _currentIndex++;
        _answered      = false;
        _selectedIndex = null;
        _showBonus     = false;
      });
    });
  }

  void _end({required bool allDone}) {
    if (_dead) return;
    _dead = true;
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TimeAttackResultScreen(
          score:           _score,
          correctCount:    _correctCount,
          totalAnswered:   min(_currentIndex + (_answered ? 1 : 0), _questions.length),
          totalQuestions:  _questions.length,
          allDone:         allDone,
          selectedSeriesIds: widget.selectedSeriesIds,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: NeonBackground(child: Center(child: Text('Yeterli soru yok'))),
      );
    }

    final q      = _questions[_currentIndex];
    final isLow  = _remainingSeconds < 3.0;
    final isMid  = _remainingSeconds < 5.0 && !isLow;
    final tColor = isLow
        ? AppColors.neonRed
        : isMid
            ? const Color(0xFFFFD700)
            : AppColors.neonGreen;

    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 14),

                    // ── Top bar ──────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Timer pill
                        AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (_, child) {
                            final dx = isLow
                                ? sin(_shakeAnim.value * pi * 8) * 4
                                : 0.0;
                            return Transform.translate(
                              offset: Offset(dx, 0),
                              child: child,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: tColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                  color: tColor.withValues(alpha: 0.65),
                                  width: isLow ? 1.8 : 1.2),
                              boxShadow: isLow
                                  ? [
                                      BoxShadow(
                                          color:
                                              tColor.withValues(alpha: 0.45),
                                          blurRadius: 18)
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded,
                                    color: tColor, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${_remainingSeconds.toStringAsFixed(1)}s',
                                  style: TextStyle(
                                    color: tColor,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    shadows: isLow
                                        ? [
                                            Shadow(
                                                color: tColor,
                                                blurRadius: 10)
                                          ]
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Soru no
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                    AppColors.neonPurple.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${_questions.length}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Skor
                        Text(
                          '$_score',
                          style: const TextStyle(
                            color: AppColors.neonCyan,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                  color: AppColors.neonCyan, blurRadius: 10)
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    QuizImageCard(imagePath: q.imagePath),
                    const SizedBox(height: 10),

                    Text(
                      q.questionText,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: ListView.separated(
                          key: ValueKey(_currentIndex),
                          itemCount: q.options.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            AnswerState state = AnswerState.idle;
                            if (_answered) {
                              if (i == q.correctIndex) {
                                state = AnswerState.correct;
                              } else if (i == _selectedIndex) {
                                state = AnswerState.wrong;
                              }
                            }
                            return AnswerButton(
                              index: i,
                              label: q.options[i],
                              state: state,
                              onPressed:
                                  _answered ? null : () => _onAnswer(i),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // ── Zaman bonusu popup ────────────────────────────────────
              if (_showBonus)
                Positioned(
                  top: 70,
                  left: 0,
                  right: 0,
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('bonus_${_currentIndex}_$_answered'),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, t, _) {
                      final dy = -40.0 * Curves.easeOut.transform(t);
                      final opacity =
                          (t < 0.4 ? 1.0 : (1.0 - t) * 1.67).clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: Opacity(
                          opacity: opacity,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    _bonusColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: _bonusColor
                                        .withValues(alpha: 0.55)),
                                boxShadow: [
                                  BoxShadow(
                                    color: _bonusColor
                                        .withValues(alpha: 0.35),
                                    blurRadius: 20,
                                  )
                                ],
                              ),
                              child: Text(
                                _bonusText,
                                style: TextStyle(
                                  color: _bonusColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                        color: _bonusColor,
                                        blurRadius: 14)
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
