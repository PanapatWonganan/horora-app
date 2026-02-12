import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/exceptions.dart' as ex;

class OpenAIClient {
  final String apiKey;
  final http.Client httpClient;
  final SharedPreferences prefs;

  // Cache key constants
  static const String _dailyHoroscopeCacheKey = 'openai_daily_horoscope';
  static const String _weeklyHoroscopeCacheKey = 'openai_weekly_horoscope';
  static const String _monthlyHoroscopeCacheKey = 'openai_monthly_horoscope';

  OpenAIClient({
    required this.apiKey,
    required this.prefs,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// ขอดวงชะตารายวันจาก OpenAI API
  Future<Map<String, dynamic>> getDailyHoroscope(String zodiacSign) async {
    // ตรวจสอบแคชก่อน
    final today = DateTime.now().toIso8601String().split('T')[0];
    final cacheKey = '${_dailyHoroscopeCacheKey}_${zodiacSign}_$today';

    // ถ้ามีข้อมูลในแคช ให้ใช้ข้อมูลจากแคช
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      return jsonDecode(cachedData);
    }

    // สร้างคำขอไปยัง OpenAI
    final prompt = _createDailyHoroscopePrompt(zodiacSign);

    try {
      final response = await _sendRequest(prompt);

      // แปลงข้อความตอบกลับเป็นรูปแบบดวงชะตา
      final horoscope = _parseDailyHoroscopeResponse(response, zodiacSign);

      // บันทึกลงแคช
      await prefs.setString(cacheKey, jsonEncode(horoscope));

      return horoscope;
    } catch (e) {
      throw ex.ApiException(
          'Failed to get horoscope from OpenAI: ${e.toString()}');
    }
  }

  /// ขอดวงชะตารายสัปดาห์จาก OpenAI API
  Future<Map<String, dynamic>> getWeeklyHoroscope(String zodiacSign) async {
    // ตรวจสอบแคชก่อน
    final today = DateTime.now();
    final weekStart = today
        .subtract(Duration(days: today.weekday - 1))
        .toIso8601String()
        .split('T')[0];
    final cacheKey = '${_weeklyHoroscopeCacheKey}_${zodiacSign}_$weekStart';

    // ถ้ามีข้อมูลในแคช ให้ใช้ข้อมูลจากแคช
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      return jsonDecode(cachedData);
    }

    // สร้างคำขอไปยัง OpenAI
    final prompt = _createWeeklyHoroscopePrompt(zodiacSign);

    try {
      final response = await _sendRequest(prompt);

      // แปลงข้อความตอบกลับเป็นรูปแบบดวงชะตา
      final horoscope = _parseWeeklyHoroscopeResponse(response, zodiacSign);

      // บันทึกลงแคช
      await prefs.setString(cacheKey, jsonEncode(horoscope));

      return horoscope;
    } catch (e) {
      throw ex.ApiException(
          'Failed to get weekly horoscope from OpenAI: ${e.toString()}');
    }
  }

  /// ขอดวงชะตารายเดือนจาก OpenAI API
  Future<Map<String, dynamic>> getMonthlyHoroscope(String zodiacSign) async {
    // ตรวจสอบแคชก่อน
    final today = DateTime.now();
    final monthStart =
        DateTime(today.year, today.month, 1).toIso8601String().split('T')[0];
    final cacheKey = '${_monthlyHoroscopeCacheKey}_${zodiacSign}_$monthStart';

    // ถ้ามีข้อมูลในแคช ให้ใช้ข้อมูลจากแคช
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      return jsonDecode(cachedData);
    }

    // สร้างคำขอไปยัง OpenAI
    final prompt = _createMonthlyHoroscopePrompt(zodiacSign);

    try {
      final response = await _sendRequest(prompt);

      // แปลงข้อความตอบกลับเป็นรูปแบบดวงชะตา
      final horoscope = _parseMonthlyHoroscopeResponse(response, zodiacSign);

      // บันทึกลงแคช
      await prefs.setString(cacheKey, jsonEncode(horoscope));

      return horoscope;
    } catch (e) {
      throw ex.ApiException(
          'Failed to get monthly horoscope from OpenAI: ${e.toString()}');
    }
  }

  /// ส่งคำขอไปยัง OpenAI API
  Future<String> _sendRequest(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are an astrology expert providing daily, weekly, and monthly horoscopes.'
        },
        {'role': 'user', 'content': prompt}
      ],
      'temperature': 0.7,
      'max_tokens': 500,
    });

    try {
      final response = await httpClient
          .post(
            url,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw ex.ApiException(
            'OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw ex.ApiException('Failed to connect to OpenAI: ${e.toString()}');
    }
  }

  /// สร้างคำขอสำหรับดวงชะตารายวัน
  String _createDailyHoroscopePrompt(String zodiacSign) {
    return '''
    สร้างดวงชะตารายวันสำหรับปีนักษัตรไทย "$zodiacSign" ในวันนี้ โดยให้ครอบคลุมเรื่องต่อไปนี้:
    1. คำทำนายทั่วไป (ประมาณ 3-4 ประโยค)
    2. คะแนนความรัก (1-5)
    3. คะแนนอาชีพ (1-5)
    4. คะแนนสุขภาพ (1-5)
    5. เลขนำโชค (3 ตัว)
    6. สีนำโชค (2 สี)
    
    โปรดตอบเป็นภาษาไทยและให้ข้อมูลครบทุกหัวข้อที่กำหนดไว้ ขอให้ทำนายในเชิงบวกและให้กำลังใจ
    ''';
  }

  /// สร้างคำขอสำหรับดวงชะตารายสัปดาห์
  String _createWeeklyHoroscopePrompt(String zodiacSign) {
    return '''
    สร้างดวงชะตารายสัปดาห์สำหรับปีนักษัตรไทย "$zodiacSign" ในสัปดาห์นี้ โดยให้ครอบคลุมเรื่องต่อไปนี้:
    1. คำทำนายทั่วไป (ประมาณ 4-5 ประโยค)
    2. ด้านความรัก (2-3 ประโยค พร้อมคะแนน 1-5)
    3. ด้านอาชีพ (2-3 ประโยค พร้อมคะแนน 1-5)
    4. ด้านสุขภาพ (2-3 ประโยค พร้อมคะแนน 1-5)
    5. ด้านการเงิน (2-3 ประโยค พร้อมคะแนน 1-5)
    6. เลขนำโชค (5 ตัว)
    7. วันนำโชค (2 วัน)
    8. สีนำโชค (2 สี)
    
    โปรดตอบเป็นภาษาไทยและให้ข้อมูลครบทุกหัวข้อที่กำหนดไว้ ขอให้ทำนายในเชิงบวกและให้กำลังใจ
    ''';
  }

  /// สร้างคำขอสำหรับดวงชะตารายเดือน
  String _createMonthlyHoroscopePrompt(String zodiacSign) {
    final today = DateTime.now();
    final monthNames = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    final currentMonth = monthNames[today.month - 1];

    return '''
    สร้างดวงชะตาประจำเดือน$currentMonth สำหรับปีนักษัตรไทย "$zodiacSign" โดยให้ครอบคลุมเรื่องต่อไปนี้:
    1. คำทำนายทั่วไป (ประมาณ 5-6 ประโยค)
    2. ด้านความรัก (3-4 ประโยค พร้อมคะแนน 1-5)
    3. ด้านอาชีพ (3-4 ประโยค พร้อมคะแนน 1-5)
    4. ด้านสุขภาพ (3-4 ประโยค พร้อมคะแนน 1-5)
    5. ด้านการเงิน (3-4 ประโยค พร้อมคะแนน 1-5)
    6. ช่วงวันที่ดีที่สุดของเดือน (ระบุช่วงวันที่)
    7. เลขนำโชค (5 ตัว)
    8. สีนำโชค (2-3 สี)
    
    โปรดตอบเป็นภาษาไทยและให้ข้อมูลครบทุกหัวข้อที่กำหนดไว้ ขอให้ทำนายในเชิงบวกและให้กำลังใจ
    ''';
  }

  /// แปลงข้อความตอบกลับเป็นรูปแบบดวงชะตารายวัน
  Map<String, dynamic> _parseDailyHoroscopeResponse(
      String response, String zodiacSign) {
    // เก็บคะแนนที่ได้จากการวิเคราะห์ข้อความ
    int loveRating = 3;
    int careerRating = 3;
    int healthRating = 3;
    String luckyNumber = "7, 9, 2";
    String luckyColor = "น้ำเงิน, ขาว";

    // พยายามสกัดคะแนนจากข้อความ
    final loveMatch = RegExp(r'ความรัก.*?(\d+)').firstMatch(response);
    if (loveMatch != null) {
      loveRating = int.tryParse(loveMatch.group(1) ?? '3') ?? 3;
    }

    final careerMatch = RegExp(r'อาชีพ.*?(\d+)').firstMatch(response);
    if (careerMatch != null) {
      careerRating = int.tryParse(careerMatch.group(1) ?? '3') ?? 3;
    }

    final healthMatch = RegExp(r'สุขภาพ.*?(\d+)').firstMatch(response);
    if (healthMatch != null) {
      healthRating = int.tryParse(healthMatch.group(1) ?? '3') ?? 3;
    }

    // พยายามสกัดเลขนำโชคและสีนำโชค
    final luckyNumberMatch =
        RegExp(r'เลขนำโชค.*?[^\d]([\d, ]+)').firstMatch(response);
    if (luckyNumberMatch != null) {
      luckyNumber = luckyNumberMatch.group(1)?.trim() ?? luckyNumber;
    }

    final luckyColorMatch =
        RegExp(r'สีนำโชค.*?[:]?([\\u0E00-\\u0E7F\\s,]+)', unicode: true)
            .firstMatch(response);
    if (luckyColorMatch != null) {
      luckyColor = luckyColorMatch.group(1)?.trim() ?? luckyColor;
    }

    return {
      'id': 1,
      'zodiac_sign': zodiacSign,
      'date': DateTime.now().toIso8601String(),
      'content': 'Generated by OpenAI',
      'content_th': response,
      'love_rating': loveRating,
      'career_rating': careerRating,
      'health_rating': healthRating,
      'lucky_number': luckyNumber,
      'lucky_color': luckyColor,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// แปลงข้อความตอบกลับเป็นรูปแบบดวงชะตารายสัปดาห์
  Map<String, dynamic> _parseWeeklyHoroscopeResponse(
      String response, String zodiacSign) {
    // เก็บคะแนนที่ได้จากการวิเคราะห์ข้อความ
    int loveRating = 3;
    int careerRating = 3;
    int healthRating = 3;
    int financeRating = 3;
    String luckyNumbers = "3, 7, 15, 25, 36";
    String luckyDay = "วันอังคาร, วันเสาร์";
    String luckyColor = "แดง, น้ำเงิน";

    // พยายามสกัดคะแนนจากข้อความ
    final loveMatch = RegExp(r'ความรัก.*?(\d+)').firstMatch(response);
    if (loveMatch != null) {
      loveRating = int.tryParse(loveMatch.group(1) ?? '3') ?? 3;
    }

    final careerMatch = RegExp(r'อาชีพ.*?(\d+)').firstMatch(response);
    if (careerMatch != null) {
      careerRating = int.tryParse(careerMatch.group(1) ?? '3') ?? 3;
    }

    final healthMatch = RegExp(r'สุขภาพ.*?(\d+)').firstMatch(response);
    if (healthMatch != null) {
      healthRating = int.tryParse(healthMatch.group(1) ?? '3') ?? 3;
    }

    final financeMatch = RegExp(r'การเงิน.*?(\d+)').firstMatch(response);
    if (financeMatch != null) {
      financeRating = int.tryParse(financeMatch.group(1) ?? '3') ?? 3;
    }

    // สกัดข้อมูลอื่นๆ
    final luckyNumbersMatch =
        RegExp(r'เลขนำโชค.*?[^\d]([\d, ]+)').firstMatch(response);
    if (luckyNumbersMatch != null) {
      luckyNumbers = luckyNumbersMatch.group(1)?.trim() ?? luckyNumbers;
    }

    final luckyDayMatch =
        RegExp(r'วันนำโชค.*?[:]?([\\u0E00-\\u0E7F\\s,]+)', unicode: true)
            .firstMatch(response);
    if (luckyDayMatch != null) {
      luckyDay = luckyDayMatch.group(1)?.trim() ?? luckyDay;
    }

    final luckyColorMatch =
        RegExp(r'สีนำโชค.*?[:]?([\\u0E00-\\u0E7F\\s,]+)', unicode: true)
            .firstMatch(response);
    if (luckyColorMatch != null) {
      luckyColor = luckyColorMatch.group(1)?.trim() ?? luckyColor;
    }

    return {
      'general': response,
      'love': {
        'rating': loveRating,
        'description':
            _extractSection(response, 'ความรัก', 'อาชีพ') ?? 'ความรักราบรื่น',
      },
      'career': {
        'rating': careerRating,
        'description':
            _extractSection(response, 'อาชีพ', 'สุขภาพ') ?? 'อาชีพก้าวหน้า',
      },
      'health': {
        'rating': healthRating,
        'description':
            _extractSection(response, 'สุขภาพ', 'การเงิน') ?? 'สุขภาพแข็งแรง',
      },
      'finance': {
        'rating': financeRating,
        'description':
            _extractSection(response, 'การเงิน', 'เลขนำโชค') ?? 'การเงินดี',
      },
      'lucky_numbers': luckyNumbers,
      'lucky_day': luckyDay,
      'lucky_color': luckyColor,
    };
  }

  /// แปลงข้อความตอบกลับเป็นรูปแบบดวงชะตารายเดือน
  Map<String, dynamic> _parseMonthlyHoroscopeResponse(
      String response, String zodiacSign) {
    // คล้ายกับวิธีการแปลงรายสัปดาห์ แต่มีบางส่วนที่แตกต่าง
    int loveRating = 3;
    int careerRating = 3;
    int healthRating = 3;
    int financeRating = 3;
    String bestDays = "1-15";
    String luckyNumbers = "3, 7, 15, 25, 36";
    String luckyColor = "แดง, น้ำเงิน, ทอง";

    // พยายามสกัดคะแนนจากข้อความ
    final loveMatch = RegExp(r'ความรัก.*?(\d+)').firstMatch(response);
    if (loveMatch != null) {
      loveRating = int.tryParse(loveMatch.group(1) ?? '3') ?? 3;
    }

    final careerMatch = RegExp(r'อาชีพ.*?(\d+)').firstMatch(response);
    if (careerMatch != null) {
      careerRating = int.tryParse(careerMatch.group(1) ?? '3') ?? 3;
    }

    final healthMatch = RegExp(r'สุขภาพ.*?(\d+)').firstMatch(response);
    if (healthMatch != null) {
      healthRating = int.tryParse(healthMatch.group(1) ?? '3') ?? 3;
    }

    final financeMatch = RegExp(r'การเงิน.*?(\d+)').firstMatch(response);
    if (financeMatch != null) {
      financeRating = int.tryParse(financeMatch.group(1) ?? '3') ?? 3;
    }

    // สกัดข้อมูลอื่นๆ
    final bestDaysMatch =
        RegExp(r'ช่วงวันที่ดีที่สุด.*?[:]?\s*([\d-\s,]+)').firstMatch(response);
    if (bestDaysMatch != null) {
      bestDays = bestDaysMatch.group(1)?.trim() ?? bestDays;
    }

    final luckyNumbersMatch =
        RegExp(r'เลขนำโชค.*?[^\d]([\d, ]+)').firstMatch(response);
    if (luckyNumbersMatch != null) {
      luckyNumbers = luckyNumbersMatch.group(1)?.trim() ?? luckyNumbers;
    }

    final luckyColorMatch =
        RegExp(r'สีนำโชค.*?[:]?([\\u0E00-\\u0E7F\\s,]+)', unicode: true)
            .firstMatch(response);
    if (luckyColorMatch != null) {
      luckyColor = luckyColorMatch.group(1)?.trim() ?? luckyColor;
    }

    return {
      'general': response,
      'love': {
        'rating': loveRating,
        'description':
            _extractSection(response, 'ความรัก', 'อาชีพ') ?? 'ความรักราบรื่น',
      },
      'career': {
        'rating': careerRating,
        'description':
            _extractSection(response, 'อาชีพ', 'สุขภาพ') ?? 'อาชีพก้าวหน้า',
      },
      'health': {
        'rating': healthRating,
        'description':
            _extractSection(response, 'สุขภาพ', 'การเงิน') ?? 'สุขภาพแข็งแรง',
      },
      'finance': {
        'rating': financeRating,
        'description':
            _extractSection(response, 'การเงิน', 'ช่วงวันที่ดีที่สุด') ??
                'การเงินดี',
      },
      'best_days': bestDays,
      'lucky_numbers': luckyNumbers,
      'lucky_color': luckyColor,
    };
  }

  /// ช่วยสกัดส่วนของข้อความระหว่างสองคำสำคัญ
  String? _extractSection(String text, String startKeyword, String endKeyword) {
    final startIndex = text.indexOf(startKeyword);
    if (startIndex == -1) return null;

    final endIndex = text.indexOf(endKeyword, startIndex + startKeyword.length);
    if (endIndex == -1) return text.substring(startIndex);

    return text.substring(startIndex + startKeyword.length, endIndex).trim();
  }

  // ปิดการเชื่อมต่อ
  void dispose() {
    httpClient.close();
  }
}
