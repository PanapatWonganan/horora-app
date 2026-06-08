import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/tarot_card_model.dart';
import '../../core/repositories/tarot_repository.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/laravel_auth_service.dart';
import '../../core/services/rating_service.dart';
import '../../core/api/api_client.dart';
import '../../core/utils/exceptions.dart' as ex;
import '../../config/constants.dart';
import 'dart:ui' show ImageFilter;

import '../../core/theme/app_colors.dart';
import '../../core/theme/celestial_effects.dart';
import '../../core/utils/app_icons.dart';
import '../../core/services/thai_zodiac_service.dart';
import '../shared/widgets/gradient_button.dart';
import 'widgets/reveal_burst.dart';

class TarotReadingScreen extends StatefulWidget {
  final String? spreadType;

  const TarotReadingScreen({Key? key, this.spreadType}) : super(key: key);

  @override
  State<TarotReadingScreen> createState() => _TarotReadingScreenState();
}

class _TarotReadingScreenState extends State<TarotReadingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final AuthService _authService = AuthService.instance;
  final ApiClient _apiClient = LaravelAuthService.instance.apiClient;
  // ignore: unused_field - Reserved for future API integration
  late TarotRepository _tarotRepository;

  String _spreadType = 'single';
  List<TarotCard> _allCards = [];
  List<TarotCard> _selectedCards = [];
  List<bool> _isCardRevealed = [];
  List<bool> _isCardReversed = [];
  String? _interpretation;
  String? _userThaiZodiac; // ปีนักษัตรไทย เช่น "ปีมะเมีย"
  bool _isLoading = false;
  bool _isShuffling = false;
  bool _isSelectingCards = false;
  bool _hasSelectedCards = false;

  late AnimationController _shuffleAnimationController;
  late Animation<double> _shuffleAnimation;
  late AnimationController _loadingAnimationController;
  late Animation<double> _loadingAnimation;
  late Animation<double> _pulseAnimation;

  // Signature reveal: a one-shot glow/sparkle burst when a card is flipped.
  late AnimationController _revealBurstController;
  int? _lastRevealedIndex;
  // Ambient, looping float for the selected cards + interpretation shimmer.
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _initRepository();

    _spreadType = widget.spreadType ?? 'single';
    _setupAnimations();
  }

  Future<void> _initRepository() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _tarotRepository = TarotRepository(
        apiClient: _apiClient,
        prefs: prefs,
      );

      _loadCards();
      _loadUserZodiacSign();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเริ่มต้นระบบได้: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupAnimations() {
    _shuffleAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shuffleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shuffleAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // เพิ่ม animation สำหรับการโหลด
    _loadingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _loadingAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.linear,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // One-shot burst played each time a card is revealed (the signature moment).
    _revealBurstController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    // Slow ambient loop powering the gentle card float + interpretation shimmer.
    _ambientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // ดึงข้อมูลไพ่จาก API
      _allCards = await _tarotRepository.getAllTarotCards();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถโหลดไพ่ทาโร่ได้: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadUserZodiacSign() async {
    final user = _authService.currentUser;
    if (user != null) {
      // ใช้ปีนักษัตรไทยจาก user properties
      if (user.thaiYearName != null) {
        setState(() {
          _userThaiZodiac = user.thaiYearName!;
        });
      } else if (user.thaiAnimal != null) {
        setState(() {
          _userThaiZodiac = 'ปี${user.thaiAnimal}';
        });
      } else if (user.birthDate != null) {
        // คำนวณปีนักษัตรจากวันเกิด
        final thaiZodiac =
            ThaiZodiacService.getThaiZodiacFromDate(user.birthDate!);
        setState(() {
          _userThaiZodiac = thaiZodiac.thaiName;
        });
      }
    }
  }

  void _shuffleCards() {
    setState(() {
      _isShuffling = true;
      _hasSelectedCards = false;
      _selectedCards = [];
      _isCardRevealed = [];
      _isCardReversed = [];
      _interpretation = null;
      _lastRevealedIndex = null;
    });

    _shuffleAnimationController.forward().then((_) {
      _shuffleAnimationController.reset();
      setState(() {
        _isShuffling = false;
        _isSelectingCards = true;
      });
    });
  }

  void _selectCards() {
    final random = Random();
    final cardCount = _getCardCountForSpreadType();

    final selectedIndices = <int>[];
    while (selectedIndices.length < cardCount) {
      final index = random.nextInt(_allCards.length);
      if (!selectedIndices.contains(index)) {
        selectedIndices.add(index);
      }
    }

    final selectedCards =
        selectedIndices.map((index) => _allCards[index]).toList();
    final isCardReversed = List.generate(cardCount, (_) => random.nextBool());

    setState(() {
      _selectedCards = selectedCards;
      _isCardReversed = isCardReversed;
      _isCardRevealed = List.generate(cardCount, (_) => false);
      _isSelectingCards = false;
      _hasSelectedCards = true;
    });
  }

  int _getCardCountForSpreadType() {
    switch (_spreadType) {
      case 'single':
        return 1;
      case 'three':
        return 3;
      case 'cross':
        return 5;
      case 'celtic':
        return 10;
      default:
        return 3;
    }
  }

  void _revealCard(int index) {
    if (index >= _isCardRevealed.length) return;

    // Skip the burst if this card is already revealed (no re-trigger).
    final alreadyRevealed = _isCardRevealed[index];

    setState(() {
      _isCardRevealed[index] = true;
      if (!alreadyRevealed) {
        _lastRevealedIndex = index;
      }
    });

    // Signature: fire the one-shot glow/sparkle burst on a fresh reveal.
    if (!alreadyRevealed) {
      _revealBurstController.forward(from: 0);
    }

    // Check if all cards are revealed
    if (_isCardRevealed.every((revealed) => revealed)) {
      _interpretCards();
    }
  }

  Future<void> _interpretCards() async {
    if (_selectedCards.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // สร้างรายการไพ่พร้อมความหมาย (ใช้แสดงผล + บันทึก)
      final List<String> cardsWithMeanings =
          _selectedCards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        final isReversed = _isCardReversed[index];
        final meaning =
            isReversed ? card.reversedMeaningTh : card.uprightMeaningTh;
        return '${card.nameTh} (${isReversed ? "คว่ำ" : "หงาย"}): $meaning';
      }).toList();

      // AI ถูกพร็อกซีผ่าน backend แล้ว (provider key อยู่ฝั่ง server เท่านั้น)
      // ถ้า login แล้วจะบันทึกลงประวัติผ่าน /tarot/readings; ถ้าเป็น guest จะเรียก
      // /tarot/guest เพื่อให้เปิดไพ่/ตีความได้โดยไม่เจอ 401 Unauthorized.
      final revealedCardsPayload = _selectedCards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        final isReversed = _isCardReversed[index];
        return {
          'name': card.name,
          'name_th': card.nameTh,
          'meaning':
              isReversed ? card.reversedMeaningTh : card.uprightMeaningTh,
          'is_reversed': isReversed,
        };
      }).toList();

      final requestData = {
        'spread_type': _backendSpreadType(),
        'cards': revealedCardsPayload,
        if (_questionController.text.trim().isNotEmpty)
          'question': _questionController.text.trim(),
      };

      // ถ้า login แล้วยิง /tarot/readings (บันทึกประวัติ); ถ้าเป็น guest หรือ token
      // หมดอายุ จะ fallback ไป /tarot/guest อัตโนมัติ เพื่อให้ตีความไพ่ได้เสมอ
      // โดยไม่ค้างที่ 401 Unauthorized.
      Map<String, dynamic> response;
      final isLoggedIn = await LaravelAuthService.instance.isLoggedIn();
      try {
        response = Map<String, dynamic>.from(
          await _apiClient.post(
            isLoggedIn
                ? ApiConstants.tarotReadingsPath
                : ApiConstants.tarotGuestPath,
            data: requestData,
          ),
        );
      } on ex.UnauthorizedException {
        // token ใช้ไม่ได้จริง → retry เป็น guest (public endpoint)
        response = Map<String, dynamic>.from(
          await _apiClient.post(
            ApiConstants.tarotGuestPath,
            data: requestData,
          ),
        );
      }

      // ใช้ข้อความคำทำนายจาก backend
      final content = (response['interpretation'] as String?) ?? '';

      setState(() {
        _interpretation = content;
        _isLoading = false;
      });

      // บันทึก action สำเร็จ และเช็คว่าควรขอ rating หรือไม่
      RatingService.instance.onSuccessfulAction();

      // บันทึกการอ่าน
      _saveTarotReading({
        'overall': content,
        'cards': cardsWithMeanings,
        'question': _questionController.text,
        'spread_type': _spreadType,
        'thai_zodiac': _userThaiZodiac,
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถตีความไพ่ได้: ${e.toString()}')),
        );
      }
    }
  }

  // แปลง spread type ฝั่ง client เป็นค่าที่ backend รองรับ
  // backend: 'single' | 'three_card' | 'celtic_cross'
  String _backendSpreadType() {
    switch (_spreadType) {
      case 'single':
        return 'single';
      case 'three':
        return 'three_card';
      case 'cross':
      case 'celtic':
        return 'celtic_cross';
      default:
        return 'three_card';
    }
  }

  Future<void> _saveTarotReading(Map<String, dynamic> interpretation) async {
    try {
      final cardPositions = <TarotCardPosition>[];

      for (int i = 0; i < _selectedCards.length; i++) {
        String position;
        switch (_spreadType) {
          case 'single':
            position = 'ปัจจุบัน';
            break;
          case 'three':
            position = i == 0 ? 'อดีต' : (i == 1 ? 'ปัจจุบัน' : 'อนาคต');
            break;
          default:
            position = 'ตำแหน่งที่ ${i + 1}';
        }

        // ใช้ความหมายจาก cardsWithMeanings ที่ส่งมา
        final cardMeaning = (interpretation['cards'] as List<String>)[i];

        cardPositions.add(
          TarotCardPosition(
            card: _selectedCards[i],
            position: position,
            isReversed: _isCardReversed[i],
            meaning: cardMeaning,
          ),
        );
      }

      // ใช้ข้อมูลจำลองแทนการเรียกใช้ API
      // await _tarotRepository.createTarotReading(
      //   spreadType: _spreadType,
      //   question: _questionController.text,
      //   cards: cardPositions,
      // );

      // แสดงข้อความว่าบันทึกสำเร็จ
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกการอ่านไพ่เรียบร้อยแล้ว')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('ไม่สามารถบันทึกการอ่านไพ่ได้: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _shuffleAnimationController.dispose();
    _loadingAnimationController.dispose();
    _revealBurstController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'การอ่านไพ่ทาโร่',
          style: GoogleFonts.kanit(
            color: AppColors.onBackdrop,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onBackdrop,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: celestialBackdrop),
        child: Stack(
          children: [
            // Layered celestial atmosphere.
            const Positioned(
              top: -110,
              right: -80,
              child: CelestialGlow(
                size: 250,
                color: AppColors.primary,
                intensity: 0.26,
              ),
            ),
            const Positioned(
              top: 240,
              left: -100,
              child: CelestialGlow(
                size: 230,
                color: AppColors.secondary,
                intensity: 0.2,
              ),
            ),
            const Positioned(
              bottom: -70,
              right: -50,
              child: CelestialGlow(
                size: 220,
                color: AppColors.tertiary,
                intensity: 0.18,
              ),
            ),
            const Positioned.fill(child: GrainOverlay(opacity: 0.03)),
            _isLoading
                ? _buildLoadingAnimation()
                : SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSpreadTypeSelector(),
                          const SizedBox(height: 16),
                          _buildQuestionInput(),
                          const SizedBox(height: 16),
                          if (_userThaiZodiac != null) _buildZodiacInfo(),
                          const SizedBox(height: 24),
                          if (!_hasSelectedCards && !_isSelectingCards)
                            _buildStartButton(),
                          if (_isShuffling) _buildShufflingAnimation(),
                          if (_isSelectingCards) _buildSelectCardsButton(),
                          if (_hasSelectedCards) _buildSelectedCards(),
                          const SizedBox(height: 24),
                          if (_interpretation != null) _buildInterpretation(),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? overline}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: overline != null ? 30 : 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.accent, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (overline != null)
              Text(
                overline,
                style: GoogleFonts.fraunces(
                  color: AppColors.candleGold.withValues(alpha: 0.82),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.5,
                ),
              ),
            Text(
              title,
              style: GoogleFonts.kanit(
                color: AppColors.onBackdrop,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpreadTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('เลือกรูปแบบการอ่านไพ่', overline: 'THE SPREAD'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSpreadTypeOption('single', 'ไพ่ 1 ใบ', 'คำตอบรวดเร็ว'),
              const SizedBox(width: 12),
              _buildSpreadTypeOption(
                  'three', 'ไพ่ 3 ใบ', 'อดีต ปัจจุบัน อนาคต'),
              const SizedBox(width: 12),
              _buildSpreadTypeOption(
                  'cross', 'ไพ่กางเขน', 'การวิเคราะห์ละเอียด'),
              const SizedBox(width: 12),
              _buildSpreadTypeOption(
                  'celtic', 'ไพ่เซลติก', 'การอ่านแบบครอบคลุม'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpreadTypeOption(String type, String title, String description) {
    final isSelected = _spreadType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _spreadType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 124,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.lightSurface,
                    AppColors.cream.withValues(alpha: 0.94),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.candleGold.withValues(alpha: 0.92)
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? AppColors.candleGold : AppColors.deepText)
                  .withValues(alpha: isSelected ? 0.24 : 0.05),
              blurRadius: isSelected ? 18 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.kanit(
                    fontSize: 12,
                    height: 1.3,
                    color: isSelected
                        ? AppColors.deepText.withValues(alpha: 0.72)
                        : AppColors.mutedText,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.candleGold,
                    border: Border.all(color: AppColors.lightSurface, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepGoldBrown.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 13,
                    color: AppColors.deepText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('คำถามหรือประเด็นที่ต้องการคำตอบ',
            overline: 'YOUR QUESTION'),
        const SizedBox(height: 12),
        TextField(
          controller: _questionController,
          decoration: InputDecoration(
            hintText: 'พิมพ์คำถามของคุณที่นี่...',
            hintStyle: GoogleFonts.kanit(color: AppColors.mutedText),
            filled: true,
            fillColor: AppColors.lightSurface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: GoogleFonts.kanit(color: AppColors.deepText),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildZodiacInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceMuted,
            AppColors.cream.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            child: const Center(
              child: SvgIcon(
                AppIcons.sparkle,
                size: 22,
                color: AppColors.accent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ปีนักษัตร: $_userThaiZodiac',
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'การตีความไพ่จะคำนึงถึงราศีของคุณเพื่อให้คำทำนายที่แม่นยำยิ่งขึ้น',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: GradientButton(
        text: 'เริ่มการอ่านไพ่',
        onPressed: _shuffleCards,
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        icon: const Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildShufflingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _shuffleAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _shuffleAnimation.value * 2 * pi,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: AppColors.mysticalGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: SvgIcon(
                      AppIcons.sparkle,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'SHUFFLING',
            style: GoogleFonts.fraunces(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'กำลังสับไพ่...',
            style: GoogleFonts.kanit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.deepText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectCardsButton() {
    return Center(
      child: GradientButton(
        text: 'เลือกไพ่',
        onPressed: _selectCards,
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        icon: const Icon(
          Icons.touch_app,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSelectedCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ไพ่ของคุณ', overline: 'YOUR CARDS'),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: List.generate(
              _selectedCards.length,
              (index) => _buildTarotCard(index),
            ),
          ),
        ),
      ],
    );
  }

  // Roman-numeral arcana label for the editorial overline.
  String _romanNumeral(int n) {
    if (n < 0 || n > 21) return '';
    const numerals = [
      '0',
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X',
      'XI',
      'XII',
      'XIII',
      'XIV',
      'XV',
      'XVI',
      'XVII',
      'XVIII',
      'XIX',
      'XX',
      'XXI'
    ];
    return numerals[n];
  }

  // English editorial overline e.g. "THE FOOL · 0" — display feel for the card.
  String _cardOverline(TarotCard card) {
    final name = card.name.toUpperCase();
    final isMajor = card.suit.toLowerCase() == 'major arcana';
    final num = isMajor ? _romanNumeral(card.number) : '${card.number}';
    return num.isEmpty ? name : '$name · $num';
  }

  Widget _buildTarotCard(int index) {
    final isRevealed = _isCardRevealed[index];
    final isReversed = _isCardReversed[index];
    final isJustRevealed = _lastRevealedIndex == index;

    // Gentle continuous float; each card offset by index so they bob out of sync.
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final t = _ambientController.value * 2 * pi + index * 1.1;
        final dy = isRevealed ? sin(t) * 3.0 : 0.0;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: GestureDetector(
        onTap: () => _revealCard(index),
        // Reveal glow pulse: a soft halo blooms behind a freshly revealed card.
        child: AnimatedBuilder(
          animation: _revealBurstController,
          builder: (context, child) {
            final p = isJustRevealed ? _revealBurstController.value : 0.0;
            final glow = (sin(p * pi)).clamp(0.0, 1.0);
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: 124,
                  height: 204,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    // Soft gold celestial frame — catches light on reveal.
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent.withValues(
                            alpha: (0.9 + glow * 0.1).clamp(0.0, 1.0)),
                        Color.lerp(
                          AppColors.accent.withValues(alpha: 0.45),
                          Colors.white,
                          glow * 0.6,
                        )!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                      // Reveal glow halo.
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.55 * glow),
                        blurRadius: 26 * glow,
                        spreadRadius: 4 * glow,
                      ),
                    ],
                  ),
                  child: child,
                ),
                // Signature sparkle burst overlaid on the freshly revealed card.
                if (isJustRevealed && p > 0 && p < 1)
                  Positioned.fill(
                    child: RevealBurst(progress: p),
                  ),
              ],
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isRevealed ? Colors.white : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: isRevealed
                ? Transform.rotate(
                    angle: isReversed ? pi : 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.asset(
                              _selectedCards[index].imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // แสดงไอคอนเมื่อไม่สามารถโหลดรูปภาพได้
                                return const Center(
                                  child: SvgIcon(
                                    AppIcons.sparkle,
                                    size: 32,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: AppColors.surfaceMuted,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            child: Column(
                              children: [
                                // English editorial overline (display font).
                                Text(
                                  _cardOverline(_selectedCards[index]),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.fraunces(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.4,
                                    color: AppColors.primary
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedCards[index].nameTh,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.kanit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepText,
                                  ),
                                ),
                                if (isReversed)
                                  Text(
                                    '(กลับหัว)',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        // Deeper, more mystical card back gradient.
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6C5BD0), // deep lavender
                            Color(0xFF8B6FE0),
                            Color(0xFFB8A6F0),
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Faint inner top sheen for depth.
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.22),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Scattered star/sparkle accents on the back.
                          Positioned(
                            top: 14,
                            left: 14,
                            child: SvgIcon(
                              AppIcons.star,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            right: 18,
                            child: SvgIcon(
                              AppIcons.star,
                              size: 8,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                          const Positioned(
                            bottom: 16,
                            right: 16,
                            child: SvgIcon(
                              AppIcons.sparkle,
                              size: 14,
                              color: AppColors.accent,
                            ),
                          ),
                          Positioned(
                            bottom: 26,
                            left: 20,
                            child: SvgIcon(
                              AppIcons.sparkle,
                              size: 9,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.32),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.85),
                                width: 1.5,
                              ),
                            ),
                            child: const Center(
                              child: SvgIcon(
                                AppIcons.sparkle,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterpretation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('คำทำนาย', overline: 'THE READING'),
        const SizedBox(height: 16),
        // The cards "speaking": a gentle fade + a one-time shimmer sweep over a
        // glassmorphic panel as the interpretation appears.
        StaggeredReveal(
          index: 0,
          duration: const Duration(milliseconds: 700),
          offsetY: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  // Translucent white glass over the celestial backdrop.
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.78),
                      Colors.white.withValues(alpha: 0.55),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  // Gold hairline border.
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.45),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
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
                        const SizedBox(height: 4),
                        Text(
                          'THE CARDS SPEAK',
                          style: GoogleFonts.fraunces(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.5,
                            color: AppColors.mutedText.withValues(alpha: 0.8),
                          ),
                        ),
                        if (_userThaiZodiac != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'สำหรับผู้ที่เกิด$_userThaiZodiac',
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepText,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          _interpretation ?? '',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            color: AppColors.deepText,
                            height: 1.7,
                          ),
                        ),
                      ],
                    ),
                    // One-time diagonal shimmer sweep across the panel.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1400),
                          curve: Curves.easeInOut,
                          builder: (context, t, _) {
                            return ShaderMask(
                              blendMode: BlendMode.srcATop,
                              shaderCallback: (rect) {
                                final dx = (t * 2 - 0.5) * rect.width;
                                return LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.0),
                                    Colors.white
                                        .withValues(alpha: 0.35 * (1 - t)),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.35, 0.5, 0.65],
                                ).createShader(
                                  Rect.fromLTWH(dx, 0, rect.width, rect.height),
                                );
                              },
                              child: const SizedBox.expand(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: GradientButton(
            text: 'อ่านไพ่อีกครั้ง',
            onPressed: _shuffleCards,
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingAnimation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // วงกลมแสงด้านนอก
              AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _loadingAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.2),
                            AppColors.secondary.withValues(alpha: 0.2),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // ไพ่ที่หมุน
              AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _loadingAnimation.value,
                    child: Container(
                      width: 100,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            // เอฟเฟกต์แสง
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary
                                              .withValues(alpha: 0.3),
                                          AppColors.secondary
                                              .withValues(alpha: 0.3),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // ไอคอน
                            const Center(
                              child: SvgIcon(
                                AppIcons.sparkle,
                                color: AppColors.primary,
                                size: 44,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'THE CARDS SPEAK',
            style: GoogleFonts.fraunces(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'กำลังตีความไพ่...',
            style: GoogleFonts.kanit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.deepText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'กำลังวิเคราะห์ความหมายและความสัมพันธ์ของไพ่',
            style: GoogleFonts.kanit(
              fontSize: 14,
              color: AppColors.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
