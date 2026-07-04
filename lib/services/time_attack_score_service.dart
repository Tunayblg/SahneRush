import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TAScore {
  final String name;
  final int score;
  final DateTime date;

  const TAScore({required this.name, required this.score, required this.date});

  Map<String, dynamic> toJson() => {
        'name': name,
        'score': score,
        'date': date.toIso8601String(),
      };

  factory TAScore.fromJson(Map<String, dynamic> j) => TAScore(
        name: j['name'] as String,
        score: j['score'] as int,
        date: DateTime.parse(j['date'] as String),
      );
}

class TimeAttackScoreService {
  static const _scoresKey  = 'ta_scores_v2';
  static const _nameKey    = 'ta_last_name';
  static const _maxEntries = 5;

  static Future<String?> getSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  /// Saves score+name, returns updated top-5 list (descending by score).
  static Future<List<TAScore>> saveAndGetTop(String name, int score) async {
    final prefs  = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);

    final raw    = prefs.getStringList(_scoresKey) ?? [];
    final scores = raw
        .map((s) => TAScore.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();

    scores.add(TAScore(name: name, score: score, date: DateTime.now()));
    scores.sort((a, b) => b.score.compareTo(a.score));
    final top = scores.take(_maxEntries).toList();

    await prefs.setStringList(
        _scoresKey, top.map((s) => jsonEncode(s.toJson())).toList());
    return top;
  }

  static Future<List<TAScore>> getTop() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_scoresKey) ?? [];
    return raw
        .map((s) => TAScore.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }
}
