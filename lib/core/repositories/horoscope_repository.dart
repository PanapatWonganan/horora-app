import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/openai_client.dart';
import '../models/models.dart';
import '../models/compatibility_result.dart';
import '../../features/chat/repositories/chat_repository.dart';
import '../utils/exceptions.dart' as ex;

class HoroscopeRepository {
  final ApiClient _apiClient;
  final OpenAIClient? _openaiClient;
  final SharedPreferences _prefs;
  final bool _useOpenAI;

  // Key constants for SharedPreferences
  static const String _dailyHoroscopeKey = 'daily_horoscope';
  static const String _zodiacSignsKey = 'zodiac_signs';
  static const String _compatibilityKey = 'zodiac_compatibility';

  HoroscopeRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
    OpenAIClient? openaiClient,
    bool useOpenAI = false,
  })  : _apiClient = apiClient,
        _prefs = prefs,
        _openaiClient = openaiClient,
        _useOpenAI = useOpenAI;

  // ดึงดวงชะตาประจำวันตามราศี
  Future<DailyHoroscope> getDailyHoroscope(String zodiacSign) async {
    try {
      // ตรวจสอบว่าใช้ OpenAI หรือไม่
      if (_useOpenAI && _openaiClient != null) {
        return await _getOpenAIDailyHoroscope(zodiacSign);
      }

      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String cacheKey =
          '${_dailyHoroscopeKey}_${zodiacSign}_${DateTime.now().toIso8601String().split('T')[0]}';
      final String? cachedData = _prefs.getString(cacheKey);

      if (cachedData != null) {
        return DailyHoroscope.fromJson(jsonDecode(cachedData));
      }

      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      try {
        final response = await _apiClient.get('/horoscope/daily/$zodiacSign');
        final horoscope = DailyHoroscope.fromJson(response);

        // บันทึกข้อมูลลงในแคช
        await _prefs.setString(cacheKey, jsonEncode(horoscope.toJson()));

        return horoscope;
      } catch (e) {
        // ถ้าไม่สามารถดึงข้อมูลจาก API ได้
        // ลองใช้ OpenAI หากมีการตั้งค่าไว้
        if (_openaiClient != null) {
          try {
            return await _getOpenAIDailyHoroscope(zodiacSign);
          } catch (openaiError) {
            // ถ้า OpenAI ล้มเหลว ใช้ข้อมูลตัวอย่าง
            return _getMockDailyHoroscope(zodiacSign);
          }
        } else {
          // ถ้าไม่มี OpenAI ใช้ข้อมูลตัวอย่าง
          return _getMockDailyHoroscope(zodiacSign);
        }
      }
    } catch (e) {
      // ในกรณีที่มีข้อผิดพลาด ให้ใช้ข้อมูลตัวอย่าง
      return _getMockDailyHoroscope(zodiacSign);
    }
  }

  // ดึงดวงชะตาประจำวันจาก OpenAI
  Future<DailyHoroscope> _getOpenAIDailyHoroscope(String zodiacSign) async {
    if (_openaiClient == null) {
      throw ex.AppException('OpenAI client is not initialized');
    }

    try {
      final openaiResponse = await _openaiClient!.getDailyHoroscope(zodiacSign);
      return DailyHoroscope.fromJson(openaiResponse);
    } catch (e) {
      throw ex.DataException(
          'Failed to get horoscope from OpenAI: ${e.toString()}');
    }
  }

  // ดึงดวงชะตารายสัปดาห์ตามราศี
  Future<Map<String, dynamic>> getWeeklyHoroscope(String zodiacSign) async {
    try {
      // ตรวจสอบว่าใช้ OpenAI หรือไม่
      if (_useOpenAI && _openaiClient != null) {
        return await getWeeklyHoroscopeFromOpenAI(zodiacSign);
      }

      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final weekStartDate = _getStartOfWeek(DateTime.now());
      final String cacheKey =
          'weekly_horoscope_${zodiacSign}_${weekStartDate.toIso8601String().split('T')[0]}';
      final String? cachedData = _prefs.getString(cacheKey);

      if (cachedData != null) {
        return jsonDecode(cachedData);
      }

      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      try {
        final response = await _apiClient.get('/horoscope/weekly/$zodiacSign');

        // บันทึกข้อมูลลงในแคช
        await _prefs.setString(cacheKey, jsonEncode(response));

        return response;
      } catch (e) {
        // ถ้าไม่สามารถดึงข้อมูลจาก API ได้
        // ลองใช้ OpenAI หากมีการตั้งค่าไว้
        if (_openaiClient != null) {
          try {
            return await getWeeklyHoroscopeFromOpenAI(zodiacSign);
          } catch (openaiError) {
            // ถ้า OpenAI ล้มเหลว ใช้ข้อมูลตัวอย่าง
            return _getMockWeeklyHoroscope(zodiacSign);
          }
        } else {
          // ถ้าไม่มี OpenAI ใช้ข้อมูลตัวอย่าง
          return _getMockWeeklyHoroscope(zodiacSign);
        }
      }
    } catch (e) {
      // ในกรณีที่มีข้อผิดพลาด ให้ใช้ข้อมูลตัวอย่าง
      return _getMockWeeklyHoroscope(zodiacSign);
    }
  }

  // ดึงข้อมูลดวงชะตารายสัปดาห์จาก OpenAI
  Future<Map<String, dynamic>> getWeeklyHoroscopeFromOpenAI(
      String zodiacSign) async {
    if (_openaiClient == null) {
      throw ex.AppException('OpenAI client is not initialized');
    }

    try {
      return await _openaiClient!.getWeeklyHoroscope(zodiacSign);
    } catch (e) {
      throw ex.DataException(
          'Failed to get weekly horoscope from OpenAI: ${e.toString()}');
    }
  }

  // ดึงข้อมูลดวงชะตารายเดือนจาก OpenAI
  Future<Map<String, dynamic>> getMonthlyHoroscopeFromOpenAI(
      String zodiacSign) async {
    if (_openaiClient == null) {
      throw ex.AppException('OpenAI client is not initialized');
    }

    try {
      return await _openaiClient!.getMonthlyHoroscope(zodiacSign);
    } catch (e) {
      throw ex.DataException(
          'Failed to get monthly horoscope from OpenAI: ${e.toString()}');
    }
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับดวงชะตารายวัน
  DailyHoroscope _getMockDailyHoroscope(String zodiacSign) {
    final Map<String, dynamic> mockData = {
      'id': 1,
      'zodiac_sign': zodiacSign,
      'date': DateTime.now().toIso8601String(),
      'content': 'This is a mock horoscope content for $zodiacSign.',
      'content_th': _getMockContentThai(zodiacSign),
      'love_rating': _getMockRating(zodiacSign, 'love'),
      'career_rating': _getMockRating(zodiacSign, 'career'),
      'health_rating': _getMockRating(zodiacSign, 'health'),
      'lucky_number': _getMockLuckyNumber(zodiacSign),
      'lucky_color': _getMockLuckyColor(zodiacSign),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    return DailyHoroscope.fromJson(mockData);
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับคำทำนายภาษาไทย
  String _getMockContentThai(String zodiacSign) {
    switch (zodiacSign) {
      case 'aries':
        return 'วันนี้คุณจะมีพลังงานเต็มเปี่ยม เหมาะกับการเริ่มต้นโครงการใหม่ๆ ความกล้าหาญและความเป็นผู้นำของคุณจะโดดเด่น แต่ควรระวังความใจร้อนและความหุนหันพลันแล่น';
      case 'taurus':
        return 'วันนี้คุณจะรู้สึกมั่นคงและมีความอดทนสูง เป็นวันที่ดีสำหรับการจัดการเรื่องการเงินและการลงทุน แต่ควรระวังความดื้อรั้นที่อาจทำให้พลาดโอกาสดีๆ';
      case 'gemini':
        return 'วันนี้คุณจะมีความคิดสร้างสรรค์และมีพลังในการสื่อสาร เป็นวันที่ดีสำหรับการเข้าสังคมและแลกเปลี่ยนความคิดเห็น แต่ควรระวังความไม่แน่นอนและการตัดสินใจที่เปลี่ยนแปลงไปมา';
      case 'cancer':
        return 'วันนี้ความรู้สึกและอารมณ์ของคุณจะไหลลื่น เป็นวันที่ดีสำหรับการอยู่กับครอบครัวและคนที่คุณรัก แต่ควรระวังความอ่อนไหวและการยึดติดกับอดีต';
      case 'leo':
        return 'วันนี้คุณจะมีเสน่ห์และพลังที่โดดเด่น เป็นวันที่ดีสำหรับการแสดงความสามารถและการเป็นผู้นำ แต่ควรระวังความหยิ่งและการเรียกร้องความสนใจมากเกินไป';
      case 'virgo':
        return 'วันนี้คุณจะมีความละเอียดรอบคอบและมีเหตุผล เป็นวันที่ดีสำหรับการจัดระเบียบและวางแผน แต่ควรระวังการวิจารณ์และความวิตกกังวลที่มากเกินไป';
      case 'libra':
        return 'วันนี้คุณจะมีความสมดุลและความยุติธรรม เป็นวันที่ดีสำหรับการเจรจาและการประนีประนอม แต่ควรระวังการลังเลและการตัดสินใจที่ยากลำบาก';
      case 'scorpio':
        return 'วันนี้คุณจะมีพลังและความเข้มข้นในอารมณ์ เป็นวันที่ดีสำหรับการค้นคว้าและการวิจัยเชิงลึก แต่ควรระวังความหึงหวงและการแก้แค้น';
      case 'sagittarius':
        return 'วันนี้คุณจะมีอิสระและการผจญภัย เป็นวันที่ดีสำหรับการเดินทางและการศึกษา แต่ควรระวังการพูดตรงเกินไปและการสัญญาเกินจริง';
      case 'capricorn':
        return 'วันนี้คุณจะมีความรับผิดชอบและความมุ่งมั่น เป็นวันที่ดีสำหรับการทำงานและการวางแผนระยะยาว แต่ควรระวังความเคร่งเครียดและการทำงานหนักเกินไป';
      case 'aquarius':
        return 'วันนี้คุณจะมีความคิดที่เป็นอิสระและแปลกใหม่ เป็นวันที่ดีสำหรับนวัตกรรมและการทำงานเพื่อสังคม แต่ควรระวังความแปลกแยกและการไม่ยืดหยุ่น';
      case 'pisces':
        return 'วันนี้คุณจะมีความเมตตาและจินตนาการ เป็นวันที่ดีสำหรับงานศิลปะและการช่วยเหลือผู้อื่น แต่ควรระวังการหลบหนีความจริงและความสับสน';
      default:
        return 'วันนี้เป็นวันที่ดีสำหรับการพักผ่อนและการทบทวนตัวเอง ควรใช้เวลาอย่างมีคุณค่าและวางแผนสำหรับอนาคต';
    }
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับคะแนนด้านต่างๆ
  int _getMockRating(String zodiacSign, String aspect) {
    // สร้างคะแนนสุ่มระหว่าง 1-5 แต่ให้มีความคงที่สำหรับราศีและด้านเดียวกัน
    final int seed = zodiacSign.codeUnitAt(0) + aspect.codeUnitAt(0);
    return (seed % 5) + 1; // คะแนน 1-5
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับเลขนำโชค
  String _getMockLuckyNumber(String zodiacSign) {
    final List<String> numbers = [
      '1, 7, 13',
      '2, 8, 16',
      '3, 9, 21',
      '4, 10, 22',
      '5, 11, 23',
      '6, 12, 24',
      '7, 14, 28',
      '8, 15, 29',
      '9, 18, 27',
      '10, 19, 30',
      '11, 20, 33',
      '12, 21, 36'
    ];

    final int index = zodiacSign.codeUnitAt(0) % numbers.length;
    return numbers[index];
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับสีนำโชค
  String _getMockLuckyColor(String zodiacSign) {
    final Map<String, String> colors = {
      'aries': 'แดง, ส้ม',
      'taurus': 'เขียว, น้ำตาล',
      'gemini': 'เหลือง, ฟ้า',
      'cancer': 'เงิน, ขาว',
      'leo': 'ทอง, ส้ม',
      'virgo': 'น้ำตาล, เขียว',
      'libra': 'ฟ้า, ชมพู',
      'scorpio': 'แดงเข้ม, ดำ',
      'sagittarius': 'ม่วง, น้ำเงิน',
      'capricorn': 'เทา, น้ำตาลเข้ม',
      'aquarius': 'ฟ้า, เงิน',
      'pisces': 'เขียวอมฟ้า, ม่วง',
    };

    return colors[zodiacSign] ?? 'น้ำเงิน, ม่วง';
  }

  // ดึงดวงชะตาประจำวันสำหรับผู้ใช้ปัจจุบัน
  Future<DailyHoroscope> getCurrentUserDailyHoroscope() async {
    try {
      final response = await _apiClient.get('/horoscope/daily/me');
      final horoscope = DailyHoroscope.fromJson(response);

      // บันทึกข้อมูลลงในแคช
      final String cacheKey =
          '${_dailyHoroscopeKey}_me_${DateTime.now().toIso8601String().split('T')[0]}';
      await _prefs.setString(cacheKey, jsonEncode(horoscope.toJson()));

      return horoscope;
    } catch (e) {
      if (e is ex.UnauthorizedException) {
        throw ex.AuthException('User not authenticated');
      }
      // ในกรณีที่มีข้อผิดพลาด ให้ใช้ข้อมูลตัวอย่าง
      return _getMockDailyHoroscope('unknown');
    }
  }

  // ดึงข้อมูลราศีทั้งหมด
  Future<List<ZodiacSign>> getAllZodiacSigns() async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String? cachedData = _prefs.getString(_zodiacSignsKey);

      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => ZodiacSign.fromJson(item)).toList();
      }

      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      final response = await _apiClient.get('/horoscope/zodiac-signs');

      final List<ZodiacSign> zodiacSigns =
          (response as List).map((item) => ZodiacSign.fromJson(item)).toList();

      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_zodiacSignsKey,
          jsonEncode(zodiacSigns.map((sign) => sign.toJson()).toList()));

      return zodiacSigns;
    } catch (e) {
      throw ex.DataException('Failed to get zodiac signs: ${e.toString()}');
    }
  }

  // ดึงข้อมูลราศีตามชื่อ
  Future<ZodiacSign> getZodiacSignByName(String name) async {
    try {
      final List<ZodiacSign> allSigns = await getAllZodiacSigns();

      final ZodiacSign sign = allSigns.firstWhere(
        (sign) =>
            sign.name.toLowerCase() == name.toLowerCase() ||
            sign.nameEn.toLowerCase() == name.toLowerCase(),
        orElse: () => throw ex.DataException('Zodiac sign not found: $name'),
      );

      return sign;
    } catch (e) {
      throw ex.DataException('Failed to get zodiac sign: ${e.toString()}');
    }
  }

  // คำนวณราศีจากวันเกิด
  Future<ZodiacSign> calculateZodiacSign(DateTime birthDate) async {
    try {
      final List<ZodiacSign> allSigns = await getAllZodiacSigns();

      // ใช้เมธอด static ของ ZodiacSign เพื่อคำนวณราศี
      final String signName = ZodiacSign.calculateZodiacSign(birthDate);

      final ZodiacSign sign = allSigns.firstWhere(
        (sign) =>
            sign.name.toLowerCase() == signName.toLowerCase() ||
            sign.nameEn.toLowerCase() == signName.toLowerCase(),
        orElse: () => throw ex.DataException(
            'Zodiac sign not found for birth date: $birthDate'),
      );

      return sign;
    } catch (e) {
      throw ex.DataException(
          'Failed to calculate zodiac sign: ${e.toString()}');
    }
  }

  // ดึงข้อมูลความเข้ากันของราศี
  Future<CompatibilityResult> getZodiacCompatibility(
      String sign1, String sign2) async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String cacheKey = '${_compatibilityKey}_${sign1}_$sign2';
      final String? cachedData = _prefs.getString(cacheKey);

      if (cachedData != null) {
        return CompatibilityResult.fromJson(jsonDecode(cachedData));
      }

      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      try {
        final response = await _apiClient.get(
          '/horoscope/compatibility',
          queryParams: {
            'sign1': sign1,
            'sign2': sign2,
          },
        );

        final compatibility = CompatibilityResult.fromJson(response);

        // บันทึกข้อมูลลงในแคช
        await _prefs.setString(cacheKey, jsonEncode(compatibility.toJson()));

        return compatibility;
      } catch (e) {
        // ถ้าไม่สามารถดึงข้อมูลจาก API ได้ ใช้ข้อมูลตัวอย่าง
        final mockData = _getMockCompatibilityData(sign1, sign2);

        // บันทึกข้อมูลตัวอย่างลงในแคช
        await _prefs.setString(cacheKey, jsonEncode(mockData.toJson()));

        return mockData;
      }
    } catch (e) {
      // ในกรณีที่มีข้อผิดพลาด ให้ใช้ข้อมูลตัวอย่าง
      return _getMockCompatibilityData(sign1, sign2);
    }
  }

  // ตรวจสอบความเข้ากันระหว่างราศีของผู้ใช้และราศีที่เลือก
  Future<CompatibilityResult> getCurrentUserCompatibility(
      String otherSign) async {
    try {
      final chatRepository = ChatRepository();
      final String? userSign = await chatRepository.getUserZodiacSign();

      if (userSign == null || userSign.isEmpty) {
        throw Exception('ไม่พบข้อมูลราศีของผู้ใช้');
      }

      return await getZodiacCompatibility(userSign, otherSign);
    } catch (e) {
      print('Error in getCurrentUserCompatibility: $e');
      throw Exception('ไม่สามารถตรวจสอบความเข้ากันได้: ${e.toString()}');
    }
  }

  // สร้างข้อมูลตัวอย่างสำหรับความเข้ากันระหว่างราศี
  CompatibilityResult _getMockCompatibilityData(String sign1, String sign2) {
    final random = Random();

    final overallScore = 50 + random.nextInt(51); // 50-100
    final loveScore = 40 + random.nextInt(61); // 40-100
    final workScore = 40 + random.nextInt(61); // 40-100

    // คำอธิบายตัวอย่าง
    String description =
        'ความเข้ากันระหว่าง $sign1 และ $sign2 อยู่ในระดับ${_getCompatibilityLevel(overallScore)}. '
        'ทั้งสองราศีนี้มีพลังงานที่ส่งเสริมกันในหลายด้าน แต่ก็มีความท้าทายบางประการที่ต้องเรียนรู้ที่จะปรับตัวเข้าหากัน';

    String loveCompatibility =
        'ด้านความรัก ทั้งสองราศีมีความเข้ากันในระดับ${_getCompatibilityLevel(loveScore)}. '
        'มีความเข้าใจในความต้องการของกันและกัน สามารถสร้างความสัมพันธ์ที่มั่นคงได้หากทั้งสองฝ่ายมีความจริงใจและเปิดใจคุยกัน';

    String workCompatibility =
        'ด้านการทำงาน ทั้งสองราศีมีความเข้ากันในระดับ${_getCompatibilityLevel(workScore)}. '
        'สามารถทำงานร่วมกันได้ดี โดยแต่ละฝ่ายมีจุดแข็งที่เติมเต็มอีกฝ่ายได้ดี ทำให้เกิดทีมที่มีประสิทธิภาพ';

    String advice =
        'คำแนะนำสำหรับทั้งสองราศี: ควรเรียนรู้ที่จะยอมรับความแตกต่างของกันและกัน '
        'ใช้การสื่อสารที่เปิดเผยและจริงใจเพื่อแก้ไขปัญหา และให้เวลากันในการปรับตัวเข้าหากัน';

    return CompatibilityResult(
      sign1: sign1,
      sign2: sign2,
      overallScore: overallScore,
      loveScore: loveScore,
      workScore: workScore,
      description: description,
      loveCompatibility: loveCompatibility,
      workCompatibility: workCompatibility,
      advice: advice,
    );
  }

  // แปลงคะแนนเป็นระดับความเข้ากัน
  String _getCompatibilityLevel(int score) {
    if (score >= 90) return 'ดีเยี่ยม';
    if (score >= 75) return 'ดีมาก';
    if (score >= 60) return 'ดี';
    if (score >= 40) return 'ปานกลาง';
    if (score >= 20) return 'น้อย';
    return 'น้อยมาก';
  }

  // ล้างแคชดวงชะตาประจำวัน
  Future<void> clearDailyHoroscopeCache() async {
    try {
      final List<String> keys = _prefs
          .getKeys()
          .where((key) => key.startsWith(_dailyHoroscopeKey))
          .toList();

      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw ex.CacheException(
          'Failed to clear daily horoscope cache: ${e.toString()}');
    }
  }

  // ล้างแคชทั้งหมดที่เกี่ยวกับดวงชะตา
  Future<void> clearAllHoroscopeCache() async {
    try {
      final List<String> keys = _prefs
          .getKeys()
          .where((key) =>
              key.startsWith(_dailyHoroscopeKey) ||
              key.startsWith(_zodiacSignsKey) ||
              key.startsWith(_compatibilityKey))
          .toList();

      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      throw ex.CacheException(
          'Failed to clear horoscope cache: ${e.toString()}');
    }
  }

  // ฟังก์ชันคำนวณวันแรกของสัปดาห์ (วันจันทร์)
  DateTime _getStartOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day - date.weekday + 1);
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับดวงชะตารายสัปดาห์
  Map<String, dynamic> _getMockWeeklyHoroscope(String zodiacSign) {
    final DateTime now = DateTime.now();
    final DateTime weekStart = _getStartOfWeek(now);
    final DateTime weekEnd = weekStart.add(const Duration(days: 6));

    return {
      'zodiac_sign': zodiacSign,
      'period':
          '${weekStart.day}/${weekStart.month}/${weekStart.year} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year}',
      'overview':
          'สัปดาห์นี้เป็นช่วงเวลาแห่งการเปลี่ยนแปลงและโอกาสใหม่ๆ สำหรับคุณ',
      'love': {
        'rating': _getMockRating(zodiacSign, 'love'),
        'description':
            'ความสัมพันธ์ของคุณจะมีความเข้าใจกันมากขึ้น หากโสด อาจมีคนพิเศษเข้ามาในชีวิต'
      },
      'career': {
        'rating': _getMockRating(zodiacSign, 'career'),
        'description':
            'โอกาสทางอาชีพจะเข้ามา เป็นช่วงเวลาที่ดีในการเริ่มโครงการใหม่หรือเรียนรู้ทักษะใหม่'
      },
      'health': {
        'rating': _getMockRating(zodiacSign, 'health'),
        'description':
            'ควรใส่ใจสุขภาพของตัวเองให้มากขึ้น โดยเฉพาะการพักผ่อนและการออกกำลังกาย'
      },
      'finance': {
        'rating': _getMockRating(zodiacSign, 'finance'),
        'description':
            'การเงินมีแนวโน้มที่ดี แต่ควรใช้จ่ายอย่างระมัดระวังและวางแผนการออมในระยะยาว'
      },
      'lucky_days': _getMockLuckyDays(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // ฟังก์ชันสุ่มวันที่โชคดีในสัปดาห์
  List<String> _getMockLuckyDays() {
    final List<String> days = [
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
      'อาทิตย์'
    ];
    days.shuffle();
    return days.take(2).toList();
  }

  // ดึงดวงชะตารายเดือนตามราศี
  Future<Map<String, dynamic>> getMonthlyHoroscope(String zodiacSign) async {
    try {
      // ตรวจสอบว่าใช้ OpenAI หรือไม่
      if (_useOpenAI && _openaiClient != null) {
        return await getMonthlyHoroscopeFromOpenAI(zodiacSign);
      }

      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final DateTime now = DateTime.now();
      final String cacheKey =
          'monthly_horoscope_${zodiacSign}_${now.year}_${now.month}';
      final String? cachedData = _prefs.getString(cacheKey);

      if (cachedData != null) {
        return jsonDecode(cachedData);
      }

      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      try {
        final response = await _apiClient.get('/horoscope/monthly/$zodiacSign');

        // บันทึกข้อมูลลงในแคช
        await _prefs.setString(cacheKey, jsonEncode(response));

        return response;
      } catch (e) {
        // ถ้าไม่สามารถดึงข้อมูลจาก API ได้
        // ลองใช้ OpenAI หากมีการตั้งค่าไว้
        if (_openaiClient != null) {
          try {
            return await getMonthlyHoroscopeFromOpenAI(zodiacSign);
          } catch (openaiError) {
            // ถ้า OpenAI ล้มเหลว ใช้ข้อมูลตัวอย่าง
            return _getMockMonthlyHoroscope(zodiacSign);
          }
        } else {
          // ถ้าไม่มี OpenAI ใช้ข้อมูลตัวอย่าง
          return _getMockMonthlyHoroscope(zodiacSign);
        }
      }
    } catch (e) {
      // ในกรณีที่มีข้อผิดพลาด ให้ใช้ข้อมูลตัวอย่าง
      return _getMockMonthlyHoroscope(zodiacSign);
    }
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับดวงชะตารายเดือน
  Map<String, dynamic> _getMockMonthlyHoroscope(String zodiacSign) {
    final DateTime now = DateTime.now();
    final List<String> months = [
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

    return {
      'zodiac_sign': zodiacSign,
      'month': months[now.month - 1],
      'year': now.year,
      'overview':
          'เดือนนี้เป็นช่วงเวลาแห่งการเติบโตและการค้นพบตัวเองสำหรับชาว$zodiacSign',
      'love': {
        'rating': _getMockRating(zodiacSign, 'love'),
        'description':
            'ความรักของคุณจะมีความมั่นคงและลึกซึ้งมากขึ้น เป็นช่วงเวลาที่ดีในการสร้างความสัมพันธ์ที่แน่นแฟ้น'
      },
      'career': {
        'rating': _getMockRating(zodiacSign, 'career'),
        'description':
            'การงานจะมีความก้าวหน้า อาจได้รับโอกาสใหม่ๆ ที่ท้าทาย ให้กล้าที่จะรับความรับผิดชอบมากขึ้น'
      },
      'health': {
        'rating': _getMockRating(zodiacSign, 'health'),
        'description':
            'สุขภาพโดยรวมอยู่ในเกณฑ์ดี แต่ควรหลีกเลี่ยงความเครียดและหาเวลาพักผ่อนให้เพียงพอ'
      },
      'finance': {
        'rating': _getMockRating(zodiacSign, 'finance'),
        'description':
            'การเงินมีเสถียรภาพ เป็นช่วงเวลาที่ดีในการวางแผนการลงทุนระยะยาวและการออม'
      },
      'lucky_dates': _getMockLuckyDates(),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // ฟังก์ชันสุ่มวันที่โชคดีในเดือน
  List<int> _getMockLuckyDates() {
    final List<int> dates = List.generate(28, (index) => index + 1);
    dates.shuffle();
    return dates.take(3).toList()..sort();
  }

  // Helper method to get cached data
  Future<T?> _getCachedData<T>(String key) async {
    final cachedDataStr = _prefs.getString(key);
    if (cachedDataStr != null) {
      try {
        final data = jsonDecode(cachedDataStr);
        return data as T;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Helper method to cache data
  Future<void> _cacheData(String key, dynamic data) async {
    await _prefs.setString(key, jsonEncode(data));
  }
}
