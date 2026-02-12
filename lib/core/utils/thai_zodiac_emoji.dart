import 'package:flutter/material.dart';
import 'app_icons.dart';

/// Utility class for Thai Zodiac icons and display names
class ThaiZodiacEmoji {
  /// Legacy emoji map (for backward compatibility if needed)
  static const Map<String, String> emoji = {
    'ชวด': '🐀',
    'ฉลู': '🐂',
    'ขาล': '🐅',
    'เถาะ': '🐇',
    'มะโรง': '🐉',
    'มะเส็ง': '🐍',
    'มะเมีย': '🐴',
    'มะแม': '🐐',
    'วอก': '🐒',
    'ระกา': '🐓',
    'จอ': '🐕',
    'กุน': '🐷',
  };

  static const Map<String, String> displayNames = {
    'ชวด': 'ปีชวด (หนู)',
    'ฉลู': 'ปีฉลู (วัว)',
    'ขาล': 'ปีขาล (เสือ)',
    'เถาะ': 'ปีเถาะ (กระต่าย)',
    'มะโรง': 'ปีมะโรง (งูใหญ่)',
    'มะเส็ง': 'ปีมะเส็ง (งูเล็ก)',
    'มะเมีย': 'ปีมะเมีย (ม้า)',
    'มะแม': 'ปีมะแม (แพะ)',
    'วอก': 'ปีวอก (ลิง)',
    'ระกา': 'ปีระกา (ไก่)',
    'จอ': 'ปีจอ (สุนัข)',
    'กุน': 'ปีกุน (หมู)',
  };

  /// Get emoji for Thai zodiac animal (legacy)
  static String getEmoji(String animal) {
    return emoji[animal] ?? '🐾';
  }

  /// Get display name for Thai zodiac animal
  static String getDisplayName(String animal) {
    return displayNames[animal] ?? 'ปี$animal';
  }

  /// Get SVG icon path for Thai zodiac animal
  static String getIconPath(String animal) {
    return AppIcons.getThaiZodiacIcon(animal);
  }

  /// Get SVG icon widget for Thai zodiac animal
  static Widget getIcon(String animal, {double size = 24, Color? color}) {
    return ThaiZodiacIcon(
      animal: animal,
      size: size,
      color: color,
    );
  }
}
