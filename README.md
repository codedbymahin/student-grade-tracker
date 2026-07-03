# Student Grade Tracker

A clean, beginner-friendly Flutter application that lets students add
subjects and marks, automatically calculate letter grades, browse the
list with swipe-to-delete, and watch a live summary update in real
time. All data is kept in memory — no backend, no database, no
authentication.

![Material 3](https://img.shields.io/badge/Material_3-3F51B5?logo=flutter&logoColor=white)
![State](https://img.shields.io/badge/state-Provider-0F9D58)
![Platforms](https://img.shields.io/badge/platforms-android%20%7C%20ios%20%7C%20web%20%7C%20desktop-0277BD)
![Tests](https://img.shields.io/badge/tests-13%2F13_passing-success)

## Features

- **Add subject** with a validated form (name + mark 0–100) and a live
  preview of the resulting letter grade.
- **Subject list** rendered with `ListView.builder` and `Dismissible`
  swipe-to-delete, plus a one-tap *Undo* action in the snackbar.
- **Live summary** that recomputes total subjects, average mark,
  highest / lowest mark, overall grade and a passing ratio on every
  change — no manual refresh.
- **Light, dark and system themes** built from a custom `ThemeData`
  based on `ColorScheme.fromSeed` (no `ThemeData.light()` /
  `ThemeData.dark()`).
- **State management with Provider only** — zero `setState()` calls in
  the entire codebase.
- **Polished empty states**, hero gradient headers, animated tab
  switches, color-coded grade chips and a passing-progress card.

## Screenshots

Drop your captures into a `screenshots/` folder and they will show up
here automatically.

| Add Subject                                       | Subject List                                       | Summary                                            |
| ------------------------------------------------- | -------------------------------------------------- | -------------------------------------------------- |
| ![Add Subject](screenshots/add.png)               | ![Subject List](screenshots/list.png)              | ![Summary](screenshots/summary.png)                |
| *Live grade preview while typing.*                | *Swipe to delete with undo.*                       | *Hero overall grade + passing progress.*           |

## Requirements

- Flutter SDK ≥ 3.19
- Dart ≥ 3.3
- A device or emulator (Android, iOS, web, or desktop)

## How to run

```bash
cd student_grade_tracker
flutter pub get
flutter run
```

To launch on a specific target:

```bash
flutter run -d chrome          # web
flutter run -d android         # android device/emulator
flutter run -d ios             # ios device/simulator (macOS only)
```

To verify code quality and run the test suite:

```bash
flutter analyze
flutter test
```

## Folder structure

```
student_grade_tracker/
├── lib/
│   ├── main.dart                       # 5-line shim → runApp(StudentGradeTrackerApp())
│   ├── app/
│   │   ├── app.dart                    # Root widget with MultiProvider
│   │   └── app_theme.dart              # light() / dark() ThemeData builders
│   ├── models/
│   │   ├── grade.dart                  # Grade value class with fromMark()
│   │   └── subject.dart                # Immutable Subject with private mark
│   ├── providers/
│   │   ├── subject_provider.dart       # id-keyed CRUD + computed values
│   │   ├── theme_provider.dart         # light/dark/system cycle
│   │   └── navigation_provider.dart    # BottomNav index state
│   ├── screens/
│   │   ├── home_shell.dart             # AppBar + AnimatedSwitcher + IndexedStack
│   │   ├── add_subject_screen.dart     # Form + preview grade chip
│   │   ├── subject_list_screen.dart    # Dismissible list with undo
│   │   └── summary_screen.dart         # Hero card + stat cards
│   └── widgets/                        # Reusable UI atoms
│       ├── empty_state.dart
│       ├── grade_chip.dart
│       ├── stat_card.dart
│       ├── subject_card.dart
│       └── swipe_background.dart
├── test/
│   ├── subject_provider_test.dart      # 12 unit tests (Grade + Subject + Provider)
│   └── widget_test.dart                # 1 smoke test (add → list → summary)
├── .github/workflows/flutter-ci.yml    # CI on push / PR
├── .gitignore
├── analysis_options.yaml
├── LICENSE
├── pubspec.yaml
└── README.md
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  StudentGradeTrackerApp  (MultiProvider)                        │
│  ┌───────────────┐  ┌────────────────┐  ┌────────────────────┐ │
│  │ SubjectProv.  │  │  ThemeProv.    │  │ NavigationProv.    │ │
│  └───────────────┘  └────────────────┘  └────────────────────┘ │
│                              │                                  │
│                              ▼                                  │
│                       MaterialApp                               │
│                  themeMode ← ThemeProvider                      │
│                  theme      ← AppTheme.light()                  │
│                  darkTheme  ← AppTheme.dark()                   │
│                              │                                  │
│                              ▼                                  │
│                       HomeShell (AppBar + BottomNav)            │
│                              │                                  │
│                  AnimatedSwitcher + IndexedStack                 │
│                  ┌───────────┼────────────┐                     │
│                  ▼           ▼            ▼                     │
│           AddSubject   SubjectList     Summary                  │
└─────────────────────────────────────────────────────────────────┘
```

**Why Provider?** `SubjectProvider` exposes a `List<Subject>` and
computed values. The screens rebuild via `Selector` / `Consumer` only
when their slice changes — no `setState`, no inheritance, no build
runner.

**Why a custom `ThemeData`?** `ColorScheme.fromSeed(seedColor: indigo)`
generates the entire Material 3 palette; everything else (cards,
inputs, snackbars, navigation bar) is themed explicitly so the app
looks the same on every device.

## Grade boundaries

| Letter | Minimum mark | Notes                                            |
| :----: | :----------: | ------------------------------------------------ |
| A      | 80           | Excellent                                        |
| B      | 65           | Good                                             |
| C      | 50           | Pass                                             |
| F      | 0            | Fail — also the safe default for `NaN` / `±∞` |

These boundaries live in **one** place: `lib/models/grade.dart`.

## Packages used

- [`provider`](https://pub.dev/packages/provider) — state management.

No other dependencies were added.

## Continuous integration

`.github/workflows/flutter-ci.yml` runs `flutter analyze` and
`flutter test` on Ubuntu and Windows for every push and pull request
to `main`.

## License

[MIT](LICENSE)
