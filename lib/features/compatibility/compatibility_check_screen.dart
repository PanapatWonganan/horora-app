import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/compatibility_result.dart';
import '../../core/repositories/horoscope_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../features/chat/repositories/chat_repository.dart';

class CompatibilityCheckScreen extends StatefulWidget {
  const CompatibilityCheckScreen({Key? key}) : super(key: key);

  @override
  State<CompatibilityCheckScreen> createState() =>
      _CompatibilityCheckScreenState();
}

class _CompatibilityCheckScreenState extends State<CompatibilityCheckScreen> {
  final List<String> zodiacSigns = [
    'aries',
    'taurus',
    'gemini',
    'cancer',
    'leo',
    'virgo',
    'libra',
    'scorpio',
    'sagittarius',
    'capricorn',
    'aquarius',
    'pisces'
  ];

  final Map<String, String> zodiacDisplayNames = {
    'aries': 'ราศีเมษ',
    'taurus': 'ราศีพฤษภ',
    'gemini': 'ราศีเมถุน',
    'cancer': 'ราศีกรกฎ',
    'leo': 'ราศีสิงห์',
    'virgo': 'ราศีกันย์',
    'libra': 'ราศีตุลย์',
    'scorpio': 'ราศีพิจิก',
    'sagittarius': 'ราศีธนู',
    'capricorn': 'ราศีมังกร',
    'aquarius': 'ราศีกุมภ์',
    'pisces': 'ราศีมีน',
  };

  String? selectedSign;
  bool isLoading = false;
  CompatibilityResult? compatibilityResult;
  String? errorMessage;
  String? userZodiacSign;
  final ChatRepository _chatRepository = ChatRepository();

  @override
  void initState() {
    super.initState();
    _loadUserZodiacSign();
  }

  Future<void> _loadUserZodiacSign() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      userZodiacSign = await _chatRepository.getUserZodiacSign();

      print("Loaded user zodiac sign: $userZodiacSign");

      if (userZodiacSign == null || userZodiacSign!.isEmpty) {
        setState(() {
          errorMessage = 'ไม่พบข้อมูลราศีของคุณ กรุณาตั้งค่าราศีในโปรไฟล์';
          isLoading = false;
        });
        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error loading user zodiac sign: $e");
      setState(() {
        errorMessage = 'ไม่สามารถโหลดข้อมูลราศีของคุณได้: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _checkCompatibility(String otherSign) async {
    print("Checking compatibility with: $otherSign");

    if (userZodiacSign == null || userZodiacSign!.isEmpty) {
      setState(() {
        errorMessage = 'ไม่พบข้อมูลราศีของคุณ กรุณาตั้งค่าราศีในโปรไฟล์';
      });
      return;
    }

    setState(() {
      isLoading = true;
      selectedSign = otherSign;
      errorMessage = null;
    });

    try {
      print("User zodiac: $userZodiacSign, Selected zodiac: $otherSign");

      final horoscopeRepository;
      try {
        horoscopeRepository =
            Provider.of<HoroscopeRepository>(context, listen: false);
      } catch (e) {
        print("Error getting HoroscopeRepository: $e");
        throw Exception("ไม่สามารถเข้าถึง HoroscopeRepository ได้");
      }

      final result =
          await horoscopeRepository.getCurrentUserCompatibility(otherSign);

      setState(() {
        compatibilityResult = result;
        isLoading = false;
      });
    } catch (e) {
      print("Error checking compatibility: $e");
      setState(() {
        errorMessage =
            'ไม่สามารถตรวจสอบความเข้ากันได้ในขณะนี้: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ตรวจสอบความเข้ากัน',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading && compatibilityResult == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : errorMessage != null && compatibilityResult == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => _loadUserZodiacSign(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'ลองใหม่อีกครั้ง',
                            style: TextStyle(
                              color: AppColors.lightText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'ราศีของคุณ',
                              style: TextStyle(
                                color: AppColors.lightText.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userZodiacSign != null
                                  ? zodiacDisplayNames[userZodiacSign!] ??
                                      userZodiacSign!
                                  : "ไม่ทราบ",
                              style: TextStyle(
                                color: AppColors.lightText,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'เลือกราศีที่ต้องการตรวจสอบความเข้ากัน',
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: compatibilityResult == null
                          ? _buildZodiacGrid()
                          : _buildCompatibilityResult(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildZodiacGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: zodiacSigns.length,
      itemBuilder: (context, index) {
        final sign = zodiacSigns[index];
        return _buildZodiacCard(sign);
      },
    );
  }

  Widget _buildZodiacCard(String sign) {
    return GestureDetector(
      onTap: () => _checkCompatibility(sign),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/zodiac/$sign.png',
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 8),
            Text(
              zodiacDisplayNames[sign] ?? sign,
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityResult() {
    if (compatibilityResult == null) {
      return Center(
        child: Text(
          'กรุณาเลือกราศีเพื่อตรวจสอบความเข้ากัน',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildZodiacColumn(userZodiacSign!),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                _buildZodiacColumn(selectedSign!),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildScoreSection(),
          const SizedBox(height: 24),
          _buildCompatibilitySection('ความเข้ากันโดยรวม',
              compatibilityResult?.description ?? 'ไม่มีข้อมูล'),
          const SizedBox(height: 16),
          _buildCompatibilitySection('ความเข้ากันด้านความรัก',
              compatibilityResult?.loveCompatibility ?? 'ไม่มีข้อมูล'),
          const SizedBox(height: 16),
          _buildCompatibilitySection('ความเข้ากันด้านการทำงาน',
              compatibilityResult?.workCompatibility ?? 'ไม่มีข้อมูล'),
          const SizedBox(height: 16),
          _buildCompatibilitySection(
              'คำแนะนำ', compatibilityResult?.advice ?? 'ไม่มีข้อมูล'),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  compatibilityResult = null;
                  selectedSign = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'เลือกราศีอื่น',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacColumn(String sign) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Image.asset(
            'assets/images/zodiac/$sign.png',
            height: 60,
            width: 60,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          zodiacDisplayNames[sign] ?? sign,
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(
              'ความเข้ากันโดยรวม', compatibilityResult?.overallScore ?? 0),
          _buildScoreItem('ความรัก', compatibilityResult?.loveScore ?? 0),
          _buildScoreItem('การทำงาน', compatibilityResult?.workScore ?? 0),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.lightText.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              '$score%',
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilitySection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: AppColors.lightText.withOpacity(0.9),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
