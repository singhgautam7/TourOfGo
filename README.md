# A Tour of Go

A mobile-first reader for the official [Tour of Go](https://go.dev/tour/), plus a built-in sandbox for running Go code from your phone. Designed to be fast, offline-friendly, and easy to read on a small screen.

***

## Features

### Lesson reader
- All 7 chapters and 80+ lessons from the official Go tour
- Custom HTML renderer tuned for phone reading (typography, code blocks, inline links)
- Per-lesson syntax-highlighted Go source with line numbers
- Volume keys page the content; swipe Prev/Next between lessons
- A sticky progress bar and dot indicator that show where you are in the chapter

### Run any sample
- Tap **Run** on any lesson to send the source to the official Go Playground (`go.dev/_/compile`) and stream the output back, with stdout and stderr surfaced separately
- Errors from the compiler are shown in a dedicated STDERR panel

### Sandbox
- Editable code playground reachable from the home FAB, or from the "Edit in Sandbox" button on the Go Playground lesson
- Live syntax highlighting as you type
- Line numbers that stay aligned with logical lines even when long lines wrap
- A "Reset" action to restore the starting code

### Progress tracking
- Tracks the lessons you have finished, per chapter
- Inline browser on the home screen so you can jump straight to any chapter or lesson
- Completion overlay when you finish a chapter, with quick links to the next chapter or the chapter browser

### Settings
- Light, dark, or system theme
- Three font sizes for the reader (small, medium, large)
- Global "Wrap code lines" toggle that applies to every code surface (reader and sandbox), with a quick toggle pill on each code card

### Offline-first
- Tour content is fetched once and cached locally; subsequent launches do not need the network
- Tap the refresh action on the home header to pull fresh content from `go.dev`

### Privacy
- 100% local-first state (progress, preferences, position)
- No accounts, no analytics, no tracking, no ads
- Network is used only for: pulling tour content, sending code you choose to run, and loading UI fonts
- See [PRIVACY_POLICY.md](PRIVACY_POLICY.md) for full details

***

## Tech stack

- Flutter (Android target)
- Riverpod (`flutter_riverpod` + `riverpod_generator`)
- GoRouter
- `shared_preferences` for all persistence
- `http` for the Go Playground compile API and content fetch
- `google_fonts` (Inter for UI, JetBrains Mono for code)
- `url_launcher` for external links

There is no Isar / SQLite. There is no analytics SDK. The app intentionally has a very small dependency surface.

***

## Getting Started

### Prerequisites
- Flutter SDK
- Android Studio or a connected Android device

### Run locally
```bash
git clone <repo-url>
cd tourgo
flutter pub get
flutter run
```

### Build a release APK
```bash
flutter build apk --split-per-abi --release
```
Per-ABI APKs land in `build/app/outputs/flutter-apk/`. Each one is about 9 MB.

### Build an App Bundle for the Play Store
```bash
flutter build appbundle --release
```
The Play Store splits the resulting AAB per device. Typical install size on a real phone is around 5-7 MB.

***

## Project layout

```
lib/
  core/
    models/        # tour_models.dart: ChapterData, LessonData, CodeFile, CompileResponse
    router/        # GoRouter config
    theme/         # AppTheme, KuberSpacing/Radius, code color palettes
    utils/         # html_parser, go_syntax_highlighter, compile_service, content_service, tour_url
  features/
    splash/
    onboarding/
    home/          # home screen + inline chapter browser
    reader/        # PageView-based lesson reader, code card, output panel, sandbox glue
    sandbox/       # editable Go playground screen
    navigation/    # chapter browser list + bottom sheet
    completion/    # chapter completion overlay
    more/          # more / settings / about / data screens
  providers/       # Riverpod notifiers for content, position, progress, settings, compile
  shared/widgets/  # KuberAppBar, KuberBottomSheet, KuberPageHeader, settings_widgets, GoTourButton
```

***

## Attribution

Tour content is fetched live from [go.dev/tour](https://go.dev/tour/) and is licensed under the [Creative Commons Attribution 3.0 License](https://creativecommons.org/licenses/by/3.0/). Go and the Go gopher are trademarks of Google LLC. This app is not affiliated with Google.
