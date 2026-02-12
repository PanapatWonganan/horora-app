import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openai_service.dart';

class SmartHoroscopeService {
  static const String _cachePrefix = 'smart_horoscope';
  static const int _cacheValidityDays = 7; // Cache valid for 7 days
  
  // Base templates ที่ไม่ต้องเรียก OpenAI
  static final Map<String, Map<String, List<String>>> _baseTemplates = {
    'ชวด': {
      'positive': [
        'ไหวพริบและความขยันของคุณจะเป็นกุญแจสู่ความสำเร็จ',
        'วันนี้เหมาะกับการใช้ความรอบคอบในการตัดสินใจ',
        'ความสามารถในการประหยัดจะช่วยให้คุณมีเงินเก็บ',
      ],
      'moderate': [
        'ควรระมัดระวังในการใช้จ่าย แม้จะมีเงินเก็บ',
        'อาจมีเรื่องเล็กน้อยให้คิดแก้ไข แต่ผ่านไปได้',
      ],
      'advice': [
        'ใช้ความอดทนและไหวพริบในการแก้ปัญหา',
        'การวางแผนล่วงหน้าจะช่วยให้ชีวิตราบรื่น',
      ]
    },
    'ฉลู': {
      'positive': [
        'ความมั่นคงและอดทนจะนำพาคุณสู่เป้าหมาย',
        'วันนี้เหมาะกับการลงทุนและวางแผนระยะยาว',
        'ความจริงใจของคุณจะได้รับการตอบแทน',
      ],
      'moderate': [
        'อาจต้องใช้เวลานานกว่าที่คิด แต่ผลลัพธ์จะดี',
        'ความดื้อรั้นอาจทำให้พลาดโอกาส ควรเปิดใจ',
      ],
      'advice': [
        'ความอดทนและความมั่นคงคือจุดแข็งของคุณ',
        'อย่าเปลี่ยนแปลงทิศทางบ่อยเกินไป',
      ]
    },
    'ขาล': {
      'positive': [
        'ความกล้าหาญและการเป็นผู้นำจะโดดเด่นวันนี้',
        'เหมาะกับการเริ่มโครงการใหม่และการแก้ปัญหาท้าทาย',
        'พลังแห่งการเปลี่ยนแปลงจะอยู่ข้างคุณ',
      ],
      'moderate': [
        'ควรระวังความหุนหันพลันแล่น อาจทำให้เกิดผลเสีย',
        'การตัดสินใจรวดเร็วอาจไม่เหมาะในทุกสถานการณ์',
      ],
      'advice': [
        'ใช้ความกล้าหาญอย่างชาญฉลาด',
        'การเป็นผู้นำต้องมาพร้อมกับความรับผิดชอบ',
      ]
    },
    'เถาะ': {
      'positive': [
        'ความอ่อนโยนและมารยาทจะสร้างความสัมพันธ์ที่ดี',
        'วันนี้เหมาะกับการทำงานเป็นทีมและการประนีประนอม',
        'ความสงบและสุขุมจะนำความสำเร็จมาให้',
      ],
      'moderate': [
        'อาจลังเลในการตัดสินใจครั้งสำคัญ',
        'ความอ่อนไหวอาจทำให้เสียโอกาสบางครั้ง',
      ],
      'advice': [
        'ความอ่อนโยนคือจุดแข็ง ไม่ใช่จุดอ่อน',
        'การรักสันติไม่ใช่การหลีกหนีปัญหา',
      ]
    },
    'มะโรง': {
      'positive': [
        'พลังและความมั่นใจของคุณจะเปล่งประกายวันนี้',
        'เหมาะกับการแสดงความสามารถและเป็นที่สนใจ',
        'ความกล้าหาญจะนำโอกาสดีๆ มาให้',
      ],
      'moderate': [
        'ควรระวังความหยิ่งผยองที่อาจสร้างศัตรู',
        'การต้องการความสนใจมากเกินไปอาจเป็นโทษ',
      ],
      'advice': [
        'ใช้พลังงานในทางสร้างสรรค์',
        'การเป็นที่สนใจควรมาจากคุณค่าที่แท้จริง',
      ]
    },
    'มะเส็ง': {
      'positive': [
        'ปัญญาและสัญชาตญาณจะช่วยในการตัดสินใจสำคัญ',
        'เหมาะกับการเรียนรู้สิ่งใหม่และการวิจัย',
        'ความลึกซึ้งในความคิดจะเป็นประโยชน์',
      ],
      'moderate': [
        'ความลึกซึ้งอาจทำให้คิดมากเกินไป',
        'การวิเคราะห์มากเกินไปอาจพลาดโอกาส',
      ],
      'advice': [
        'เชื่อมั่นในสัญชาตญาณของตัวเอง',
        'ความรู้คือพลัง แต่การปฏิบัติคือความสำเร็จ',
      ]
    },
    'มะเมีย': {
      'positive': [
        'ความกระฉับกระเฉงและรักเสรีภาพจะนำผลดีมาให้',
        'เหมาะกับการเดินทางและการผจญภัย',
        'ความตรงไปตรงมาจะได้รับการชื่นชม',
      ],
      'moderate': [
        'การพูดตรงเกินไปอาจทำให้คนอื่นไม่พอใจ',
        'ความรักเสรีภาพอาจขัดแย้งกับข้อผูกพัน',
      ],
      'advice': [
        'ความอิสระต้องมาพร้อมกับความรับผิดชอบ',
        'การผจญภัยควรมีการวางแผนที่ดี',
      ]
    },
    'มะแม': {
      'positive': [
        'ความอ่อนโยนและจิตใจศิลปินจะได้รับการชื่นชม',
        'เหมาะกับงานสร้างสรรค์และการดูแลผู้อื่น',
        'ความงามและความสง่างามจะอยู่รอบตัว',
      ],
      'moderate': [
        'ความอ่อนไหวอาจทำให้ได้รับผลกระทบง่าย',
        'การหลีกหนีความขัดแย้งอาจสะสมปัญหา',
      ],
      'advice': [
        'ความอ่อนโยนคือพลังที่ยิ่งใหญ่',
        'การแสดงออกทางศิลปะจะช่วยบำบัดจิตใจ',
      ]
    },
    'วอก': {
      'positive': [
        'ความฉลาดและไหวพริบจะช่วยแก้ปัญหาได้ดี',
        'เหมาะกับการเจรจาและการปรับเปลี่ยน',
        'ความยืดหยุ่นจะเป็นประโยชน์อย่างมาก',
      ],
      'moderate': [
        'การเปลี่ยนแปลงบ่อยอาจสร้างความสับสน',
        'ความฉลาดอาจทำให้ดูถูกผู้อื่น',
      ],
      'advice': [
        'ใช้ความฉลาดเพื่อช่วยเหลือผู้อื่น',
        'การปรับตัวคือกุญแจสู่ความสำเร็จ',
      ]
    },
    'ระกา': {
      'positive': [
        'ความตรงไปตรงมาและรักความสะอาดจะสร้างความน่าเชื่อถือ',
        'เหมาะกับการจัดระเบียบและปรับปรุง',
        'ความสวยงามจะเข้ามาในชีวิต',
      ],
      'moderate': [
        'ความเป็นนักสมบูรณ์แบบอาจสร้างความกดดัน',
        'การวิจารณ์มากเกินไปอาจทำร้ายความสัมพันธ์',
      ],
      'advice': [
        'ความสมบูรณ์แบบไม่จำเป็นในทุกสิ่ง',
        'การยอมรับข้อบกพร่องเป็นส่วนหนึ่งของความสวยงาม',
      ]
    },
    'จอ': {
      'positive': [
        'ความซื่อสัตย์และความรับผิดชอบจะได้รับการยอมรับ',
        'เหมาะกับการดูแลครอบครัวและงานที่ต้องใช้ความไว้วางใจ',
        'ความจริงใจจะได้รับรางวัล',
      ],
      'moderate': [
        'ความรับผิดชอบมากเกินไปอาจเป็นภาระ',
        'การไว้ใจคนอื่นง่ายเกินไปอาจถูกหลอก',
      ],
      'advice': [
        'ความซื่อสัตย์คือสมบัติที่มีค่าที่สุด',
        'การดูแลผู้อื่นต้องไม่ลืมดูแลตัวเอง',
      ]
    },
    'กุน': {
      'positive': [
        'ใจกว้างและความเอื้อเฟื้อจะนำความสุขมาให้',
        'เหมาะกับการช่วยเหลือผู้อื่นและสร้างความสุขสบาย',
        'การให้จะได้รับกลับคืนมาเป็นสิบเท่า',
      ],
      'moderate': [
        'ความเอื้อเฟื้อมากเกินไปอาจถูกเอาเปรียบ',
        'การใจดีอาจทำให้ลืมดูแลตัวเองบางครั้ง',
      ],
      'advice': [
        'ความใจกว้างคือพลังแห่งความสุข',
        'การให้อย่างฉลาดจะสร้างประโยชน์ยั่งยืน',
      ]
    }
  };

  // ดึงข้อมูลดวงชะตาแบบ smart
  static Future<Map<String, dynamic>> getDailyHoroscope(
    String thaiAnimal, 
    DateTime date,
  ) async {
    try {
      debugPrint('SmartHoroscopeService.getDailyHoroscope called with: "$thaiAnimal"');

      // 1. ตรวจสอบ cache ก่อน
      final cached = await _getCachedHoroscope(thaiAnimal, date);
      if (cached != null) {
        debugPrint('Using cached horoscope for $thaiAnimal');
        return cached;
      }

      // 2. ถ้าไม่มี cache ให้สร้างแบบ smart
      final horoscope = await _generateSmartHoroscope(thaiAnimal, date);
      
      // 3. Cache ข้อมูลที่สร้างใหม่
      await _cacheHoroscope(thaiAnimal, date, horoscope);

      debugPrint('Generated new horoscope for $thaiAnimal: ${horoscope['generated_by']}');
      return horoscope;
    } catch (e) {
      debugPrint('Error in SmartHoroscopeService: $e');
      // 4. หาก error ใช้ template พื้นฐาน
      return _generateBasicHoroscope(thaiAnimal, date);
    }
  }

  // สร้างดวงชะตาแบบ smart (ผสม OpenAI + templates)
  static Future<Map<String, dynamic>> _generateSmartHoroscope(
    String thaiAnimal,
    DateTime date,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // ตรวจสอบว่าเคยเรียก OpenAI สำหรับสัปดาห์นี้แล้วหรือไม่
    final weekKey = _getWeekKey(date);
    final openaiUsageKey = '${_cachePrefix}_openai_usage_${thaiAnimal}_$weekKey';
    final hasUsedOpenAI = prefs.getBool(openaiUsageKey) ?? false;

    if (!hasUsedOpenAI && _shouldUseOpenAI()) {
      try {
        // เรียก OpenAI เพื่อสร้างข้อมูล 7 วันข้างหน้า
        final weeklyData = await _generateWeeklyWithOpenAI(thaiAnimal, date);
        
        // Cache ข้อมูล 7 วัน
        await _cacheWeeklyData(thaiAnimal, date, weeklyData);
        
        // Mark ว่าใช้ OpenAI แล้วสำหรับสัปดาห์นี้
        await prefs.setBool(openaiUsageKey, true);
        
        // Return ข้อมูลวันนี้
        return weeklyData[date.day.toString()] ?? _generateBasicHoroscope(thaiAnimal, date);
      } catch (e) {
        // หาก OpenAI fail ใช้ template
        return _generateBasicHoroscope(thaiAnimal, date);
      }
    } else {
      // ใช้ template + algorithm
      return _generateBasicHoroscope(thaiAnimal, date);
    }
  }

  // สร้างข้อมูล 7 วันด้วย OpenAI
  static Future<Map<String, dynamic>> _generateWeeklyWithOpenAI(
    String thaiAnimal, 
    DateTime startDate,
  ) async {
    final openaiService = OpenAIService.instance;
    final endDate = startDate.add(const Duration(days: 6));
    
    final prompt = '''
คุณเป็นนักพยากรณ์ไทยที่เชี่ยวชาญเรื่องปีนักษัตรไทย

สร้างคำทำนายสำหรับคนเกิดปี$thaiAnimal 
ตั้งแต่วันที่ ${startDate.day}/${startDate.month}/${startDate.year}
ถึงวันที่ ${endDate.day}/${endDate.month}/${endDate.year}

สร้างในรูปแบบ JSON:
{
  "1": {
    "content_th": "คำทำนายภาษาไทย",
    "love_rating": 4,
    "career_rating": 3,
    "health_rating": 5,
    "lucky_number": "7, 14, 21",
    "lucky_color": "น้ำเงิน"
  },
  "2": { ... }
}

เน้นลักษณะเด่นของปี$thaiAnimal และใช้ภาษาไทยที่เข้าใจง่าย
''';

    final response = await openaiService.sendMessage(
      prompt: prompt,
      history: [],
      model: 'gpt-4o-mini', // ใช้ model ที่ถูกกว่า
      temperature: 0.8,
      maxTokens: 1500, // จำกัด token
    );

    try {
      final content = response['content'][0]['text'];
      return jsonDecode(content);
    } catch (e) {
      throw Exception('Failed to parse OpenAI response: $e');
    }
  }

  // สร้างดวงชะตาพื้นฐานด้วย templates + algorithm
  static Map<String, dynamic> _generateBasicHoroscope(
    String thaiAnimal, 
    DateTime date,
  ) {
    final templates = _baseTemplates[thaiAnimal] ?? _baseTemplates['ชวด']!;
    final random = Random(date.millisecondsSinceEpoch); // Seed เดียวกันสำหรับวันเดียวกัน
    
    // เลือก template ตามวันในเดือน
    final dayInfluence = _calculateDayInfluence(date);
    String mood;
    List<String> contentPool;
    
    if (dayInfluence > 0.7) {
      mood = 'positive';
      contentPool = templates['positive']!;
    } else if (dayInfluence > 0.3) {
      mood = 'moderate'; 
      contentPool = templates['moderate']!;
    } else {
      mood = 'advice';
      contentPool = templates['advice']!;
    }

    final content = contentPool[random.nextInt(contentPool.length)];
    
    return {
      'content_th': content,
      'love_rating': _calculateRating(thaiAnimal, 'love', date),
      'career_rating': _calculateRating(thaiAnimal, 'career', date),
      'health_rating': _calculateRating(thaiAnimal, 'health', date),
      'lucky_number': _generateLuckyNumber(thaiAnimal, date),
      'lucky_color': _generateLuckyColor(thaiAnimal, date),
      'mood': mood,
      'generated_by': 'template',
    };
  }

  // คำนวณอิทธิพลของวัน (0.0 - 1.0)
  static double _calculateDayInfluence(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final moonPhase = (dayOfYear % 29.53) / 29.53; // Approximate moon phase
    final weekday = date.weekday;
    
    // สูตรคำนวณอิทธิพล (ปรับได้ตามต้องการ)
    double influence = 0.5; // Base
    
    // Moon phase influence
    if (moonPhase < 0.25 || moonPhase > 0.75) {
      influence += 0.2; // New moon, Full moon = positive
    }
    
    // Weekday influence
    if (weekday == 1 || weekday == 6) {
      influence += 0.1; // Monday, Saturday = positive
    }
    
    // Day of month influence
    if (date.day % 7 == 0 || date.day % 9 == 0) {
      influence += 0.1; // Numbers 7, 9 = positive
    }
    
    return influence.clamp(0.0, 1.0);
  }

  // คำนวณคะแนนต่างๆ
  static int _calculateRating(String thaiAnimal, String aspect, DateTime date) {
    final seed = thaiAnimal.codeUnitAt(0) + aspect.codeUnitAt(0) + date.day;
    final random = Random(seed);
    final dayInfluence = _calculateDayInfluence(date);
    
    int baseRating = 3;
    if (dayInfluence > 0.7) baseRating = 4;
    if (dayInfluence > 0.8) baseRating = 5;
    if (dayInfluence < 0.3) baseRating = 2;
    
    return (baseRating + random.nextInt(2) - 1).clamp(1, 5);
  }

  // สร้างเลขนำโชค
  static String _generateLuckyNumber(String thaiAnimal, DateTime date) {
    final animalIndex = ['ชวด', 'ฉลู', 'ขาล', 'เถาะ', 'มะโรง', 'มะเส็ง', 
                        'มะเมีย', 'มะแม', 'วอก', 'ระกา', 'จอ', 'กุน'].indexOf(thaiAnimal);
    final baseNum = (animalIndex + 1) % 10;
    final lucky1 = (baseNum + date.day) % 50;
    final lucky2 = (baseNum * 2 + date.month) % 50;
    final lucky3 = (baseNum * 3 + date.year % 100) % 50;
    
    return '$lucky1, $lucky2, $lucky3';
  }

  // สร้างสีนำโชค
  static String _generateLuckyColor(String thaiAnimal, DateTime date) {
    final colors = {
      'ชวด': ['ทอง', 'เหลือง', 'น้ำตาล'],
      'ฉลู': ['เขียว', 'น้ำตาล', 'ดำ'],
      'ขาล': ['แดง', 'ส้ม', 'ชมพู'],
      'เถาะ': ['เงิน', 'ขาว', 'ฟ้าอ่อน'],
      'มะโรง': ['เขียว', 'แดง', 'ทอง'],
      'มะเส็ง': ['น้ำเงิน', 'ดำ', 'เงิน'],
      'มะเมีย': ['ม่วง', 'แดง', 'ส้ม'],
      'มะแม': ['ชมพู', 'เงิน', 'ขาว'],
      'วอก': ['เหลือง', 'ทอง', 'ส้ม'],
      'ระกา': ['ขาว', 'เงิน', 'ฟ้า'],
      'จอ': ['น้ำตาล', 'ทอง', 'เหลือง'],
      'กุน': ['ดำ', 'น้ำเงิน', 'ม่วงเข้ม'],
    };
    
    final animalColors = colors[thaiAnimal] ?? colors['ชวด']!;
    final colorIndex = (date.day + date.month) % animalColors.length;
    final secondColorIndex = (colorIndex + 1) % animalColors.length;
    
    return '${animalColors[colorIndex]}, ${animalColors[secondColorIndex]}';
  }

  // Helper functions
  static String _getWeekKey(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final weekNumber = ((date.difference(startOfYear).inDays) / 7).ceil();
    return '${date.year}_$weekNumber';
  }

  static bool _shouldUseOpenAI() {
    // สุ่มว่าจะใช้ OpenAI หรือไม่ (เช่น 20% ของเวลา)
    return Random().nextDouble() < 0.2;
  }

  static Future<Map<String, dynamic>?> _getCachedHoroscope(
    String thaiAnimal, 
    DateTime date,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_cachePrefix}_${thaiAnimal}_${date.day}_${date.month}_${date.year}';
    final cached = prefs.getString(key);
    
    if (cached != null) {
      try {
        final data = jsonDecode(cached);
        final cachedDate = DateTime.parse(data['cached_at']);
        
        // ตรวจสอบว่า cache ยังไม่หมดอายุ
        if (DateTime.now().difference(cachedDate).inDays < _cacheValidityDays) {
          return data['horoscope'];
        }
      } catch (e) {
        // Cache corrupted, will regenerate
      }
    }
    
    return null;
  }

  static Future<void> _cacheHoroscope(
    String thaiAnimal, 
    DateTime date, 
    Map<String, dynamic> horoscope,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_cachePrefix}_${thaiAnimal}_${date.day}_${date.month}_${date.year}';
    
    final cacheData = {
      'horoscope': horoscope,
      'cached_at': DateTime.now().toIso8601String(),
    };
    
    await prefs.setString(key, jsonEncode(cacheData));
  }

  static Future<void> _cacheWeeklyData(
    String thaiAnimal, 
    DateTime startDate, 
    Map<String, dynamic> weeklyData,
  ) async {
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final dayData = weeklyData[date.day.toString()];
      
      if (dayData != null) {
        await _cacheHoroscope(thaiAnimal, date, dayData);
      }
    }
  }

  // ล้าง cache ที่หมดอายุ
  static Future<void> clearExpiredCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
    
    for (final key in keys) {
      final cached = prefs.getString(key);
      if (cached != null) {
        try {
          final data = jsonDecode(cached);
          final cachedDate = DateTime.parse(data['cached_at']);
          
          if (DateTime.now().difference(cachedDate).inDays >= _cacheValidityDays) {
            await prefs.remove(key);
          }
        } catch (e) {
          // Remove corrupted cache
          await prefs.remove(key);
        }
      }
    }
  }

  // ล้าง cache ทั้งหมด (สำหรับ debug)
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix)).toList();

    debugPrint('Clearing ${keys.length} cached horoscope entries...');
    for (final key in keys) {
      await prefs.remove(key);
    }
    debugPrint('All SmartHoroscope cache cleared!');
  }
}