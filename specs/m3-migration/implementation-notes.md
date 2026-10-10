# M3 migration: implementation notes

Tour of Go moved to the Material 3 language Kuber now uses
(`kuber/specs/design/kuber-m3-round-1-design-system`, `kuber/specs/m3-redesign`).
UI only: no parsing, compile/run, content fetching, progress, search, Go by
Example download, provider logic, route path, prefs key or model changed.

Checks: `flutter analyze` clean (the three pre-existing infos/warnings are gone
too: two were dead code in the old More screen, one in the deleted app bar),
`flutter test` green. Verified on the API 36 emulator in light and dark.

## 1. Foundations

| Area | What changed |
|---|---|
| Tokens | `KuberSpace`, `KuberShape`, `KuberMotion` ported (Kuber names kept). `KuberSpacing` / `KuberRadius` deleted; every use migrated. |
| Colour | `ColorScheme.fromSeed(#00ACD7)` with `DynamicSchemeVariant.vibrant`; dark drops `surface` / `surfaceContainerLowest` to true black. `GoTourColors` / `GoTourLightColors` deleted. `code_colors.dart` kept as content colours. |
| Theme | Kuber's component themes (inputs, buttons, chips, sheets, dialogs, snackbar, dividers, sliders and progress with `year2023: false`, list tiles, menus, tooltips), `InkSparkle`. Depth from `outlineVariant` borders and tonal surfaces; no shadows. |
| Type | Kuber's 13-role scale (`buildTextTheme`). Inter, JetBrains Mono and Instrument Serif italic are engine-registered in pubspec `fonts:`; `google_fonts` is removed, so there is no runtime font load. `localeFont` / `monoFont` / `serifFont` / `sectionHeaderStyle` / `sentenceCase` in `core/utils/locale_font.dart`, English only. |

## 2. Copied from Kuber (file by file)

| Tour of Go file | Kuber source | Changes |
|---|---|---|
| `shared/widgets/kuber_app_bar.dart` | same | No pin-shortcut slot, brand is the "A Tour of Go" wordmark (no icon), new `titleWidget` slot for the readers' switcher chip, search pill content padding fixed (see §4). |
| `kuber_menu.dart`, `kuber_bottom_sheet.dart`, `kuber_extended_fab.dart`, `timed_snackbar.dart`, `kuber_segmented_control.dart`, `kuber_skeleton.dart`, `kuber_loader.dart`, `kuber_empty_state.dart`, `kuber_info_bottom_sheet.dart` | same | `showKuberBottomSheet` helper added; `KuberLoader.show(future)` ported from the old `GoTourLoader`; `KuberEmptyState.actionIcon`; info sheet without l10n and worked examples. |
| `app_button.dart`, `app_icon_button.dart` | same | Semantics fixed (§4). |
| `kuber_list.dart`, `kuber_progress.dart` | same | Money / warning tones and over-limit states removed (Tour of Go has none). |
| `settings_section.dart` | `features/settings/widgets/settings_section.dart` | No-op description class removed; subtitles wrap to 3 lines so copy is never cut. |
| `core/models/overflow_config.dart`, `info_config.dart` | same | `KuberInfoExample` removed. |
| About page | `features/more/screens/about_screen.dart` | Flat cards (no gradients, no watermark), solid avatar, "More apps from the developer" row. |

New, Tour of Go only: `reader_header.dart` (both readers' header), `nav_sheet.dart`
(draggable list sheet with `KuberBottomSheet` chrome, chapters / examples /
downloads), `url_box.dart`.

Deleted: `tourgo_app_bar`, `tourgo_page_header`, `tourgo_bottom_sheet`,
`go_tour_button`, `go_tour_snackbar`, `go_tour_loader`, `settings_widgets`, the
unused `chapter_progress_row`, the old onboarding illustration painter and
`assets/go_brand.png`.

## 3. Deviations, with reasons

1. **Splash.** Not Kuber's painter pipeline: the app already uses the icon
   family's splash (same `flutter_native_splash` mechanism, `android_12` pairs,
   light and dark). The Dart `SplashScreen` route is gone; `main()` reads the
   onboarded flag before `runApp` and passes the first route to the router, so
   behaviour is unchanged and there is no blank first frame.
2. **Readers keep a fixed header.** The lesson and example readers are pagers;
   the header carries the chapter switcher and the reading progress, so it
   stays put while pages swipe. Every list / content page scrolls its header
   away (`KuberScrollAwayHeader` or header as item 0).
3. **Info actions.** "Lesson info" / "Example info" live in the readers'
   overflow, per Kuber's rule that info never sits as a standalone icon.
4. **Header descriptions removed** on More, Settings and Feedback, and the line
   under the Home greeting (review feedback: they do not read well in M3).
5. **Colour variant.** Kuber uses `fidelity`; for Go cyan that makes
   `primaryContainer` the raw seed, a bright cyan that read flushed and mixed
   white and dark text. `vibrant` keeps containers pale with dark text.
6. **Feedback type** is M3 choice chips: the three labels are too long for a
   segmented control.
7. **Welcome.** Dots and buttons are one fixed footer (only the content swipes);
   Skip sits beside "Get started", as in Perch.

## 4. Bugs fixed on the way

- `AppButton` / `AppIconButton` (also in Kuber): the button's semantics merged
  into the page, and the icon button's `excludeSemantics` dropped its tap
  action, so TalkBack could not activate them. Both now have their own node and
  tap action.
- Collapsed search fields kept the theme's 16dp content padding, so the text
  sat high and off the icon. Zeroed explicitly.
- Inline code named the font `JetBrains Mono`, which only resolved through
  google_fonts; it now uses the bundled `JetBrainsMono`.

## 5. Open questions

- Inter ships without an OFL text in Kuber's bundle either; add one if the
  licence file is wanted in the repo.
- The emulator only has API 36; the pre-12 splash path is not checked on device.
