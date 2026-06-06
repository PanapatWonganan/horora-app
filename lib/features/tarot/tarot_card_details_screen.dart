import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/tarot_card_model.dart';
import '../../core/repositories/tarot_repository.dart';
import '../../core/services/auth_guard.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_icons.dart';
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
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'รายละเอียดการอ่านไพ่',
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.deepText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBackground,
              AppColors.surfaceMuted,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: LoadingIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.kanit(color: AppColors.deepText),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadReading,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'ลองใหม่',
                            style: GoogleFonts.kanit(),
                          ),
                        ),
                      ],
                    ),
                  )
                : _reading == null
                    ? Center(
                        child: Text(
                          'ไม่พบข้อมูลการอ่านไพ่',
                          style: GoogleFonts.kanit(color: AppColors.deepText),
                        ),
                      )
                    : _buildReadingDetails(),
      ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightSurface,
            AppColors.cream.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: AppColors.mysticalGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: SvgIcon(
                    AppIcons.divination,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'การอ่านไพ่แบบ$spreadTypeText',
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'วันที่: $formattedDate',
            style: GoogleFonts.kanit(
              fontSize: 13,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.deepText,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('คำถามหรือประเด็นที่ต้องการคำตอบ'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Text(
            _reading!.question ?? 'ไม่ระบุคำถาม',
            style: GoogleFonts.kanit(
              fontSize: 16,
              height: 1.5,
              color: AppColors.deepText,
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
        _buildSectionTitle('ไพ่ที่ได้'),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
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
      width: 124,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 124,
            height: 168,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              // Soft gold celestial frame.
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withValues(alpha: 0.9),
                  AppColors.accent.withValues(alpha: 0.45),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.lightSurface,
                    AppColors.surfaceMuted,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Transform.rotate(
                angle: cardPosition.isReversed ? 3.14159 : 0, // 180 degrees if reversed
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SvgIcon(
                      AppIcons.sparkle,
                      color: AppColors.primary,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        cardPosition.card.nameTh,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cardPosition.position,
            textAlign: TextAlign.center,
            style: GoogleFonts.kanit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.deepText,
            ),
          ),
          if (cardPosition.isReversed)
            Text(
              '(กลับหัว)',
              style: GoogleFonts.kanit(
                fontSize: 12,
                color: AppColors.secondary,
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
        _buildSectionTitle('คำทำนาย'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.lightSurface,
                AppColors.surfaceMuted.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            _reading!.interpretation,
            style: GoogleFonts.kanit(
              fontSize: 16,
              color: AppColors.deepText,
              height: 1.65,
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
        _buildSectionTitle('อิทธิพลของราศี'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceMuted,
                AppColors.cream.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SvgIcon(
                    AppIcons.sparkle,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ราศีของคุณ',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                interpretationData['zodiac_influence'] as String,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  color: AppColors.deepText,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 