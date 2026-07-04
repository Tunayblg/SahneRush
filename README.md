# SahneRush 🎬

**SahneRush** is a scene-guessing quiz game built with Flutter. Players are shown a scene image and have to answer questions about which show or movie it's from.

## About

Content is organized by category, and the image/question sets are pluggable — new categories can be added by dropping in data without changing app logic.

### Game Modes

- **Normal Mode** — play at your own pace, pick a category and answer questions.
- **Time Attack** — race against a countdown; your score is saved to a local leaderboard.

### Features

- Category-based visual quiz questions
- Countdown and result screens for Time Attack mode
- Sound effects and background music (correct/wrong answer, win sound)
- On-device score tracking and leaderboard (via `shared_preferences`, no backend required)
- Image caching for remotely-loaded cover art (`cached_network_image`)

## Tech Stack

- **Framework:** Flutter (Dart)
- **Storage:** `shared_preferences` (local score persistence)
- **Audio:** `audioplayers`
- **Images:** `cached_network_image`
- **Platform:** currently targets iOS

### Project Structure

```
lib/
├── main.dart              # App entry point
├── constants.dart
├── models/                # GameMode, QuizQuestion, PlayerScore, SeriesCategory
├── data/                  # Category and question data
├── screens/               # Home, category selection, quiz, time attack, result screens
├── services/               # Audio service, quiz engine, leaderboard, time attack score service
├── theme/                  # App theme
└── widgets/                # Shared UI components
```

> Note: quiz image assets are not tracked in this repository (see `.gitignore`) to avoid distributing third-party media. To run the app locally, add your own images under `assets/images/`.

## Getting Started

```bash
flutter pub get
flutter run
```

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) (see `pubspec.yaml` → `environment.sdk`).
