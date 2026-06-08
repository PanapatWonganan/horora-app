import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/sacred_ui.dart';
import '../../core/theme/celestial_effects.dart';
import '../../core/utils/zodiac_utils.dart';
import '../../core/api/api_client.dart';
import '../../config/constants.dart';
import '../../core/repositories/horoscope_repository.dart';
import '../../core/models/horoscope_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import '../chat/repositories/chat_repository.dart';
import 'widgets/horoscope_category_card.dart';

/// Calm temple-toned colors for the four horoscope life areas. No neon.
const Color _kLoveColor = AppColors.templeVermilion;
const Color _kCareerColor = AppColors.deepGoldBrown;
const Color _kHealthColor = AppColors.bodhiGreen;
const Color _kFinanceColor = AppColors.mutedGold;

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({Key? key}) : super(key: key);

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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

  // Bumped each time the user lands on a new tab so the tab body's
  // StaggeredReveal widgets rebuild fresh and re-cascade in (a soft reveal on
  // tab switch instead of a hard swap). Visual only — no data is reloaded.
  int _revealEpoch = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _init();
  }

  // Re-trigger the entrance cascade once the swipe/tap settles on a new tab.
  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    if (!mounted) return;
    setState(() => _revealEpoch++);
  }

  Future<void> _init() async {
    // Initialize the repository before loading any horoscope data to avoid
    // a LateInitializationError race between _initRepository and
    // _loadUserZodiacSign (which depends on _horoscopeRepository).
    await _initRepository();
    await _loadUserZodiacSign();
  }

  Future<void> _initRepository() async {
    final prefs = await SharedPreferences.getInstance();
    final apiClient = ApiClient(baseUrl: ApiConstants.baseUrl);

    if (!mounted) return;
    setState(() {
      _horoscopeRepository = HoroscopeRepository(
        apiClient: apiClient,
        prefs: prefs,
      );
    });
  }

  Future<void> _loadUserZodiacSign() async {
    try {
      // Use the working method from ChatRepository ที่คืน Thai animal name
      final thaiAnimal = await _chatRepository.getUserZodiacSign();

      if (thaiAnimal != null && thaiAnimal.isNotEmpty) {
        setState(() {
          _zodiacSignEn = thaiAnimal; // เก็บ Thai animal name
          _zodiacSign = 'ปี$thaiAnimal'; // แสดงเป็น "ปีมะเมีย"
          _isLoading = false;
        });

        // ดึงข้อมูลดวงชะตาตาม Thai animal
        _loadHoroscopeData(thaiAnimal);
      } else {
        setState(() {
          _zodiacSign = "ไม่ทราบปีนักษัตร";
          _zodiacSignEn = "unknown";
          _isLoading = false;
          _isHoroscopeLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user zodiac sign: $e');
      setState(() {
        _zodiacSign = "ไม่ทราบปีนักษัตร";
        _zodiacSignEn = "unknown";
        _isLoading = false;
        _isHoroscopeLoading = false;
      });
    }
  }

  Future<void> _loadHoroscopeData(String thaiAnimal) async {
    try {
      debugPrint('_loadHoroscopeData called with: "$thaiAnimal"');
      
      // ดึงข้อมูลดวงชะตารายวันตาม Thai animal
      final dailyHoroscope =
          await _horoscopeRepository.getDailyHoroscope(thaiAnimal);

      if (mounted) {
        setState(() {
          _dailyHoroscope = dailyHoroscope;
          _weeklyHoroscope = _getMockWeeklyHoroscope(thaiAnimal);
          _monthlyHoroscope = _getMockMonthlyHoroscope(thaiAnimal);
          _yearlyHoroscope = _getMockYearlyHoroscope(thaiAnimal);
          _isHoroscopeLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading horoscope data: $e');
      if (mounted) {
        setState(() {
          _isHoroscopeLoading = false;
        });
      }
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
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              )
            : Column(
                children: [
                  StaggeredReveal(index: 0, child: _buildHeader()),
                  StaggeredReveal(index: 1, child: _buildTabBar()),
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
    );
  }

  Widget _buildHeader() {
    return SacredHeader(
      showBack: false,
      overline: 'HOROSCOPE',
      title: 'ดวงชะตา',
      trailing: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.candleGold.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    ZodiacUtils.getZodiacIcon(_zodiacSignEn),
                    color: AppColors.candleGold,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  _zodiacSign,
                  style: SacredText.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.candleGold,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: AppColors.onBackdrop,
      unselectedLabelColor: AppColors.onBackdropMuted,
      labelStyle: GoogleFonts.kanit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.kanit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
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
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      );
    }

    return SingleChildScrollView(
      key: ValueKey('daily_$_revealEpoch'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          StaggeredReveal(index: 2, child: _buildHoroscopeCategories()),
          const SizedBox(height: 32),
          StaggeredReveal(index: 3, child: _buildLuckyElements()),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    if (_isHoroscopeLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      );
    }

    final weeklyData = _weeklyHoroscope;
    if (weeklyData.isEmpty) {
      return _buildEmptyState('ดวงชะตารายสัปดาห์จะมาเร็วๆ นี้');
    }

    return SingleChildScrollView(
      key: ValueKey('weekly_$_revealEpoch'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const StaggeredReveal(
            index: 2,
            child: SacredSectionTitle(
              'แนวทางประจำสัปดาห์',
              overline: 'THIS WEEK',
            ),
          ),
          const SizedBox(height: 16),
          StaggeredReveal(
            index: 3,
            child: Row(
              children: [
                Expanded(
                  child: HoroscopeCategoryCard(
                    title: 'ความรัก',
                    icon: Icons.favorite,
                    color: _kLoveColor,
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
                    color: _kCareerColor,
                    description: weeklyData['career']['description'],
                    rating: weeklyData['career']['rating'],
                    onTap: () {
                      // TODO: Navigate to career horoscope details
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StaggeredReveal(
            index: 4,
            child: Row(
              children: [
                Expanded(
                  child: HoroscopeCategoryCard(
                    title: 'สุขภาพ',
                    icon: Icons.favorite_border,
                    color: _kHealthColor,
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
                    color: _kFinanceColor,
                    description: weeklyData['finance']['description'],
                    rating: weeklyData['finance']['rating'],
                    onTap: () {
                      // TODO: Navigate to finance horoscope details
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          StaggeredReveal(
            index: 5,
            child: SacredCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ข้อมูลเพิ่มเติม',
                    style: SacredText.kanit(
                      color: AppColors.deepText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem('เลขนำโชค', weeklyData['lucky_numbers']),
                  const SizedBox(height: 16),
                  const SacredGoldDivider(),
                  const SizedBox(height: 16),
                  _buildInfoItem('วันนำโชค', weeklyData['lucky_day']),
                  const SizedBox(height: 16),
                  const SacredGoldDivider(),
                  const SizedBox(height: 16),
                  _buildInfoItem('สีนำโชค', weeklyData['lucky_color']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: SacredText.kanit(
            color: AppColors.onBackdropMuted,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyTab() {
    if (_isHoroscopeLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      );
    }

    final monthlyData = _monthlyHoroscope;
    if (monthlyData.isEmpty) {
      return _buildEmptyState('ดวงชะตารายเดือนจะมาเร็วๆ นี้');
    }

    return SingleChildScrollView(
      key: ValueKey('monthly_$_revealEpoch'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          StaggeredReveal(
            index: 2,
            child: SacredCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SacredSectionTitle(
                    'ภาพรวมประจำเดือน',
                    overline: 'THIS MONTH',
                    onCard: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    monthlyData['overview'],
                    style: SacredText.kanit(
                      color: AppColors.mutedText,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const StaggeredReveal(
            index: 3,
            child: SacredSectionTitle('ด้านต่างๆ ของชีวิต'),
          ),
          const SizedBox(height: 16),
          StaggeredReveal(
            index: 4,
            child: Row(
              children: [
                Expanded(
                  child: HoroscopeCategoryCard(
                    title: 'ความรัก',
                    icon: Icons.favorite,
                    color: _kLoveColor,
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
                    color: _kCareerColor,
                    description: monthlyData['career']['description'],
                    rating: monthlyData['career']['rating'],
                    onTap: () {
                      // TODO: Navigate to career horoscope details
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StaggeredReveal(
            index: 5,
            child: Row(
              children: [
                Expanded(
                  child: HoroscopeCategoryCard(
                    title: 'สุขภาพ',
                    icon: Icons.favorite_border,
                    color: _kHealthColor,
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
                    color: _kFinanceColor,
                    description: monthlyData['finance']['description'],
                    rating: monthlyData['finance']['rating'],
                    onTap: () {
                      // TODO: Navigate to finance horoscope details
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyTab() {
    if (_isHoroscopeLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      );
    }

    final yearlyData = _yearlyHoroscope;
    if (yearlyData.isEmpty) {
      return _buildEmptyState('ดวงชะตารายปีจะมาเร็วๆ นี้');
    }

    return SingleChildScrollView(
      key: ValueKey('yearly_$_revealEpoch'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          StaggeredReveal(
            index: 2,
            child: SacredCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SacredSectionTitle(
                    'ภาพรวมประจำปี',
                    overline: 'THIS YEAR',
                    onCard: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    yearlyData['overview'],
                    style: SacredText.kanit(
                      color: AppColors.mutedText,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'คำแนะนำ',
                    style: SacredText.kanit(
                      color: AppColors.deepText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    yearlyData['advice'],
                    style: SacredText.kanit(
                      color: AppColors.mutedText,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const StaggeredReveal(
            index: 3,
            child: SacredSectionTitle('ด้านต่างๆ ของชีวิต'),
          ),
          const SizedBox(height: 16),
          StaggeredReveal(
            index: 4,
            child: Row(
              children: [
                Expanded(
                  child: HoroscopeCategoryCard(
                    title: 'ความรัก',
                    icon: Icons.favorite,
                    color: _kLoveColor,
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
                    color: _kCareerColor,
                    description: yearlyData['career']['description'],
                    rating: yearlyData['career']['rating'],
                    onTap: () {
                      // TODO: Navigate to career horoscope details
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StaggeredReveal(
            index: 5,
            child: Row(
              children: [
                Expanded(
                  child: HoroscopeCategoryCard(
                    title: 'สุขภาพ',
                    icon: Icons.favorite_border,
                    color: _kHealthColor,
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
                    color: _kFinanceColor,
                    description: yearlyData['finance']['description'],
                    rating: yearlyData['finance']['rating'],
                    onTap: () {
                      // TODO: Navigate to finance horoscope details
                    },
                  ),
                ),
              ],
            ),
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
            color: AppColors.candleGold.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getLuckyIcon(title),
            color: AppColors.deepGoldBrown,
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
                style: SacredText.kanit(
                  color: AppColors.mutedText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
          const SacredSectionTitle(
            'พลังงานวันนี้',
            overline: 'TODAY',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HoroscopeCategoryCard(
                  title: 'ความรัก',
                  icon: Icons.favorite,
                  color: _kLoveColor,
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
                  color: _kCareerColor,
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
                  color: _kHealthColor,
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
                  color: _kFinanceColor,
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
        const SacredSectionTitle(
          'แนวทางวันนี้',
          overline: 'TODAY',
        ),
        const SizedBox(height: 16),
        SacredCard(
          highlight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'คำทำนายประจำวันที่ ${_dailyHoroscope!.date.day}/${_dailyHoroscope!.date.month}/${_dailyHoroscope!.date.year}',
                style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _dailyHoroscope!.contentTh,
                style: SacredText.kanit(
                  color: AppColors.mutedText,
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
                color: _kLoveColor,
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
                color: _kCareerColor,
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
                color: _kHealthColor,
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
                color: _kFinanceColor,
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

  Widget _buildLuckyElements() {
    // ถ้าไม่มีข้อมูลดวงชะตาประจำวัน ให้แสดงข้อมูลเดิม
    if (_dailyHoroscope == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SacredSectionTitle(
            'สิ่งนำโชค',
            overline: 'LUCKY',
          ),
          const SizedBox(height: 16),
          SacredCard(
            child: Column(
              children: [
                _buildLuckyItem('เลขนำโชค', '3, 8, 13, 17, 21'),
                _luckyDivider(),
                _buildLuckyItem('สีนำโชค', 'แดง, ม่วง, น้ำเงินเข้ม'),
                _luckyDivider(),
                _buildLuckyItem('วันนำโชค', 'วันอังคาร, วันอาทิตย์'),
                _luckyDivider(),
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
        const SacredSectionTitle(
          'สิ่งนำโชค',
          overline: 'LUCKY',
        ),
        const SizedBox(height: 16),
        SacredCard(
          child: Column(
            children: [
              _buildLuckyItem('เลขนำโชค', _dailyHoroscope!.luckyNumber),
              _luckyDivider(),
              _buildLuckyItem('สีนำโชค', _dailyHoroscope!.luckyColor),
              _luckyDivider(),
              _buildLuckyItem('วันนำโชค', 'วันอังคาร, วันอาทิตย์'),
              _luckyDivider(),
              _buildLuckyItem('อัญมณีนำโชค', 'โกเมน, ทับทิม, โอปอล'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _luckyDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: SacredGoldDivider(),
    );
  }

  Widget _buildLuckyItem(String title, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.candleGold.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            _getLuckyIcon(title),
            color: AppColors.deepGoldBrown,
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
                style: SacredText.kanit(
                  color: AppColors.mutedText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
