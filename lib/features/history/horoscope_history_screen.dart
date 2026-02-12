import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../core/utils/zodiac_utils.dart';
import '../shared/widgets/gradient_button.dart';

class HoroscopeHistoryScreen extends StatefulWidget {
  const HoroscopeHistoryScreen({Key? key}) : super(key: key);

  @override
  State<HoroscopeHistoryScreen> createState() => _HoroscopeHistoryScreenState();
}

class _HoroscopeHistoryScreenState extends State<HoroscopeHistoryScreen> {
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
      // TODO: ดึงข้อมูลจาก API เมื่อ backend พร้อม
      // final history = await _horoscopeRepository.getHoroscopeHistory();

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _horoscopeHistory = []; // ส่งคืนรายการว่างจนกว่า API จะพร้อม
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ไม่สามารถโหลดประวัติการดูดวงได้: ${e.toString()}';
        _isLoading = false;
      });
    }
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
              color: AppColors.primary.withValues(alpha: 0.5),
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
                color: AppColors.lightText.withValues(alpha: 0.7),
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
                    color: AppColors.lightText.withValues(alpha: 0.7),
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
              color: AppColors.lightText.withValues(alpha: 0.1),
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
            color: AppColors.lightText.withValues(alpha: 0.7),
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