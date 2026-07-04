class PlayerScore {
  final String playerName;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final List<String> selectedSeriesTitles;
  final DateTime dateTime;

  const PlayerScore({
    required this.playerName,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.selectedSeriesTitles,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'score': score,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'selectedSeriesTitles': selectedSeriesTitles,
        'dateTime': dateTime.toIso8601String(),
      };

  factory PlayerScore.fromJson(Map<String, dynamic> json) => PlayerScore(
        playerName: json['playerName'] as String,
        score: json['score'] as int,
        correctAnswers: json['correctAnswers'] as int,
        totalQuestions: json['totalQuestions'] as int,
        selectedSeriesTitles:
            List<String>.from(json['selectedSeriesTitles'] as List),
        dateTime: DateTime.parse(json['dateTime'] as String),
      );
}
