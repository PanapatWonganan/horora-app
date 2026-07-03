import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/core/utils/simple_markdown.dart';

/// Flattens a TextSpan tree into a list of (text, style) leaves, in order —
/// mirrors the helper in typewriter_rich_text_test.dart so both suites assert
/// on the same shape without depending on TextSpan's own equality.
List<MapEntry<String, TextStyle?>> _leaves(InlineSpan span) {
  final out = <MapEntry<String, TextStyle?>>[];
  void walk(InlineSpan node) {
    if (node is TextSpan) {
      if (node.text != null && node.text!.isNotEmpty) {
        out.add(MapEntry(node.text!, node.style));
      }
      node.children?.forEach(walk);
    }
  }

  walk(span);
  return out;
}

String _visibleText(InlineSpan span) => _leaves(span).map((e) => e.key).join();

void main() {
  const base = TextStyle(fontSize: 14, color: Colors.black);

  group('SimpleMarkdown.parse bold spans', () {
    test('bold segment gets FontWeight.w700 by default', () {
      final result = SimpleMarkdown.parse('plain **bold** tail', base: base);
      final leaves = _leaves(result);

      expect(_visibleText(result), 'plain bold tail');
      final boldLeaf = leaves.firstWhere((e) => e.key == 'bold');
      expect(boldLeaf.value?.fontWeight, FontWeight.w700);
      // Non-bold leaves keep the base style (no explicit style override).
      final plainLeaf = leaves.firstWhere((e) => e.key == 'plain ');
      expect(plainLeaf.value, isNull);
    });

    test('supplied bold style is used instead of the default w700', () {
      const customBold = TextStyle(fontWeight: FontWeight.w900, color: Colors.red);
      final result = SimpleMarkdown.parse(
        '**shout**',
        base: base,
        bold: customBold,
      );
      final leaves = _leaves(result);
      final boldLeaf = leaves.firstWhere((e) => e.key == 'shout');
      expect(boldLeaf.value, customBold);
    });

    test('multiple bold segments are each styled independently', () {
      final result =
          SimpleMarkdown.parse('**one** middle **two**', base: base);
      final leaves = _leaves(result);

      expect(_visibleText(result), 'one middle two');
      expect(leaves.firstWhere((e) => e.key == 'one').value?.fontWeight,
          FontWeight.w700);
      expect(leaves.firstWhere((e) => e.key == 'two').value?.fontWeight,
          FontWeight.w700);
      expect(leaves.firstWhere((e) => e.key == ' middle ').value, isNull);
    });

    test('root span carries the base style', () {
      final result = SimpleMarkdown.parse('hello', base: base);
      expect(result.style, base);
    });
  });

  group('SimpleMarkdown.parse heading markers', () {
    test('leading # heading markers are stripped', () {
      final result = SimpleMarkdown.parse('# Title\nbody text', base: base);
      expect(_visibleText(result), 'Title\nbody text');
    });

    test('multiple heading levels (##, ###) are stripped on each line', () {
      final result = SimpleMarkdown.parse(
        '## Section\ntext\n### Sub\nmore text',
        base: base,
      );
      expect(_visibleText(result), 'Section\ntext\nSub\nmore text');
    });

    test('heading marker combined with bold text still resolves correctly',
        () {
      final result = SimpleMarkdown.parse('# **Bold Title**', base: base);
      final leaves = _leaves(result);
      expect(_visibleText(result), 'Bold Title');
      expect(leaves.firstWhere((e) => e.key == 'Bold Title').value?.fontWeight,
          FontWeight.w700);
    });
  });

  group('SimpleMarkdown.parse stray unpaired markers', () {
    test('a single stray ** with no matching pair is stripped, not shown',
        () {
      final result = SimpleMarkdown.parse('this is **odd', base: base);
      expect(_visibleText(result), 'this is odd');
    });

    test(
        'an extra leading ** pairs with the next ** (non-greedy regex), '
        'leaving no stray asterisks in the visible text', () {
      final result =
          SimpleMarkdown.parse('odd ** then **bold** ok', base: base);
      // The non-greedy bold regex pairs the FIRST "**" it sees with the
      // NEXT "**", so "** then **" (not "**bold**") is the bold segment
      // here; "bold" itself ends up as trailing plain text. This documents
      // the actual (simple, not markdown-spec-perfect) behavior rather than
      // an idealized one.
      final visible = _visibleText(result);
      expect(visible, isNot(contains('*')));
      expect(visible, 'odd  then bold ok');
      final leaves = _leaves(result);
      expect(leaves.firstWhere((e) => e.key == ' then ').value?.fontWeight,
          FontWeight.w700);
      expect(leaves.firstWhere((e) => e.key == 'bold ok').value, isNull);
    });
  });

  group('SimpleMarkdown.parse plain text / edge cases', () {
    test('plain text with no markdown passes through unchanged', () {
      final result = SimpleMarkdown.parse('just plain text', base: base);
      expect(_visibleText(result), 'just plain text');
      expect(_leaves(result).every((e) => e.value == null), isTrue);
    });

    test('Thai text mixed with markdown bold renders correctly', () {
      final result =
          SimpleMarkdown.parse('สวัสดี **ดวงใจ** ยินดีต้อนรับ', base: base);
      final leaves = _leaves(result);
      expect(_visibleText(result), 'สวัสดี ดวงใจ ยินดีต้อนรับ');
      expect(leaves.firstWhere((e) => e.key == 'ดวงใจ').value?.fontWeight,
          FontWeight.w700);
    });

    test('Thai heading marker line is stripped like any other', () {
      final result = SimpleMarkdown.parse('# หัวข้อ\nเนื้อหา', base: base);
      expect(_visibleText(result), 'หัวข้อ\nเนื้อหา');
    });

    test('empty string yields an empty span with no children text', () {
      final result = SimpleMarkdown.parse('', base: base);
      expect(_visibleText(result), '');
      expect(result.style, base);
    });
  });
}
