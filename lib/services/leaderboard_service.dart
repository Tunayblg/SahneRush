import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_score.dart';

class LeaderboardService {
  static const String _key = 'sahnerush_scores';
  static const int _maxEntries = 10;

  Future<List<PlayerScore>> getScores() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final scores = raw
        .map((s) => PlayerScore.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores;
  }

  Future<void> saveScore(PlayerScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = await getScores();
    scores.add(score);
    scores.sort((a, b) => b.score.compareTo(a.score));
    final trimmed = scores.take(_maxEntries).toList();
    final raw = trimmed.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }

  Future<void> clearScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
