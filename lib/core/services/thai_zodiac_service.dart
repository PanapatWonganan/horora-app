class ThaiZodiac {
  final String animalName; // ชวด, ฉลู, ขาล...
  final String thaiName; // ปีชวด, ปีฉลู...
  final String englishName; // Year of Rat, Ox...
  final String element; // ทอง, น้ำ, ไม้, ไฟ, ดิน
  final String elementThai; // ธาตุทอง, ธาตุน้ำ...
  final List<String> luckyColors;
  final List<int> luckyNumbers;
  final String characteristics;
  final String compatibility;

  const ThaiZodiac({
    required this.animalName,
    required this.thaiName,
    required this.englishName,
    required this.element,
    required this.elementThai,
    required this.luckyColors,
    required this.luckyNumbers,
    required this.characteristics,
    required this.compatibility,
  });
}

class ThaiZodiacService {
  // รายการปีนักษัตร 12 ปี
  static const List<Map<String, dynamic>> _zodiacAnimals = [
    {
      'animal': 'วอก',
      'thai': 'ปีวอก',
      'english': 'Year of Monkey',
      'characteristics': 'ฉลาด เก่ง มีไหวพริบ ชอบเปลี่ยนแปลง มีจิตใจเปิดกว้าง',
      'compatibility': 'เข้ากันดีกับปีชวด ปีมะโรง',
    },
    {
      'animal': 'ระกา',
      'thai': 'ปีระกา',
      'english': 'Year of Rooster',
      'characteristics': 'ตรงไปตรงมา รักความสะอาด มีระเบียบแบบแผน ชอบความสวยงาม',
      'compatibility': 'เข้ากันดีกับปีฉลู ปีมะเส็ง',
    },
    {
      'animal': 'จอ',
      'thai': 'ปีจอ',
      'english': 'Year of Dog',
      'characteristics': 'ซื่อสัตย์ จริงใจ มีความรับผิดชอบสูง รักครอบครัว',
      'compatibility': 'เข้ากันดีกับปีเถาะ ปีมะเมีย',
    },
    {
      'animal': 'กุน',
      'thai': 'ปีกุน',
      'english': 'Year of Pig',
      'characteristics': 'ใจกว้าง เอื้อเฟื้อ มีน้ำใจ รักความสุขสบาย',
      'compatibility': 'เข้ากันดีกับปีเถาะ ปีมะแม',
    },
    {
      'animal': 'ชวด',
      'thai': 'ปีชวด',
      'english': 'Year of Rat',
      'characteristics': 'ขยัน อดทน รอบคอบ มีไหวพริบ เก็บเงินเก่ง',
      'compatibility': 'เข้ากันดีกับปีฉลู ปีมะโรง',
    },
    {
      'animal': 'ฉลู',
      'thai': 'ปีฉลู',
      'english': 'Year of Ox',
      'characteristics': 'อดทน มั่นคง เชื่อถือได้ ทำงานหนัก รักความมั่นคง',
      'compatibility': 'เข้ากันดีกับปีชวด ปีมะเส็ง',
    },
    {
      'animal': 'ขาล',
      'thai': 'ปีขาล',
      'english': 'Year of Tiger',
      'characteristics': 'กล้าหาญ มีความเป็นผู้นำ อิสระ ชอบการผจญภัย',
      'compatibility': 'เข้ากันดีกับปีมะเมีย ปีจอ',
    },
    {
      'animal': 'เถาะ',
      'thai': 'ปีเถาะ',
      'english': 'Year of Rabbit',
      'characteristics': 'อ่อนโยน มีมารยาท รักสันติ ชอบความงาม',
      'compatibility': 'เข้ากันดีกับปีมะแม ปีกุน',
    },
    {
      'animal': 'มะโรง',
      'thai': 'ปีมะโรง',
      'english': 'Year of Dragon',
      'characteristics': 'ทะเยอทะยาน มีพลัง มั่นใจ ชอบเป็นที่สนใจ',
      'compatibility': 'เข้ากันดีกับปีชวด ปีวอก',
    },
    {
      'animal': 'มะเส็ง',
      'thai': 'ปีมะเส็ง',
      'english': 'Year of Snake',
      'characteristics': 'ลึกซึ้ง ปัญญาดี ชอบการเรียนรู้ มีสัญชาตญาณ',
      'compatibility': 'เข้ากันดีกับปีฉลู ปีระกา',
    },
    {
      'animal': 'มะเมีย',
      'thai': 'ปีมะเมีย',
      'english': 'Year of Horse',
      'characteristics': 'กระฉับกระเฉง รักเสรีภาพ ตรงไปตรงมา ชอบเดินทาง',
      'compatibility': 'เข้ากันดีกับปีขาล ปีจอ',
    },
    {
      'animal': 'มะแม',
      'thai': 'ปีมะแม',
      'english': 'Year of Goat',
      'characteristics': 'อ่อนโยน ศิลปิน ชอบความงาม มีจิตใจนุ่มนวล',
      'compatibility': 'เข้ากันดีกับปีเถาะ ปีกุน',
    },
  ];

  // รายการธาตุ 5 ธาตุ (10 ปี รอบ)
  static const List<String> _elements = [
    'ทอง', 'ทอง', // ปีที่ 0,1
    'น้ำ', 'น้ำ',   // ปีที่ 2,3
    'ไม้', 'ไม้',   // ปีที่ 4,5
    'ไฟ', 'ไฟ',   // ปีที่ 6,7
    'ดิน', 'ดิน',  // ปีที่ 8,9
  ];

  // สีมงคลตามธาตุ
  static const Map<String, List<String>> _elementColors = {
    'ทอง': ['ทอง', 'เงิน', 'ขาว', 'เทา'],
    'น้ำ': ['น้ำเงิน', 'ดำ', 'เทาเข้ม'],
    'ไม้': ['เขียว', 'เขียวเข้ม', 'เขียวอ่อน'],
    'ไฟ': ['แดง', 'ส้ม', 'ชมพู', 'ม่วงแดง'],
    'ดิน': ['เหลือง', 'น้ำตาล', 'ครีม', 'เบจ'],
  };

  // เลขมงคลตามปีนักษัตร
  static const Map<String, List<int>> _animalNumbers = {
    'ชวด': [1, 6, 11, 16],
    'ฉลู': [2, 7, 12, 17],
    'ขาล': [3, 8, 13, 18],
    'เถาะ': [4, 9, 14, 19],
    'มะโรง': [5, 10, 15, 20],
    'มะเส็ง': [1, 6, 11, 21],
    'มะเมีย': [2, 7, 12, 22],
    'มะแม': [3, 8, 13, 23],
    'วอก': [4, 9, 14, 24],
    'ระกา': [5, 10, 15, 25],
    'จอ': [1, 6, 16, 26],
    'กุน': [2, 7, 17, 27],
  };

  /// คำนวณปีนักษัตรจากปี ค.ศ.
  static ThaiZodiac getThaiZodiac(int year) {
    // ปี 1984 = ชวด (index 4 ใน array), ใช้เป็นปีฐาน
    // การคำนวณ: (year - 1984 + 4) % 12 = array index
    final animalIndex = (year - 1984 + 4) % 12;
    final elementIndex = year % 10;
    
    final animal = _zodiacAnimals[animalIndex];
    final element = _elements[elementIndex];
    final elementThai = 'ธาตุ$element';
    
    return ThaiZodiac(
      animalName: animal['animal'],
      thaiName: animal['thai'],
      englishName: animal['english'],
      element: element,
      elementThai: elementThai,
      luckyColors: _elementColors[element] ?? [],
      luckyNumbers: _animalNumbers[animal['animal']] ?? [],
      characteristics: animal['characteristics'],
      compatibility: animal['compatibility'],
    );
  }

  /// คำนวณปีนักษัตรจากวันเกิด
  static ThaiZodiac getThaiZodiacFromDate(DateTime birthDate) {
    return getThaiZodiac(birthDate.year);
  }

  /// ตรวจสอบความเข้ากันได้ระหว่าง 2 ปี
  static String getCompatibility(ThaiZodiac zodiac1, ThaiZodiac zodiac2) {
    // Logic ความเข้ากันได้แบบง่าย
    final compatible1 = zodiac1.compatibility.contains(zodiac2.animalName);
    final compatible2 = zodiac2.compatibility.contains(zodiac1.animalName);
    
    if (compatible1 || compatible2) {
      return 'เข้ากันดีมาก มีความสุขร่วมกัน';
    } else if (zodiac1.element == zodiac2.element) {
      return 'เข้ากันได้ดี ธาตุเดียวกัน เข้าใจกัน';
    } else {
      return 'เข้ากันได้ปานกลาง ต้องพยายามทำความเข้าใจกัน';
    }
  }

  /// สร้างคำทำนายดวงรายวัน
  static Map<String, dynamic> getDailyFortune(ThaiZodiac zodiac, DateTime date) {
    // คำนวณดวงจากวันในสัปดาห์ + เดือน
    final weekday = date.weekday;
    final month = date.month;
    final day = date.day;
    
    // สูตรการคำนวณแบบง่าย (สามารถปรับปรุงให้ซับซ้อนขึ้น)
    final luckScore = ((day + month + weekday) % 5) + 1;
    final loveScore = ((day * 2 + month) % 5) + 1;
    final careerScore = ((day + month * 2) % 5) + 1;
    final healthScore = ((day + month + weekday * 2) % 5) + 1;
    
    // เลขมงคลประจำวัน
    final todayLuckyNumber = zodiac.luckyNumbers[(day % zodiac.luckyNumbers.length)];
    
    // สีมงคลประจำวัน
    final todayLuckyColor = zodiac.luckyColors[(weekday - 1) % zodiac.luckyColors.length];
    
    return {
      'overall_luck': luckScore,
      'love': loveScore,
      'career': careerScore,
      'health': healthScore,
      'lucky_number': todayLuckyNumber,
      'lucky_color': todayLuckyColor,
      'zodiac': zodiac,
    };
  }

  /// รายการปีนักษัตรทั้งหมด
  static List<String> getAllAnimals() {
    return _zodiacAnimals.map((animal) => animal['animal'] as String).toList();
  }

  /// รายการธาตุทั้งหมด
  static List<String> getAllElements() {
    return ['ทอง', 'น้ำ', 'ไม้', 'ไฟ', 'ดิน'];
  }
}