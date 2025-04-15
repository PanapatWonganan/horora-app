import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/compatibility_result.dart';
import '../../core/repositories/horoscope_repository.dart';
import '../../features/chat/repositories/chat_repository.dart';
import '../../ui/widgets/common/custom_app_bar.dart';
import '../../ui/widgets/common/error_view.dart';
import '../../ui/widgets/common/loading_indicator.dart';
import '../../core/theme/app_colors.dart';

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
    });

    try {
      userZodiacSign = await _chatRepository.getUserZodiacSign();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'ไม่สามารถโหลดข้อมูลราศีของคุณได้';
        isLoading = false;
      });
    }
  }

  Future<void> _checkCompatibility(String otherSign) async {
    if (userZodiacSign == null) {
      setState(() {
        errorMessage = 'ไม่พบข้อมูลราศีของคุณ';
      });
      return;
    }

    setState(() {
      isLoading = true;
      selectedSign = otherSign;
      errorMessage = null;
    });

    try {
      final horoscopeRepository =
          Provider.of<HoroscopeRepository>(context, listen: false);
      final result =
          await horoscopeRepository.getCurrentUserCompatibility(otherSign);

      setState(() {
        compatibilityResult = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'ไม่สามารถตรวจสอบความเข้ากันได้ในขณะนี้';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'ตรวจสอบความเข้ากัน',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading && compatibilityResult == null
          ? const Center(child: LoadingIndicator())
          : errorMessage != null && compatibilityResult == null
              ? ErrorView(
                  message: errorMessage!,
                  onRetry: () => _loadUserZodiacSign(),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'ราศีของคุณ: ${userZodiacSign != null ? zodiacDisplayNames[userZodiacSign!] ?? userZodiacSign! : "ไม่ทราบ"}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'เลือกราศีที่ต้องการตรวจสอบความเข้ากัน',
                        style: Theme.of(context).textTheme.titleMedium,
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
                fontWeight: FontWeight.bold,
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
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildZodiacColumn(userZodiacSign!),
              const Icon(Icons.favorite, color: Colors.red, size: 30),
              _buildZodiacColumn(selectedSign!),
            ],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('เลือกราศีอื่น'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacColumn(String sign) {
    return Column(
      children: [
        Image.asset(
          'assets/images/zodiac/$sign.png',
          height: 80,
          width: 80,
        ),
        const SizedBox(height: 8),
        Text(
          zodiacDisplayNames[sign] ?? sign,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.lightText,
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
              style: const TextStyle(
                color: Colors.white,
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.lightText.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
