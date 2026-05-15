/// Lightweight index entry — always in memory, fetched from gobyexample.com homepage.
class GoExampleIndex {
  final String slug;
  final String title;
  final int order;

  const GoExampleIndex({
    required this.slug,
    required this.title,
    required this.order,
  });

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'title': title,
        'order': order,
      };

  factory GoExampleIndex.fromJson(Map<String, dynamic> json) => GoExampleIndex(
        slug: json['slug'] as String,
        title: json['title'] as String,
        order: json['order'] as int,
      );
}

/// One annotation + code pair from an example page.
class ExampleSegment {
  final String annotation; // HTML-stripped docs text
  final String code; // raw Go source with newlines preserved

  const ExampleSegment({
    required this.annotation,
    required this.code,
  });

  Map<String, dynamic> toJson() => {
        'annotation': annotation,
        'code': code,
      };

  factory ExampleSegment.fromJson(Map<String, dynamic> json) => ExampleSegment(
        annotation: json['annotation'] as String? ?? '',
        code: json['code'] as String? ?? '',
      );
}

/// Full example content — fetched lazily per slug, cached as JSON in prefs.
class GoExample {
  final String slug;
  final String title;
  final int order;
  final List<ExampleSegment> segments;
  final String shellOutput; // empty if none

  const GoExample({
    required this.slug,
    required this.title,
    required this.order,
    required this.segments,
    required this.shellOutput,
  });

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'title': title,
        'order': order,
        'segments': segments.map((s) => s.toJson()).toList(),
        'shellOutput': shellOutput,
      };

  factory GoExample.fromJson(Map<String, dynamic> json) => GoExample(
        slug: json['slug'] as String,
        title: json['title'] as String,
        order: json['order'] as int,
        segments: (json['segments'] as List<dynamic>)
            .map((e) => ExampleSegment.fromJson(e as Map<String, dynamic>))
            .toList(),
        shellOutput: json['shellOutput'] as String? ?? '',
      );
}
