import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/series_category.dart';
import '../theme/app_theme.dart';

class SeriesCard extends StatelessWidget {
  final SeriesCategory series;
  final bool isSelected;
  final VoidCallback onTap;

  const SeriesCard({
    super.key,
    required this.series,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? series.accentColor
                : series.accentColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: series.accentColor.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Görsel alanı
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: series.imagePath.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: series.imagePath,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _EmojiPlaceholder(series: series),
                        errorWidget: (_, _, _) => _EmojiPlaceholder(series: series),
                      )
                    : Image.asset(
                        series.imagePath,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _EmojiPlaceholder(series: series),
                      ),
              ),
              const SizedBox(width: 14),
              // Metin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      series.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Seçim göstergesi
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? series.accentColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? series.accentColor
                        : AppColors.textMuted,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiPlaceholder extends StatelessWidget {
  final SeriesCategory series;
  const _EmojiPlaceholder({required this.series});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: series.accentColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(series.emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}
