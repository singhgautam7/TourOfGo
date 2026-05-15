import 'dart:convert';

// ── Data Models ───────────────────────────────────────────────────────────────

class CodeFile {
  final String name;
  final String content;
  final String hash;

  const CodeFile({
    required this.name,
    required this.content,
    required this.hash,
  });

  factory CodeFile.fromJson(Map<String, dynamic> json) => CodeFile(
        name: json['Name'] as String? ?? json['name'] as String? ?? '',
        content: json['Content'] as String? ?? json['content'] as String? ?? '',
        hash: json['Hash'] as String? ?? json['hash'] as String? ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'Name': name, 'Content': content, 'Hash': hash};
}

class LessonData {
  final String title;
  final String content;
  final List<CodeFile> files;

  const LessonData({
    required this.title,
    required this.content,
    required this.files,
  });

  factory LessonData.fromJson(Map<String, dynamic> json) {
    final rawFiles = json['Files'] as List<dynamic>? ?? [];
    return LessonData(
      title: json['Title'] as String? ?? '',
      content: json['Content'] as String? ?? '',
      files: rawFiles
          .map((f) => CodeFile.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'Title': title,
        'Content': content,
        'Files': files.map((f) => f.toJson()).toList(),
      };
}

class ChapterData {
  final String title;
  final String description;
  final List<LessonData> pages;

  const ChapterData({
    required this.title,
    required this.description,
    required this.pages,
  });

  factory ChapterData.fromJson(Map<String, dynamic> json) {
    final rawPages = json['Pages'] as List<dynamic>? ?? [];
    return ChapterData(
      title: json['Title'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      pages: rawPages
          .map((p) => LessonData.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'Title': title,
        'Description': description,
        'Pages': pages.map((p) => p.toJson()).toList(),
      };
}

class CompileEvent {
  final String message;
  final String kind;
  final int delay;

  const CompileEvent({
    required this.message,
    required this.kind,
    required this.delay,
  });

  factory CompileEvent.fromJson(Map<String, dynamic> json) => CompileEvent(
        message: json['Message'] as String? ?? json['message'] as String? ?? '',
        kind: json['Kind'] as String? ?? json['kind'] as String? ?? '',
        delay: json['Delay'] as int? ?? json['delay'] as int? ?? 0,
      );
}

class CompileResponse {
  final String errors;
  final List<CompileEvent> events;
  final String vetErrors;

  const CompileResponse({
    required this.errors,
    required this.events,
    required this.vetErrors,
  });

  factory CompileResponse.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['Events'] as List<dynamic>? ?? [];
    return CompileResponse(
      errors: json['Errors'] as String? ?? json['errors'] as String? ?? '',
      events: rawEvents
          .map((e) => CompileEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      vetErrors:
          json['VetErrors'] as String? ?? json['vetErrors'] as String? ?? '',
    );
  }
}

// ── Fixed chapter order ───────────────────────────────────────────────────────
const List<String> kChapterOrder = [
  'welcome',
  'basics',
  'flowcontrol',
  'moretypes',
  'methods',
  'concurrency',
  'generics',
];

// ── Chapter display names ─────────────────────────────────────────────────────
const Map<String, String> kChapterDisplayNames = {
  'welcome': 'Welcome',
  'basics': 'Basics',
  'flowcontrol': 'Flow control',
  'moretypes': 'More types',
  'methods': 'Methods',
  'concurrency': 'Concurrency',
  'generics': 'Generics',
};

/// Returns ordered chapter entries from a raw content map.
List<MapEntry<String, ChapterData>> orderedChapters(
    Map<String, ChapterData> content) {
  return kChapterOrder
      .where(content.containsKey)
      .map((k) => MapEntry(k, content[k]!))
      .toList();
}

/// Parses the raw JSON string from the Content API.
Map<String, ChapterData> parseContentJson(String raw) {
  final Map<String, dynamic> decoded =
      jsonDecode(raw) as Map<String, dynamic>;
  return decoded.map(
    (k, v) => MapEntry(k, ChapterData.fromJson(v as Map<String, dynamic>)),
  );
}
