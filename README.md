# SahneRush

**Recognize the details. Keep your streak. Beat the clock.**

SahneRush is a Flutter visual trivia game about familiar TV worlds: their characters, locations, objects and memorable moments. Choose your series, answer image-based multiple-choice questions and chase a better score through two timed game modes.

The current question bank includes Friends, Attack on Titan, How I Met Your Mother, Game of Thrones and Ezel. The interface and questions are primarily in Turkish. The repository currently includes an iOS runner.

## The Player Experience

Start from the animated home screen, select a game mode and choose the series you want in your question pool. Each question combines a picture with answer choices. Correct and incorrect answers receive immediate visual and audio feedback before the next question appears.

The standard quiz rewards accuracy, quick answers and consecutive correct answers. Time Attack creates a different rhythm: every correct answer buys more time, while a mistake shortens the remaining run. Result screens summarize the session, and local leaderboards make replaying worthwhile without an account or backend service.

### Game Modes and Scoring

| Rule | Standard quiz | Time Attack |
| --- | --- | --- |
| Question pool | Shuffled selection of up to 10 questions | Shuffled pool from selected series |
| Timer | 15 seconds per question | Starts with 8 seconds for the run |
| Correct answer | 100 points + 5 per remaining second + streak bonus | 10 points and 3 extra seconds |
| Incorrect answer | 0 points; resets the streak | Removes 1 second |
| Finish | Selected questions completed | Time runs out or the pool is completed |
| Local leaderboard storage | Top 10 scores | Top 5 scores |

Standard-mode streak bonuses are 10, 20 and 30 points for the second, third and fourth consecutive correct answers, then 50 points from the fifth onward. A timeout counts as an incorrect answer. Both modes are timed; standard mode is not an untimed practice mode.

## Technical Design

- **Flutter / Dart:** screens, navigation, animations and reusable answer/image widgets.
- **Quiz engine:** filters the question bank by selected series, shuffles the pool and calculates standard-mode scores.
- **Time Attack screen:** maintains the shared countdown, answer bonuses and end-of-run conditions.
- **Local persistence:** `shared_preferences` stores serialized leaderboard entries; the two modes use separate storage keys.
- **Audio:** `audioplayers` supplies music and answer feedback.
- **Images:** question data contains local asset paths and remote URLs; remote imagery requires network access.

```text
lib/
├── constants.dart       # Standard quiz timing and scoring
├── data/                # Series definitions and question bank
├── models/              # Questions, series, modes and scores
├── screens/             # Selection, gameplay, results and leaderboards
├── services/            # Quiz engine, audio and score persistence
├── theme/               # Shared visual styling
└── widgets/             # Reusable interface components
```

## Run Locally

Use a Flutter SDK whose bundled Dart version satisfies `^3.12.2`, as declared in [pubspec.yaml](pubspec.yaml). Running the included iOS target requires macOS and an iOS development environment with Xcode.

```sh
git clone https://github.com/Tunayblg/SahneRush.git
cd SahneRush
flutter pub get
```

Before launching, restore the image assets referenced by [question_data.dart](lib/data/question_data.dart) and [series_data.dart](lib/data/series_data.dart), or update those references to your own images. Most quiz images are not committed. The asset directories declared in `pubspec.yaml` are:

```text
assets/audio/
assets/images/series/
assets/images/gorseller/friends/
assets/images/gorseller/aot/
assets/images/gorseller/himym/
assets/images/gorseller/got/
```

Preserve the referenced filenames and directory structure when restoring assets. Audio files are included. Once the declared asset directories are populated and an iOS device or simulator is available:

```sh
flutter devices
flutter run -d <device-id>
```

## Add Your Own Questions

1. Define a series in `lib/data/series_data.dart` if it does not already exist.
2. Add `QuizQuestion` entries to `lib/data/question_data.dart` with the matching `seriesId`, image path, question text, options and zero-based correct-answer index.
3. Supply the referenced images and register any new local asset directories in `pubspec.yaml`.
4. Check both modes: they consume the same question data but use different timing and scoring rules.

Standard quiz settings live in `lib/constants.dart`; Time Attack settings are defined in `lib/screens/time_attack_screen.dart`. Changes to one do not automatically change the other.

## Current Scope

Scores are stored on the device rather than synced between players. Android, web and desktop runner folders are not included. A fresh checkout needs the omitted local image assets before it can reproduce the intended visual experience.
