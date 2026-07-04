import 'package:flutter/material.dart';
import '../constants.dart';
import '../data/series_data.dart';
import '../models/game_mode.dart';
import '../models/series_category.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/series_card.dart';
import 'quiz_screen.dart';
import 'time_attack_intro_screen.dart';

class SeriesSelectionScreen extends StatefulWidget {
  final GameMode gameMode;

  const SeriesSelectionScreen({
    super.key,
    this.gameMode = GameMode.normal,
  });

  @override
  State<SeriesSelectionScreen> createState() => _SeriesSelectionScreenState();
}

class _SeriesSelectionScreenState extends State<SeriesSelectionScreen> {
  final Set<String> _selectedIds = {};

  void _toggleSeries(SeriesCategory series) {
    setState(() {
      if (_selectedIds.contains(series.id)) {
        _selectedIds.remove(series.id);
      } else {
        _selectedIds.add(series.id);
      }
    });
  }

  bool get _canStart => _selectedIds.length >= minSeriesSelection;

  void _startQuiz() {
    if (!_canStart) return;
    final ids = _selectedIds.toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => widget.gameMode == GameMode.timeAttack
            ? TimeAttackIntroScreen(selectedSeriesIds: ids)
            : QuizScreen(selectedSeriesIds: ids),
      ),
    );
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SelectionHint(
                  selected: _selectedIds.length,
                  canStart: _canStart,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: allSeries.length,
                  itemBuilder: (_, i) {
                    final series = allSeries[i];
                    return SeriesCard(
                      series: series,
                      isSelected: _selectedIds.contains(series.id),
                      onTap: () => _toggleSeries(series),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: PrimaryButton(
                  label: 'Teste Başla',
                  onPressed: _canStart ? _startQuiz : null,
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
              border: Border.all(color: AppColors.neonPurple.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 18),
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hangi evrenlerden?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            Text(
              'Dizi Seç',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectionHint extends StatelessWidget {
  final int selected;
  final bool canStart;

  const _SelectionHint({required this.selected, required this.canStart});

  @override
  Widget build(BuildContext context) {
    final color = canStart ? AppColors.neonGreen : AppColors.neonPink;
    final text = canStart
        ? '$selected dizi seçildi ✓'
        : 'En az $minSeriesSelection dizi seç ($selected/$minSeriesSelection)';
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
