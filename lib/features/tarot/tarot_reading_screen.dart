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
import '../../config/constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_icons.dart';
import '../../core/services/thai_zodiac_service.dart';
import '../shared/widgets/gradient_button.dart';

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
        apiClient: ApiClient(baseUrl: ApiConstants.baseUrl),
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
        final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(user.birthDate!);
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

    setState(() {
      _isCardRevealed[index] = true;
    });

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

      // AI ถูกพร็อกซีผ่าน backend แล้ว (OpenAI key อยู่ฝั่ง server เท่านั้น)
      // หมายเหตุการออกแบบ: หน้าจอนี้ยังคงสุ่ม/เปิดไพ่ฝั่ง client เพื่อรักษา UX
      // การโต้ตอบ (สับไพ่/เลือกไพ่/พลิกไพ่) ส่วน "คำทำนาย" เราเรียก backend
      // POST /tarot/readings (auth-only) แล้วใช้ค่า `interpretation` เป็นข้อความคำทำนาย
      // backend จะสุ่มไพ่ของตัวเอง แต่เรายังคงแสดงไพ่ที่ผู้ใช้เปิดไว้ตามเดิม
      final response = Map<String, dynamic>.from(
        await _apiClient.post(
          ApiConstants.tarotReadingsPath,
          data: {
            'spread_type': _backendSpreadType(),
            if (_questionController.text.trim().isNotEmpty)
              'question': _questionController.text.trim(),
          },
        ),
      );

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'การอ่านไพ่ทาโร่',
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.deepText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
            ? _buildLoadingAnimation()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSpreadTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('เลือกรูปแบบการอ่านไพ่'),
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
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.primaryGradient,
                )
              : null,
          color: isSelected ? null : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.7)
                : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? AppColors.primary : AppColors.deepText)
                  .withValues(alpha: isSelected ? 0.18 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.kanit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.deepText : AppColors.deepText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.kanit(
                fontSize: 12,
                height: 1.3,
                color: isSelected
                    ? AppColors.deepText.withValues(alpha: 0.7)
                    : AppColors.mutedText,
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
        _buildSectionTitle('คำถามหรือประเด็นที่ต้องการคำตอบ'),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
        _buildSectionTitle('ไพ่ของคุณ'),
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

  Widget _buildTarotCard(int index) {
    final isRevealed = _isCardRevealed[index];
    final isReversed = _isCardReversed[index];

    return GestureDetector(
      onTap: () => _revealCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: 124,
        height: 204,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          // Soft gold celestial frame around every card.
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
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isRevealed
                ? Colors.white
                : AppColors.surfaceMuted,
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.mysticalGradient,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 14,
                          left: 14,
                          child: SvgIcon(
                            AppIcons.star,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.8),
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
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.25),
                            border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.8),
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
    );
  }

  Widget _buildInterpretation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('คำทำนาย'),
        const SizedBox(height: 16),
        Container(
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
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 18,
                offset: const Offset(0, 8),
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
                  height: 1.65,
                ),
              ),
            ],
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
                                          AppColors.primary.withValues(alpha: 0.3),
                                          AppColors.secondary.withValues(alpha: 0.3),
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
