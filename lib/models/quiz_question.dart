enum Difficulty { easy, medium, hard }

enum QuestionType { character, object, location, symbol, detail }

class QuizQuestion {
  final String id;
  final String seriesId;
  final String imagePath;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final Difficulty difficulty;
  final QuestionType questionType;

  const QuizQuestion({
    required this.id,
    required this.seriesId,
    required this.imagePath,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
    required this.questionType,
  });
}
