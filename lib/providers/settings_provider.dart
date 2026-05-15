import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/go_tour_prefs.dart';

part 'settings_provider.g.dart';

enum FontSize {
  small(13.0),
  medium(15.0),
  large(17.0);

  final double size;
  const FontSize(this.size);
}

typedef SettingsState = ({
  ThemeMode themeMode,
  FontSize fontSize,
  bool wrapLines,
});

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsState build() {
    _loadFromPrefs();
    return (
      themeMode: ThemeMode.system,
      fontSize: FontSize.medium,
      wrapLines: false,
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(GoTourPrefs.themeMode) ?? 'system';
    final fontStr = prefs.getString(GoTourPrefs.fontSize) ?? 'medium';
    final wrap = prefs.getBool(GoTourPrefs.wrapLines) ?? false;

    final tm = switch (themeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final fs = switch (fontStr) {
      'small' => FontSize.small,
      'large' => FontSize.large,
      _ => FontSize.medium,
    };

    state = (themeMode: tm, fontSize: fs, wrapLines: wrap);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = (
      themeMode: mode,
      fontSize: state.fontSize,
      wrapLines: state.wrapLines,
    );
    final prefs = await SharedPreferences.getInstance();
    final s = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await prefs.setString(GoTourPrefs.themeMode, s);
  }

  Future<void> setFontSize(FontSize size) async {
    state = (
      themeMode: state.themeMode,
      fontSize: size,
      wrapLines: state.wrapLines,
    );
    final prefs = await SharedPreferences.getInstance();
    final s = switch (size) {
      FontSize.small => 'small',
      FontSize.large => 'large',
      _ => 'medium',
    };
    await prefs.setString(GoTourPrefs.fontSize, s);
  }

  Future<void> setWrapLines(bool wrap) async {
    state = (
      themeMode: state.themeMode,
      fontSize: state.fontSize,
      wrapLines: wrap,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(GoTourPrefs.wrapLines, wrap);
  }
}
