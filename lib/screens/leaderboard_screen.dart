import 'package:flutter/material.dart';
import '../models/player_score.dart';
import '../services/leaderboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_background.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<PlayerScore>> _scoresFuture;

  @override
  void initState() {
    super.initState();
    _scoresFuture = LeaderboardService().getScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _Header(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<PlayerScore>>(
                  future: _scoresFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.neonPurple,
                        ),
                      );
                    }
                    final scores = snapshot.data ?? [];
                    if (scores.isEmpty) return _EmptyState();
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: scores.length,
                      itemBuilder: (_, i) =>
                          _ScoreRow(rank: i + 1, score: scores[i]),
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.neonPurple.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 18),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Skor Tablosu',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        const Text('🏆', style: TextStyle(fontSize: 24)),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final int rank;
  final PlayerScore score;

  const _ScoreRow({required this.rank, required this.score});

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.textMuted;
  }

  String get _rankIcon {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '$rank';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank <= 3
              ? _rankColor.withValues(alpha: 0.4)
              : AppColors.neonPurple.withValues(alpha: 0.15),
          width: rank == 1 ? 1.5 : 1,
        ),
        boxShadow: rank <= 3
            ? [
                BoxShadow(
                  color: _rankColor.withValues(alpha: 0.1),
                  blurRadius: 12,
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: rank <= 3
                ? Text(_rankIcon, style: const TextStyle(fontSize: 22))
                : Text(
                    _rankIcon,
                    style: TextStyle(
                      color: _rankColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.playerName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${score.correctAnswers}/${score.totalQuestions} doğru  •  ${_formatDate(score.dateTime)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${score.score}',
            style: TextStyle(
              color: rank <= 3 ? _rankColor : AppColors.neonCyan,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 72,
            color: AppColors.neonPurple.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz skor yok',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İlk oyunu oyna ve\nilk sırayı kap!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
