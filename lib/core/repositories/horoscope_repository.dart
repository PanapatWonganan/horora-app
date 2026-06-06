import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/openai_client.dart';
import '../models/models.dart';
import '../models/compatibility_result.dart';
import '../services/thai_zodiac_service.dart';
import '../services/smart_horoscope_service.dart';
import '../services/laravel_auth_service.dart';
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

  // ดึงดวงชะตาประจำวันตามปีนักษัตรไทย
  Future<DailyHoroscope> getDailyHoroscope(String thaiAnimal) async {
    try {
      final today = DateTime.now();
      
      // Debug: ล้าง cache เพื่อให้ได้ข้อมูลใหม่ทุกครั้ง (เพื่อทดสอบ)
      await SmartHoroscopeService.clearAllCache();
      
      // ใช้ SmartHoroscopeService ที่จัดการ OpenAI + caching + templates
      final horoscopeData = await SmartHoroscopeService.getDailyHoroscope(thaiAnimal, today);
      
      // แปลงเป็น DailyHoroscope model
      return DailyHoroscope(
        id: today.millisecondsSinceEpoch,
        thaiAnimal: thaiAnimal,
        date: today,
        content: horoscopeData['content_th'] ?? 'คำทำนายสำหรับวันนี้',
        contentTh: horoscopeData['content_th'] ?? 'คำทำนายสำหรับวันนี้',
        loveRating: horoscopeData['love_rating'] ?? 3,
        careerRating: horoscopeData['career_rating'] ?? 3,
        healthRating: horoscopeData['health_rating'] ?? 3,
        luckyNumber: horoscopeData['lucky_number'] ?? '7, 14, 21',
        luckyColor: horoscopeData['lucky_color'] ?? 'น้ำเงิน',
        createdAt: today,
        updatedAt: today,
      );
    } catch (e) {
      debugPrint('Error getting daily horoscope: $e');
      // Fallback to mock data
      return _getMockDailyHoroscope(thaiAnimal);
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
  DailyHoroscope _getMockDailyHoroscope(String thaiAnimal) {
    final now = DateTime.now();
    final Map<String, dynamic> mockData = {
      'id': 1,
      'thai_animal': thaiAnimal,
      'date': now.toIso8601String(),
      'content': 'This is a mock horoscope content for $thaiAnimal.',
      'content_th': _getMockContentThaiAnimal(thaiAnimal),
      'love_rating': _getMockRating(thaiAnimal, 'love'),
      'career_rating': _getMockRating(thaiAnimal, 'career'),
      'health_rating': _getMockRating(thaiAnimal, 'health'),
      'lucky_number': _getMockLuckyNumber(thaiAnimal),
      'lucky_color': _getMockLuckyColor(thaiAnimal),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    return DailyHoroscope.fromJson(mockData);
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับคำทำนายภาษาไทยตามปีนักษัตรไทย
  String _getMockContentThaiAnimal(String thaiAnimal) {
    debugPrint('_getMockContentThaiAnimal received: "$thaiAnimal"');
    switch (thaiAnimal) {
      case 'ชวด':
        return 'วันนี้ไหวพริบและความขยันของคุณจะเป็นกุญแจสำคัญ เหมาะกับการใช้ความรอบคอบในการตัดสินใจ ความสามารถในการประหยัดจะช่วยให้มีเงินเก็บ';
      case 'ฉลู':
        return 'ความมั่นคงและอดทนของคุณจะได้รับการตอบแทนวันนี้ เหมาะกับการวางแผนระยะยาวและการลงทุนที่มั่นคง ความจริงใจจะนำความสำเร็จมาให้';
      case 'ขาล':
        return 'ความกล้าหาญและการเป็นผู้นำของคุณจะโดดเด่นวันนี้ เหมาะกับการเริ่มโครงการใหม่และการแก้ปัญหาที่ท้าทาย แต่ควรระวังความหุนหันพลันแล่น';
      case 'เถาะ':
        return 'ความอ่อนโยนและมารยาทของคุณจะช่วยสร้างความสัมพันธ์ที่ดี วันนี้เหมาะกับการทำงานเป็นทีมและการประนีประนอม ความสงบจะนำสุขมาให้';
      case 'มะโรง':
        return 'พลังและความมั่นใจของคุณจะเปล่งประกายวันนี้ เหมาะกับการแสดงความสามารถและเป็นที่สนใจของผู้อื่น ความกล้าหาญจะนำโอกาสมาให้';
      case 'มะเส็ง':
        return 'ปัญญาและสัญชาตญาณของคุณจะช่วยในการตัดสินใจสำคัญวันนี้ เหมาะกับการเรียนรู้สิ่งใหม่และการวิจัย ความลึกซึ้งจะเป็นจุดแข็ง';
      case 'มะเมีย':
        return 'ความกระฉับกระเฉงและรักเสรีภาพของคุณจะนำพาผลลัพธ์ดีวันนี้ เหมาะกับการเดินทางและการผจญภัย ความตรงไปตรงมาจะได้รับการชื่นชม';
      case 'มะแม':
        return 'ความอ่อนโยนและจิตใจศิลปินของคุณจะได้รับการชื่นชมวันนี้ เหมาะกับงานสร้างสรรค์และการดูแลผู้อื่น ความงามจะอยู่รอบตัวคุณ';
      case 'วอก':
        return 'ความฉลาดและไหวพริบของคุณจะช่วยแก้ปัญหาได้ดีวันนี้ เหมาะกับการเจรจาและการปรับเปลี่ยน ความยืดหยุ่นจะเป็นประโยชน์';
      case 'ระกา':
        return 'ความตรงไปตรงมาและรักความสะอาดของคุณจะสร้างความน่าเชื่อถือวันนี้ เหมาะกับการจัดระเบียบและปรับปรุง ความสวยงามจะเข้ามาในชีวิต';
      case 'จอ':
        return 'ความซื่อสัตย์และความรับผิดชอบของคุณจะได้รับการยอมรับวันนี้ เหมาะกับการดูแลครอบครัวและงานที่ต้องใช้ความไว้วางใจ ความจริงใจจะได้รับรางวัล';
      case 'กุน':
        return 'ใจกว้างและความเอื้อเฟื้อของคุณจะนำพาความสุขมาให้วันนี้ เหมาะกับการช่วยเหลือผู้อื่นและการสร้างความสุขสบาย การให้จะได้รับกลับคืนมา';
      default:
        return 'วันนี้เป็นวันที่ดีสำหรับการใช้ลักษณะเฉพาะของปีนักษัตรของคุณ คุณจะได้พบกับโอกาสดีๆ ในการทำงานและความสัมพันธ์';
    }
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับคะแนนด้านต่างๆ
  int _getMockRating(String zodiacSign, String aspect) {
    // สร้างคะแนนสุ่มระหว่าง 1-5 แต่ให้มีความคงที่สำหรับราศีและด้านเดียวกัน
    // ป้องกัน RangeError เมื่อ zodiacSign หรือ aspect เป็นค่าว่าง
    final int signSeed = zodiacSign.isNotEmpty ? zodiacSign.codeUnitAt(0) : 0;
    final int aspectSeed = aspect.isNotEmpty ? aspect.codeUnitAt(0) : 0;
    final int seed = signSeed + aspectSeed;
    return (seed % 5) + 1; // คะแนน 1-5
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับเลขนำโชคตามปีนักษัตรไทย
  String _getMockLuckyNumber(String thaiAnimal) {
    final Map<String, String> luckyNumbers = {
      'ชวด': '1, 8, 12',
      'ฉลู': '2, 6, 15',
      'ขาล': '3, 9, 18',
      'เถาะ': '4, 11, 20',
      'มะโรง': '5, 14, 23',
      'มะเส็ง': '6, 13, 24',
      'มะเมีย': '7, 16, 25',
      'มะแม': '8, 17, 26',
      'วอก': '9, 18, 27',
      'ระกา': '10, 19, 28',
      'จอ': '11, 20, 29',
      'กุน': '12, 21, 30',
    };

    return luckyNumbers[thaiAnimal] ?? '7, 14, 21';
  }

  // ฟังก์ชันสร้างข้อมูลตัวอย่างสำหรับสีนำโชคตามปีนักษัตรไทย
  String _getMockLuckyColor(String thaiAnimal) {
    final Map<String, String> colors = {
      'ชวด': 'ทอง, เหลือง',
      'ฉลู': 'เขียว, น้ำตาล',
      'ขาล': 'แดง, ส้ม',
      'เถาะ': 'เงิน, ขาว',
      'มะโรง': 'เขียว, แดง',
      'มะเส็ง': 'น้ำเงิน, ดำ',
      'มะเมีย': 'ม่วง, แดง',
      'มะแม': 'ชมพู, เงิน',
      'วอก': 'เหลือง, ทอง',
      'ระกา': 'ขาว, เงิน',
      'จอ': 'น้ำตาล, ทอง',
      'กุน': 'ดำ, น้ำเงิน',
    };

    return colors[thaiAnimal] ?? 'น้ำเงิน, ม่วง';
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

  // ดึงข้อมูลปีนักษัตรไทยทั้งหมด
  Future<List<String>> getAllThaiZodiacAnimals() async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String? cachedData = _prefs.getString(_zodiacSignsKey);

      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return List<String>.from(decoded);
      }

      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      // Note: API response is currently not used, returning hardcoded list instead
      // TODO: Use API response when backend endpoint is ready
      // final response = await _apiClient.get('/horoscope/zodiac-signs');

      final List<String> thaiAnimals = ['ชวด', 'ฉลู', 'ขาล', 'เถาะ', 'มะโรง', 'มะเส็ง', 'มะเมีย', 'มะแม', 'วอก', 'ระกา', 'จอ', 'กุน'];

      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_zodiacSignsKey, jsonEncode(thaiAnimals));

      return thaiAnimals;
    } catch (e) {
      throw ex.DataException('Failed to get zodiac signs: ${e.toString()}');
    }
  }

  // ดึงข้อมูลปีนักษัตรตามชื่อ
  Future<String> getThaiAnimalByName(String name) async {
    try {
      final List<String> allAnimals = await getAllThaiZodiacAnimals();

      final String animal = allAnimals.firstWhere(
        (animal) => animal.toLowerCase() == name.toLowerCase(),
        orElse: () => throw ex.DataException('Thai animal not found: $name'),
      );

      return animal;
    } catch (e) {
      throw ex.DataException('Failed to get zodiac sign: ${e.toString()}');
    }
  }

  // คำนวณปีนักษัตรจากวันเกิด
  Future<String> calculateThaiAnimal(DateTime birthDate) async {
    try {
      // ใช้ Thai Zodiac Service
      final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(birthDate);
      return thaiZodiac.animalName;
    } catch (e) {
      throw ex.DataException('Failed to calculate Thai animal: ${e.toString()}');
    }
  }

  // ดึง Thai Zodiac สำหรับใช้ใน UI
  Future<ThaiZodiac?> getUserThaiZodiac() async {
    try {
      final user = LaravelAuthService.instance.currentUser;
      if (user == null) return null;

      if (user.birthDate != null) {
        return ThaiZodiacService.getThaiZodiacFromDate(user.birthDate!);
      }

      return null;
    } catch (e) {
      throw ex.DataException('Failed to get user Thai zodiac: ${e.toString()}');
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
      debugPrint('Error in getCurrentUserCompatibility: $e');
      throw Exception('ไม่สามารถตรวจสอบความเข้ากันได้: ${e.toString()}');
    }
  }

  // ตรวจสอบความเข้ากันระหว่างปีนักษัตรไทย
  Future<CompatibilityResult> getThaiZodiacCompatibility(
      String animal1, String animal2) async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String cacheKey = 'thai_zodiac_compatibility_${animal1}_$animal2';
      final String? cachedData = _prefs.getString(cacheKey);

      if (cachedData != null) {
        return CompatibilityResult.fromJson(jsonDecode(cachedData));
      }

      // สร้างข้อมูลความเข้ากันตามปีนักษัตรไทย
      final result = _getThaiZodiacCompatibilityData(animal1, animal2);

      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(cacheKey, jsonEncode(result.toJson()));

      return result;
    } catch (e) {
      debugPrint('Error in getThaiZodiacCompatibility: $e');
      return _getThaiZodiacCompatibilityData(animal1, animal2);
    }
  }

  // สร้างข้อมูลความเข้ากันตามปีนักษัตรไทย
  CompatibilityResult _getThaiZodiacCompatibilityData(String animal1, String animal2) {
    // ตารางความเข้ากันตามปีนักษัตรไทย (อิงจากความเชื่อดั้งเดิม)
    // สามเหลี่ยมเป็นกันเอง: ชวด-มะโรง-วอก, ฉลู-มะเส็ง-ระกา, ขาล-มะเมีย-จอ, เถาะ-มะแม-กุน
    final Map<String, List<String>> compatibleGroups = {
      'ชวด': ['มะโรง', 'วอก'],
      'มะโรง': ['ชวด', 'วอก'],
      'วอก': ['ชวด', 'มะโรง'],
      'ฉลู': ['มะเส็ง', 'ระกา'],
      'มะเส็ง': ['ฉลู', 'ระกา'],
      'ระกา': ['ฉลู', 'มะเส็ง'],
      'ขาล': ['มะเมีย', 'จอ'],
      'มะเมีย': ['ขาล', 'จอ'],
      'จอ': ['ขาล', 'มะเมีย'],
      'เถาะ': ['มะแม', 'กุน'],
      'มะแม': ['เถาะ', 'กุน'],
      'กุน': ['เถาะ', 'มะแม'],
    };

    // ปีที่ขัดแย้ง (ตรงข้าม 6 ปี)
    final Map<String, String> conflictingPairs = {
      'ชวด': 'มะเมีย', 'มะเมีย': 'ชวด',
      'ฉลู': 'มะแม', 'มะแม': 'ฉลู',
      'ขาล': 'วอก', 'วอก': 'ขาล',
      'เถาะ': 'ระกา', 'ระกา': 'เถาะ',
      'มะโรง': 'จอ', 'จอ': 'มะโรง',
      'มะเส็ง': 'กุน', 'กุน': 'มะเส็ง',
    };

    int overallScore;
    int loveScore;
    int workScore;
    String description;
    String loveCompatibility;
    String workCompatibility;
    String advice;

    // ตรวจสอบความสัมพันธ์
    if (animal1 == animal2) {
      // ปีเดียวกัน
      overallScore = 75;
      loveScore = 80;
      workScore = 70;
      description = 'ปี$animal1 ทั้งคู่ มีความเข้าใจกันดีเพราะมีลักษณะนิสัยคล้ายกัน แต่อาจมีความขัดแย้งในบางเรื่องเพราะไม่ยอมกัน';
      loveCompatibility = 'ความรักระหว่างปีเดียวกันมักจะเข้าใจกันดี แต่ควรระวังการชิงดีชิงเด่น';
      workCompatibility = 'ทำงานร่วมกันได้ดีเพราะคิดเหมือนกัน แต่ควรมีคนตัดสินใจหลัก';
      advice = 'ควรยอมรับความแตกต่างเล็กน้อยที่มี และหาจุดร่วมในการตัดสินใจ';
    } else if (compatibleGroups[animal1]?.contains(animal2) ?? false) {
      // อยู่ในกลุ่มสามเหลี่ยมเป็นกันเอง
      overallScore = 90 + Random().nextInt(11);
      loveScore = 85 + Random().nextInt(16);
      workScore = 88 + Random().nextInt(13);
      description = 'ปี$animal1 และ ปี$animal2 เป็นคู่ที่เข้ากันได้ดีมาก! อยู่ในกลุ่มสามเหลี่ยมเป็นกันเอง มีพลังส่งเสริมกัน';
      loveCompatibility = 'ความรักระหว่างกันมีความราบรื่นมาก เข้าใจกันโดยธรรมชาติ มีโอกาสสร้างครอบครัวที่อบอุ่น';
      workCompatibility = 'ทำงานร่วมกันได้อย่างลงตัว ช่วยเหลือเกื้อกูลกัน สามารถสร้างความสำเร็จร่วมกันได้';
      advice = 'ความสัมพันธ์นี้ดีอยู่แล้ว ควรรักษาความเข้าใจกันไว้และสนับสนุนซึ่งกันและกัน';
    } else if (conflictingPairs[animal1] == animal2) {
      // ปีที่ขัดแย้ง (ตรงข้าม)
      overallScore = 30 + Random().nextInt(21);
      loveScore = 35 + Random().nextInt(26);
      workScore = 40 + Random().nextInt(21);
      description = 'ปี$animal1 และ ปี$animal2 เป็นปีที่ตรงข้ามกัน อาจมีความท้าทายในการอยู่ร่วมกัน แต่หากเข้าใจกันก็สามารถเติมเต็มข้อบกพร่องของกันได้';
      loveCompatibility = 'ความรักอาจต้องใช้ความพยายามมากกว่าปกติ ควรฝึกการสื่อสารและเข้าใจมุมมองของอีกฝ่าย';
      workCompatibility = 'การทำงานร่วมกันอาจมีความเห็นต่าง ควรแบ่งหน้าที่ชัดเจนและเคารพความเชี่ยวชาญของกัน';
      advice = 'ความสัมพันธ์นี้ต้องการความอดทนและความเข้าใจ หากผ่านความท้าทายได้ จะกลายเป็นคู่ที่แข็งแกร่ง';
    } else {
      // ความสัมพันธ์ทั่วไป
      overallScore = 60 + Random().nextInt(21);
      loveScore = 55 + Random().nextInt(26);
      workScore = 60 + Random().nextInt(21);
      description = 'ปี$animal1 และ ปี$animal2 มีความเข้ากันในระดับปานกลาง สามารถสร้างความสัมพันธ์ที่ดีได้หากทั้งสองฝ่ายพยายาม';
      loveCompatibility = 'ความรักมีโอกาสพัฒนาได้ดีหากทั้งสองฝ่ายเปิดใจและยอมรับความแตกต่าง';
      workCompatibility = 'ทำงานร่วมกันได้ แต่ควรกำหนดบทบาทและหน้าที่ให้ชัดเจน';
      advice = 'ควรสื่อสารกันอย่างเปิดเผยและหาจุดร่วมที่ทั้งสองฝ่ายสนใจ';
    }

    return CompatibilityResult(
      sign1: 'ปี$animal1',
      sign2: 'ปี$animal2',
      overallScore: overallScore,
      loveScore: loveScore,
      workScore: workScore,
      description: description,
      loveCompatibility: loveCompatibility,
      workCompatibility: workCompatibility,
      advice: advice,
    );
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
}
