import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_client.dart';
import '../../core/services/auth_guard.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/sacred_ui.dart';
import '../../core/utils/zodiac_utils.dart';

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
    // History เป็นข้อมูลส่วนตัว (token-gated) — guard ก่อนเรียก API
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardAndLoad());
  }

  Future<void> _guardAndLoad() async {
    final ok = await AuthGuard.requireAuth(context);
    if (!mounted) return;
    if (!ok) {
      Navigator.of(context).pop();
      return;
    }
    _loadHoroscopeHistory();
  }

  Future<void> _loadHoroscopeHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('/horoscope/history');
      final List<dynamic> data =
          response is List ? response : (response?['data'] ?? []);

      setState(() {
        _horoscopeHistory =
            data.map((e) => Map<String, dynamic>.from(e)).toList();
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
    return SacredScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SacredHeader(
              title: 'ประวัติการดูดวงจากราศี',
              overline: 'HOROSCOPE HISTORY',
            ),
            Expanded(
              child: _isLoading
                  ? _buildLoadingView()
                  : _errorMessage != null
                      ? _buildErrorView()
                      : _horoscopeHistory.isEmpty
                          ? _buildEmptyView()
                          : _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.accent,
          ),
          const SizedBox(height: 16),
          Text(
            'กำลังโหลดประวัติการดูดวง...',
            style: SacredText.kanit(
              color: AppColors.onBackdrop,
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
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'เกิดข้อผิดพลาดในการโหลดข้อมูล',
              style: SacredText.kanit(
                color: AppColors.onBackdrop,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SacredPrimaryButton(
              label: 'ลองใหม่อีกครั้ง',
              onTap: _loadHoroscopeHistory,
              filled: true,
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
              color: AppColors.candleGold.withValues(alpha: 0.6),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีประวัติการดูดวง',
              style: SacredText.kanit(
                color: AppColors.onBackdrop,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'เมื่อคุณดูดวงจากราศี ประวัติจะปรากฏที่นี่',
              style: SacredText.kanit(
                color: AppColors.onBackdropMuted,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SacredPrimaryButton(
              label: 'ดูดวงจากราศี',
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/horoscope');
              },
              filled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadHoroscopeHistory,
      color: AppColors.deepGoldBrown,
      backgroundColor: AppColors.ivorySilk,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SacredCard(
        radius: 18,
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
                      color: AppColors.deepGoldBrown,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getThaiZodiacName(zodiacSign),
                      style: SacredText.kanit(
                        color: AppColors.deepText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: SacredText.kanit(
                    color: AppColors.mutedText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'คำทำนายประจำวัน',
              style: SacredText.kanit(
                color: AppColors.deepGoldBrown,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              prediction,
              style: SacredText.kanit(
                color: AppColors.deepText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const SacredGoldDivider(),
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
          style: SacredText.kanit(
            fontSize: 12,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: index < rating
                  ? AppColors.candleGold
                  : AppColors.mutedText.withValues(alpha: 0.4),
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
