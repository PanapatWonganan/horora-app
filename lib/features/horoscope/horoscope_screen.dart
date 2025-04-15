import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/zodiac_utils.dart';
import '../../core/services/auth_service.dart';
import '../../core/api/api_client.dart';
import '../../core/repositories/horoscope_repository.dart';
import '../../core/models/horoscope_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/widgets/gradient_button.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import '../chat/repositories/chat_repository.dart';
import 'widgets/horoscope_category_card.dart';
import 'widgets/zodiac_compatibility_card.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({Key? key}) : super(key: key);

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = AuthService.instance;
  final _chatRepository = ChatRepository();
  late HoroscopeRepository _horoscopeRepository;
  String _zodiacSign = "ไม่ทราบราศี";
  String _zodiacSignEn = "unknown";
  bool _isLoading = true;
  bool _isHoroscopeLoading = true;

  // ข้อมูลดวงชะตา
  DailyHoroscope? _dailyHoroscope;
  Map<String, dynamic> _weeklyHoroscope = {};
  Map<String, dynamic> _monthlyHoroscope = {};
  Map<String, dynamic> _yearlyHoroscope = {};

  // ข้อมูลความเข้ากัน
  List<dynamic> _goodCompatibility = [];
  List<dynamic> _badCompatibility = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initRepository();
    _loadUserZodiacSign();
  }

  Future<void> _initRepository() async {
    final prefs = await SharedPreferences.getInstance();
    final apiClient = ApiClient(baseUrl: 'https://api.astrology-app.com/api');

    setState(() {
      _horoscopeRepository = HoroscopeRepository(
        apiClient: apiClient,
        prefs: prefs,
      );
    });
  }

  Future<void> _loadUserZodiacSign() async {
    try {
      // Use the working method from ChatRepository
      final zodiacSign = await _chatRepository.getUserZodiacSign();

      if (zodiacSign != null && zodiacSign.isNotEmpty) {
        setState(() {
          _zodiacSignEn = zodiacSign;
          _zodiacSign = ZodiacUtils.getZodiacSignThai(
            DateTime.now(),
            zodiacSign: zodiacSign,
          );
          _isLoading = false;
        });

        // ดึงข้อมูลดวงชะตาตามราศี
        _loadHoroscopeData(zodiacSign);
      } else {
        setState(() {
          _zodiacSign = "ไม่ทราบราศี";
          _zodiacSignEn = "unknown";
          _isLoading = false;
          _isHoroscopeLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user zodiac sign: $e');
      setState(() {
        _zodiacSign = "ไม่ทราบราศี";
        _zodiacSignEn = "unknown";
        _isLoading = false;
        _isHoroscopeLoading = false;
      });
    }
  }

  Future<void> _loadHoroscopeData(String zodiacSign) async {
    try {
      // ดึงข้อมูลดวงชะตารายวัน
      final dailyHoroscope =
          await _horoscopeRepository.getDailyHoroscope(zodiacSign);

      // ข้อมูลความเข้ากัน (ตัวอย่าง)
      final goodZodiac = _getGoodCompatibility(zodiacSign);
      final badZodiac = _getBadCompatibility(zodiacSign);

      setState(() {
        _dailyHoroscope = dailyHoroscope;
        _goodCompatibility = goodZodiac;
        _badCompatibility = badZodiac;
        _weeklyHoroscope = _getMockWeeklyHoroscope(zodiacSign);
        _monthlyHoroscope = _getMockMonthlyHoroscope(zodiacSign);
        _yearlyHoroscope = _getMockYearlyHoroscope(zodiacSign);
        _isHoroscopeLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading horoscope data: $e');
      setState(() {
        _isHoroscopeLoading = false;
      });
    }
  }

  // ตัวอย่างข้อมูลราศีที่เข้ากันได้ดี
  List<dynamic> _getGoodCompatibility(String zodiacSign) {
    switch (zodiacSign) {
      case 'aries':
        return [
          {'name': 'ราศีสิงห์', 'imagePath': 'assets/images/zodiac/leo.png'},
          {
            'name': 'ราศีธนู',
            'imagePath': 'assets/images/zodiac/sagittarius.png'
          },
        ];
      case 'taurus':
        return [
          {'name': 'ราศีกันย์', 'imagePath': 'assets/images/zodiac/virgo.png'},
          {
            'name': 'ราศีมังกร',
            'imagePath': 'assets/images/zodiac/capricorn.png'
          },
        ];
      case 'gemini':
        return [
          {'name': 'ราศีตุลย์', 'imagePath': 'assets/images/zodiac/libra.png'},
          {
            'name': 'ราศีกุมภ์',
            'imagePath': 'assets/images/zodiac/aquarius.png'
          },
        ];
      case 'cancer':
        return [
          {
            'name': 'ราศีพิจิก',
            'imagePath': 'assets/images/zodiac/scorpio.png'
          },
          {'name': 'ราศีมีน', 'imagePath': 'assets/images/zodiac/pisces.png'},
        ];
      case 'leo':
        return [
          {'name': 'ราศีเมษ', 'imagePath': 'assets/images/zodiac/aries.png'},
          {
            'name': 'ราศีธนู',
            'imagePath': 'assets/images/zodiac/sagittarius.png'
          },
        ];
      case 'virgo':
        return [
          {'name': 'ราศีพฤษภ', 'imagePath': 'assets/images/zodiac/taurus.png'},
          {
            'name': 'ราศีมังกร',
            'imagePath': 'assets/images/zodiac/capricorn.png'
          },
        ];
      case 'libra':
        return [
          {'name': 'ราศีเมถุน', 'imagePath': 'assets/images/zodiac/gemini.png'},
          {
            'name': 'ราศีกุมภ์',
            'imagePath': 'assets/images/zodiac/aquarius.png'
          },
        ];
      case 'scorpio':
        return [
          {'name': 'ราศีกรกฎ', 'imagePath': 'assets/images/zodiac/cancer.png'},
          {'name': 'ราศีมีน', 'imagePath': 'assets/images/zodiac/pisces.png'},
        ];
      case 'sagittarius':
        return [
          {'name': 'ราศีเมษ', 'imagePath': 'assets/images/zodiac/aries.png'},
          {'name': 'ราศีสิงห์', 'imagePath': 'assets/images/zodiac/leo.png'},
        ];
      case 'capricorn':
        return [
          {'name': 'ราศีพฤษภ', 'imagePath': 'assets/images/zodiac/taurus.png'},
          {'name': 'ราศีกันย์', 'imagePath': 'assets/images/zodiac/virgo.png'},
        ];
      case 'aquarius':
        return [
          {'name': 'ราศีเมถุน', 'imagePath': 'assets/images/zodiac/gemini.png'},
          {'name': 'ราศีตุลย์', 'imagePath': 'assets/images/zodiac/libra.png'},
        ];
      case 'pisces':
        return [
          {'name': 'ราศีกรกฎ', 'imagePath': 'assets/images/zodiac/cancer.png'},
          {
            'name': 'ราศีพิจิก',
            'imagePath': 'assets/images/zodiac/scorpio.png'
          },
        ];
      default:
        return [
          {'name': 'ราศีกรกฎ', 'imagePath': 'assets/images/zodiac/cancer.png'},
          {'name': 'ราศีมีน', 'imagePath': 'assets/images/zodiac/pisces.png'},
        ];
    }
  }

  // ตัวอย่างข้อมูลราศีที่เข้ากันได้ยาก
  List<dynamic> _getBadCompatibility(String zodiacSign) {
    switch (zodiacSign) {
      case 'aries':
        return [
          {'name': 'ราศีกรกฎ', 'imagePath': 'assets/images/zodiac/cancer.png'},
          {
            'name': 'ราศีมังกร',
            'imagePath': 'assets/images/zodiac/capricorn.png'
          },
        ];
      case 'taurus':
        return [
          {'name': 'ราศีสิงห์', 'imagePath': 'assets/images/zodiac/leo.png'},
          {
            'name': 'ราศีกุมภ์',
            'imagePath': 'assets/images/zodiac/aquarius.png'
          },
        ];
      case 'gemini':
        return [
          {
            'name': 'ราศีพิจิก',
            'imagePath': 'assets/images/zodiac/scorpio.png'
          },
          {'name': 'ราศีมีน', 'imagePath': 'assets/images/zodiac/pisces.png'},
        ];
      case 'cancer':
        return [
          {'name': 'ราศีเมษ', 'imagePath': 'assets/images/zodiac/aries.png'},
          {'name': 'ราศีตุลย์', 'imagePath': 'assets/images/zodiac/libra.png'},
        ];
      case 'leo':
        return [
          {'name': 'ราศีพฤษภ', 'imagePath': 'assets/images/zodiac/taurus.png'},
          {
            'name': 'ราศีพิจิก',
            'imagePath': 'assets/images/zodiac/scorpio.png'
          },
        ];
      case 'virgo':
        return [
          {'name': 'ราศีเมถุน', 'imagePath': 'assets/images/zodiac/gemini.png'},
          {'name': 'ราศีมีน', 'imagePath': 'assets/images/zodiac/pisces.png'},
        ];
      case 'libra':
        return [
          {'name': 'ราศีกรกฎ', 'imagePath': 'assets/images/zodiac/cancer.png'},
          {
            'name': 'ราศีมังกร',
            'imagePath': 'assets/images/zodiac/capricorn.png'
          },
        ];
      case 'scorpio':
        return [
          {'name': 'ราศีเมถุน', 'imagePath': 'assets/images/zodiac/gemini.png'},
          {'name': 'ราศีสิงห์', 'imagePath': 'assets/images/zodiac/leo.png'},
        ];
      case 'sagittarius':
        return [
          {'name': 'ราศีพฤษภ', 'imagePath': 'assets/images/zodiac/taurus.png'},
          {
            'name': 'ราศีพิจิก',
            'imagePath': 'assets/images/zodiac/scorpio.png'
          },
        ];
      case 'capricorn':
        return [
          {'name': 'ราศีเมษ', 'imagePath': 'assets/images/zodiac/aries.png'},
          {'name': 'ราศีตุลย์', 'imagePath': 'assets/images/zodiac/libra.png'},
        ];
      case 'aquarius':
        return [
          {'name': 'ราศีพฤษภ', 'imagePath': 'assets/images/zodiac/taurus.png'},
          {
            'name': 'ราศีพิจิก',
            'imagePath': 'assets/images/zodiac/scorpio.png'
          },
        ];
      case 'pisces':
        return [
          {'name': 'ราศีเมถุน', 'imagePath': 'assets/images/zodiac/gemini.png'},
          {'name': 'ราศีกันย์', 'imagePath': 'assets/images/zodiac/virgo.png'},
        ];
      default:
        return [
          {'name': 'ราศีพฤษภ', 'imagePath': 'assets/images/zodiac/taurus.png'},
          {'name': 'ราศีสิงห์', 'imagePath': 'assets/images/zodiac/leo.png'},
        ];
    }
  }

  // ตัวอย่างข้อมูลดวงชะตารายสัปดาห์
  Map<String, dynamic> _getMockWeeklyHoroscope(String zodiacSign) {
    switch (zodiacSign) {
      case 'aries':
        return {
          'love': {
            'rating': 4,
            'description':
                'สัปดาห์นี้ความรักของคุณจะราบรื่น มีโอกาสได้พบคนถูกใจ หากมีคู่แล้วจะได้ใช้เวลาด้วยกันอย่างมีความสุข',
          },
          'career': {
            'rating': 3,
            'description':
                'ต้องระวังเรื่องการตัดสินใจในการทำงานให้รอบคอบ อาจมีอุปสรรคเล็กน้อยแต่สามารถผ่านไปได้ด้วยดี',
          },
          'health': {
            'rating': 4,
            'description':
                'สุขภาพแข็งแรงดี แต่ควรระวังเรื่องการพักผ่อนที่ไม่เพียงพอ ควรแบ่งเวลาพักผ่อนให้เหมาะสม',
          },
          'finance': {
            'rating': 4,
            'description':
                'การเงินมีโชคลาภเล็กๆ น้อยๆ มีรายได้เข้ามาอย่างต่อเนื่อง แต่ควรระวังรายจ่ายที่ไม่จำเป็น',
          },
          'lucky_numbers': '3, 7, 15, 25, 36',
          'lucky_day': 'วันอังคาร, วันเสาร์',
          'lucky_color': 'แดง, ส้ม',
        };
      default:
        return {
          'love': {
            'rating': 3,
            'description':
                'ความรักมีการปรับตัวที่ดีขึ้น แต่ต้องอาศัยความเข้าใจและอดทน',
          },
          'career': {
            'rating': 4,
            'description':
                'การงานเข้าที่เข้าทางดี มีโอกาสได้รับการยอมรับจากเพื่อนร่วมงานและผู้บังคับบัญชา',
          },
          'health': {
            'rating': 3,
            'description':
                'ควรดูแลสุขภาพให้มากขึ้น ระวังความผิดปกติเล็กน้อยที่อาจเกิดขึ้นได้',
          },
          'finance': {
            'rating': 3,
            'description':
                'การเงินปานกลาง มีรายรับรายจ่ายที่สมดุล ควรใช้จ่ายอย่างประหยัด',
          },
          'lucky_numbers': '1, 8, 14, 23, 39',
          'lucky_day': 'วันพฤหัสบดี, วันอาทิตย์',
          'lucky_color': 'น้ำเงิน, เขียว',
        };
    }
  }

  // ตัวอย่างข้อมูลดวงชะตารายเดือน
  Map<String, dynamic> _getMockMonthlyHoroscope(String zodiacSign) {
    switch (zodiacSign) {
      case 'aries':
        return {
          'love': {
            'rating': 5,
            'description':
                'เดือนนี้ความรักของคุณจะเต็มไปด้วยความหวานชื่น คนโสดมีโอกาสพบรักครั้งใหม่ที่น่าประทับใจ',
          },
          'career': {
            'rating': 4,
            'description':
                'มีความก้าวหน้าในหน้าที่การงาน อาจได้รับโครงการใหม่หรือโอกาสในการแสดงฝีมือ',
          },
          'health': {
            'rating': 3,
            'description':
                'สุขภาพโดยรวมดี แต่ควรระวังความเครียดสะสม ควรหาเวลาผ่อนคลายด้วยกิจกรรมที่ชื่นชอบ',
          },
          'finance': {
            'rating': 5,
            'description':
                'การเงินคล่องตัว อาจมีโชคลาภก้อนใหญ่เข้ามา เหมาะแก่การลงทุนหรือเก็บออม',
          },
          'overview':
              'เดือนนี้เป็นช่วงที่ดีสำหรับคุณในหลายๆ ด้าน โดยเฉพาะความรักและการเงิน ควรใช้โอกาสนี้ในการวางแผนอนาคต',
        };
      default:
        return {
          'love': {
            'rating': 4,
            'description':
                'ความรักมีแนวโน้มที่ดี มีความเข้าใจกันมากขึ้น คนโสดมีโอกาสได้พบเจอคนพิเศษ',
          },
          'career': {
            'rating': 4,
            'description':
                'การงานราบรื่น อาจได้รับมอบหมายงานที่ท้าทายความสามารถ',
          },
          'health': {
            'rating': 4,
            'description':
                'สุขภาพแข็งแรงดี ควรออกกำลังกายสม่ำเสมอเพื่อรักษาสุขภาพให้แข็งแรง',
          },
          'finance': {
            'rating': 3,
            'description':
                'การเงินปานกลาง มีรายรับรายจ่ายที่สมดุล ควรวางแผนการใช้จ่ายให้รัดกุม',
          },
          'overview':
              'เดือนนี้เป็นช่วงที่มีความสมดุลในชีวิต ทั้งเรื่องงานและความรักจะดำเนินไปได้ด้วยดี',
        };
    }
  }

  // ตัวอย่างข้อมูลดวงชะตารายปี
  Map<String, dynamic> _getMockYearlyHoroscope(String zodiacSign) {
    switch (zodiacSign) {
      case 'aries':
        return {
          'love': {
            'rating': 4,
            'description':
                'ปีนี้ความรักของคุณจะมีการเปลี่ยนแปลงในทางที่ดี หากมีคู่แล้วความสัมพันธ์จะแน่นแฟ้นขึ้น คนโสดมีโอกาสพบรักครั้งใหม่ในช่วงกลางปี',
          },
          'career': {
            'rating': 5,
            'description':
                'การงานมีความก้าวหน้าอย่างมาก อาจได้รับการเลื่อนตำแหน่งหรือมีโอกาสในการเติบโตทางอาชีพ',
          },
          'health': {
            'rating': 3,
            'description':
                'สุขภาพโดยรวมดี แต่ควรระวังโรคเกี่ยวกับระบบทางเดินหายใจและความเครียดสะสม',
          },
          'finance': {
            'rating': 4,
            'description':
                'การเงินมั่นคง มีโอกาสในการลงทุนที่ให้ผลตอบแทนดี ควรวางแผนการเงินระยะยาว',
          },
          'overview':
              'ปีนี้เป็นปีแห่งความสำเร็จและการเติบโตในหลายด้านของชีวิต โดยเฉพาะเรื่องงานและความมั่นคง',
          'advice':
              'ควรใช้พลังงานและความกระตือรือร้นให้เป็นประโยชน์ในทางสร้างสรรค์ อย่าใจร้อนจนเกินไป',
        };
      default:
        return {
          'love': {
            'rating': 4,
            'description':
                'ปีนี้เรื่องความรักจะดำเนินไปอย่างราบรื่น มีความเข้าใจและให้เกียรติซึ่งกันและกัน',
          },
          'career': {
            'rating': 4,
            'description':
                'การงานมีความมั่นคงและก้าวหน้า อาจมีโอกาสได้เรียนรู้สิ่งใหม่หรือพัฒนาทักษะเพิ่มเติม',
          },
          'health': {
            'rating': 4,
            'description':
                'สุขภาพแข็งแรง แต่ควรใส่ใจดูแลตัวเองและหมั่นตรวจสุขภาพประจำปี',
          },
          'finance': {
            'rating': 3,
            'description':
                'การเงินมีความมั่นคงพอสมควร มีโอกาสได้รับรายได้พิเศษจากงานเสริม',
          },
          'overview':
              'ปีนี้เป็นปีแห่งความสมดุลและการพัฒนาตนเอง ทั้งในด้านอาชีพและชีวิตส่วนตัว',
          'advice': 'ควรใช้เวลาในการดูแลตัวเองและวางแผนอนาคตอย่างรอบคอบ',
        };
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  _buildActionButtons(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDailyTab(),
                        _buildWeeklyTab(),
                        _buildMonthlyTab(),
                        _buildYearlyTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                ZodiacUtils.getZodiacIcon(_zodiacSignEn),
                color: AppColors.primary,
                size: 20,
              ),
            ),
          const SizedBox(width: 12),
          Text(
            _zodiacSign,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: GradientButton(
              text: 'ตรวจสอบความเข้ากัน',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.compatibilityCheck);
              },
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              height: 44,
              borderRadius: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.grey,
      tabs: const [
        Tab(text: 'รายวัน'),
        Tab(text: 'รายสัปดาห์'),
        Tab(text: 'รายเดือน'),
        Tab(text: 'รายปี'),
      ],
    );
  }

  Widget _buildDailyTab() {
    if (_isHoroscopeLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildHoroscopeCategories(),
          const SizedBox(height: 32),
          _buildCompatibility(),
          const SizedBox(height: 32),
          _buildLuckyElements(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    if (_isHoroscopeLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    final weeklyData = _weeklyHoroscope;
    if (weeklyData.isEmpty) {
      return const Center(
        child: Text(
          'ดวงชะตารายสัปดาห์จะมาเร็วๆ นี้',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'ดวงชะตาประจำสัปดาห์',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'ความรัก',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  description: weeklyData['love']['description'],
                  rating: weeklyData['love']['rating'],
                  onTap: () {
                    // TODO: Navigate to love horoscope details
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'การงาน',
                  icon: Icons.work,
                  color: Colors.amber,
                  description: weeklyData['career']['description'],
                  rating: weeklyData['career']['rating'],
                  onTap: () {
                    // TODO: Navigate to career horoscope details
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'สุขภาพ',
                  icon: Icons.favorite_border,
                  color: Colors.green,
                  description: weeklyData['health']['description'],
                  rating: weeklyData['health']['rating'],
                  onTap: () {
                    // TODO: Navigate to health horoscope details
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'การเงิน',
                  icon: Icons.attach_money,
                  color: Colors.blue,
                  description: weeklyData['finance']['description'],
                  rating: weeklyData['finance']['rating'],
                  onTap: () {
                    // TODO: Navigate to finance horoscope details
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ข้อมูลเพิ่มเติม',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoItem('เลขนำโชค', weeklyData['lucky_numbers']),
                const Divider(height: 24, color: Colors.white10),
                _buildInfoItem('วันนำโชค', weeklyData['lucky_day']),
                const Divider(height: 24, color: Colors.white10),
                _buildInfoItem('สีนำโชค', weeklyData['lucky_color']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab() {
    if (_isHoroscopeLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    final monthlyData = _monthlyHoroscope;
    if (monthlyData.isEmpty) {
      return const Center(
        child: Text(
          'ดวงชะตารายเดือนจะมาเร็วๆ นี้',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ภาพรวมประจำเดือน',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  monthlyData['overview'],
                  style: TextStyle(
                    color: AppColors.lightText.withOpacity(0.8),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ด้านต่างๆ ของชีวิต',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'ความรัก',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  description: monthlyData['love']['description'],
                  rating: monthlyData['love']['rating'],
                  onTap: () {
                    // TODO: Navigate to love horoscope details
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'การงาน',
                  icon: Icons.work,
                  color: Colors.amber,
                  description: monthlyData['career']['description'],
                  rating: monthlyData['career']['rating'],
                  onTap: () {
                    // TODO: Navigate to career horoscope details
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'สุขภาพ',
                  icon: Icons.favorite_border,
                  color: Colors.green,
                  description: monthlyData['health']['description'],
                  rating: monthlyData['health']['rating'],
                  onTap: () {
                    // TODO: Navigate to health horoscope details
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'การเงิน',
                  icon: Icons.attach_money,
                  color: Colors.blue,
                  description: monthlyData['finance']['description'],
                  rating: monthlyData['finance']['rating'],
                  onTap: () {
                    // TODO: Navigate to finance horoscope details
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyTab() {
    if (_isHoroscopeLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    final yearlyData = _yearlyHoroscope;
    if (yearlyData.isEmpty) {
      return const Center(
        child: Text(
          'ดวงชะตารายปีจะมาเร็วๆ นี้',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ภาพรวมประจำปี',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  yearlyData['overview'],
                  style: TextStyle(
                    color: AppColors.lightText.withOpacity(0.8),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'คำแนะนำ',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  yearlyData['advice'],
                  style: TextStyle(
                    color: AppColors.lightText.withOpacity(0.8),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ด้านต่างๆ ของชีวิต',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'ความรัก',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  description: yearlyData['love']['description'],
                  rating: yearlyData['love']['rating'],
                  onTap: () {
                    // TODO: Navigate to love horoscope details
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'การงาน',
                  icon: Icons.work,
                  color: Colors.amber,
                  description: yearlyData['career']['description'],
                  rating: yearlyData['career']['rating'],
                  onTap: () {
                    // TODO: Navigate to career horoscope details
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'สุขภาพ',
                  icon: Icons.favorite_border,
                  color: Colors.green,
                  description: yearlyData['health']['description'],
                  rating: yearlyData['health']['rating'],
                  onTap: () {
                    // TODO: Navigate to health horoscope details
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'การเงิน',
                  icon: Icons.attach_money,
                  color: Colors.blue,
                  description: yearlyData['finance']['description'],
                  rating: yearlyData['finance']['rating'],
                  onTap: () {
                    // TODO: Navigate to finance horoscope details
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getLuckyIcon(title),
            color: AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.lightText.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoroscopeCategories() {
    if (_dailyHoroscope == null) {
      // ถ้ายังไม่มีข้อมูลดวงประจำวัน ให้แสดงข้อมูลตัวอย่าง
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ดวงชะตาวันนี้',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'ความรัก',
                  icon: Icons.favorite,
                  color: Colors.pink,
                  description:
                      'วันนี้คุณจะได้พบกับความรักที่สดใสและมีความสุขกับคนรอบข้าง',
                  rating: 4,
                  onTap: () {
                    // TODO: Navigate to love horoscope details
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'การงาน',
                  icon: Icons.work,
                  color: Colors.amber,
                  description: 'งานของคุณจะราบรื่น มีโอกาสได้รับคำชมจากผู้ใหญ่',
                  rating: 3,
                  onTap: () {
                    // TODO: Navigate to career horoscope details
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'สุขภาพ',
                  icon: Icons.favorite_border,
                  color: Colors.green,
                  description:
                      'สุขภาพของคุณแข็งแรงดี ควรออกกำลังกายเพื่อเสริมพลัง',
                  rating: 5,
                  onTap: () {
                    // TODO: Navigate to health horoscope details
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'การเงิน',
                  icon: Icons.attach_money,
                  color: Colors.blue,
                  description:
                      'การเงินของคุณมีแนวโน้มที่ดี มีโอกาสได้รับโชคลาภ',
                  rating: 4,
                  onTap: () {
                    // TODO: Navigate to finance horoscope details
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }

    // ถ้ามีข้อมูลดวงประจำวัน ให้แสดงข้อมูลจริง
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ดวงชะตาวันนี้',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'คำทำนายประจำวันที่ ${_dailyHoroscope!.date.day}/${_dailyHoroscope!.date.month}/${_dailyHoroscope!.date.year}',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _dailyHoroscope!.contentTh,
                style: TextStyle(
                  color: AppColors.lightText.withOpacity(0.8),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: HoroscopeCategoryCard(
                title: 'ความรัก',
                icon: Icons.favorite,
                color: Colors.pink,
                description:
                    'ความรักของคุณอยู่ในช่วงที่ดี สัมพันธภาพกับคนรอบข้างเป็นไปอย่างราบรื่น',
                rating: _dailyHoroscope!.loveRating,
                onTap: () {
                  // TODO: Navigate to love horoscope details
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: HoroscopeCategoryCard(
                title: 'การงาน',
                icon: Icons.work,
                color: Colors.amber,
                description:
                    'งานของคุณมีความคืบหน้า ได้รับการยอมรับจากเพื่อนร่วมงาน',
                rating: _dailyHoroscope!.careerRating,
                onTap: () {
                  // TODO: Navigate to career horoscope details
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: HoroscopeCategoryCard(
                title: 'สุขภาพ',
                icon: Icons.favorite_border,
                color: Colors.green,
                description:
                    'สุขภาพของคุณอยู่ในเกณฑ์ดี ควรหาเวลาพักผ่อนให้เพียงพอ',
                rating: _dailyHoroscope!.healthRating,
                onTap: () {
                  // TODO: Navigate to health horoscope details
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: HoroscopeCategoryCard(
                title: 'การเงิน',
                icon: Icons.attach_money,
                color: Colors.blue,
                description: 'การเงินมีเสถียรภาพ อาจมีรายได้พิเศษเข้ามา',
                rating: 4,
                onTap: () {
                  // TODO: Navigate to finance horoscope details
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompatibility() {
    // แปลง List<dynamic> เป็น List<Map<String, String>> สำหรับ ZodiacCompatibilityCard
    final List<Map<String, String>> goodCompatibility = _goodCompatibility
        .map((item) => Map<String, String>.from(item))
        .toList();

    final List<Map<String, String>> badCompatibility = _badCompatibility
        .map((item) => Map<String, String>.from(item))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ความเข้ากันได้',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ZodiacCompatibilityCard(
                title: 'เข้ากันได้ดี',
                zodiacSigns: goodCompatibility,
                onTap: () {
                  AppRouter.navigateTo(context, AppRoutes.compatibilityCheck);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ZodiacCompatibilityCard(
                title: 'เข้ากันได้ยาก',
                zodiacSigns: badCompatibility,
                onTap: () {
                  AppRouter.navigateTo(context, AppRoutes.compatibilityCheck);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GradientButton(
          text: 'ตรวจสอบความเข้ากัน',
          onPressed: () {
            AppRouter.navigateTo(context, AppRoutes.compatibilityCheck);
          },
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          width: double.infinity,
          height: 48,
        ),
      ],
    );
  }

  Widget _buildLuckyElements() {
    // ถ้าไม่มีข้อมูลดวงชะตาประจำวัน ให้แสดงข้อมูลเดิม
    if (_dailyHoroscope == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สิ่งนำโชค',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildLuckyItem('เลขนำโชค', '3, 8, 13, 17, 21'),
                const Divider(height: 24, color: Colors.white10),
                _buildLuckyItem('สีนำโชค', 'แดง, ม่วง, น้ำเงินเข้ม'),
                const Divider(height: 24, color: Colors.white10),
                _buildLuckyItem('วันนำโชค', 'วันอังคาร, วันอาทิตย์'),
                const Divider(height: 24, color: Colors.white10),
                _buildLuckyItem('อัญมณีนำโชค', 'โกเมน, ทับทิม, โอปอล'),
              ],
            ),
          ),
        ],
      );
    }

    // ถ้ามีข้อมูลดวงชะตาประจำวัน ให้แสดงข้อมูลจริง
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'สิ่งนำโชค',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildLuckyItem('เลขนำโชค', _dailyHoroscope!.luckyNumber),
              const Divider(height: 24, color: Colors.white10),
              _buildLuckyItem('สีนำโชค', _dailyHoroscope!.luckyColor),
              const Divider(height: 24, color: Colors.white10),
              _buildLuckyItem('วันนำโชค', 'วันอังคาร, วันอาทิตย์'),
              const Divider(height: 24, color: Colors.white10),
              _buildLuckyItem('อัญมณีนำโชค', 'โกเมน, ทับทิม, โอปอล'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyItem(String title, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getLuckyIcon(title),
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.lightText.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getLuckyIcon(String title) {
    switch (title) {
      case 'เลขนำโชค':
        return Icons.pin;
      case 'สีนำโชค':
        return Icons.color_lens;
      case 'วันนำโชค':
        return Icons.calendar_today;
      case 'อัญมณีนำโชค':
        return Icons.diamond;
      default:
        return Icons.star;
    }
  }
}
