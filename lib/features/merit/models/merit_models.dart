/// Models สำหรับระบบทำบุญออนไลน์

/// วันในสัปดาห์สำหรับตารางการไปมู
enum MeritDay {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension MeritDayX on MeritDay {
  String get displayName {
    switch (this) {
      case MeritDay.monday:
        return 'วันจันทร์';
      case MeritDay.tuesday:
        return 'วันอังคาร';
      case MeritDay.wednesday:
        return 'วันพุธ';
      case MeritDay.thursday:
        return 'วันพฤหัสบดี';
      case MeritDay.friday:
        return 'วันศุกร์';
      case MeritDay.saturday:
        return 'วันเสาร์';
      case MeritDay.sunday:
        return 'วันอาทิตย์';
    }
  }

  String get shortName {
    switch (this) {
      case MeritDay.monday:
        return 'จ.';
      case MeritDay.tuesday:
        return 'อ.';
      case MeritDay.wednesday:
        return 'พ.';
      case MeritDay.thursday:
        return 'พฤ.';
      case MeritDay.friday:
        return 'ศ.';
      case MeritDay.saturday:
        return 'ส.';
      case MeritDay.sunday:
        return 'อา.';
    }
  }

  int get weekdayNumber {
    switch (this) {
      case MeritDay.monday:
        return 1;
      case MeritDay.tuesday:
        return 2;
      case MeritDay.wednesday:
        return 3;
      case MeritDay.thursday:
        return 4;
      case MeritDay.friday:
        return 5;
      case MeritDay.saturday:
        return 6;
      case MeritDay.sunday:
        return 7;
    }
  }

  static MeritDay fromWeekday(int weekday) {
    return MeritDay.values.firstWhere(
      (e) => e.weekdayNumber == weekday,
      orElse: () => MeritDay.monday,
    );
  }
}

/// ตารางการไปมูประจำสัปดาห์
class WeeklyMeritSchedule {
  final MeritDay day;
  final String locationId;
  final String locationName;
  final String belief;
  final List<MeritOfferingItem> requiredItems;
  final List<MeritAddon> addons;
  final bool isActive;

  const WeeklyMeritSchedule({
    required this.day,
    required this.locationId,
    required this.locationName,
    required this.belief,
    required this.requiredItems,
    required this.addons,
    this.isActive = true,
  });

  /// ตารางการไปมูประจำสัปดาห์ (Default)
  static List<WeeklyMeritSchedule> get defaultSchedule => [
    // วันจันทร์ - ศาลหลักเมือง
    WeeklyMeritSchedule(
      day: MeritDay.monday,
      locationId: 'city_pillar',
      locationName: 'ศาลหลักเมือง',
      belief: 'ความสำเร็จ การงาน ความมั่นคง',
      requiredItems: [
        const MeritOfferingItem(id: 'incense_3', name: 'ธูป 3 ดอก', isRequired: true),
        const MeritOfferingItem(id: 'candle_1', name: 'เทียน 1 เล่ม', isRequired: true),
        const MeritOfferingItem(id: 'gold_leaf', name: 'ทองคำเปลว', isRequired: true),
        const MeritOfferingItem(id: 'lotus', name: 'ดอกบัว', isRequired: true),
      ],
      addons: [
        const MeritAddon(
          id: 'lamp_oil',
          name: 'น้ำมันเติมตะเกียง',
          description: 'สื่อถึงการต่อช่วงโชติช่วงชัชวาล',
          price: 99,
        ),
        const MeritAddon(
          id: 'silk_3_colors',
          name: 'ผ้าแพร 3 สี',
          description: 'ผ้าแพรมงคล 3 สี ถวายเพื่อเสริมบารมี',
          price: 199,
        ),
      ],
    ),
    // วันอังคาร - ศาลเจ้าพ่อเสือ
    WeeklyMeritSchedule(
      day: MeritDay.tuesday,
      locationId: 'tiger_shrine',
      locationName: 'ศาลเจ้าพ่อเสือ',
      belief: 'โชคลาภ การค้าขาย ป้องกันภัย',
      requiredItems: [
        const MeritOfferingItem(id: 'pork_belly', name: 'หมูสามชั้นดิบ', isRequired: true),
        const MeritOfferingItem(id: 'raw_egg', name: 'ไข่ไก่ดิบ', isRequired: true),
        const MeritOfferingItem(id: 'sticky_rice_sweet', name: 'ข้าวเหนียวหวาน', isRequired: true),
      ],
      addons: [
        const MeritAddon(
          id: 'joss_paper',
          name: 'กระดาษไหว้เจ้า',
          description: 'เผาเพื่อส่งคำขอถึงเจ้าพ่อเสือ',
          price: 129,
        ),
        const MeritAddon(
          id: 'lucky_orange',
          name: 'ส้มมงคล 4 ลูก',
          description: 'ส้มมงคลนำโชค เสริมความเป็นสิริมงคล',
          price: 79,
        ),
        const MeritAddon(
          id: 'indian_incense',
          name: 'ธูปหอมอินเดีย',
          description: 'ธูปหอมเฉพาะจากอินเดีย',
          price: 149,
        ),
      ],
    ),
    // วันพุธ - พระพิฆเนศ ห้วยขวาง
    WeeklyMeritSchedule(
      day: MeritDay.wednesday,
      locationId: 'ganesha_huaykwang',
      locationName: 'พระพิฆเนศ ห้วยขวาง',
      belief: 'การศึกษา ศิลปะ ความสำเร็จ',
      requiredItems: [
        const MeritOfferingItem(id: 'incense_9', name: 'ธูป 9 ดอก', isRequired: true),
        const MeritOfferingItem(id: 'candle_1', name: 'เทียน 1 เล่ม', isRequired: true),
        const MeritOfferingItem(id: 'garland_jasmine', name: 'พวงมาลัยดอกมะลิ', isRequired: true),
        const MeritOfferingItem(id: 'banana', name: 'กล้วยน้ำว้า', isRequired: true),
      ],
      addons: [
        const MeritAddon(
          id: 'modak',
          name: 'ขนมโมทกะ',
          description: 'ขนมโปรดของพระพิฆเนศ',
          price: 149,
        ),
        const MeritAddon(
          id: 'red_cloth',
          name: 'ผ้าแดงถวาย',
          description: 'ผ้าแดงมงคลสำหรับพระพิฆเนศ',
          price: 199,
        ),
        const MeritAddon(
          id: 'durva_grass',
          name: 'หญ้าแพรก',
          description: 'หญ้าศักดิ์สิทธิ์สำหรับบูชา',
          price: 79,
        ),
      ],
    ),
    // วันพฤหัสบดี - วัดระฆังโฆสิตาราม (หลวงพ่อโต)
    WeeklyMeritSchedule(
      day: MeritDay.thursday,
      locationId: 'wat_rakang',
      locationName: 'วัดระฆังโฆสิตาราม',
      belief: 'โชคลาภ การเงิน ค้าขายร่ำรวย',
      requiredItems: [
        const MeritOfferingItem(id: 'incense_9', name: 'ธูป 9 ดอก', isRequired: true),
        const MeritOfferingItem(id: 'candle_2', name: 'เทียน 2 เล่ม', isRequired: true),
        const MeritOfferingItem(id: 'lotus_9', name: 'ดอกบัว 9 ดอก', isRequired: true),
        const MeritOfferingItem(id: 'gold_leaf', name: 'ทองคำเปลว', isRequired: true),
      ],
      addons: [
        const MeritAddon(
          id: 'bell_offering',
          name: 'ตีระฆังขอพร',
          description: 'ตีระฆังส่งเสียงถึงสวรรค์',
          price: 99,
        ),
        const MeritAddon(
          id: 'sanghathan',
          name: 'ชุดสังฆทาน',
          description: 'ถวายสังฆทานเสริมบุญ',
          price: 299,
        ),
      ],
    ),
    // วันศุกร์ - วัดเล่งเน่ยยี่ (วัดมังกรกมลาวาส) - เจ้าแม่กวนอิม
    WeeklyMeritSchedule(
      day: MeritDay.friday,
      locationId: 'wat_leng_noei_yi',
      locationName: 'วัดเล่งเน่ยยี่ (วัดมังกรกมลาวาส)',
      belief: 'เจ้าแม่กวนอิม - สุขภาพ ลูกหลาน ครอบครัว ขอบุตร',
      requiredItems: [
        const MeritOfferingItem(id: 'incense_3', name: 'ธูป 3 ดอก', isRequired: true),
        const MeritOfferingItem(id: 'candle_2', name: 'เทียน 2 เล่ม', isRequired: true),
        const MeritOfferingItem(id: 'fruit_5', name: 'ผลไม้ 5 อย่าง', isRequired: true),
        const MeritOfferingItem(id: 'flower_white', name: 'ดอกไม้สีขาว', isRequired: true),
      ],
      addons: [
        const MeritAddon(
          id: 'vegetarian_set',
          name: 'ชุดอาหารเจ',
          description: 'อาหารเจถวายเจ้าแม่กวนอิม',
          price: 199,
        ),
        const MeritAddon(
          id: 'tea_offering',
          name: 'ชาถวาย 3 ถ้วย',
          description: 'ชาหอมถวายเจ้าแม่',
          price: 79,
        ),
        const MeritAddon(
          id: 'joss_paper_gold',
          name: 'กระดาษทอง',
          description: 'กระดาษทองเผาถวาย',
          price: 149,
        ),
      ],
    ),
    // วันเสาร์ - ท้าวเวสสุวรรณ วัดจุฬามณี (สำเพ็ง)
    WeeklyMeritSchedule(
      day: MeritDay.saturday,
      locationId: 'vessavana_sampheng',
      locationName: 'ท้าวเวสสุวรรณ วัดจุฬามณี (สำเพ็ง)',
      belief: 'ป้องกันภัย โชคลาภ เสริมดวง',
      requiredItems: [
        const MeritOfferingItem(id: 'incense_9', name: 'ธูป 9 ดอก', isRequired: true),
        const MeritOfferingItem(id: 'candle_2', name: 'เทียน 2 เล่ม', isRequired: true),
        const MeritOfferingItem(id: 'red_water', name: 'น้ำแดง', isRequired: true),
        const MeritOfferingItem(id: 'garland_red', name: 'พวงมาลัยสีแดง', isRequired: true),
      ],
      addons: [
        const MeritAddon(
          id: 'yantra',
          name: 'ผ้ายันต์ท้าวเวสสุวรรณ',
          description: 'ผ้ายันต์ป้องกันภัย',
          price: 299,
        ),
        const MeritAddon(
          id: 'gold_leaf_9',
          name: 'ทองคำเปลว 9 แผ่น',
          description: 'ปิดทององค์ท้าวเวสสุวรรณ',
          price: 199,
        ),
      ],
    ),
    // วันอาทิตย์ - ท้าวมหาพรหม เอราวัณ
    WeeklyMeritSchedule(
      day: MeritDay.sunday,
      locationId: 'brahma_erawan',
      locationName: 'ท้าวมหาพรหม เอราวัณ',
      belief: 'ขอพรทุกด้าน โชคลาภ ความสำเร็จ',
      requiredItems: [
        const MeritOfferingItem(id: 'garland_7_colors', name: 'มาลัยเจ็ดสีเจ็ดศอก 4 พวง (4 พักตร์)', isRequired: true),
        const MeritOfferingItem(id: 'incense_12', name: 'ธูป 12 ดอก', isRequired: true),
        const MeritOfferingItem(id: 'candle_4', name: 'เทียน 4 เล่ม', isRequired: true),
      ],
      addons: [
        const MeritAddon(
          id: 'thai_dance',
          name: 'รำถวาย',
          description: 'รำถวายบูชาองค์พระพรหม',
          price: 599,
        ),
        const MeritAddon(
          id: 'gold_elephant',
          name: 'ช้างทองคำเปลว',
          description: 'ช้างมงคลปิดทองคำเปลว',
          price: 299,
        ),
      ],
    ),
  ];
}

/// รายการของไหว้
class MeritOfferingItem {
  final String id;
  final String name;
  final String? description;
  final bool isRequired;

  const MeritOfferingItem({
    required this.id,
    required this.name,
    this.description,
    this.isRequired = false,
  });
}

/// Add-on สำหรับเพิ่มเติมชุดไหว้
class MeritAddon {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;

  const MeritAddon({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
  });

  String get priceFormatted => '฿${price.toStringAsFixed(0)}';
}

class MeritLocation {
  final String id;
  final String nameTh;
  final String? nameEn;
  final String? description;
  final String? belief;
  final String? address;
  final String? imageUrl;
  final bool isActive;
  final int sortOrder;

  const MeritLocation({
    required this.id,
    required this.nameTh,
    this.nameEn,
    this.description,
    this.belief,
    this.address,
    this.imageUrl,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory MeritLocation.fromJson(Map<String, dynamic> json) {
    return MeritLocation(
      id: json['id']?.toString() ?? '',
      nameTh: json['name_th']?.toString() ?? '',
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      belief: json['belief'] as String?,
      address: json['address'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_th': nameTh,
      'name_en': nameEn,
      'description': description,
      'belief': belief,
      'address': address,
      'image_url': imageUrl,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  // Default locations (fallback when offline)
  static List<MeritLocation> get defaultLocations => [
    const MeritLocation(
      id: 'erawan',
      nameTh: 'ศาลพระพรหม เอราวัณ',
      nameEn: 'Erawan Shrine',
      description: 'ศาลพระพรหมที่มีชื่อเสียงที่สุดในประเทศไทย',
      belief: 'ขอพรทุกด้าน โชคลาภ ความสำเร็จ',
      sortOrder: 1,
    ),
    const MeritLocation(
      id: 'city_pillar',
      nameTh: 'ศาลหลักเมือง',
      nameEn: 'City Pillar Shrine',
      description: 'ศาลหลักเมืองกรุงเทพมหานคร',
      belief: 'ความสำเร็จ การงาน ความมั่นคง',
      sortOrder: 2,
    ),
    const MeritLocation(
      id: 'wat_rakang',
      nameTh: 'วัดระฆังโฆสิตาราม',
      nameEn: 'Wat Rakang',
      description: 'วัดเก่าแก่ริมแม่น้ำเจ้าพระยา',
      belief: 'การเงิน โชคลาภ ค้าขาย',
      sortOrder: 3,
    ),
    const MeritLocation(
      id: 'ganesha_central',
      nameTh: 'พระพิฆเนศ เซ็นทรัลเวิลด์',
      nameEn: 'Ganesha Central World',
      description: 'พระพิฆเนศองค์ใหญ่หน้าเซ็นทรัลเวิลด์',
      belief: 'การศึกษา ศิลปะ ความสำเร็จ',
      sortOrder: 4,
    ),
    const MeritLocation(
      id: 'guanyin_yaowarat',
      nameTh: 'เจ้าแม่กวนอิม เยาวราช',
      nameEn: 'Guanyin Yaowarat',
      description: 'ศาลเจ้าแม่กวนอิมที่เก่าแก่ในย่านเยาวราช',
      belief: 'สุขภาพ ลูกหลาน ครอบครัว',
      sortOrder: 5,
    ),
    const MeritLocation(
      id: 'wat_pho',
      nameTh: 'วัดโพธิ์',
      nameEn: 'Wat Pho',
      description: 'วัดที่มีพระพุทธไสยาสน์ที่ใหญ่ที่สุด',
      belief: 'สุขภาพ ปัดเป่าโรคภัย',
      sortOrder: 6,
    ),
    const MeritLocation(
      id: 'wat_suthat',
      nameTh: 'วัดสุทัศนเทพวราราม',
      nameEn: 'Wat Suthat',
      description: 'วัดที่มีพระศรีศากยมุนี',
      belief: 'ความสงบ สติปัญญา',
      sortOrder: 7,
    ),
    const MeritLocation(
      id: 'vessavana_sampheng',
      nameTh: 'ท้าวเวสสุวรรณ วัดจุฬามณี (สำเพ็ง)',
      nameEn: 'Vessavana Wat Chulamani Sampheng',
      description: 'ท้าวเวสสุวรรณที่ศักดิ์สิทธิ์ย่านสำเพ็ง เยาวราช กทม.',
      belief: 'ป้องกันภัย โชคลาภ ค้าขาย',
      sortOrder: 8,
    ),
  ];
}

class MeritPackage {
  final String id;
  final String nameTh;
  final String? nameEn;
  final String? description;
  final List<String> items;
  final double price;
  final int photoCount;
  final bool hasVideo;
  final bool hasLive;
  final bool isActive;
  final int sortOrder;

  const MeritPackage({
    required this.id,
    required this.nameTh,
    this.nameEn,
    this.description,
    required this.items,
    required this.price,
    this.photoCount = 3,
    this.hasVideo = false,
    this.hasLive = false,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory MeritPackage.fromJson(Map<String, dynamic> json) {
    return MeritPackage(
      id: json['id']?.toString() ?? '',
      nameTh: json['name_th']?.toString() ?? '',
      nameEn: json['name_en'] as String?,
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      price: MeritOrder._parsePrice(json['price']),
      photoCount: (json['photo_count'] as num?)?.toInt() ?? 3,
      hasVideo: json['has_video'] as bool? ?? false,
      hasLive: json['has_live'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_th': nameTh,
      'name_en': nameEn,
      'description': description,
      'items': items,
      'price': price,
      'photo_count': photoCount,
      'has_video': hasVideo,
      'has_live': hasLive,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  String get priceFormatted => '฿${price.toStringAsFixed(0)}';

  // Default packages (fallback when offline)
  static List<MeritPackage> get defaultPackages => [
    const MeritPackage(
      id: 'basic',
      nameTh: 'ไหว้มงคล',
      nameEn: 'Basic',
      description: 'ชุดไหว้พื้นฐาน เหมาะสำหรับขอพรทั่วไป',
      items: ['ธูป 9 ดอก', 'เทียน 2 เล่ม', 'ดอกไม้สด'],
      price: 199,
      photoCount: 3,
      hasVideo: false,
      sortOrder: 1,
    ),
    const MeritPackage(
      id: 'standard',
      nameTh: 'ไหว้เสริมดวง',
      nameEn: 'Standard',
      description: 'ชุดไหว้ครบครัน พร้อมผลไม้มงคล',
      items: ['ธูป 9 ดอก', 'เทียน 2 เล่ม', 'ดอกไม้สด', 'พวงมาลัย', 'ผลไม้ 5 อย่าง', 'น้ำแดง'],
      price: 399,
      photoCount: 5,
      hasVideo: true,
      sortOrder: 2,
    ),
    const MeritPackage(
      id: 'premium',
      nameTh: 'ไหว้ครบเครื่อง',
      nameEn: 'Premium',
      description: 'ชุดไหว้พรีเมียม พร้อมทองคำเปลว',
      items: ['ธูป 9 ดอก', 'เทียน 2 เล่ม', 'ดอกไม้สด', 'พวงมาลัย', 'ผลไม้ 9 อย่าง', 'น้ำแดง', 'ทองคำเปลว', 'ของถวายพิเศษ'],
      price: 699,
      photoCount: 10,
      hasVideo: true,
      sortOrder: 3,
    ),
    const MeritPackage(
      id: 'vip',
      nameTh: 'VIP บูชาใหญ่',
      nameEn: 'VIP',
      description: 'ชุดไหว้ VIP ครบทุกอย่าง พร้อม Live สด',
      items: ['ธูป 9 ดอก', 'เทียน 2 เล่ม', 'ดอกไม้สด', 'พวงมาลัยพิเศษ', 'ผลไม้ 9 อย่าง', 'น้ำแดง', 'ทองคำเปลว', 'ของถวายพิเศษ', 'รำถวาย'],
      price: 1299,
      photoCount: 15,
      hasVideo: true,
      hasLive: true,
      sortOrder: 4,
    ),
  ];
}

enum MeritOrderStatus {
  pending,    // รอชำระเงิน
  paid,       // ชำระเงินแล้ว รอดำเนินการ
  processing, // กำลังดำเนินการ
  completed,  // เสร็จสิ้น
  cancelled,  // ยกเลิก
}

extension MeritOrderStatusX on MeritOrderStatus {
  String get displayName {
    switch (this) {
      case MeritOrderStatus.pending:
        return 'รอชำระเงิน';
      case MeritOrderStatus.paid:
        return 'รอดำเนินการ';
      case MeritOrderStatus.processing:
        return 'กำลังไหว้';
      case MeritOrderStatus.completed:
        return 'เสร็จสิ้น';
      case MeritOrderStatus.cancelled:
        return 'ยกเลิก';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static MeritOrderStatus fromString(String value) {
    return MeritOrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MeritOrderStatus.pending,
    );
  }
}

class MeritOrder {
  final String? id;
  final String? orderNumber;
  final String? userId;
  final String locationId;
  final String packageId;
  final String prayerName;
  final DateTime? prayerBirthdate;
  final String? prayerWish;
  final String? prayerPhone;
  final double price;
  final String? slipUrl;
  // Single-use token returned only by the create-weekly-order response.
  // Used to authorize the subsequent guest slip upload (IDOR mitigation).
  final String? slipUploadToken;
  final DateTime? paidAt;
  final MeritOrderStatus status;
  final List<String>? proofUrls;
  final String? proofVideoUrl;
  final DateTime? completedAt;
  final String? adminNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data
  final MeritLocation? location;
  final MeritPackage? package;

  const MeritOrder({
    this.id,
    this.orderNumber,
    this.userId,
    required this.locationId,
    required this.packageId,
    required this.prayerName,
    this.prayerBirthdate,
    this.prayerWish,
    this.prayerPhone,
    required this.price,
    this.slipUrl,
    this.slipUploadToken,
    this.paidAt,
    this.status = MeritOrderStatus.pending,
    this.proofUrls,
    this.proofVideoUrl,
    this.completedAt,
    this.adminNote,
    this.createdAt,
    this.updatedAt,
    this.location,
    this.package,
  });

  factory MeritOrder.fromJson(Map<String, dynamic> json) {
    return MeritOrder(
      id: json['id']?.toString(),
      orderNumber: json['order_number']?.toString(),
      userId: json['user_id']?.toString(),
      locationId: json['location_id']?.toString() ?? '',
      packageId: json['package_id']?.toString() ?? '',
      prayerName: json['prayer_name']?.toString() ?? '',
      prayerBirthdate: _tryParseDate(json['prayer_birthdate']),
      prayerWish: json['prayer_wish'] as String?,
      prayerPhone: json['prayer_phone'] as String?,
      price: _parsePrice(json['price']),
      slipUrl: json['slip_url'] as String?,
      slipUploadToken: json['slip_upload_token'] as String?,
      paidAt: _tryParseDate(json['paid_at']),
      status: MeritOrderStatusX.fromString(json['status']?.toString() ?? 'pending'),
      proofUrls: (json['proof_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      proofVideoUrl: json['proof_video_url'] as String?,
      completedAt: _tryParseDate(json['completed_at']),
      adminNote: json['admin_note'] as String?,
      createdAt: _tryParseDate(json['created_at']),
      updatedAt: _tryParseDate(json['updated_at']),
      location: json['merit_locations'] != null
          ? MeritLocation.fromJson(json['merit_locations'] as Map<String, dynamic>)
          : null,
      package: json['merit_packages'] != null
          ? MeritPackage.fromJson(json['merit_packages'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'location_id': locationId,
      'package_id': packageId,
      'prayer_name': prayerName,
      'prayer_birthdate': prayerBirthdate?.toIso8601String().split('T').first,
      'prayer_wish': prayerWish,
      'prayer_phone': prayerPhone,
      'price': price,
      'slip_url': slipUrl,
      'status': status.value,
    };
  }

  MeritOrder copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? locationId,
    String? packageId,
    String? prayerName,
    DateTime? prayerBirthdate,
    String? prayerWish,
    String? prayerPhone,
    double? price,
    String? slipUrl,
    DateTime? paidAt,
    MeritOrderStatus? status,
    List<String>? proofUrls,
    String? proofVideoUrl,
    DateTime? completedAt,
    String? adminNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    MeritLocation? location,
    MeritPackage? package,
  }) {
    return MeritOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      locationId: locationId ?? this.locationId,
      packageId: packageId ?? this.packageId,
      prayerName: prayerName ?? this.prayerName,
      prayerBirthdate: prayerBirthdate ?? this.prayerBirthdate,
      prayerWish: prayerWish ?? this.prayerWish,
      prayerPhone: prayerPhone ?? this.prayerPhone,
      price: price ?? this.price,
      slipUrl: slipUrl ?? this.slipUrl,
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
      proofUrls: proofUrls ?? this.proofUrls,
      proofVideoUrl: proofVideoUrl ?? this.proofVideoUrl,
      completedAt: completedAt ?? this.completedAt,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      package: package ?? this.package,
    );
  }

  String get priceFormatted => '฿${price.toStringAsFixed(0)}';

  /// Parse a price value that the backend may send as a num, a numeric String,
  /// or null. Never throws; defaults to 0.
  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Parse a date value that the backend may send as a String or null.
  /// Never throws; returns null on missing/invalid input.
  static DateTime? _tryParseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
