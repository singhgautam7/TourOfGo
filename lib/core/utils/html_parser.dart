import 'package:flutter/material.dart';

// ── Content block types ───────────────────────────────────────────────────────

sealed class ContentBlock {}

class ParagraphBlock extends ContentBlock {
  final List<InlineSpan> spans;
  ParagraphBlock(this.spans);
}

class CodePreBlock extends ContentBlock {
  final String code;
  CodePreBlock(this.code);
}

class BulletListBlock extends ContentBlock {
  final List<List<InlineSpan>> items;
  BulletListBlock(this.items);
}

// ── Parser ────────────────────────────────────────────────────────────────────

class GoHtmlParser {
  final String _raw;
  final BuildContext _context;
  final void Function(BuildContext ctx, String href)? _onLinkTap;

  GoHtmlParser(this._raw, this._context, {onLinkTap})
      : _onLinkTap = onLinkTap;

  static List<ContentBlock> parse(
    String html,
    BuildContext context, {
    void Function(BuildContext ctx, String href)? onLinkTap,
  }) {
    return GoHtmlParser(html, context, onLinkTap: onLinkTap)._parse();
  }

  // ── Simple HTML entity decoder ────────────────────────────────────────────
  static String decodeEntities(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#34;', '"')
        .replaceAll('&nbsp;', '\u00a0');
  }

  List<ContentBlock> _parse() {
    final blocks = <ContentBlock>[];
    String remaining = _raw;

    while (remaining.isNotEmpty) {
      // Skip whitespace-only
      if (remaining.trimLeft().isEmpty) break;

      // <h2> — skip entirely
      if (_matchTag(remaining, 'h2')) {
        remaining = _skipTag(remaining, 'h2');
        continue;
      }

      // <p>
      if (_matchTag(remaining, 'p')) {
        final extracted = _extractTag(remaining, 'p');
        if (extracted != null) {
          remaining = extracted.$2;
          final inner = extracted.$1.trim();
          // A paragraph that is just a single <code>…</code> block is
          // really a code sample on the web — promote it to a code block.
          final codeOnly = RegExp(r'^<code[^>]*>([\s\S]*?)</code>$')
              .firstMatch(inner);
          if (codeOnly != null) {
            blocks.add(CodePreBlock(
                decodeEntities(_stripTags(codeOnly.group(1)!))));
          } else {
            final spans = _parseInline(extracted.$1);
            if (_hasMeaningfulContent(spans)) {
              blocks.add(ParagraphBlock(spans));
            }
          }
        } else {
          remaining = remaining.substring(1);
        }
        continue;
      }

      // <pre>
      if (_matchTag(remaining, 'pre')) {
        final extracted = _extractTag(remaining, 'pre');
        if (extracted != null) {
          remaining = extracted.$2;
          // Strip inner <code> wrapper
          String code = extracted.$1;
          code = code.replaceAll(RegExp(r'<code[^>]*>'), '');
          code = code.replaceAll('</code>', '');
          code = decodeEntities(code);
          blocks.add(CodePreBlock(code.trim()));
        } else {
          remaining = remaining.substring(1);
        }
        continue;
      }

      // <ul>
      if (_matchTag(remaining, 'ul')) {
        final extracted = _extractTag(remaining, 'ul');
        if (extracted != null) {
          remaining = extracted.$2;
          final items = _parseList(extracted.$1);
          if (items.isNotEmpty) blocks.add(BulletListBlock(items));
        } else {
          remaining = remaining.substring(1);
        }
        continue;
      }

      // Any other tag — skip
      if (remaining.startsWith('<')) {
        final end = remaining.indexOf('>');
        remaining = end >= 0 ? remaining.substring(end + 1) : '';
        continue;
      }

      // Plain text (shouldn't really happen at top level)
      remaining = remaining.substring(1);
    }

    return blocks;
  }

  bool _hasMeaningfulContent(List<InlineSpan> spans) {
    return spans.any((s) =>
        s is WidgetSpan ||
        (s is TextSpan && (s.text ?? '').trim().isNotEmpty));
  }

  bool _matchTag(String s, String tag) {
    // Must start with `<tag` followed by a non-name character (space, >, /).
    // Without this guard, `<pre>` would also match tag `p`.
    if (!s.startsWith('<$tag')) return false;
    if (s.length == tag.length + 1) return false;
    final next = s.codeUnitAt(tag.length + 1);
    // 0x20 space, 0x09 tab, 0x0A LF, 0x0D CR, 0x2F '/', 0x3E '>'
    return next == 0x20 ||
        next == 0x09 ||
        next == 0x0A ||
        next == 0x0D ||
        next == 0x2F ||
        next == 0x3E;
  }

  String _skipTag(String s, String tag) {
    final close = s.indexOf('</$tag>');
    if (close < 0) return '';
    return s.substring(close + tag.length + 3);
  }

  /// Returns (innerHtml, remainder) or null if tag not found.
  (String, String)? _extractTag(String s, String tag) {
    final openEnd = s.indexOf('>');
    if (openEnd < 0) return null;
    final content = s.substring(openEnd + 1);
    final closeIdx = content.indexOf('</$tag>');
    if (closeIdx < 0) return null;
    return (content.substring(0, closeIdx), content.substring(closeIdx + tag.length + 3));
  }

  List<List<InlineSpan>> _parseList(String ulHtml) {
    final items = <List<InlineSpan>>[];
    String rem = ulHtml;
    while (rem.contains('<li')) {
      final extracted = _extractTag(rem, 'li');
      if (extracted == null) break;
      items.add(_parseInline(extracted.$1));
      rem = extracted.$2;
    }
    return items;
  }

  // ── Inline span parser ────────────────────────────────────────────────────
  List<InlineSpan> _parseInline(String html) {
    final cs = Theme.of(_context).colorScheme;
    final spans = <InlineSpan>[];

    // Strip block-level tags we don't handle inline
    html = html.replaceAll(RegExp(r'</?(?:div|h[1-6]|p|ul|ol|li|pre|blockquote|section|article|header|footer|nav|aside|main)[^>]*>'), '');

    while (html.isNotEmpty) {
      if (!html.contains('<')) {
        spans.add(TextSpan(text: _collapseWs(decodeEntities(html))));
        break;
      }

      final tagStart = html.indexOf('<');
      if (tagStart > 0) {
        spans.add(TextSpan(
            text: _collapseWs(decodeEntities(html.substring(0, tagStart)))));
        html = html.substring(tagStart);
        continue;
      }

      // <b> or <strong>
      for (final bold in ['strong', 'b']) {
        if (html.startsWith('<$bold>') || html.startsWith('<$bold ')) {
          final ex = _extractTag(html, bold);
          if (ex != null) {
            spans.add(TextSpan(
              text: decodeEntities(_stripTags(ex.$1)),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ));
            html = ex.$2;
          } else {
            html = html.substring(1);
          }
          break;
        }
      }
      if (html.isEmpty) break;

      // <i> or <em>
      bool handled = false;
      for (final italic in ['em', 'i']) {
        if (html.startsWith('<$italic>') || html.startsWith('<$italic ')) {
          final ex = _extractTag(html, italic);
          if (ex != null) {
            spans.add(TextSpan(
              text: decodeEntities(_stripTags(ex.$1)),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ));
            html = ex.$2;
            handled = true;
          }
          break;
        }
      }
      if (handled) continue;

      // <code>
      if (html.startsWith('<code')) {
        final ex = _extractTag(html, 'code');
        if (ex != null) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: cs.outline),
              ),
              child: Text(
                decodeEntities(_stripTags(ex.$1)).replaceAll(' ', ' '),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  color: cs.primary,
                  height: 1.4,
                ),
              ),
            ),
          ));
          html = ex.$2;
          continue;
        }
      }

      // <a href="...">
      if (html.startsWith('<a ')) {
        final hrefMatch = RegExp(r'href="([^"]*)"').firstMatch(html);
        final ex = _extractTag(html, 'a');
        if (ex != null && hrefMatch != null) {
          final href = hrefMatch.group(1) ?? '';
          final text = decodeEntities(_stripTags(ex.$1));
          final onTap = _onLinkTap;
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => onTap?.call(_context, href),
              child: Text(
                text,
                style: TextStyle(
                  color: cs.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: cs.primary,
                ),
              ),
            ),
          ));
          html = ex.$2;
          continue;
        }
      }

      // <img> — skip
      if (html.startsWith('<img')) {
        final end = html.indexOf('>');
        html = end >= 0 ? html.substring(end + 1) : '';
        continue;
      }

      // Any other tag — skip the opening tag
      final end = html.indexOf('>');
      html = end >= 0 ? html.substring(end + 1) : '';
    }

    return spans;
  }

  String _stripTags(String s) => s.replaceAll(RegExp(r'<[^>]*>'), '');

  String _collapseWs(String s) => s.replaceAll(RegExp(r'\s+'), ' ');
}
