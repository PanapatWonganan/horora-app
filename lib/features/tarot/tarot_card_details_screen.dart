import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/tarot_card_model.dart';
import '../../core/repositories/tarot_repository.dart';
import '../../core/services/auth_guard.dart';
import '../../core/theme/app_colors.dart';
import '../shared/widgets/loading_indicator.dart';

class TarotCardDetailsScreen extends StatefulWidget {
  final int readingId;

  const TarotCardDetailsScreen({Key? key, required this.readingId}) : super(key: key);

  @override
  State<TarotCardDetailsScreen> createState() => _TarotCardDetailsScreenState();
}

class _TarotCardDetailsScreenState extends State<TarotCardDetailsScreen> {
  late TarotRepository _tarotRepository;
  TarotReading? _reading;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _tarotRepository = Provider.of<TarotRepository>(context, listen: false);
    _loadReading();
  }

  Future<void> _loadReading() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reading = await _tarotRepository.getTarotReadingById(widget.readingId);
      setState(() {
        _reading = reading;
        _isSaved = reading.isSaved;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ไม่สามารถโหลดข้อมูลการอ่านไพ่ได้: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSaved() async {
    // บันทึก/ยกเลิกบันทึกการอ่านไพ่ต้อง login (POST /tarot/readings ต้อง token)
    if (!await AuthGuard.requireAuth(context, intentLabel: 'tarot_save')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เข้าสู่ระบบเพื่อบันทึกการอ่านไพ่ได้นะ'),
        ),
      );
      return;
    }
    if (!mounted) return;
    try {
      if (_isSaved) {
        await _tarotRepository.unsaveTarotReading(widget.readingId);
      } else {
        await _tarotRepository.saveTarotReading(widget.readingId);
      }
      setState(() {
        _isSaved = !_isSaved;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถ${_isSaved ? 'ยกเลิกการบันทึก' : 'บันทึก'}การอ่านไพ่ได้: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _shareReading() async {
    if (_reading == null) return;

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(_reading!.createdAt);

    // แปลงชื่อรูปแบบการอ่านไพ่เป็นภาษาไทย
    String spreadTypeText;
    switch (_reading!.spreadType) {
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
        spreadTypeText = _reading!.spreadType;
    }

    final cardsText = _reading!.cards
        .map((card) => '${card.position}: ${card.card.nameTh}${card.isReversed ? ' (กลับหัว)' : ''}')
        .join('\n');

    final shareText = '''
🔮 ผลการอ่านไพ่ทาโร่ 🔮

วันที่: $formattedDate
รูปแบบ: $spreadTypeText
คำถาม: ${_reading!.question ?? 'ไม่ระบุคำถาม'}

ไพ่ที่ได้:
$cardsText

คำทำนาย:
${_reading!.interpretation}

แชร์จากแอป Astrology
''';

    await Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดการอ่านไพ่'),
        backgroundColor: AppColors.darkSurface,
        actions: [
          if (_reading != null) ...[
            IconButton(
              icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
              onPressed: _toggleSaved,
              tooltip: _isSaved ? 'ยกเลิกการบันทึก' : 'บันทึกการอ่านไพ่',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareReading,
              tooltip: 'แชร์การอ่านไพ่',
            ),
          ],
        ],
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
                        onPressed: _loadReading,
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ),
                )
              : _reading == null
                  ? const Center(child: Text('ไม่พบข้อมูลการอ่านไพ่'))
                  : _buildReadingDetails(),
    );
  }

  Widget _buildReadingDetails() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(_reading!.createdAt);

    // แปลงชื่อรูปแบบการอ่านไพ่เป็นภาษาไทย
    String spreadTypeText;
    switch (_reading!.spreadType) {
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
        spreadTypeText = _reading!.spreadType;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(spreadTypeText, formattedDate),
          const SizedBox(height: 24),
          _buildQuestion(),
          const SizedBox(height: 24),
          _buildCards(),
          const SizedBox(height: 24),
          _buildInterpretation(),
          const SizedBox(height: 24),
          if (_reading!.cards.length > 1) _buildZodiacInfluence(),
        ],
      ),
    );
  }

  Widget _buildHeader(String spreadTypeText, String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'การอ่านไพ่แบบ$spreadTypeText',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'วันที่: $formattedDate',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightText.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'คำถามหรือประเด็นที่ต้องการคำตอบ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _reading!.question ?? 'ไม่ระบุคำถาม',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.lightText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ไพ่ที่ได้',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _reading!.cards.length,
            itemBuilder: (context, index) {
              return _buildTarotCard(_reading!.cards[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTarotCard(TarotCardPosition cardPosition) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Transform.rotate(
              angle: cardPosition.isReversed ? 3.14159 : 0, // 180 degrees if reversed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      cardPosition.card.nameTh,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            cardPosition.position,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.lightText,
            ),
          ),
          if (cardPosition.isReversed)
            Text(
              '(กลับหัว)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[400],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInterpretation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'คำทำนาย',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _reading!.interpretation,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.lightText,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZodiacInfluence() {
    // ตรวจสอบว่ามีข้อมูลอิทธิพลของราศีหรือไม่
    final Map<String, dynamic> interpretationData = {};
    try {
      // ลองแปลงข้อความตีความเป็น JSON
      if (_reading!.interpretation.contains('zodiac_influence')) {
        interpretationData['zodiac_influence'] = 'อิทธิพลของราศีต่อการตีความไพ่นี้จะแสดงที่นี่';
      }
    } catch (e) {
      // ไม่สามารถแปลงเป็น JSON ได้ ไม่เป็นไร
    }

    if (!interpretationData.containsKey('zodiac_influence')) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'อิทธิพลของราศี',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ราศีของคุณ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                interpretationData['zodiac_influence'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.lightText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 