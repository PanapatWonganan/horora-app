import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/tarot_card_model.dart';
import '../../core/repositories/tarot_repository.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/openai_service.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/zodiac_utils.dart';
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
  final OpenAIService _openAIService = OpenAIService.instance;
  late final TarotRepository _tarotRepository;

  String _spreadType = 'single';
  List<TarotCard> _allCards = [];
  List<TarotCard> _selectedCards = [];
  List<bool> _isCardRevealed = [];
  List<bool> _isCardReversed = [];
  String? _interpretation;
  String? _userZodiacSign;
  String? _userZodiacSignThai;
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
        apiClient: ApiClient(baseUrl: 'https://api.astrology-app.com/api'),
        prefs: prefs,
      );

      _loadCards();
      _loadUserZodiacSign();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเริ่มต้นระบบได้: ${e.toString()}')),
      );
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
      // ใช้ข้อมูลจำลองแทนการเรียกใช้ API
      _allCards = _getMockTarotCards();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดไพ่ทาโร่ได้: ${e.toString()}')),
      );
    }
  }

  // สร้างข้อมูลไพ่ทาโร่จำลอง
  List<TarotCard> _getMockTarotCards() {
    final now = DateTime.now();
    return [
      TarotCard(
        id: 1,
        name: 'The Fool',
        nameTh: 'คนโง่',
        suit: 'Major Arcana',
        number: 0,
        imagePath: 'assets/images/tarot/fool.png',
        keywords: 'beginnings, innocence, adventure',
        keywordsTh: 'การเริ่มต้น, ความไร้เดียงสา, การผจญภัย',
        uprightMeaning: 'New beginnings, innocence, adventure',
        uprightMeaningTh: 'การเริ่มต้นใหม่ การผจญภัย ความไร้เดียงสา',
        reversedMeaning: 'Recklessness, poor decisions, risk-taking',
        reversedMeaningTh: 'ความประมาท การตัดสินใจที่ไม่ดี ความเสี่ยง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 2,
        name: 'The Magician',
        nameTh: 'นักเวทย์',
        suit: 'Major Arcana',
        number: 1,
        imagePath: 'assets/images/tarot/magician.png',
        keywords: 'power, creativity, ability',
        keywordsTh: 'พลัง, การสร้างสรรค์, ความสามารถ',
        uprightMeaning: 'Power, creativity, ability',
        uprightMeaningTh: 'พลัง การสร้างสรรค์ ความสามารถ',
        reversedMeaning: 'Deception, misuse of power',
        reversedMeaningTh: 'การหลอกลวง การใช้พลังในทางที่ผิด',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 3,
        name: 'The High Priestess',
        nameTh: 'มหาปุโรหิตหญิง',
        suit: 'Major Arcana',
        number: 2,
        imagePath: 'assets/images/tarot/high_priestess.png',
        keywords: 'mystery, intuition, inner knowledge',
        keywordsTh: 'ความลึกลับ, สัญชาตญาณ, ความรู้ภายใน',
        uprightMeaning: 'Mystery, intuition, inner knowledge',
        uprightMeaningTh: 'ความลึกลับ สัญชาตญาณ ความรู้ภายใน',
        reversedMeaning:
            'Secrets, hidden information, not listening to intuition',
        reversedMeaningTh: 'การปิดบัง ความลังเล การไม่ฟังเสียงภายใน',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 4,
        name: 'The Empress',
        nameTh: 'จักรพรรดินี',
        suit: 'Major Arcana',
        number: 3,
        imagePath: 'assets/images/tarot/empress.png',
        keywords: 'abundance, motherhood, beauty',
        keywordsTh: 'ความอุดมสมบูรณ์, ความเป็นแม่, ความงาม',
        uprightMeaning: 'Abundance, motherhood, beauty',
        uprightMeaningTh: 'ความอุดมสมบูรณ์ ความเป็นแม่ ความงาม',
        reversedMeaning: 'Dependency, smothering, lack of confidence',
        reversedMeaningTh: 'การพึ่งพาผู้อื่นมากเกินไป การขาดความมั่นใจ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 5,
        name: 'The Emperor',
        nameTh: 'จักรพรรดิ',
        suit: 'Major Arcana',
        number: 4,
        imagePath: 'assets/images/tarot/emperor.png',
        keywords: 'authority, leadership, stability',
        keywordsTh: 'อำนาจ, ความเป็นผู้นำ, ความมั่นคง',
        uprightMeaning: 'Authority, leadership, stability',
        uprightMeaningTh: 'อำนาจ ความเป็นผู้นำ ความมั่นคง',
        reversedMeaning: 'Tyranny, rigidity, stubbornness',
        reversedMeaningTh: 'การใช้อำนาจในทางที่ผิด ความดื้อรั้น',
        createdAt: now,
        updatedAt: now,
      ),
      // เพิ่มไพ่ต่อไปนี้ (6-20)
      TarotCard(
        id: 6,
        name: 'The Hierophant',
        nameTh: 'ผู้นำศาสนา',
        suit: 'Major Arcana',
        number: 5,
        imagePath: 'assets/images/tarot/hierophant.png',
        keywords: 'tradition, convention, beliefs',
        keywordsTh: 'ประเพณี, ความเชื่อ, หลักการ',
        uprightMeaning: 'Tradition, conformity, religious beliefs',
        uprightMeaningTh: 'ความเชื่อทางศาสนา ประเพณี การปฏิบัติตามกฎ',
        reversedMeaning: 'Rebellion, challenging beliefs, unconventional',
        reversedMeaningTh: 'การต่อต้าน การท้าทายความเชื่อ แนวคิดที่แหกกฎ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 7,
        name: 'The Lovers',
        nameTh: 'คู่รัก',
        suit: 'Major Arcana',
        number: 6,
        imagePath: 'assets/images/tarot/lovers.png',
        keywords: 'love, harmony, choices',
        keywordsTh: 'ความรัก, ความกลมกลืน, การเลือก',
        uprightMeaning: 'Love, harmony, relationships, value alignment',
        uprightMeaningTh:
            'ความรัก ความกลมกลืน ความสัมพันธ์ การเลือกอย่างสอดคล้อง',
        reversedMeaning: 'Disharmony, imbalance, misalignment of values',
        reversedMeaningTh: 'ความไม่ลงรอย ความขัดแย้ง ค่านิยมไม่ตรงกัน',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 8,
        name: 'The Chariot',
        nameTh: 'รถศึก',
        suit: 'Major Arcana',
        number: 7,
        imagePath: 'assets/images/tarot/chariot.png',
        keywords: 'control, willpower, victory',
        keywordsTh: 'การควบคุม, พลังใจ, ชัยชนะ',
        uprightMeaning: 'Control, willpower, success, determination',
        uprightMeaningTh: 'การควบคุม พลังใจ ชัยชนะ ความมุ่งมั่น',
        reversedMeaning: 'Lack of control, lack of direction, aggression',
        reversedMeaningTh: 'การสูญเสียการควบคุม ขาดเป้าหมาย ความก้าวร้าว',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 9,
        name: 'Strength',
        nameTh: 'พละกำลัง',
        suit: 'Major Arcana',
        number: 8,
        imagePath: 'assets/images/tarot/strength.png',
        keywords: 'courage, patience, influence',
        keywordsTh: 'ความกล้าหาญ, ความอดทน, อิทธิพล',
        uprightMeaning: 'Courage, inner strength, compassion',
        uprightMeaningTh: 'ความกล้าหาญ พลังภายใน ความเมตตา',
        reversedMeaning: 'Self-doubt, weakness, insecurity',
        reversedMeaningTh: 'ความไม่มั่นใจ ความอ่อนแอ ความไม่มั่นคง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 10,
        name: 'The Hermit',
        nameTh: 'ฤาษี',
        suit: 'Major Arcana',
        number: 9,
        imagePath: 'assets/images/tarot/hermit.png',
        keywords: 'soul-searching, introspection, solitude',
        keywordsTh: 'การค้นหาตัวเอง, การพิจารณาภายใน, ความสันโดษ',
        uprightMeaning: 'Soul-searching, introspection, inner guidance',
        uprightMeaningTh: 'การค้นหาตัวเอง การพิจารณาภายใน การนำทางจากภายใน',
        reversedMeaning: 'Isolation, loneliness, withdrawal',
        reversedMeaningTh: 'ความโดดเดี่ยว ความเปล่าเปลี่ยว การถอนตัว',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 11,
        name: 'Wheel of Fortune',
        nameTh: 'วงล้อแห่งโชคชะตา',
        suit: 'Major Arcana',
        number: 10,
        imagePath: 'assets/images/tarot/wheel_of_fortune.png',
        keywords: 'fate, cycles, turning point',
        keywordsTh: 'โชคชะตา, วัฏจักร, จุดเปลี่ยน',
        uprightMeaning: 'Good luck, karma, destiny, turning point',
        uprightMeaningTh: 'โชคดี กรรม ชะตากรรม จุดเปลี่ยน',
        reversedMeaning: 'Bad luck, lack of control, resistance to change',
        reversedMeaningTh: 'โชคร้าย ขาดการควบคุม การต่อต้านการเปลี่ยนแปลง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 12,
        name: 'Justice',
        nameTh: 'ความยุติธรรม',
        suit: 'Major Arcana',
        number: 11,
        imagePath: 'assets/images/tarot/justice.png',
        keywords: 'fairness, truth, law',
        keywordsTh: 'ความยุติธรรม, ความจริง, กฎหมาย',
        uprightMeaning: 'Justice, fairness, truth, cause and effect',
        uprightMeaningTh: 'ความยุติธรรม ความเป็นธรรม ความจริง เหตุและผล',
        reversedMeaning: 'Unfairness, dishonesty, lack of accountability',
        reversedMeaningTh: 'ความไม่ยุติธรรม ความไม่ซื่อสัตย์ การไม่รับผิดชอบ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 13,
        name: 'The Hanged Man',
        nameTh: 'คนแขวนคอ',
        suit: 'Major Arcana',
        number: 12,
        imagePath: 'assets/images/tarot/hanged_man.png',
        keywords: 'surrender, new perspective, sacrifice',
        keywordsTh: 'การยอมจำนน, มุมมองใหม่, การเสียสละ',
        uprightMeaning: 'Surrender, letting go, new perspective',
        uprightMeaningTh: 'การยอมจำนน การปล่อยวาง มุมมองใหม่',
        reversedMeaning: 'Indecision, resistance, stalling',
        reversedMeaningTh: 'ลังเล ขัดขืน การถ่วงเวลา',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 14,
        name: 'Death',
        nameTh: 'ความตาย',
        suit: 'Major Arcana',
        number: 13,
        imagePath: 'assets/images/tarot/death.png',
        keywords: 'endings, transformation, transition',
        keywordsTh: 'การสิ้นสุด, การเปลี่ยนแปลง, การเปลี่ยนผ่าน',
        uprightMeaning: 'Endings, change, transformation, transition',
        uprightMeaningTh: 'การสิ้นสุด การเปลี่ยนแปลง การแปรรูป การเปลี่ยนผ่าน',
        reversedMeaning: 'Resistance to change, inability to move on',
        reversedMeaningTh: 'การต่อต้านการเปลี่ยนแปลง ไม่สามารถก้าวต่อไปได้',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 15,
        name: 'Temperance',
        nameTh: 'ความพอดี',
        suit: 'Major Arcana',
        number: 14,
        imagePath: 'assets/images/tarot/temperance.png',
        keywords: 'balance, moderation, patience',
        keywordsTh: 'ความสมดุล, ความพอดี, ความอดทน',
        uprightMeaning: 'Balance, moderation, patience, purpose',
        uprightMeaningTh: 'ความสมดุล ความพอดี ความอดทน จุดมุ่งหมาย',
        reversedMeaning: 'Imbalance, excess, lack of harmony',
        reversedMeaningTh: 'ความไม่สมดุล ความมากเกินไป ความไม่กลมกลืน',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 16,
        name: 'The Devil',
        nameTh: 'ปีศาจ',
        suit: 'Major Arcana',
        number: 15,
        imagePath: 'assets/images/tarot/devil.png',
        keywords: 'attachment, materialism, addiction',
        keywordsTh: 'ความผูกพัน, วัตถุนิยม, การเสพติด',
        uprightMeaning: 'Bondage, addiction, obsession, materialism',
        uprightMeaningTh: 'ความผูกมัด การเสพติด ความหมกมุ่น วัตถุนิยม',
        reversedMeaning: 'Breaking free, release, restoring control',
        reversedMeaningTh: 'การปลดปล่อย การคืนอิสรภาพ การฟื้นฟูการควบคุม',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 17,
        name: 'The Tower',
        nameTh: 'หอคอย',
        suit: 'Major Arcana',
        number: 16,
        imagePath: 'assets/images/tarot/tower.png',
        keywords: 'sudden change, upheaval, revelation',
        keywordsTh: 'การเปลี่ยนแปลงฉับพลัน, ความปั่นป่วน, การเปิดเผย',
        uprightMeaning: 'Sudden change, upheaval, revelation, awakening',
        uprightMeaningTh:
            'การเปลี่ยนแปลงฉับพลัน ความปั่นป่วน การเปิดเผย การตื่นรู้',
        reversedMeaning:
            'Avoiding disaster, fear of change, delaying the inevitable',
        reversedMeaningTh:
            'การหลีกเลี่ยงหายนะ ความกลัวการเปลี่ยนแปลง การประวิงสิ่งที่หลีกเลี่ยงไม่ได้',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 18,
        name: 'The Star',
        nameTh: 'ดวงดาว',
        suit: 'Major Arcana',
        number: 17,
        imagePath: 'assets/images/tarot/star.png',
        keywords: 'hope, faith, inspiration',
        keywordsTh: 'ความหวัง, ความศรัทธา, แรงบันดาลใจ',
        uprightMeaning: 'Hope, faith, purpose, renewal, spirituality',
        uprightMeaningTh: 'ความหวัง ความศรัทธา จุดมุ่งหมาย การฟื้นฟู จิตวิญญาณ',
        reversedMeaning: 'Lack of faith, despair, self-trust issues',
        reversedMeaningTh: 'การขาดความศรัทธา ความสิ้นหวัง ปัญหาการไว้ใจตัวเอง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 19,
        name: 'The Moon',
        nameTh: 'ดวงจันทร์',
        suit: 'Major Arcana',
        number: 18,
        imagePath: 'assets/images/tarot/moon.png',
        keywords: 'illusion, fear, anxiety',
        keywordsTh: 'ภาพลวงตา, ความกลัว, ความวิตกกังวล',
        uprightMeaning: 'Illusion, fear, anxiety, intuition, subconscious',
        uprightMeaningTh:
            'ภาพลวงตา ความกลัว ความวิตกกังวล สัญชาตญาณ จิตใต้สำนึก',
        reversedMeaning: 'Release of fear, repressed emotion, confusion',
        reversedMeaningTh: 'การปล่อยวางความกลัว อารมณ์ที่ถูกกดทับ ความสับสน',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 20,
        name: 'The Sun',
        nameTh: 'ดวงอาทิตย์',
        suit: 'Major Arcana',
        number: 19,
        imagePath: 'assets/images/tarot/sun.png',
        keywords: 'success, joy, vitality',
        keywordsTh: 'ความสำเร็จ, ความสุข, พลังชีวิต',
        uprightMeaning: 'Success, joy, happiness, optimism, vitality',
        uprightMeaningTh:
            'ความสำเร็จ ความสุข ความร่าเริง การมองโลกในแง่ดี พลังชีวิต',
        reversedMeaning: 'Temporary depression, bad luck, clouded joy',
        reversedMeaningTh: 'ภาวะซึมเศร้าชั่วคราว โชคร้าย ความสุขที่ถูกบดบัง',
        createdAt: now,
        updatedAt: now,
      ),
      // เพิ่มไพ่ลำดับที่ 21-40
      TarotCard(
        id: 21,
        name: 'Judgement',
        nameTh: 'การพิพากษา',
        suit: 'Major Arcana',
        number: 20,
        imagePath: 'assets/images/tarot/judgement.png',
        keywords: 'rebirth, inner calling, absolution',
        keywordsTh: 'การเกิดใหม่, เสียงเรียกภายใน, การอภัยโทษ',
        uprightMeaning: 'Rebirth, inner calling, absolution, self-reflection',
        uprightMeaningTh:
            'การเกิดใหม่ เสียงเรียกภายใน การอภัยโทษ การใคร่ครวญตนเอง',
        reversedMeaning:
            'Self-doubt, lack of self-awareness, failing to learn lessons',
        reversedMeaningTh:
            'ความไม่มั่นใจในตนเอง การขาดการรับรู้ตัวเอง ความล้มเหลวในการเรียนรู้',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 22,
        name: 'The World',
        nameTh: 'โลก',
        suit: 'Major Arcana',
        number: 21,
        imagePath: 'assets/images/tarot/world.png',
        keywords: 'completion, achievement, fulfillment',
        keywordsTh: 'ความสำเร็จ, ความสมบูรณ์, การบรรลุเป้าหมาย',
        uprightMeaning: 'Completion, achievement, travel, a cycle ending',
        uprightMeaningTh:
            'ความสำเร็จ ความสมบูรณ์ การเดินทาง การสิ้นสุดของวัฏจักร',
        reversedMeaning: 'Lack of completion, stagnation, delay',
        reversedMeaningTh: 'การขาดความสมบูรณ์ ความหยุดชะงัก ความล่าช้า',
        createdAt: now,
        updatedAt: now,
      ),
      // เริ่มชุด Minor Arcana - Cups (ถ้วย)
      TarotCard(
        id: 23,
        name: 'Ace of Cups',
        nameTh: 'เอซแห่งถ้วย',
        suit: 'Cups',
        number: 1,
        imagePath: 'assets/images/tarot/ace_of_cups.png',
        keywords: 'new feelings, intuition, creativity',
        keywordsTh: 'ความรู้สึกใหม่, สัญชาตญาณ, ความคิดสร้างสรรค์',
        uprightMeaning:
            'New feelings, emotional awakening, creativity, intuition',
        uprightMeaningTh:
            'ความรู้สึกใหม่ การตื่นทางอารมณ์ ความคิดสร้างสรรค์ สัญชาตญาณ',
        reversedMeaning: 'Emotional loss, blocked creativity, emptiness',
        reversedMeaningTh:
            'การสูญเสียทางอารมณ์ การปิดกั้นความคิดสร้างสรรค์ ความว่างเปล่า',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 24,
        name: 'Two of Cups',
        nameTh: 'สองแห่งถ้วย',
        suit: 'Cups',
        number: 2,
        imagePath: 'assets/images/tarot/two_of_cups.png',
        keywords: 'unity, partnership, mutual attraction',
        keywordsTh: 'ความเป็นหนึ่ง, หุ้นส่วน, การดึงดูดซึ่งกันและกัน',
        uprightMeaning: 'Unity, partnership, mutual attraction, connection',
        uprightMeaningTh:
            'ความเป็นหนึ่ง หุ้นส่วน การดึงดูดซึ่งกันและกัน การเชื่อมต่อ',
        reversedMeaning: 'Imbalance, broken communication, tension',
        reversedMeaningTh: 'ความไม่สมดุล การสื่อสารที่ล้มเหลว ความตึงเครียด',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 25,
        name: 'Three of Cups',
        nameTh: 'สามแห่งถ้วย',
        suit: 'Cups',
        number: 3,
        imagePath: 'assets/images/tarot/three_of_cups.png',
        keywords: 'celebration, friendship, joy',
        keywordsTh: 'การเฉลิมฉลอง, มิตรภาพ, ความสุข',
        uprightMeaning: 'Celebration, friendship, creativity, collaborations',
        uprightMeaningTh: 'การเฉลิมฉลอง มิตรภาพ ความคิดสร้างสรรค์ ความร่วมมือ',
        reversedMeaning: 'Overindulgence, gossip, isolation',
        reversedMeaningTh: 'ความมัวเมา นินทา ความโดดเดี่ยว',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 26,
        name: 'Four of Cups',
        nameTh: 'สี่แห่งถ้วย',
        suit: 'Cups',
        number: 4,
        imagePath: 'assets/images/tarot/four_of_cups.png',
        keywords: 'contemplation, apathy, reevaluation',
        keywordsTh: 'การครุ่นคิด, ความเฉยเมย, การประเมินค่าใหม่',
        uprightMeaning: 'Contemplation, apathy, reevaluation, discontent',
        uprightMeaningTh:
            'การครุ่นคิด ความเฉยเมย การประเมินค่าใหม่ ความไม่พอใจ',
        reversedMeaning: 'New opportunities, seeking purpose, curiosity',
        reversedMeaningTh: 'โอกาสใหม่ การแสวงหาจุดมุ่งหมาย ความอยากรู้',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 27,
        name: 'Five of Cups',
        nameTh: 'ห้าแห่งถ้วย',
        suit: 'Cups',
        number: 5,
        imagePath: 'assets/images/tarot/five_of_cups.png',
        keywords: 'loss, grief, disappointment',
        keywordsTh: 'การสูญเสีย, ความโศกเศร้า, ความผิดหวัง',
        uprightMeaning:
            'Loss, grief, disappointment, regret, focusing on the negative',
        uprightMeaningTh:
            'การสูญเสีย ความโศกเศร้า ความผิดหวัง ความเสียใจ การจดจ่อกับสิ่งลบ',
        reversedMeaning: 'Acceptance, moving on, forgiveness',
        reversedMeaningTh: 'การยอมรับ การก้าวต่อไป การให้อภัย',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 28,
        name: 'Six of Cups',
        nameTh: 'หกแห่งถ้วย',
        suit: 'Cups',
        number: 6,
        imagePath: 'assets/images/tarot/six_of_cups.png',
        keywords: 'nostalgia, childhood, innocence',
        keywordsTh: 'ความคิดถึง, วัยเด็ก, ความไร้เดียงสา',
        uprightMeaning: 'Nostalgia, childhood memories, innocence, joy',
        uprightMeaningTh: 'ความคิดถึง ความทรงจำวัยเด็ก ความไร้เดียงสา ความสุข',
        reversedMeaning: 'Moving forward, leaving past behind, independence',
        reversedMeaningTh:
            'การก้าวไปข้างหน้า การทิ้งอดีตไว้เบื้องหลัง ความเป็นอิสระ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 29,
        name: 'Seven of Cups',
        nameTh: 'เจ็ดแห่งถ้วย',
        suit: 'Cups',
        number: 7,
        imagePath: 'assets/images/tarot/seven_of_cups.png',
        keywords: 'choices, fantasy, delusion',
        keywordsTh: 'ทางเลือก, จินตนาการ, ภาพลวงตา',
        uprightMeaning: 'Choices, fantasy, illusion, wishful thinking',
        uprightMeaningTh: 'ทางเลือก จินตนาการ ภาพลวงตา ความคิดเพ้อฝัน',
        reversedMeaning: 'Clarity, focus, realistic choices',
        reversedMeaningTh: 'ความชัดเจน การจดจ่อ ทางเลือกที่เป็นจริง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 30,
        name: 'Eight of Cups',
        nameTh: 'แปดแห่งถ้วย',
        suit: 'Cups',
        number: 8,
        imagePath: 'assets/images/tarot/eight_of_cups.png',
        keywords: 'walking away, abandonment, leaving behind',
        keywordsTh: 'การจากไป, การละทิ้ง, การทิ้งไว้เบื้องหลัง',
        uprightMeaning:
            'Walking away, abandonment, leaving behind, seeking more',
        uprightMeaningTh:
            'การจากไป การละทิ้ง การทิ้งไว้เบื้องหลัง การแสวงหาสิ่งที่มากกว่า',
        reversedMeaning:
            'Fear of change, fear of loss, staying in a bad situation',
        reversedMeaningTh:
            'ความกลัวการเปลี่ยนแปลง ความกลัวการสูญเสีย การคงอยู่ในสถานการณ์ที่ไม่ดี',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 31,
        name: 'Nine of Cups',
        nameTh: 'เก้าแห่งถ้วย',
        suit: 'Cups',
        number: 9,
        imagePath: 'assets/images/tarot/nine_of_cups.png',
        keywords: 'satisfaction, wishes, harmony',
        keywordsTh: 'ความพึงพอใจ, ความปรารถนา, ความกลมกลืน',
        uprightMeaning:
            'Satisfaction, emotional fulfillment, wishes coming true',
        uprightMeaningTh:
            'ความพึงพอใจ ความสมบูรณ์ทางอารมณ์ ความปรารถนาที่เป็นจริง',
        reversedMeaning: 'Inner happiness, materialism, dissatisfaction',
        reversedMeaningTh: 'ความสุขภายใน วัตถุนิยม ความไม่พึงพอใจ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 32,
        name: 'Ten of Cups',
        nameTh: 'สิบแห่งถ้วย',
        suit: 'Cups',
        number: 10,
        imagePath: 'assets/images/tarot/ten_of_cups.png',
        keywords: 'harmony, family, community',
        keywordsTh: 'ความกลมกลืน, ครอบครัว, ชุมชน',
        uprightMeaning: 'Harmony, family connection, community, contentment',
        uprightMeaningTh: 'ความกลมกลืน ความผูกพันในครอบครัว ชุมชน ความพึงพอใจ',
        reversedMeaning:
            'Disconnection, misaligned values, struggling relationships',
        reversedMeaningTh:
            'การขาดการเชื่อมต่อ ค่านิยมที่ไม่ตรงกัน ความสัมพันธ์ที่มีปัญหา',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 33,
        name: 'Page of Cups',
        nameTh: 'แพจแห่งถ้วย',
        suit: 'Cups',
        number: 11,
        imagePath: 'assets/images/tarot/page_of_cups.png',
        keywords: 'new ideas, intuitive messages, curiosity',
        keywordsTh: 'แนวคิดใหม่, ข้อความจากสัญชาตญาณ, ความอยากรู้',
        uprightMeaning: 'New ideas, intuitive messages, curiosity, creativity',
        uprightMeaningTh:
            'แนวคิดใหม่ ข้อความจากสัญชาตญาณ ความอยากรู้ ความคิดสร้างสรรค์',
        reversedMeaning: 'Emotional immaturity, insecurity, disappointment',
        reversedMeaningTh:
            'ความไม่เป็นผู้ใหญ่ทางอารมณ์ ความไม่มั่นคง ความผิดหวัง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 34,
        name: 'Knight of Cups',
        nameTh: 'ไนต์แห่งถ้วย',
        suit: 'Cups',
        number: 12,
        imagePath: 'assets/images/tarot/knight_of_cups.png',
        keywords: 'romance, charm, imagination',
        keywordsTh: 'ความโรแมนติก, เสน่ห์, จินตนาการ',
        uprightMeaning: 'Romance, charm, imagination, emotional proposals',
        uprightMeaningTh: 'ความโรแมนติก เสน่ห์ จินตนาการ การเสนอทางอารมณ์',
        reversedMeaning: 'Emotional manipulation, moodiness, unrealistic',
        reversedMeaningTh: 'การบงการทางอารมณ์ อารมณ์แปรปรวน ความไม่เป็นจริง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 35,
        name: 'Queen of Cups',
        nameTh: 'ควีนแห่งถ้วย',
        suit: 'Cups',
        number: 13,
        imagePath: 'assets/images/tarot/queen_of_cups.png',
        keywords: 'compassion, empathy, emotional stability',
        keywordsTh: 'ความเห็นอกเห็นใจ, ความเข้าอกเข้าใจ, ความมั่นคงทางอารมณ์',
        uprightMeaning: 'Compassion, calm, comfort, emotional security',
        uprightMeaningTh:
            'ความเห็นอกเห็นใจ ความสงบ ความสบายใจ ความมั่นคงทางอารมณ์',
        reversedMeaning: 'Emotional insecurity, martyr mentality, dependency',
        reversedMeaningTh: 'ความไม่มั่นคงทางอารมณ์ จิตใจแบบผู้ยอมสละ การพึ่งพา',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 36,
        name: 'King of Cups',
        nameTh: 'คิงแห่งถ้วย',
        suit: 'Cups',
        number: 14,
        imagePath: 'assets/images/tarot/king_of_cups.png',
        keywords: 'emotional balance, wisdom, diplomacy',
        keywordsTh: 'ความสมดุลทางอารมณ์, ปัญญา, การทูต',
        uprightMeaning: 'Emotional balance, generosity, control, diplomatic',
        uprightMeaningTh: 'ความสมดุลทางอารมณ์ ความใจกว้าง การควบคุม การทูต',
        reversedMeaning:
            'Emotional manipulation, emotional outbursts, coldness',
        reversedMeaningTh: 'การบงการทางอารมณ์ การระเบิดอารมณ์ ความเย็นชา',
        createdAt: now,
        updatedAt: now,
      ),
      // เริ่มชุด Minor Arcana - Pentacles (เหรียญ)
      TarotCard(
        id: 37,
        name: 'Ace of Pentacles',
        nameTh: 'เอซแห่งเหรียญ',
        suit: 'Pentacles',
        number: 1,
        imagePath: 'assets/images/tarot/ace_of_pentacles.png',
        keywords: 'new opportunity, prosperity, abundance',
        keywordsTh: 'โอกาสใหม่, ความเจริญรุ่งเรือง, ความอุดมสมบูรณ์',
        uprightMeaning: 'New opportunity, prosperity, abundance, manifestation',
        uprightMeaningTh:
            'โอกาสใหม่ ความเจริญรุ่งเรือง ความอุดมสมบูรณ์ การแสดงออก',
        reversedMeaning: 'Missed opportunity, lack of planning, scarcity',
        reversedMeaningTh: 'โอกาสที่หลุดลอย การขาดการวางแผน ความขาดแคลน',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 38,
        name: 'Two of Pentacles',
        nameTh: 'สองแห่งเหรียญ',
        suit: 'Pentacles',
        number: 2,
        imagePath: 'assets/images/tarot/two_of_pentacles.png',
        keywords: 'balance, adaptability, juggling priorities',
        keywordsTh: 'ความสมดุล, การปรับตัว, การรับมือกับหลายสิ่งพร้อมกัน',
        uprightMeaning:
            'Balance, adaptability, juggling priorities, flexibility',
        uprightMeaningTh:
            'ความสมดุล การปรับตัว การรับมือกับหลายสิ่งพร้อมกัน ความยืดหยุ่น',
        reversedMeaning: 'Imbalance, disorganization, chaos',
        reversedMeaningTh: 'ความไม่สมดุล ความไร้ระเบียบ ความวุ่นวาย',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 39,
        name: 'Three of Pentacles',
        nameTh: 'สามแห่งเหรียญ',
        suit: 'Pentacles',
        number: 3,
        imagePath: 'assets/images/tarot/three_of_pentacles.png',
        keywords: 'teamwork, collaboration, mastery',
        keywordsTh: 'การทำงานเป็นทีม, ความร่วมมือ, ความเชี่ยวชาญ',
        uprightMeaning: 'Teamwork, collaboration, mastery, skill development',
        uprightMeaningTh:
            'การทำงานเป็นทีม ความร่วมมือ ความเชี่ยวชาญ การพัฒนาทักษะ',
        reversedMeaning: 'Lack of cohesion, discord, low-quality work',
        reversedMeaningTh:
            'การขาดความเป็นอันหนึ่งอันเดียวกัน ความขัดแย้ง งานที่มีคุณภาพต่ำ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 40,
        name: 'Four of Pentacles',
        nameTh: 'สี่แห่งเหรียญ',
        suit: 'Pentacles',
        number: 4,
        imagePath: 'assets/images/tarot/four_of_pentacles.png',
        keywords: 'security, control, possession',
        keywordsTh: 'ความมั่นคง, การควบคุม, การครอบครอง',
        uprightMeaning: 'Security, stability, conservatism, hoarding',
        uprightMeaningTh: 'ความมั่นคง เสถียรภาพ ความอนุรักษ์นิยม การสะสม',
        reversedMeaning: 'Generosity, release, spending unwisely',
        reversedMeaningTh: 'ความใจกว้าง การปล่อยวาง การใช้จ่ายอย่างไม่ฉลาด',
        createdAt: now,
        updatedAt: now,
      ),
      // เพิ่มไพ่ลำดับที่ 41-60
      TarotCard(
        id: 41,
        name: 'Five of Pentacles',
        nameTh: 'ห้าแห่งเหรียญ',
        suit: 'Pentacles',
        number: 5,
        imagePath: 'assets/images/tarot/five_of_pentacles.png',
        keywords: 'hardship, poverty, insecurity',
        keywordsTh: 'ความยากลำบาก, ความยากจน, ความไม่มั่นคง',
        uprightMeaning: 'Hardship, poverty, insecurity, worry, isolation',
        uprightMeaningTh:
            'ความยากลำบาก ความยากจน ความไม่มั่นคง ความกังวล ความโดดเดี่ยว',
        reversedMeaning: 'Recovery, finding help, spiritual poverty',
        reversedMeaningTh:
            'การฟื้นตัว การพบความช่วยเหลือ ความยากจนทางจิตวิญญาณ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 42,
        name: 'Six of Pentacles',
        nameTh: 'หกแห่งเหรียญ',
        suit: 'Pentacles',
        number: 6,
        imagePath: 'assets/images/tarot/six_of_pentacles.png',
        keywords: 'generosity, charity, sharing',
        keywordsTh: 'ความใจกว้าง, การกุศล, การแบ่งปัน',
        uprightMeaning: 'Generosity, charity, giving and receiving, gratitude',
        uprightMeaningTh: 'ความใจกว้าง การกุศล การให้และการรับ ความกตัญญู',
        reversedMeaning: 'Selfishness, debt, strings attached giving',
        reversedMeaningTh: 'ความเห็นแก่ตัว หนี้สิน การให้ที่มีเงื่อนไขแอบแฝง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 43,
        name: 'Seven of Pentacles',
        nameTh: 'เจ็ดแห่งเหรียญ',
        suit: 'Pentacles',
        number: 7,
        imagePath: 'assets/images/tarot/seven_of_pentacles.png',
        keywords: 'patience, waiting, investment',
        keywordsTh: 'ความอดทน, การรอคอย, การลงทุน',
        uprightMeaning: 'Patience, waiting for rewards, investment, planning',
        uprightMeaningTh: 'ความอดทน การรอรางวัล การลงทุน การวางแผน',
        reversedMeaning: 'Poor planning, missed opportunity, impatience',
        reversedMeaningTh: 'การวางแผนที่ไม่ดี โอกาสที่หลุดลอย ความใจร้อน',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 44,
        name: 'Eight of Pentacles',
        nameTh: 'แปดแห่งเหรียญ',
        suit: 'Pentacles',
        number: 8,
        imagePath: 'assets/images/tarot/eight_of_pentacles.png',
        keywords: 'mastery, skill development, dedication',
        keywordsTh: 'ความเชี่ยวชาญ, การพัฒนาทักษะ, ความทุ่มเท',
        uprightMeaning: 'Mastery, skill development, dedication, effort',
        uprightMeaningTh: 'ความเชี่ยวชาญ การพัฒนาทักษะ ความทุ่มเท ความพยายาม',
        reversedMeaning: 'Perfectionism, lack of progress, frustration',
        reversedMeaningTh:
            'ความสมบูรณ์แบบเกินไป การขาดความก้าวหน้า ความคับข้องใจ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 45,
        name: 'Nine of Pentacles',
        nameTh: 'เก้าแห่งเหรียญ',
        suit: 'Pentacles',
        number: 9,
        imagePath: 'assets/images/tarot/nine_of_pentacles.png',
        keywords: 'luxury, self-sufficiency, financial independence',
        keywordsTh: 'ความหรูหรา, การพึ่งพาตนเอง, อิสรภาพทางการเงิน',
        uprightMeaning:
            'Luxury, self-sufficiency, financial independence, comfort',
        uprightMeaningTh:
            'ความหรูหรา การพึ่งพาตนเอง อิสรภาพทางการเงิน ความสะดวกสบาย',
        reversedMeaning: 'Dependency, cage of luxury, lack of true security',
        reversedMeaningTh:
            'การพึ่งพาผู้อื่น กรงขังแห่งความหรูหรา การขาดความมั่นคงที่แท้จริง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 46,
        name: 'Ten of Pentacles',
        nameTh: 'สิบแห่งเหรียญ',
        suit: 'Pentacles',
        number: 10,
        imagePath: 'assets/images/tarot/ten_of_pentacles.png',
        keywords: 'wealth, family legacy, inheritance',
        keywordsTh: 'ความมั่งคั่ง, มรดกครอบครัว, การสืบทอด',
        uprightMeaning: 'Wealth, family, legacy, inheritance, establishment',
        uprightMeaningTh: 'ความมั่งคั่ง ครอบครัว มรดก การสืบทอด การก่อตั้ง',
        reversedMeaning: 'Family problems, financial failure, instability',
        reversedMeaningTh: 'ปัญหาครอบครัว ความล้มเหลวทางการเงิน ความไม่มั่นคง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 47,
        name: 'Page of Pentacles',
        nameTh: 'แพจแห่งเหรียญ',
        suit: 'Pentacles',
        number: 11,
        imagePath: 'assets/images/tarot/page_of_pentacles.png',
        keywords: 'manifestation, opportunity, study',
        keywordsTh: 'การแสดงออก, โอกาส, การศึกษา',
        uprightMeaning: 'Manifestation, opportunity, study, practicality',
        uprightMeaningTh: 'การแสดงออก โอกาส การศึกษา ความเป็นไปได้',
        reversedMeaning: 'Lack of focus, poor planning, missed opportunity',
        reversedMeaningTh: 'การขาดสมาธิ การวางแผนที่ไม่ดี โอกาสที่พลาดไป',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 48,
        name: 'Knight of Pentacles',
        nameTh: 'ไนต์แห่งเหรียญ',
        suit: 'Pentacles',
        number: 12,
        imagePath: 'assets/images/tarot/knight_of_pentacles.png',
        keywords: 'reliability, responsibility, patience',
        keywordsTh: 'ความน่าเชื่อถือ, ความรับผิดชอบ, ความอดทน',
        uprightMeaning:
            'Reliability, responsibility, patience, methodical approach',
        uprightMeaningTh:
            'ความน่าเชื่อถือ ความรับผิดชอบ ความอดทน วิธีการที่เป็นระบบ',
        reversedMeaning: 'Laziness, boredom, feeling stuck, being negative',
        reversedMeaningTh:
            'ความขี้เกียจ ความเบื่อหน่าย ความรู้สึกติดขัด การเป็นคนในแง่ลบ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 49,
        name: 'Queen of Pentacles',
        nameTh: 'ควีนแห่งเหรียญ',
        suit: 'Pentacles',
        number: 13,
        imagePath: 'assets/images/tarot/queen_of_pentacles.png',
        keywords: 'nurturing, abundance, security',
        keywordsTh: 'การเลี้ยงดู, ความอุดมสมบูรณ์, ความมั่นคง',
        uprightMeaning: 'Nurturing, abundance, security, down-to-earth',
        uprightMeaningTh:
            'การเลี้ยงดู ความอุดมสมบูรณ์ ความมั่นคง ความเป็นคนติดดิน',
        reversedMeaning:
            'Self-care neglect, financial dependency, creative blocks',
        reversedMeaningTh:
            'การละเลยการดูแลตัวเอง การพึ่งพาทางการเงิน อุปสรรคทางความคิดสร้างสรรค์',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 50,
        name: 'King of Pentacles',
        nameTh: 'คิงแห่งเหรียญ',
        suit: 'Pentacles',
        number: 14,
        imagePath: 'assets/images/tarot/king_of_pentacles.png',
        keywords: 'wealth, business, leadership',
        keywordsTh: 'ความมั่งคั่ง, ธุรกิจ, ความเป็นผู้นำ',
        uprightMeaning: 'Wealth, business, leadership, abundance, security',
        uprightMeaningTh:
            'ความมั่งคั่ง ธุรกิจ ความเป็นผู้นำ ความอุดมสมบูรณ์ ความมั่นคง',
        reversedMeaning: 'Corrupt, obsessed with wealth, materialistic',
        reversedMeaningTh: 'การคอร์รัปชัน ความหมกมุ่นกับความมั่งคั่ง วัตถุนิยม',
        createdAt: now,
        updatedAt: now,
      ),
      // เริ่มชุด Minor Arcana - Swords (ดาบ)
      TarotCard(
        id: 51,
        name: 'Ace of Swords',
        nameTh: 'เอซแห่งดาบ',
        suit: 'Swords',
        number: 1,
        imagePath: 'assets/images/tarot/ace_of_swords.png',
        keywords: 'clarity, truth, communication',
        keywordsTh: 'ความชัดเจน, ความจริง, การสื่อสาร',
        uprightMeaning: 'Clarity, truth, communication, new ideas',
        uprightMeaningTh: 'ความชัดเจน ความจริง การสื่อสาร แนวคิดใหม่',
        reversedMeaning: 'Deception, manipulation, conflict',
        reversedMeaningTh: 'การหลอกลวง การใช้พลังในทางที่ผิด ความขัดแย้ง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 52,
        name: 'Two of Swords',
        nameTh: 'สองแห่งดาบ',
        suit: 'Swords',
        number: 2,
        imagePath: 'assets/images/tarot/two_of_swords.png',
        keywords: 'stalemate, decisions, blockage',
        keywordsTh: 'ทางตัน, การตัดสินใจ, การถูกปิดกั้น',
        uprightMeaning: 'Stalemate, difficult decisions, blockage, denial',
        uprightMeaningTh: 'ทางตัน การตัดสินใจที่ยาก การถูกปิดกั้น การปฏิเสธ',
        reversedMeaning: 'Indecision, confusion, information overload',
        reversedMeaningTh: 'ความลังเล ความสับสน ข้อมูลมากเกินไป',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 53,
        name: 'Three of Swords',
        nameTh: 'สามแห่งดาบ',
        suit: 'Swords',
        number: 3,
        imagePath: 'assets/images/tarot/three_of_swords.png',
        keywords: 'heartbreak, rejection, betrayal',
        keywordsTh: 'ความเสียใจ, การถูกปฏิเสธ, การทรยศ',
        uprightMeaning: 'Heartbreak, rejection, betrayal, emotional pain',
        uprightMeaningTh:
            'ความเสียใจ การถูกปฏิเสธ การทรยศ ความเจ็บปวดทางอารมณ์',
        reversedMeaning: 'Recovery, forgiveness, moving on',
        reversedMeaningTh: 'การฟื้นตัว การให้อภัย การก้าวต่อไป',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 54,
        name: 'Four of Swords',
        nameTh: 'สี่แห่งดาบ',
        suit: 'Swords',
        number: 4,
        imagePath: 'assets/images/tarot/four_of_swords.png',
        keywords: 'rest, recovery, contemplation',
        keywordsTh: 'การพักผ่อน, การฟื้นฟู, การใคร่ครวญ',
        uprightMeaning: 'Rest, recovery, contemplation, restoration',
        uprightMeaningTh: 'การพักผ่อน การฟื้นฟู การใคร่ครวญ การฟื้นฟู',
        reversedMeaning: 'Restlessness, burnout, stress, activity',
        reversedMeaningTh: 'ความกระวนกระวาย ความหมดไฟ ความเครียด กิจกรรม',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 55,
        name: 'Five of Swords',
        nameTh: 'ห้าแห่งดาบ',
        suit: 'Swords',
        number: 5,
        imagePath: 'assets/images/tarot/five_of_swords.png',
        keywords: 'conflict, defeat, win at all costs',
        keywordsTh: 'ความขัดแย้ง, ความพ่ายแพ้, การชนะที่ทุกราคา',
        uprightMeaning: 'Conflict, tension, defeat, win at all costs',
        uprightMeaningTh:
            'ความขัดแย้ง ความตึงเครียด ความพ่ายแพ้ การชนะที่ทุกราคา',
        reversedMeaning: 'Reconciliation, forgiveness, moving on',
        reversedMeaningTh: 'การคืนดี การให้อภัย การก้าวต่อไป',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 56,
        name: 'Six of Swords',
        nameTh: 'หกแห่งดาบ',
        suit: 'Swords',
        number: 6,
        imagePath: 'assets/images/tarot/six_of_swords.png',
        keywords: 'transition, moving on, leaving behind',
        keywordsTh: 'การเปลี่ยนผ่าน, การก้าวต่อไป, การทิ้งไว้เบื้องหลัง',
        uprightMeaning: 'Transition, moving on, leaving behind, moving forward',
        uprightMeaningTh:
            'การเปลี่ยนผ่าน การก้าวต่อไป การทิ้งไว้เบื้องหลัง การก้าวไปข้างหน้า',
        reversedMeaning: 'Stuck, resistance to change, unresolved issues',
        reversedMeaningTh:
            'การติดขัด การต่อต้านการเปลี่ยนแปลง ปัญหาที่ยังไม่ได้รับการแก้ไข',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 57,
        name: 'Seven of Swords',
        nameTh: 'เจ็ดแห่งดาบ',
        suit: 'Swords',
        number: 7,
        imagePath: 'assets/images/tarot/seven_of_swords.png',
        keywords: 'deception, strategy, stealth',
        keywordsTh: 'การหลอกลวง, กลยุทธ์, การลักลอบ',
        uprightMeaning: 'Deception, strategy, stealth, sneakiness',
        uprightMeaningTh: 'การหลอกลวง กลยุทธ์ การลักลอบ ความเจ้าเล่ห์',
        reversedMeaning: 'Confession, exposure, honesty, taking responsibility',
        reversedMeaningTh: 'การสารภาพ การเปิดเผย ความซื่อสัตย์ การรับผิดชอบ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 58,
        name: 'Eight of Swords',
        nameTh: 'แปดแห่งดาบ',
        suit: 'Swords',
        number: 8,
        imagePath: 'assets/images/tarot/eight_of_swords.png',
        keywords: 'restriction, limitation, imprisonment',
        keywordsTh: 'ข้อจำกัด, ขีดจำกัด, การถูกคุมขัง',
        uprightMeaning:
            'Restriction, limitation, imprisonment, victim mentality',
        uprightMeaningTh: 'ข้อจำกัด ขีดจำกัด การถูกคุมขัง จิตใจแบบเหยื่อ',
        reversedMeaning: 'Freedom, self-acceptance, new perspective',
        reversedMeaningTh: 'เสรีภาพ การยอมรับตัวเอง มุมมองใหม่',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 59,
        name: 'Nine of Swords',
        nameTh: 'เก้าแห่งดาบ',
        suit: 'Swords',
        number: 9,
        imagePath: 'assets/images/tarot/nine_of_swords.png',
        keywords: 'anxiety, worry, fear',
        keywordsTh: 'ความวิตกกังวล, ความกังวล, ความกลัว',
        uprightMeaning:
            'Anxiety, worry, fear, nightmare, overwhelming thoughts',
        uprightMeaningTh:
            'ความวิตกกังวล ความกังวล ความกลัว ฝันร้าย ความคิดที่ท่วมท้น',
        reversedMeaning: 'Recovery, hope, reaching out for help',
        reversedMeaningTh: 'การฟื้นตัว ความหวัง การขอความช่วยเหลือ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 60,
        name: 'Ten of Swords',
        nameTh: 'สิบแห่งดาบ',
        suit: 'Swords',
        number: 10,
        imagePath: 'assets/images/tarot/ten_of_swords.png',
        keywords: 'endings, defeat, crisis',
        keywordsTh: 'การสิ้นสุด, ความพ่ายแพ้, วิกฤติ',
        uprightMeaning: 'Endings, defeat, crisis, betrayal, rock bottom',
        uprightMeaningTh: 'การสิ้นสุด ความพ่ายแพ้ วิกฤติ การทรยศ จุดต่ำสุด',
        reversedMeaning: 'Recovery, regeneration, positive resolutions',
        reversedMeaningTh: 'การฟื้นตัว การฟื้นฟู ทางออกเชิงบวก',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 61,
        name: 'Page of Swords',
        nameTh: 'แพจแห่งดาบ',
        suit: 'Swords',
        number: 11,
        imagePath: 'assets/images/tarot/page_of_swords.png',
        keywords: 'curiosity, communication, vigilance',
        keywordsTh: 'ความอยากรู้, การสื่อสาร, ความระแวดระวัง',
        uprightMeaning: 'Curiosity, communication, vigilance, intelligence',
        uprightMeaningTh: 'ความอยากรู้ การสื่อสาร ความระแวดระวัง ปัญญา',
        reversedMeaning: 'All talk and no action, haste, cynicism',
        reversedMeaningTh: 'พูดแต่ไม่ทำ ความรีบร้อน ความเย็นชา',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 62,
        name: 'Knight of Swords',
        nameTh: 'ไนต์แห่งดาบ',
        suit: 'Swords',
        number: 12,
        imagePath: 'assets/images/tarot/knight_of_swords.png',
        keywords: 'action, impulsiveness, defense',
        keywordsTh: 'การกระทำ, ความหุนหันพลันแล่น, การป้องกัน',
        uprightMeaning: 'Action, impulsiveness, defense, intellect, courage',
        uprightMeaningTh:
            'การกระทำ ความหุนหันพลันแล่น การป้องกัน สติปัญญา ความกล้าหาญ',
        reversedMeaning: 'Recklessness, aggression, no direction',
        reversedMeaningTh: 'ความประมาท ความก้าวร้าว การขาดทิศทาง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 63,
        name: 'Queen of Swords',
        nameTh: 'ควีนแห่งดาบ',
        suit: 'Swords',
        number: 13,
        imagePath: 'assets/images/tarot/queen_of_swords.png',
        keywords: 'intellect, honesty, clarity',
        keywordsTh: 'สติปัญญา, ความซื่อสัตย์, ความชัดเจน',
        uprightMeaning: 'Intellect, honesty, clarity, wisdom, independent',
        uprightMeaningTh:
            'สติปัญญา ความซื่อสัตย์ ความชัดเจน ปัญญา ความเป็นอิสระ',
        reversedMeaning: 'Bitterness, coldness, cruelty, manipulation',
        reversedMeaningTh: 'ความขมขื่น ความเย็นชา ความโหดร้าย การบงการ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 64,
        name: 'King of Swords',
        nameTh: 'คิงแห่งดาบ',
        suit: 'Swords',
        number: 14,
        imagePath: 'assets/images/tarot/king_of_swords.png',
        keywords: 'authority, logical, intellectual power',
        keywordsTh: 'อำนาจ, เหตุผล, พลังทางปัญญา',
        uprightMeaning: 'Authority, logical, intellectual power, truth',
        uprightMeaningTh: 'อำนาจ เหตุผล พลังทางปัญญา ความจริง',
        reversedMeaning: 'Tyranny, coldness, manipulation, corruption',
        reversedMeaningTh: 'ความกดขี่ ความเย็นชา การบงการ การคอร์รัปชัน',
        createdAt: now,
        updatedAt: now,
      ),
      // เริ่มชุด Minor Arcana - Wands (ไม้เท้า)
      TarotCard(
        id: 65,
        name: 'Ace of Wands',
        nameTh: 'เอซแห่งไม้เท้า',
        suit: 'Wands',
        number: 1,
        imagePath: 'assets/images/tarot/ace_of_wands.png',
        keywords: 'inspiration, creativity, potential',
        keywordsTh: 'แรงบันดาลใจ, ความคิดสร้างสรรค์, ศักยภาพ',
        uprightMeaning: 'Inspiration, creativity, potential, new opportunities',
        uprightMeaningTh: 'แรงบันดาลใจ ความคิดสร้างสรรค์ ศักยภาพ โอกาสใหม่',
        reversedMeaning: 'Delays, lack of direction, lack of energy',
        reversedMeaningTh: 'การล่าช้า การขาดทิศทาง การขาดพลังงาน',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 66,
        name: 'Two of Wands',
        nameTh: 'สองแห่งไม้เท้า',
        suit: 'Wands',
        number: 2,
        imagePath: 'assets/images/tarot/two_of_wands.png',
        keywords: 'planning, decisions, future',
        keywordsTh: 'การวางแผน, การตัดสินใจ, อนาคต',
        uprightMeaning: 'Planning, decisions, future, progress, discovery',
        uprightMeaningTh: 'การวางแผน การตัดสินใจ อนาคต ความก้าวหน้า การค้นพบ',
        reversedMeaning: 'Fear of change, playing it safe, bad planning',
        reversedMeaningTh:
            'ความกลัวการเปลี่ยนแปลง การเล่นปลอดภัย การวางแผนที่ไม่ดี',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 67,
        name: 'Three of Wands',
        nameTh: 'สามแห่งไม้เท้า',
        suit: 'Wands',
        number: 3,
        imagePath: 'assets/images/tarot/three_of_wands.png',
        keywords: 'expansion, growth, exploration',
        keywordsTh: 'การขยาย, การเติบโต, การสำรวจ',
        uprightMeaning: 'Expansion, growth, exploration, foresight',
        uprightMeaningTh: 'การขยาย การเติบโต การสำรวจ การมองการณ์ไกล',
        reversedMeaning: 'Obstacles, delays, frustration, stagnation',
        reversedMeaningTh: 'อุปสรรค ความล่าช้า ความคับข้องใจ ความหยุดชะงัก',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 68,
        name: 'Four of Wands',
        nameTh: 'สี่แห่งไม้เท้า',
        suit: 'Wands',
        number: 4,
        imagePath: 'assets/images/tarot/four_of_wands.png',
        keywords: 'celebration, harmony, marriage',
        keywordsTh: 'การเฉลิมฉลอง, ความกลมกลืน, การแต่งงาน',
        uprightMeaning: 'Celebration, harmony, marriage, home, reunion',
        uprightMeaningTh: 'การเฉลิมฉลอง ความกลมกลืน การแต่งงาน บ้าน การรวมตัว',
        reversedMeaning: 'Lack of harmony, lack of safety, transitional period',
        reversedMeaningTh:
            'การขาดความกลมกลืน การขาดความปลอดภัย ช่วงเปลี่ยนผ่าน',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 69,
        name: 'Five of Wands',
        nameTh: 'ห้าแห่งไม้เท้า',
        suit: 'Wands',
        number: 5,
        imagePath: 'assets/images/tarot/five_of_wands.png',
        keywords: 'competition, disagreement, conflict',
        keywordsTh: 'การแข่งขัน, ความไม่ลงรอย, ความขัดแย้ง',
        uprightMeaning: 'Competition, disagreement, conflict, tension',
        uprightMeaningTh: 'การแข่งขัน ความไม่ลงรอย ความขัดแย้ง ความตึงเครียด',
        reversedMeaning: 'End of conflict, cooperation, agreement',
        reversedMeaningTh: 'การสิ้นสุดความขัดแย้ง ความร่วมมือ ข้อตกลง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 70,
        name: 'Six of Wands',
        nameTh: 'หกแห่งไม้เท้า',
        suit: 'Wands',
        number: 6,
        imagePath: 'assets/images/tarot/six_of_wands.png',
        keywords: 'victory, success, achievement',
        keywordsTh: 'ชัยชนะ, ความสำเร็จ, ความสำราญ',
        uprightMeaning: 'Victory, success, achievement, recognition',
        uprightMeaningTh: 'ชัยชนะ ความสำเร็จ ความสำราญ การรับรู้ความสำเร็จ',
        reversedMeaning: 'Disappointment, failure, lack of recognition',
        reversedMeaningTh: 'ความพ่ายแพ้ ความล้มเหลว ความไม่รับรู้ความสำเร็จ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 71,
        name: 'Seven of Wands',
        nameTh: 'เจ็ดแห่งไม้เท้า',
        suit: 'Wands',
        number: 7,
        imagePath: 'assets/images/tarot/seven_of_wands.png',
        keywords: 'defensive stance, perseverance, holding ground',
        keywordsTh: 'การยืนยัน, การอดทน, การรักษาพื้นที่',
        uprightMeaning:
            'Defensive stance, perseverance, holding ground, strength',
        uprightMeaningTh: 'การยืนยัน การอดทน การรักษาพื้นที่ การมีแรงจำกัด',
        reversedMeaning: 'Loss of ground, retreat, vulnerability',
        reversedMeaningTh: 'การสูญเสียพื้นที่ การยืนยันลง ความอ่อนแอ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 72,
        name: 'Eight of Wands',
        nameTh: 'แปดแห่งไม้เท้า',
        suit: 'Wands',
        number: 8,
        imagePath: 'assets/images/tarot/eight_of_wands.png',
        keywords: 'swift movement, speed, urgency',
        keywordsTh: 'การเคลื่อนไหวเร็ว, ความเร็ว, ความเคลียร์',
        uprightMeaning: 'Swift movement, speed, urgency, efficiency',
        uprightMeaningTh:
            'การเคลื่อนไหวเร็ว ความเร็ว ความเคลียร์ การทำงานอย่างมีประสิทธิภาพ',
        reversedMeaning: 'Slowdown, delays, lack of urgency',
        reversedMeaningTh: 'การช้าลง ความเคลียร์ลดลง ความไม่เคลียร์',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 73,
        name: 'Nine of Wands',
        nameTh: 'เก้าแห่งไม้เท้า',
        suit: 'Wands',
        number: 9,
        imagePath: 'assets/images/tarot/nine_of_wands.png',
        keywords: 'resilience, endurance, holding on',
        keywordsTh: 'การต่อสู้, การอดทน, การรักษาพื้นที่',
        uprightMeaning: 'Resilience, endurance, holding on, strength',
        uprightMeaningTh: 'การต่อสู้ การอดทน การรักษาพื้นที่ การมีแรงจำกัด',
        reversedMeaning: 'Loss of strength, giving in, vulnerability',
        reversedMeaningTh: 'การสูญเสียแรงจำกัด การยอมรับลง ความอ่อนแอ',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 74,
        name: 'Ten of Wands',
        nameTh: 'สิบแห่งไม้เท้า',
        suit: 'Wands',
        number: 10,
        imagePath: 'assets/images/tarot/ten_of_wands.png',
        keywords: 'burden, responsibility, overwork',
        keywordsTh: 'ภาระ, ความรับผิดชอบ, ความหนัก',
        uprightMeaning: 'Burden, responsibility, overwork, exhaustion',
        uprightMeaningTh: 'ภาระ ความรับผิดชอบ ความหนัก ความกดดัน ความอดทน',
        reversedMeaning: 'Release of burden, relief, new beginning',
        reversedMeaningTh: 'การปล่อยภาระ การลดภาระ การเริ่มใหม่',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 75,
        name: 'Page of Wands',
        nameTh: 'แพจแห่งไม้เท้า',
        suit: 'Wands',
        number: 11,
        imagePath: 'assets/images/tarot/page_of_wands.png',
        keywords: 'exploration, adventure, new experiences',
        keywordsTh: 'การสำราญ, การสำราญ, การสำราญ',
        uprightMeaning: 'Exploration, adventure, new experiences, growth',
        uprightMeaningTh: 'การสำราญ การสำราญ การสำราญ การเจริญเติบโต',
        reversedMeaning: 'Setback, failure, discouragement',
        reversedMeaningTh: 'ความพ่ายแพ้ ความล้มเหลว ความยุคลินทรีย์',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 76,
        name: 'Knight of Wands',
        nameTh: 'ไนต์แห่งไม้เท้า',
        suit: 'Wands',
        number: 12,
        imagePath: 'assets/images/tarot/knight_of_wands.png',
        keywords: 'energetic, adventurous, confident',
        keywordsTh: 'ความมีพลัง, ความสำราญ, ความมั่งคั่ง',
        uprightMeaning: 'Energetic, adventurous, confident, leadership',
        uprightMeaningTh: 'ความมีพลัง ความสำราญ ความมั่งคั่ง การนำเสนอ',
        reversedMeaning: 'Impulsiveness, recklessness, lack of follow-up',
        reversedMeaningTh: 'ความประมาท ความก้าวร้าว การขาดทิศทาง',
        createdAt: now,
        updatedAt: now,
      ),
      TarotCard(
        id: 77,
        name: 'Queen of Wands',
        nameTh: 'ควีนแห่งไม้เท้า',
        suit: 'Wands',
        number: 13,
        imagePath: 'assets/images/tarot/queen_of_wands.png',
        keywords: 'courage, confidence, determination',
        keywordsTh: 'ความกล้าหาญ, ความมั่นใจ, ความมุ่งมั่น',
        uprightMeaning: 'Courage, confidence, determination, social butterfly',
        uprightMeaningTh:
            'ความกล้าหาญ ความมั่นใจ ความมุ่งมั่น การเข้าสังคมเก่ง',
        reversedMeaning: 'Demanding, vengeful, intolerant',
        reversedMeaningTh: 'เรียกร้อง แก้แค้น ไม่ยอมรับ',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<void> _loadUserZodiacSign() async {
    final user = _authService.currentUser;
    if (user != null && user.userMetadata != null) {
      if (user.userMetadata!['zodiac_sign'] != null) {
        setState(() {
          _userZodiacSign = user.userMetadata!['zodiac_sign'] as String;
          _userZodiacSignThai = ZodiacUtils.getZodiacSignThai(
              DateTime(2000, 1, 1),
              zodiacSign: _userZodiacSign);
        });
      } else if (user.userMetadata!['birth_date'] != null) {
        final birthDate =
            DateTime.parse(user.userMetadata!['birth_date'] as String);
        setState(() {
          _userZodiacSign = ZodiacUtils.getZodiacSign(birthDate);
          _userZodiacSignThai = ZodiacUtils.getZodiacSignThai(birthDate);
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
      // สร้างรายการไพ่พร้อมความหมาย
      final List<String> cardsWithMeanings =
          _selectedCards.asMap().entries.map((entry) {
        final index = entry.key;
        final card = entry.value;
        final isReversed = _isCardReversed[index];
        final meaning =
            isReversed ? card.reversedMeaningTh : card.uprightMeaningTh;
        return '${card.nameTh} (${isReversed ? "คว่ำ" : "หงาย"}): $meaning';
      }).toList();

      // สร้าง prompt สำหรับ AI
      final prompt = '''
      ช่วยตีความการอ่านไพ่ทาโรต์ต่อไปนี้:

      รูปแบบการอ่าน: ${_getSpreadTypeText()}
      คำถาม: ${_questionController.text}
      ไพ่ที่เลือก:
      ${cardsWithMeanings.join('\n')}
      ${_userZodiacSignThai != null ? '\nราศีของผู้ถาม: $_userZodiacSignThai' : ''}

      กรุณาตีความให้ครอบคลุม:
      1. ความหมายรวมของไพ่ทั้งหมด
      2. ความสัมพันธ์ระหว่างไพ่แต่ละใบ
      3. คำแนะนำสำหรับผู้ถาม
      4. ${_userZodiacSignThai != null ? 'อิทธิพลของราศีต่อการตีความ' : ''}
      ''';

      // เรียกใช้ OpenAI API
      final response = await _openAIService.sendMessage(
        prompt: prompt,
        history: [],
        temperature: 0.9,
      );

      // แยกข้อความคำทำนายจาก response
      final content = response['content'][0]['text'];

      setState(() {
        _interpretation = content;
        _isLoading = false;
      });

      // บันทึกการอ่าน
      _saveTarotReading({
        'overall': content,
        'cards': cardsWithMeanings,
        'question': _questionController.text,
        'spread_type': _spreadType,
        'zodiac_sign': _userZodiacSignThai,
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถตีความไพ่ได้: ${e.toString()}')),
      );
    }
  }

  String _getSpreadTypeText() {
    switch (_spreadType) {
      case 'single':
        return 'ไพ่ 1 ใบ';
      case 'three':
        return 'ไพ่ 3 ใบ (อดีต ปัจจุบัน อนาคต)';
      case 'cross':
        return 'ไพ่กางเขน';
      case 'celtic':
        return 'ไพ่เซลติก';
      default:
        return 'ไพ่ 1 ใบ';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกการอ่านไพ่เรียบร้อยแล้ว')),
      );
    } catch (e) {
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
      appBar: AppBar(
        title: const Text('การอ่านไพ่ทาโร่'),
        backgroundColor: AppColors.darkSurface,
      ),
      body: _isLoading
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
                  if (_userZodiacSignThai != null) _buildZodiacInfo(),
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
    );
  }

  Widget _buildSpreadTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เลือกรูปแบบการอ่านไพ่',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
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
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.darkSurface.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightText.withOpacity(0.7),
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
        Text(
          'คำถามหรือประเด็นที่ต้องการคำตอบ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _questionController,
          decoration: InputDecoration(
            hintText: 'พิมพ์คำถามของคุณที่นี่...',
            hintStyle: TextStyle(color: AppColors.lightText.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.darkSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(color: AppColors.lightText),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildZodiacInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ราศีของคุณ: $_userZodiacSignThai',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'การตีความไพ่จะคำนึงถึงราศีของคุณเพื่อให้คำทำนายที่แม่นยำยิ่งขึ้น',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.lightText.withOpacity(0.8),
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
        gradient: LinearGradient(
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
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 48,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'กำลังสับไพ่...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
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
        gradient: LinearGradient(
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
        Text(
          'ไพ่ของคุณ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
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
        width: 120,
        height: 200,
        decoration: BoxDecoration(
          color: isRevealed ? Colors.white : AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isRevealed
            ? Transform.rotate(
                angle: isReversed ? pi : 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          _selectedCards[index].imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // แสดงไอคอนเมื่อไม่สามารถโหลดรูปภาพได้
                            return Icon(
                              Icons.auto_awesome,
                              color: AppColors.primary,
                              size: 32,
                            );
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        color: AppColors.primary.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            Text(
                              _selectedCards[index].nameTh,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (isReversed)
                              const Text(
                                '(กลับหัว)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.7),
                        AppColors.secondary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 48,
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
        Text(
          'คำทำนาย',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.lightText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userZodiacSignThai != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'สำหรับผู้ที่เกิด$_userZodiacSignThai',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              Text(
                _interpretation ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.lightText,
                  height: 1.5,
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
            gradient: LinearGradient(
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
                            AppColors.primary.withOpacity(0.2),
                            AppColors.secondary.withOpacity(0.2),
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
                            color: AppColors.primary.withOpacity(0.3),
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
                                          AppColors.primary.withOpacity(0.3),
                                          AppColors.secondary.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // ไอคอน
                            Center(
                              child: Icon(
                                Icons.auto_awesome,
                                color: AppColors.primary,
                                size: 48,
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'กำลังวิเคราะห์ความหมายและความสัมพันธ์ของไพ่',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.lightText.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
