import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/theme.dart';
import '../../core/models/horoscope_model.dart';
import '../../core/utils/app_icons.dart';
import '../shared/widgets/loading_indicator.dart';
import '../shared/widgets/gradient_background.dart';
import '../report/report_dialog.dart';

class HoroscopeDetailScreen extends StatefulWidget {
  final DailyHoroscope horoscope;
  final String zodiacSignThai;
  final String zodiacSignEn;

  const HoroscopeDetailScreen({
    Key? key,
    required this.horoscope,
    required this.zodiacSignThai,
    required this.zodiacSignEn,
  }) : super(key: key);

  @override
  State<HoroscopeDetailScreen> createState() => _HoroscopeDetailScreenState();
}

class _HoroscopeDetailScreenState extends State<HoroscopeDetailScreen> {
  bool _showEnglishContent = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // แสดงข้อมูลเพื่อการดีบัก
    debugPrint('HoroscopeDetailScreen - initState');
    debugPrint('Horoscope: ${widget.horoscope.thaiAnimal}');
    debugPrint('ZodiacSignThai: ${widget.zodiacSignThai}');
    debugPrint('ZodiacSignEn: ${widget.zodiacSignEn}');
    // ตรวจสอบข้อมูลที่ได้รับ
    _validateData();
  }

  void _validateData() {
    try {
      // ตรวจสอบว่าข้อมูลที่ได้รับถูกต้องหรือไม่
      if (widget.horoscope.content.isEmpty || widget.horoscope.contentTh.isEmpty) {
        setState(() {
          _errorMessage = 'ข้อมูลดวงประจำวันไม่สมบูรณ์';
          _isLoading = false;
        });
        return;
      }

      // ตรวจสอบว่าข้อมูลราศีถูกต้องหรือไม่
      if (widget.zodiacSignThai.isEmpty || widget.zodiacSignEn.isEmpty) {
        setState(() {
          _errorMessage = 'ไม่พบข้อมูลราศี';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // แสดง Loading Indicator ระหว่างโหลดข้อมูล
    if (_isLoading) {
      return Scaffold(
        body: GradientBackground(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          child: const Center(
            child: LoadingIndicator(),
          ),
        ),
      );
    }

    // แสดงข้อความแจ้งเตือนเมื่อเกิดข้อผิดพลาด
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: GradientBackground(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('กลับ'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // แสดงหน้าจอปกติเมื่อไม่มีข้อผิดพลาด
    return Scaffold(
      body: GradientBackground(
        colors: [
          AppColors.primary,
          AppColors.secondary,
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildDateSection(),
                  const SizedBox(height: 24),
                  _buildContentSection(),
                  const SizedBox(height: 32),
                  _buildRatingsSection(),
                  const SizedBox(height: 32),
                  _buildLuckyItemsSection(),
                  const SizedBox(height: 32),
                  _buildAdviceSection(),
                  const SizedBox(height: 32),
                  _buildShareSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: SvgIcon(AppIcons.arrowBack, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          'ดวงประจำวัน',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: SvgIcon(AppIcons.flag, size: 20, color: Colors.white),
              onPressed: () => _reportContent(),
              tooltip: 'รายงานเนื้อหา',
            ),
            IconButton(
              icon: SvgIcon(AppIcons.share, size: 20, color: Colors.white),
              onPressed: _shareHoroscope,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _getZodiacIcon(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.zodiacSignThai,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.zodiacSignEn,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            DateFormat('EEEE d MMMM yyyy', 'th_TH').format(widget.horoscope.date),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _getZodiacIcon() {
    return WesternZodiacIcon(
      sign: widget.zodiacSignEn,
      size: 50,
    );
  }

  Widget _buildContentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'คำทำนาย',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _showEnglishContent,
                onChanged: (value) {
                  setState(() {
                    _showEnglishContent = value;
                  });
                },
                activeColor: AppColors.tertiary,
                activeTrackColor: AppColors.tertiary.withValues(alpha: 0.5),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _showEnglishContent ? widget.horoscope.content : widget.horoscope.contentTh,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
            softWrap: true,
          ),
          const SizedBox(height: 8),
          Text(
            _showEnglishContent ? 'Switch to Thai' : 'Switch to English',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'คะแนนดวงชะตา',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildRatingBar('ความรัก', widget.horoscope.loveRating, 
          'ดวงความรักของคุณวันนี้อยู่ในเกณฑ์${_getRatingDescription(widget.horoscope.loveRating)}'),
        const SizedBox(height: 16),
        _buildRatingBar('การงาน', widget.horoscope.careerRating,
          'ดวงการงานของคุณวันนี้อยู่ในเกณฑ์${_getRatingDescription(widget.horoscope.careerRating)}'),
        const SizedBox(height: 16),
        _buildRatingBar('สุขภาพ', widget.horoscope.healthRating,
          'ดวงสุขภาพของคุณวันนี้อยู่ในเกณฑ์${_getRatingDescription(widget.horoscope.healthRating)}'),
      ],
    );
  }

  Widget _buildRatingBar(String label, int rating, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: SvgIcon(
                      index < rating ? AppIcons.starFilled : AppIcons.starOutline,
                      size: 18,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สิ่งนำโชค',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildLuckyItemSvg(
                'เลขนำโชค',
                widget.horoscope.luckyNumber,
                AppIcons.numbers,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLuckyItemSvg(
                'สีมงคล',
                widget.horoscope.luckyColor,
                AppIcons.palette,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLuckyItemSvg(String label, String value, String svgPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SvgIcon(
            svgPath,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.amber,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'คำแนะนำประจำวัน',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getDailyAdvice(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _shareHoroscope,
        icon: SvgIcon(AppIcons.share, size: 18, color: Colors.white),
        label: const Text('แชร์ดวงของคุณ'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tertiary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'แย่';
      case 2:
        return 'พอใช้';
      case 3:
        return 'ปานกลาง';
      case 4:
        return 'ดี';
      case 5:
        return 'ดีมาก';
      default:
        return 'ปานกลาง';
    }
  }

  String _getDailyAdvice() {
    final zodiacSign = widget.zodiacSignEn.toLowerCase();
    
    switch (zodiacSign) {
      case 'aries':
        return 'วันนี้คุณควรใช้พลังงานที่มีอยู่ให้เป็นประโยชน์ ลองเริ่มต้นโปรเจกต์ใหม่ที่คุณสนใจ และอย่าลืมพักผ่อนให้เพียงพอเพื่อรักษาสมดุลของร่างกาย';
      case 'taurus':
        return 'วันนี้เป็นวันที่ดีในการวางแผนการเงิน ควรหลีกเลี่ยงการใช้จ่ายฟุ่มเฟือย และอาจพิจารณาการลงทุนระยะยาวที่มั่นคง';
      case 'gemini':
        return 'ใช้ทักษะการสื่อสารของคุณให้เป็นประโยชน์ในวันนี้ เป็นโอกาสดีในการเจรจาต่อรองหรือนำเสนอไอเดียใหม่ๆ ให้กับผู้อื่น';
      case 'cancer':
        return 'ให้ความสำคัญกับครอบครัวและคนที่คุณรักในวันนี้ การใช้เวลาร่วมกันจะช่วยเสริมสร้างความสัมพันธ์และนำความสุขมาให้คุณ';
      case 'leo':
        return 'แสดงความเป็นผู้นำของคุณในวันนี้ แต่อย่าลืมรับฟังความคิดเห็นของผู้อื่นด้วย การทำงานเป็นทีมจะนำไปสู่ความสำเร็จที่ยิ่งใหญ่';
      case 'virgo':
        return 'ใช้ความละเอียดรอบคอบของคุณในการจัดระเบียบและวางแผน วันนี้เหมาะกับการทำงานที่ต้องการความแม่นยำและการวิเคราะห์';
      case 'libra':
        return 'รักษาสมดุลในชีวิตของคุณในวันนี้ ทั้งเรื่องงานและความสัมพันธ์ การตัดสินใจด้วยความยุติธรรมจะช่วยให้คุณได้รับการยอมรับจากผู้อื่น';
      case 'scorpio':
        return 'ใช้พลังแห่งการเปลี่ยนแปลงของคุณในทางที่สร้างสรรค์ วันนี้อาจเป็นโอกาสดีในการเริ่มต้นใหม่หรือปล่อยวางสิ่งที่ไม่จำเป็นในชีวิต';
      case 'sagittarius':
        return 'เปิดใจรับประสบการณ์ใหม่ๆ ในวันนี้ การเรียนรู้และการผจญภัยจะช่วยขยายมุมมองและนำโอกาสดีๆ มาสู่คุณ';
      case 'capricorn':
        return 'มุ่งมั่นทำงานเพื่อเป้าหมายระยะยาวของคุณ ความอดทนและความรับผิดชอบจะนำไปสู่ความสำเร็จที่คุณต้องการ';
      case 'aquarius':
        return 'ใช้ความคิดสร้างสรรค์และนวัตกรรมของคุณในวันนี้ อย่ากลัวที่จะแสดงความเป็นตัวของตัวเองและนำเสนอไอเดียที่แตกต่าง';
      case 'pisces':
        return 'ใช้ความเข้าอกเข้าใจและความเมตตาของคุณในการช่วยเหลือผู้อื่น การให้โดยไม่หวังผลตอบแทนจะนำความสุขมาสู่ชีวิตของคุณ';
      default:
        return 'วันนี้เป็นวันที่ดีสำหรับการดูแลตัวเอง ทั้งร่างกายและจิตใจ ให้เวลากับตัวเองในการทำสิ่งที่คุณรัก และพักผ่อนให้เพียงพอ';
    }
  }

  void _shareHoroscope() {
    final String zodiacSign = widget.zodiacSignThai;
    final String date = DateFormat('d MMMM yyyy', 'th_TH').format(widget.horoscope.date);
    final String content = widget.horoscope.contentTh;
    
    final String shareText = '''
🌟 ดวงประจำวันของ $zodiacSign 🌟
วันที่ $date

$content

💖 ความรัก: ${widget.horoscope.loveRating}/5
💼 การงาน: ${widget.horoscope.careerRating}/5
🏥 สุขภาพ: ${widget.horoscope.healthRating}/5

🔢 เลขนำโชค: ${widget.horoscope.luckyNumber}
🎨 สีมงคล: ${widget.horoscope.luckyColor}

#ดูดวง #ดวงประจำวัน #$zodiacSign
    ''';
    
    Share.share(shareText);
  }

  void _reportContent() async {
    await showReportDialog(
      context,
      contentId: widget.horoscope.id.toString(),
      contentType: 'horoscope',
      contentSnapshot: widget.horoscope.contentTh.substring(0, widget.horoscope.contentTh.length > 200 ? 200 : widget.horoscope.contentTh.length),
    );
  }
} 