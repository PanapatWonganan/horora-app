import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/zodiac_utils.dart';
import '../shared/widgets/gradient_button.dart';

class HoroscopeHistoryScreen extends StatefulWidget {
  const HoroscopeHistoryScreen({Key? key}) : super(key: key);

  @override
  State<HoroscopeHistoryScreen> createState() => _HoroscopeHistoryScreenState();
}

class _HoroscopeHistoryScreenState extends State<HoroscopeHistoryScreen> {
  final _supabaseService = SupabaseService.instance;
  final _authService = AuthService.instance;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _horoscopeHistory = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHoroscopeHistory();
  }

  Future<void> _loadHoroscopeHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ในแอปจริง ควรดึงข้อมูลจาก repository หรือ service
      // ตัวอย่างเช่น:
      // final history = await _supabaseService.getHoroscopeHistory();
      
      // สำหรับตัวอย่าง เราจะใช้ข้อมูลจำลอง
      await Future.delayed(const Duration(seconds: 1)); // จำลองการโหลดข้อมูล
      
      final mockHistory = _generateMockData();
      
      setState(() {
        _horoscopeHistory = mockHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ไม่สามารถโหลดประวัติการดูดวงได้: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _generateMockData() {
    final List<Map<String, dynamic>> mockData = [];
    final zodiacSigns = [
      'aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo',
      'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces'
    ];
    
    final predictions = [
      'วันนี้คุณจะพบกับโอกาสใหม่ๆ ในการทำงาน ความรักอาจมีอุปสรรคเล็กน้อย แต่จะผ่านไปได้ด้วยดี การเงินมีเกณฑ์ดี มีโชคลาภจากคนรอบข้าง',
      'ช่วงนี้การงานของคุณกำลังไปได้ดี มีโอกาสได้รับการสนับสนุนจากผู้ใหญ่ ด้านความรักคู่ครองจะให้การสนับสนุนคุณเป็นอย่างดี การเงินมีเข้ามาอย่างต่อเนื่อง',
      'ระยะนี้คุณอาจรู้สึกเหนื่อยล้ากับการทำงาน ควรพักผ่อนให้เพียงพอ ความรักอาจมีเรื่องให้ต้องปรับความเข้าใจกัน การเงินควรระมัดระวังการใช้จ่าย',
      'ช่วงนี้การงานมีการเปลี่ยนแปลงในทางที่ดี อาจได้รับมอบหมายงานสำคัญ ด้านความรักคนโสดมีเกณฑ์ได้พบคนถูกใจ การเงินมีโชคลาภจากการเสี่ยงดวง',
      'วันนี้คุณจะได้รับข่าวดีเกี่ยวกับการงาน อาจมีโอกาสได้เลื่อนตำแหน่ง ความรักราบรื่น มีความสุขดี การเงินมีรายได้พิเศษเข้ามา',
    ];
    
    for (int i = 0; i < 10; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final zodiacSign = zodiacSigns[i % zodiacSigns.length];
      final prediction = predictions[i % predictions.length];
      
      mockData.add({
        'id': 'history_$i',
        'date': date.toIso8601String(),
        'zodiac_sign': zodiacSign,
        'prediction': prediction,
        'love_rating': (i % 5) + 1,
        'career_rating': ((i + 2) % 5) + 1,
        'health_rating': ((i + 1) % 5) + 1,
        'finance_rating': ((i + 3) % 5) + 1,
      });
    }
    
    return mockData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ประวัติการดูดวงจากราศี',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.lightText,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              const Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingView()
              : _errorMessage != null
                  ? _buildErrorView()
                  : _horoscopeHistory.isEmpty
                      ? _buildEmptyView()
                      : _buildHistoryList(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'กำลังโหลดประวัติการดูดวง...',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'เกิดข้อผิดพลาดในการโหลดข้อมูล',
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'ลองใหม่อีกครั้ง',
              onPressed: _loadHoroscopeHistory,
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              color: AppColors.primary.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีประวัติการดูดวง',
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'เมื่อคุณดูดวงจากราศี ประวัติจะปรากฏที่นี่',
              style: TextStyle(
                color: AppColors.lightText.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'ดูดวงจากราศี',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/horoscope');
              },
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadHoroscopeHistory,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _horoscopeHistory.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(_horoscopeHistory[index]);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final date = DateTime.parse(item['date']);
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final zodiacSign = item['zodiac_sign'];
    final prediction = item['prediction'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      ZodiacUtils.getZodiacIcon(zodiacSign),
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getThaiZodiacName(zodiacSign),
                      style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: AppColors.lightText.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'คำทำนายประจำวัน',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prediction,
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: AppColors.lightText.withOpacity(0.1),
              thickness: 1,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRatingItem('ความรัก', item['love_rating']),
                _buildRatingItem('การงาน', item['career_rating']),
                _buildRatingItem('สุขภาพ', item['health_rating']),
                _buildRatingItem('การเงิน', item['finance_rating']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem(String label, int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.lightText.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating ? Colors.amber : Colors.grey[600],
              size: 16,
            );
          }),
        ),
      ],
    );
  }
  
  // ฟังก์ชันสำหรับแปลงชื่อราศีภาษาอังกฤษเป็นภาษาไทย
  String _getThaiZodiacName(String englishName) {
    switch (englishName.toLowerCase()) {
      case 'aries':
        return 'ราศีเมษ';
      case 'taurus':
        return 'ราศีพฤษภ';
      case 'gemini':
        return 'ราศีเมถุน';
      case 'cancer':
        return 'ราศีกรกฎ';
      case 'leo':
        return 'ราศีสิงห์';
      case 'virgo':
        return 'ราศีกันย์';
      case 'libra':
        return 'ราศีตุลย์';
      case 'scorpio':
        return 'ราศีพิจิก';
      case 'sagittarius':
        return 'ราศีธนู';
      case 'capricorn':
        return 'ราศีมังกร';
      case 'aquarius':
        return 'ราศีกุมภ์';
      case 'pisces':
        return 'ราศีมีน';
      default:
        return 'ไม่ทราบราศี';
    }
  }
} 