import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/exceptions.dart' as app_exceptions;

/// Mock implementation of TarotRepository for development and testing
class MockTarotRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  
  MockTarotRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  }) : _apiClient = apiClient, _prefs = prefs;
  
  Future<List<TarotReading>> getUserTarotReadings() async {
    try {
      // จำลองการดึงข้อมูลจาก API
      await Future.delayed(const Duration(seconds: 1));
      
      return _generateMockTarotReadings();
    } catch (e) {
      throw app_exceptions.DataException('Failed to get user tarot readings: ${e.toString()}');
    }
  }
  
  Future<TarotReading> getTarotReadingById(int id) async {
    try {
      // จำลองการดึงข้อมูลจาก API
      await Future.delayed(const Duration(milliseconds: 500));
      
      final readings = _generateMockTarotReadings();
      final reading = readings.firstWhere(
        (reading) => reading.id == id,
        orElse: () => throw app_exceptions.DataException('Tarot reading not found: $id'),
      );
      
      return reading;
    } catch (e) {
      throw app_exceptions.DataException('Failed to get tarot reading: ${e.toString()}');
    }
  }
  
  List<TarotReading> _generateMockTarotReadings() {
    final List<TarotReading> readings = [];
    
    final spreadTypes = ['single', 'three', 'cross', 'celtic'];
    final questions = [
      'ฉันควรเปลี่ยนงานหรือไม่?',
      'ความสัมพันธ์ของฉันจะเป็นอย่างไรในอนาคต?',
      'ฉันควรย้ายที่อยู่หรือไม่?',
      'อะไรคือสิ่งที่ฉันควรให้ความสำคัญในตอนนี้?',
      'ฉันจะประสบความสำเร็จในโครงการนี้หรือไม่?',
      null, // บางครั้งไม่มีคำถาม
    ];
    
    for (int i = 1; i <= 10; i++) {
      final spreadType = spreadTypes[i % spreadTypes.length];
      final question = questions[i % questions.length];
      final createdAt = DateTime.now().subtract(Duration(days: i * 3));
      
      readings.add(
        TarotReading(
          id: i,
          userId: 1,
          spreadType: spreadType,
          question: question,
          cards: _generateMockCards(spreadType),
          interpretation: _generateMockInterpretation(spreadType),
          isSaved: i % 3 == 0, // บางรายการถูกบันทึก
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
    }
    
    return readings;
  }
  
  List<TarotCardPosition> _generateMockCards(String spreadType) {
    final List<TarotCardPosition> cards = [];
    
    int cardCount;
    switch (spreadType) {
      case 'single':
        cardCount = 1;
        break;
      case 'three':
        cardCount = 3;
        break;
      case 'cross':
        cardCount = 5;
        break;
      case 'celtic':
        cardCount = 10;
        break;
      default:
        cardCount = 3;
    }
    
    final positions = [
      'ปัจจุบัน',
      'อดีต',
      'อนาคต',
      'สิ่งที่ส่งผลกระทบ',
      'อุปสรรค',
      'สิ่งที่ควรทำ',
      'สภาพแวดล้อม',
      'ความหวัง',
      'ความกลัว',
      'ผลลัพธ์',
    ];
    
    for (int i = 0; i < cardCount; i++) {
      cards.add(
        TarotCardPosition(
          card: _generateMockCard(i),
          position: positions[i],
          isReversed: i % 2 == 0,
          meaning: 'ความหมายของไพ่ในตำแหน่ง${positions[i]}',
        ),
      );
    }
    
    return cards;
  }
  
  TarotCard _generateMockCard(int index) {
    final cardNames = [
      'The Fool',
      'The Magician',
      'The High Priestess',
      'The Empress',
      'The Emperor',
      'The Hierophant',
      'The Lovers',
      'The Chariot',
      'Strength',
      'The Hermit',
    ];
    
    final cardNamesTh = [
      'คนโง่',
      'นักเวทย์',
      'มหาปุโรหิตหญิง',
      'จักรพรรดินี',
      'จักรพรรดิ',
      'ผู้นำทางศาสนา',
      'คู่รัก',
      'รถศึก',
      'พลัง',
      'ฤๅษี',
    ];
    
    final suits = ['Major Arcana', 'Cups', 'Wands', 'Swords', 'Pentacles'];
    
    return TarotCard(
      id: index + 1,
      name: cardNames[index % cardNames.length],
      nameTh: cardNamesTh[index % cardNamesTh.length],
      suit: suits[index % suits.length],
      number: index % 22,
      imagePath: 'assets/images/tarot/${index + 1}.png',
      keywords: 'keyword1, keyword2, keyword3',
      keywordsTh: 'คำสำคัญ1, คำสำคัญ2, คำสำคัญ3',
      uprightMeaning: 'Upright meaning of the card',
      uprightMeaningTh: 'ความหมายของไพ่เมื่อหงายขึ้น',
      reversedMeaning: 'Reversed meaning of the card',
      reversedMeaningTh: 'ความหมายของไพ่เมื่อคว่ำลง',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }
  
  String _generateMockInterpretation(String spreadType) {
    switch (spreadType) {
      case 'single':
        return 'ไพ่นี้บ่งบอกว่าคุณกำลังอยู่ในช่วงเริ่มต้นของการเดินทางใหม่ในชีวิต คุณมีพลังและความกระตือรือร้นที่จะก้าวไปข้างหน้า แต่ควรระมัดระวังและคิดให้รอบคอบก่อนตัดสินใจ';
      case 'three':
        return 'ในอดีตคุณเคยประสบกับความท้าทายและอุปสรรคมากมาย ปัจจุบันคุณกำลังอยู่ในช่วงของการเปลี่ยนแปลงและการเติบโต ในอนาคตคุณจะพบกับโอกาสใหม่ๆ ที่จะนำไปสู่ความสำเร็จ แต่ต้องอาศัยความอดทนและความมุ่งมั่น';
      case 'cross':
        return 'สถานการณ์ปัจจุบันของคุณกำลังอยู่ในช่วงของความไม่แน่นอน มีอุปสรรคที่ต้องเผชิญ แต่คุณมีพลังภายในที่จะช่วยให้คุณผ่านพ้นไปได้ คุณควรเชื่อมั่นในตัวเองและตัดสินใจด้วยสัญชาตญาณ ผลลัพธ์สุดท้ายจะเป็นไปในทางที่ดี หากคุณยังคงมุ่งมั่นและไม่ย่อท้อ';
      case 'celtic':
        return 'การอ่านไพ่แบบเซลติกครอสนี้แสดงให้เห็นว่าคุณกำลังอยู่ในช่วงของการเปลี่ยนแปลงครั้งสำคัญในชีวิต ปัจจุบันคุณกำลังเผชิญกับความท้าทายที่ต้องใช้ทั้งสติปัญญาและความอดทน อดีตของคุณมีประสบการณ์ที่สอนให้คุณเข้มแข็งและรู้จักปรับตัว อนาคตมีแนวโน้มที่ดี แต่ต้องอาศัยการตัดสินใจที่ถูกต้องในปัจจุบัน สิ่งที่ส่งผลกระทบต่อสถานการณ์คือความกังวลและความกลัวของคุณเอง อุปสรรคที่คุณต้องเผชิญคือการขาดความเชื่อมั่นในตัวเอง สิ่งที่ควรทำคือการเปิดใจและยอมรับการเปลี่ยนแปลง สภาพแวดล้อมรอบตัวคุณมีผู้คนที่พร้อมให้การสนับสนุน ความหวังของคุณสามารถเป็นจริงได้หากคุณลงมือทำอย่างจริงจัง ความกลัวที่คุณมีเป็นเพียงสิ่งที่คุณสร้างขึ้นในใจ ผลลัพธ์สุดท้ายจะเป็นไปในทางที่ดีหากคุณเชื่อมั่นในตัวเองและก้าวไปข้างหน้าอย่างมั่นคง';
      default:
        return 'คำทำนายจากไพ่ทาโร่';
    }
  }
} 