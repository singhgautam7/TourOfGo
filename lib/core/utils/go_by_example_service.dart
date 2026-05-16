import 'package:http/http.dart' as http;
import '../../features/gobyexample/models/go_example.dart';

/// HTTP + HTML parsing for gobyexample.com.
///
/// The site is a small static site with a stable structure:
///  - Homepage: `<ul><li><a href="<slug>">Title</a></li>...</ul>`. Hrefs are
///    relative (no leading slash). Non-example links to filter:
///    `about`, `source`, `license`, anything starting with `http`.
///  - Example pages: zero or more `<table>` blocks. Each `<table>` contains
///    rows with `<td class="docs">…</td>` and `<td class="code …">…</td>`.
///    The last table whose code cell contains a `gp` prompt span is the
///    shell-output block.
///  - Title: `<h2><a href="./">Go by Example</a>: <Title></h2>`.
///  - Code is wrapped in `<pre class="chroma"><code><span class="line">
///    <span class="cl">…</span></span>…</code></pre>` — one outer pair per
///    logical line, syntax-highlight token spans inside.
class GoByExampleService {
  static const _baseUrl = 'https://gobyexample.com';
  static const _skipSlugs = {'', 'about', 'source', 'license'};

  /// Fetches the homepage and returns the ordered list of examples.
  Future<List<GoExampleIndex>> fetchIndex() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/'),
      headers: const {'accept': 'text/html'},
    );
    if (response.statusCode != 200) {
      throw Exception('gobyexample.com homepage returned ${response.statusCode}');
    }
    return parseHomepage(response.body);
  }

  /// Fetches one example page and returns the parsed example.
  Future<GoExample> fetchExample(GoExampleIndex index) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/${index.slug}'),
      headers: const {'accept': 'text/html'},
    );
    if (response.statusCode != 200) {
      throw Exception(
          'gobyexample.com/${index.slug} returned ${response.statusCode}');
    }
    return parseExamplePage(response.body, index);
  }

  // ── parsing ────────────────────────────────────────────────────────────

  static final _linkPattern =
      RegExp(r'<li>\s*<a href="([^"]+)">([^<]+)</a>\s*</li>');

  static final _rowPattern = RegExp(
    r'<td class="docs"[^>]*>([\s\S]*?)</td>\s*<td class="code[^"]*"[^>]*>([\s\S]*?)</td>',
  );

  static final _titlePattern =
      RegExp(r'<h2>[^<]*<a [^>]*>[^<]*</a>:\s*([^<]+)</h2>');

  /// Parses the homepage HTML into the ordered example index.
  /// Public so it can be exercised by tests.
  static List<GoExampleIndex> parseHomepage(String html) {
    final results = <GoExampleIndex>[];
    int order = 0;
    for (final m in _linkPattern.allMatches(html)) {
      final slug = m.group(1)!.trim();
      final title = m.group(2)!.trim();
      if (slug.startsWith('http')) continue;
      if (_skipSlugs.contains(slug)) continue;
      // Defensive: ignore anchored fragments or query strings.
      if (slug.contains('#') || slug.contains('?')) continue;
      results.add(GoExampleIndex(slug: slug, title: title, order: order++));
    }
    return results;
  }

  /// Parses an example page into a [GoExample]. Public for testing.
  static GoExample parseExamplePage(String html, GoExampleIndex index) {
    final allCells = <_RawRow>[];
    for (final m in _rowPattern.allMatches(html)) {
      allCells.add(_RawRow(
        docsHtml: m.group(1) ?? '',
        codeHtml: m.group(2) ?? '',
      ));
    }

    // Title — fall back to index title if header doesn't match.
    final titleMatch = _titlePattern.firstMatch(html);
    final title = titleMatch != null
        ? _decodeEntities(titleMatch.group(1)!.trim())
        : index.title;

    final shellOutputs = <String>[];
    final segments = <ExampleSegment>[];
    
    for (int i = 0; i < allCells.length; i++) {
      final codeHtml = allCells[i].codeHtml;
      // Chroma adds 'gp' (generic prompt) or 'go' (generic output) to shell blocks.
      final isShell = codeHtml.contains('class="gp"') || codeHtml.contains('class="go"');
      
      final annotation = _stripHtml(allCells[i].docsHtml).trim();
      final code = _extractCode(codeHtml).trim();
      
      if (isShell) {
        if (code.isNotEmpty) shellOutputs.add(code);
        if (annotation.isNotEmpty) {
          segments.add(ExampleSegment(annotation: annotation, code: ''));
        }
      } else {
        if (annotation.isEmpty && code.isEmpty) continue;
        segments.add(ExampleSegment(annotation: annotation, code: code));
      }
    }

    final shellOutput = shellOutputs.join('\n\n');

    return GoExample(
      slug: index.slug,
      title: title,
      order: index.order,
      segments: segments,
      shellOutput: shellOutput,
    );
  }

  /// Strips HTML tags and decodes common entities, collapsing whitespace.
  static String _stripHtml(String html) {
    return _decodeEntities(html.replaceAll(RegExp(r'<[^>]*>'), ''))
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Extracts code text from a code cell, preserving newlines naturally.
  static String _extractCode(String html) {
    final match = RegExp(r'<code>([\s\S]*?)</code>').firstMatch(html);
    if (match == null) return '';
    // Chroma generates newlines inside the span for each line, so stripping
    // HTML tags leaves the text with exact formatting and no leading spaces.
    final text = match.group(1)!.replaceAll(RegExp(r'<[^>]*>'), '');
    return _decodeEntities(text).trim();
  }

  static String _decodeEntities(String s) => s
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&#34;', '"')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&ldquo;', '"')
      .replaceAll('&rdquo;', '"')
      .replaceAll('&rsquo;', "'")
      .replaceAll('&lsquo;', "'")
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '–');
}

class _RawRow {
  final String docsHtml;
  final String codeHtml;
  _RawRow({required this.docsHtml, required this.codeHtml});
}
