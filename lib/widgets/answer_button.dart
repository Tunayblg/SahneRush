import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AnswerState { idle, correct, wrong }

const _kLabels = ['A', 'B', 'C', 'D'];

class AnswerButton extends StatelessWidget {
  final int index;
  final String label;
  final AnswerState state;
  final VoidCallback? onPressed;

  const AnswerButton({
    super.key,
    required this.index,
    required this.label,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent;
    final Color bg;
    final Color letterBg;

    switch (state) {
      case AnswerState.correct:
        accent   = AppColors.neonGreen;
        bg       = AppColors.neonGreen.withValues(alpha: 0.10);
        letterBg = AppColors.neonGreen.withValues(alpha: 0.25);
      case AnswerState.wrong:
        accent   = AppColors.neonRed;
        bg       = AppColors.neonRed.withValues(alpha: 0.10);
        letterBg = AppColors.neonRed.withValues(alpha: 0.25);
      case AnswerState.idle:
        accent   = AppColors.neonPurple.withValues(alpha: 0.45);
        bg       = AppColors.card;
        letterBg = AppColors.neonPurple.withValues(alpha: 0.15);
    }

    final letter = index < _kLabels.length ? _kLabels[index] : '?';
    final textColor = state == AnswerState.idle ? AppColors.textPrimary : accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent, width: state == AnswerState.idle ? 1.0 : 1.8),
        boxShadow: state != AnswerState.idle
            ? [BoxShadow(color: accent.withValues(alpha: 0.28), blurRadius: 14)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // Harf rozeti
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: letterBg,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: accent, width: 1.2),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: state == AnswerState.idle
                            ? AppColors.neonPurple
                            : accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                // Şık metni
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: state == AnswerState.idle
                          ? FontWeight.w500
                          : FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                // Doğru/yanlış ikonu
                if (state != AnswerState.idle)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      state == AnswerState.correct
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: accent,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
