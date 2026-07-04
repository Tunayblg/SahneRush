import 'package:flutter/material.dart';

class SeriesCategory {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final Color accentColor;
  final String emoji;

  const SeriesCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.accentColor,
    required this.emoji,
  });
}
