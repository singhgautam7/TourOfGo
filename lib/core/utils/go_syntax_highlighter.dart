import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/code_colors.dart';

const _noLigatures = <FontFeature>[
  FontFeature.disable('liga'),
  FontFeature.disable('calt'),
];

const Set<String> _keywords = {
  'package', 'import', 'func', 'var', 'const', 'type', 'struct', 'interface',
  'for', 'if', 'else', 'switch', 'case', 'default', 'return', 'go', 'chan',
  'select', 'defer', 'map', 'range', 'break', 'continue', 'fallthrough',
  'goto', 'make', 'new', 'len', 'cap', 'append', 'copy', 'delete', 'close',
  'true', 'false', 'nil',
};

const Set<String> _builtinTypes = {
  'int', 'int8', 'int16', 'int32', 'int64',
  'uint', 'uint8', 'uint16', 'uint32', 'uint64',
  'float32', 'float64', 'complex64', 'complex128',
  'bool', 'string', 'byte', 'rune', 'error', 'any', 'comparable',
};

enum _TokType { lineComment, blockComment, rawStr, str, rune, keyword, builtin, number, plain }

class _Token {
  final _TokType type;
  final String text;
  const _Token(this.type, this.text);
}

class GoSyntaxHighlighter {
  static List<TextSpan> highlight(String code, {required bool isDark}) {
    final tokens = _tokenize(code);
    return tokens.map((t) => _toSpan(t, isDark)).toList();
  }

  static List<_Token> _tokenize(String src) {
    final tokens = <_Token>[];
    int i = 0;
    final n = src.length;

    while (i < n) {
      // Line comment
      if (i + 1 < n && src[i] == '/' && src[i + 1] == '/') {
        int j = i;
        while (j < n && src[j] != '\n') { j++; }
        tokens.add(_Token(_TokType.lineComment, src.substring(i, j)));
        i = j;
        continue;
      }

      // Block comment
      if (i + 1 < n && src[i] == '/' && src[i + 1] == '*') {
        int j = i + 2;
        while (j + 1 < n && !(src[j] == '*' && src[j + 1] == '/')) { j++; }
        j = (j + 2).clamp(0, n);
        tokens.add(_Token(_TokType.blockComment, src.substring(i, j)));
        i = j;
        continue;
      }

      // Raw string
      if (src[i] == '`') {
        int j = i + 1;
        while (j < n && src[j] != '`') { j++; }
        j = (j + 1).clamp(0, n);
        tokens.add(_Token(_TokType.rawStr, src.substring(i, j)));
        i = j;
        continue;
      }

      // String literal
      if (src[i] == '"') {
        int j = i + 1;
        while (j < n && src[j] != '"') {
          if (src[j] == '\\') { j++; }
          j++;
        }
        j = (j + 1).clamp(0, n);
        tokens.add(_Token(_TokType.str, src.substring(i, j)));
        i = j;
        continue;
      }

      // Rune literal
      if (src[i] == "'") {
        int j = i + 1;
        while (j < n && src[j] != "'") {
          if (src[j] == '\\') { j++; }
          j++;
        }
        j = (j + 1).clamp(0, n);
        tokens.add(_Token(_TokType.rune, src.substring(i, j)));
        i = j;
        continue;
      }

      // Number
      if (_isDigit(src[i])) {
        int j = i;
        while (j < n && (_isDigit(src[j]) || src[j] == '.' || src[j] == 'x' || src[j] == 'X' || _isHexChar(src[j]))) { j++; }
        tokens.add(_Token(_TokType.number, src.substring(i, j)));
        i = j;
        continue;
      }

      // Identifier or keyword
      if (_isAlpha(src[i])) {
        int j = i;
        while (j < n && _isAlphaNum(src[j])) { j++; }
        final word = src.substring(i, j);
        if (_keywords.contains(word)) {
          tokens.add(_Token(_TokType.keyword, word));
        } else if (_builtinTypes.contains(word)) {
          tokens.add(_Token(_TokType.builtin, word));
        } else {
          tokens.add(_Token(_TokType.plain, word));
        }
        i = j;
        continue;
      }

      // Anything else
      tokens.add(_Token(_TokType.plain, src[i]));
      i++;
    }

    return tokens;
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  static bool _isHexChar(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 70) || (code >= 97 && code <= 102);
  }
  static bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122) || code == 95;
  }
  static bool _isAlphaNum(String c) => _isAlpha(c) || _isDigit(c);

  static TextSpan _toSpan(_Token tok, bool isDark) {
    final baseStyle = GoogleFonts.jetBrainsMono(
      fontSize: 13,
      height: 1.6,
      fontFeatures: _noLigatures,
    );
    switch (tok.type) {
      case _TokType.lineComment:
      case _TokType.blockComment:
        return TextSpan(
          text: tok.text,
          style: baseStyle.copyWith(
            color: isDark ? CodeColors.comment : CodeColors.commentLight,
            fontStyle: FontStyle.italic,
          ),
        );
      case _TokType.rawStr:
      case _TokType.str:
      case _TokType.rune:
        return TextSpan(
          text: tok.text,
          style: baseStyle.copyWith(
            color: isDark ? CodeColors.string : CodeColors.stringLight,
          ),
        );
      case _TokType.keyword:
        return TextSpan(
          text: tok.text,
          style: baseStyle.copyWith(
            color: isDark ? CodeColors.keyword : CodeColors.keywordLight,
            fontWeight: FontWeight.w600,
          ),
        );
      case _TokType.builtin:
        return TextSpan(
          text: tok.text,
          style: baseStyle.copyWith(
            color: isDark ? CodeColors.typeName : CodeColors.typeNameLight,
          ),
        );
      case _TokType.number:
        return TextSpan(
          text: tok.text,
          style: baseStyle.copyWith(
            color: isDark ? CodeColors.number : CodeColors.numberLight,
          ),
        );
      case _TokType.plain:
        return TextSpan(
          text: tok.text,
          style: baseStyle.copyWith(
            color: isDark ? CodeColors.plain : CodeColors.plainLight,
          ),
        );
    }
  }
}
