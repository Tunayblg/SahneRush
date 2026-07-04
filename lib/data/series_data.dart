import 'package:flutter/material.dart';
import '../models/series_category.dart';

final List<SeriesCategory> allSeries = [
  SeriesCategory(
    id: 'friends',
    title: 'Friends',
    subtitle: 'Central Perk\'ten ikonik anlar',
    imagePath: 'assets/images/gorseller/friends/friends_kapak.jpg',
    accentColor: const Color(0xFFFFB347),
    emoji: '☕',
  ),
  SeriesCategory(
    id: 'attack_on_titan',
    title: 'Attack on Titan',
    subtitle: 'Titanların dünyasından sahneler',
    imagePath: 'assets/images/gorseller/aot/attackontitan_kapak.jpg',
    accentColor: const Color(0xFFE74C3C),
    emoji: '⚔️',
  ),
  SeriesCategory(
    id: 'himym',
    title: 'How I Met Your Mother',
    subtitle: 'Legendary! anların peşinde',
    imagePath: 'assets/images/gorseller/himym/himym_kapak.jpg',
    accentColor: const Color(0xFF3498DB),
    emoji: '🍺',
  ),
  SeriesCategory(
    id: 'game_of_thrones',
    title: 'Game of Thrones',
    subtitle: 'Taht oyunları ve ejderhalar',
    imagePath: 'assets/images/gorseller/got/got_kapak.jpg',
    accentColor: const Color(0xFF9B59B6),
    emoji: '👑',
  ),
  SeriesCategory(
    id: 'ezel',
    title: 'Ezel',
    subtitle: 'İhanet, intikam ve kimlik',
    imagePath: 'https://image.tmdb.org/t/p/w500/pHSjh4MINU2JnK7qQvjogQaX3wr.jpg',
    accentColor: const Color(0xFFE67E22),
    emoji: '🔫',
  ),
];
