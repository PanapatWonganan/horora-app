import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/models/tarot_card_model.dart';
import '../../core/repositories/tarot_repository.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/app_colors.dart';
import '../shared/widgets/loading_indicator.dart';

class TarotHistoryScreen extends StatefulWidget {
  const TarotHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TarotHistoryScreen> createState() => _TarotHistoryScreenState();
}

class _TarotHistoryScreenState extends State<TarotHistoryScreen> {
  late TarotRepository _tarotRepository;
  List<TarotReading>? _readings;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tarotRepository = Provider.of<TarotRepository>(context, listen: false);
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final readings = await _tarotRepository.getUserTarotReadings();
      setState(() {
        _readings = readings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ไม่สามารถโหลดประวัติการอ่านไพ่ได้: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการเปิดไพ่ทาโร่'),
        backgroundColor: AppColors.darkSurface,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: AppColors.lightText),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadReadings,
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ),
                )
              : _readings == null || _readings!.isEmpty
                  ? _buildEmptyState()
                  : _buildReadingsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppColors.primary.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีประวัติการอ่านไพ่',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เริ่มอ่านไพ่ทาโร่เพื่อรับคำทำนายและคำแนะนำ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightText.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              AppRouter.navigateTo(context, AppRoutes.tarotReading);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('เริ่มอ่านไพ่'),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsList() {
    // เรียงลำดับประวัติการอ่านไพ่จากใหม่ไปเก่า
    final sortedReadings = List<TarotReading>.from(_readings!)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RefreshIndicator(
      onRefresh: _loadReadings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: sortedReadings.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(context, sortedReadings[index]);
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, TarotReading reading) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(reading.createdAt);
    
    // แปลงชื่อรูปแบบการอ่านไพ่เป็นภาษาไทย
    String spreadTypeText;
    switch (reading.spreadType) {
      case 'single':
        spreadTypeText = 'ไพ่ 1 ใบ';
        break;
      case 'three':
        spreadTypeText = 'ไพ่ 3 ใบ';
        break;
      case 'cross':
        spreadTypeText = 'ไพ่กางเขน';
        break;
      case 'celtic':
        spreadTypeText = 'ไพ่เซลติก';
        break;
      default:
        spreadTypeText = reading.spreadType;
    }
    
    // ดึงคำถามหรือประเด็นที่ใช้ในการอ่านไพ่
    final question = reading.question ?? 'ไม่ระบุคำถาม';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to tarot reading detail screen
          AppRouter.navigateTo(
            context, 
            AppRoutes.tarotCardDetails,
            arguments: {'readingId': reading.id},
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'การเปิดไพ่แบบ$spreadTypeText',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'คำถาม: $question',
                style: TextStyle(
                  fontSize: 14.0,
                  color: AppColors.lightText.withValues(alpha: 0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16.0),
              _buildCardsList(reading.cards),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ดูรายละเอียด',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.0,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList(List<TarotCardPosition> cards) {
    return SizedBox(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return _buildTarotCard(cards[index]);
        },
      ),
    );
  }

  Widget _buildTarotCard(TarotCardPosition cardPosition) {
    return Container(
      width: 80.0,
      height: 120.0,
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: cardPosition.isReversed ? 3.14159 : 0, // 180 degrees if reversed
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 32.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            cardPosition.card.nameTh,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (cardPosition.isReversed)
            Text(
              '(กลับหัว)',
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.red[400],
              ),
            ),
        ],
      ),
    );
  }
} 