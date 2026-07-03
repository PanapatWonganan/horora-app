import 'package:flutter/material.dart';

/// Renders the small subset of Markdown that the AI models actually emit
/// (**bold**, heading markers) without pulling in a full markdown package.
/// Everything else is passed through as plain text.
class SimpleMarkdown {
  SimpleMarkdown._();

  static final RegExp _bold = RegExp(r'\*\*(.+?)\*\*');
  static final RegExp _heading = RegExp(r'^#{1,6}\s*', multiLine: true);

  /// Parses [text] into spans where `**...**` segments use [bold]
  /// (defaults to [base] with FontWeight.w700). Leading `#` heading
  /// markers and any stray unpaired `**` are stripped.
  static TextSpan parse(String text, {required TextStyle base, TextStyle? bold}) {
    final boldStyle = bold ?? base.copyWith(fontWeight: FontWeight.w700);
    final cleaned = text.replaceAll(_heading, '');

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in _bold.allMatches(cleaned)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
            text: cleaned.substring(cursor, match.start).replaceAll('**', '')));
      }
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      cursor = match.end;
    }
    if (cursor < cleaned.length) {
      spans.add(TextSpan(text: cleaned.substring(cursor).replaceAll('**', '')));
    }
    return TextSpan(style: base, children: spans);
  }
}
