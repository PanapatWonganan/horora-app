import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/tarot_card_model.dart';
import '../../core/repositories/tarot_repository.dart';
import '../../core/services/auth_guard.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/celestial_effects.dart';
import '../../core/theme/sacred_ui.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'รายละเอียดการอ่านไพ่',
          style: GoogleFonts.kanit(
            color: AppColors.onBackdrop,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onBackdrop,
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
        decoration: const BoxDecoration(gradient: celestialBackdrop),
        child: Stack(
          children: [
            const Positioned(
              top: -110,
              right: -80,
              child: CelestialGlow(
                size: 240,
                color: AppColors.primary,
                intensity: 0.24,
              ),
            ),
            const Positioned(
              bottom: -60,
              left: -90,
              child: CelestialGlow(
                size: 220,
                color: AppColors.tertiary,
                intensity: 0.18,
              ),
            ),
            const Positioned.fill(child: GrainOverlay(opacity: 0.03)),
            SafeArea(
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
                          style: GoogleFonts.kanit(color: AppColors.onBackdrop),
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
                          style: GoogleFonts.kanit(color: AppColors.onBackdrop),
                        ),
                      )
                    : _buildReadingDetails(),
            ),
          ],
        ),
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
          // NOTE: a "zodiac influence" section used to render here but it was
          // always placeholder copy ("...จะแสดงที่นี่") since no real backend
          // data ever populates it — removed per design audit until there is
          // real content to show (req 9).
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

  // Section titles now use the shared SacredSectionTitle (see sacred_ui.dart)
  // instead of a hand-rolled copy, so tarot reads identically to
  // Horoscope/Chat.

  Widget _buildQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SacredSectionTitle('คำถามหรือประเด็นที่ต้องการคำตอบ',
            overline: 'YOUR QUESTION'),
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
        const SacredSectionTitle('ไพ่ที่ได้', overline: 'THE CARDS'),
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
                        cardPosition.card.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.fraunces(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
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
                // Readable ink-gold on the ivory card (candle gold body text
                // on ivory reads too low-contrast).
                color: AppColors.deepGoldBrown,
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
        const SacredSectionTitle('คำทำนาย', overline: 'THE READING'),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // Warm ivory→rice-paper card (Sacred palette) over the
                // celestial backdrop, replacing the cold translucent-white
                // glass so this matches Horoscope/Chat.
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.ivorySilk, AppColors.ricePaper],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.warmCardBorder.withValues(alpha: 0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.templeIndigo.withValues(alpha: 0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SvgIcon(
                        AppIcons.sparkle,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ดวงใจของไพ่บอกว่า',
                        style: GoogleFonts.kanit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _reading!.interpretation,
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      color: AppColors.deepText,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

}