import 'dart:math';
import '../constants.dart';
import '../data/question_data.dart';
import '../models/quiz_question.dart';

class QuizEngine {
  final List<String> selectedSeriesIds;
  late final List<QuizQuestion> _questions;

  int _currentIndex = 0;
  int _score = 0;
  int _correctCount = 0;
  int _streak = 0;

  QuizEngine({required this.selectedSeriesIds}) {
    _questions = _buildQuestionPool();
  }

  List<QuizQuestion> _buildQuestionPool() {
    final pool = allQuestions
        .where((q) => selectedSeriesIds.contains(q.seriesId))
        .toList();
    pool.shuffle(Random());
    return pool.take(questionsPerGame).toList();
  }

  int get totalQuestions => _questions.length;
  int get currentIndex => _currentIndex;
  int get score => _score;
  int get correctCount => _correctCount;
  int get streak => _streak;
  bool get isFinished => _currentIndex >= _questions.length;

  QuizQuestion get currentQuestion => _questions[_currentIndex];

  // Returns the points earned for this answer (0 if wrong).
  int submitAnswer(int answerIndex, int remainingSeconds) {
    final isCorrect = answerIndex == currentQuestion.correctIndex;
    int earned = 0;

    if (isCorrect) {
      _correctCount++;
      _streak++;
      earned = pointsPerCorrect + (remainingSeconds * pointsPerRemainingSecond);
      earned += _streakBonus(_streak);
    } else {
      _streak = 0;
    }

    _score += earned;
    _currentIndex++;
    return earned;
  }

  int _streakBonus(int streak) {
    if (streak >= 5) return streakBonus5Plus;
    if (streak == 4) return streakBonus4;
    if (streak == 3) return streakBonus3;
    if (streak == 2) return streakBonus2;
    return 0;
  }
}
