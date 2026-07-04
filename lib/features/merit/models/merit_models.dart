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

  /// วันที่ของ "รอบถัดไป" ของวันนี้ในสัปดาห์ นับจาก [from] — ถ้าวันนี้ตรงกับ
  /// [this] ให้ถือว่าวันนี้เองคือรอบถัดไป (ยังทันอยู่) ไม่ใช่รอสัปดาห์หน้า
  /// มิเช่นนั้นเลื่อนไปวันที่ตรงกันถัดไปในอีก 1-6 วันข้างหน้า
  ///
  /// ใช้เป็น single source of truth ทั้งชิปวันที่บนหน้า landing และบรรทัด
  /// "รอบถัดไป" ในการ์ดรายละเอียด — ไม่ให้ตรรกะวันที่หลุดซิงค์กันระหว่างสองจุด
  DateTime nextOccurrenceDate({DateTime? from}) {
    final now = from ?? DateTime.now();
    final diff = weekdayNumber - now.weekday;
    final normalizedDiff = diff >= 0 ? diff : diff + 7;
    // ตัดเวลาออกให้เหลือแค่วันที่ (ปี/เดือน/วัน) กันปัญหาเวลาในวันเดียวกัน
    // ทำให้ diff คลาดเคลื่อน
    final today = DateTime(now.year, now.month, now.day);
    return today.add(Duration(days: normalizedDiff));
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
  ///
  /// จำกัดไว้ 3 สถานที่ตามขอบเขตการเดินทางของทีมงาน: พระตรีมูรติ (จันทร์),
  /// พระพิฆเนศ ห้วยขวาง (พุธ), พระแม่ลักษมี (ศุกร์).
  static List<WeeklyMeritSchedule> get defaultSchedule => [
    // วันจันทร์ - พระตรีมูรติ เซ็นทรัลเวิลด์
    const WeeklyMeritSchedule(
      day: MeritDay.monday,
      locationId: 'trimurti_centralworld',
      locationName: 'พระตรีมูรติ เซ็นทรัลเวิลด์',
      belief: 'ความรัก คู่ครอง ความสัมพันธ์',
      requiredItems: [
        MeritOfferingItem(id: 'incense_9', name: 'ธูปแดง 9 ดอก', isRequired: true),
        MeritOfferingItem(id: 'candle_pair', name: 'เทียนคู่', isRequired: true),
        MeritOfferingItem(id: 'red_rose_9', name: 'กุหลาบแดง 9 ดอก', isRequired: true),
        MeritOfferingItem(id: 'garland_red', name: 'พวงมาลัยสีแดง', isRequired: true),
      ],
      addons: [
        MeritAddon(
          id: 'lover_cloth',
          name: 'ผ้าแดงคู่รัก',
          description: 'ผ้าแดงถวายขอพรเรื่องคู่ครอง',
          price: 199,
        ),
        MeritAddon(
          id: 'love_elephant_pair',
          name: 'ช้างคู่ทองคำเปลว',
          description: 'สื่อถึงความรักที่มั่นคงยืนยาว',
          price: 249,
        ),
        MeritAddon(
          id: 'jasmine_garland',
          name: 'พวงมาลัยดอกมะลิ',
          description: 'ดอกมะลิสื่อถึงความรักบริสุทธิ์',
          price: 99,
        ),
      ],
    ),
    // วันพุธ - พระพิฆเนศ ห้วยขวาง
    const WeeklyMeritSchedule(
      day: MeritDay.wednesday,
      locationId: 'ganesha_huaykwang',
      locationName: 'พระพิฆเนศ ห้วยขวาง',
      belief: 'การศึกษา ศิลปะ ความสำเร็จ',
      requiredItems: [
        MeritOfferingItem(id: 'incense_9', name: 'ธูป 9 ดอก', isRequired: true),
        MeritOfferingItem(id: 'candle_1', name: 'เทียน 1 เล่ม', isRequired: true),
        MeritOfferingItem(id: 'garland_jasmine', name: 'พวงมาลัยดอกมะลิ', isRequired: true),
        MeritOfferingItem(id: 'banana', name: 'กล้วยน้ำว้า', isRequired: true),
      ],
      addons: [
        MeritAddon(
          id: 'modak',
          name: 'ขนมโมทกะ',
          description: 'ขนมโปรดของพระพิฆเนศ',
          price: 149,
        ),
        MeritAddon(
          id: 'red_cloth',
          name: 'ผ้าแดงถวาย',
          description: 'ผ้าแดงมงคลสำหรับพระพิฆเนศ',
          price: 199,
        ),
        MeritAddon(
          id: 'durva_grass',
          name: 'หญ้าแพรก',
          description: 'หญ้าศักดิ์สิทธิ์สำหรับบูชา',
          price: 79,
        ),
      ],
    ),
    // วันศุกร์ - พระแม่ลักษมี เซ็นทรัลลาดพร้าว
    const WeeklyMeritSchedule(
      day: MeritDay.friday,
      locationId: 'lakshmi_central_ladprao',
      locationName: 'พระแม่ลักษมี เซ็นทรัลลาดพร้าว',
      belief: 'โชคลาภ ความมั่งคั่ง ความอุดมสมบูรณ์',
      requiredItems: [
        MeritOfferingItem(id: 'incense_9', name: 'ธูปหอมทอง 9 ดอก', isRequired: true),
        MeritOfferingItem(id: 'candle_2', name: 'เทียน 2 เล่ม', isRequired: true),
        MeritOfferingItem(id: 'pink_lotus', name: 'ดอกบัวชมพู', isRequired: true),
        MeritOfferingItem(id: 'fruit_gold_9', name: 'ผลไม้สีทอง 9 อย่าง', isRequired: true),
      ],
      addons: [
        MeritAddon(
          id: 'gold_leaf_lakshmi',
          name: 'ทองคำเปลวถวาย',
          description: 'ปิดทององค์พระแม่ลักษมีเสริมโชคลาภ',
          price: 199,
        ),
        MeritAddon(
          id: 'coin_offering',
          name: 'เหรียญโปรยทรัพย์',
          description: 'เหรียญมงคลถวายขอพรด้านการเงิน',
          price: 129,
        ),
        MeritAddon(
          id: 'marigold_garland',
          name: 'พวงมาลัยดอกดาวเรือง',
          description: 'ดอกดาวเรืองสีทอง เสริมสิริมงคลด้านการเงิน',
          price: 99,
        ),
      ],
    ),
  ];

  /// ราคาต่ำสุดของแพ็คร่วมบุญที่เลือกได้ในหน้าฟอร์มสั่งจอง (ไม่รวม add-on)
  /// ใช้แสดง "เริ่มต้น ฿xxx" บนหน้า landing — คำนวณจากชุดข้อมูลเดียวกับที่
  /// หน้าฟอร์มสั่งจองใช้ ([WeeklyOrderPackage.defaultPackages]) ไม่ hardcode ซ้ำ
  double get cheapestPackagePrice => WeeklyOrderPackage.cheapestPrice;
}

/// แพ็คร่วมบุญที่เลือกได้ในหน้าฟอร์มสั่งจองรายสัปดาห์ (ฝากมู · ร่วมบุญ)
///
/// Hoisted out of `MeritWeeklyOrderScreen` so both the order form and the
/// landing screen (`WeeklyScheduleScreen`, for the "เริ่มต้น ฿xxx" price
/// pill) read from one source of truth instead of two hardcoded copies.
class WeeklyOrderPackage {
  final String id;
  final String name;
  final double price;
  final List<String> features;

  const WeeklyOrderPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
  });

  String get priceFormatted => '฿${price.toStringAsFixed(0)}';

  static const List<WeeklyOrderPackage> defaultPackages = [
    WeeklyOrderPackage(
      id: 'basic',
      name: '🙏 แพ็คมงคล',
      price: 299,
      features: [
        '🪷 ชุดไหว้พื้นฐาน',
        '📸 รูปถ่าย 3 รูป',
        '💬 รายงานผล LINE',
      ],
    ),
    WeeklyOrderPackage(
      id: 'standard',
      name: '⭐ แพ็คเสริมดวง',
      price: 499,
      features: [
        '🪷 ชุดไหว้พื้นฐาน',
        '📸 รูปถ่าย 5 รูป',
        '🎬 วิดีโอสั้น 30 วินาที',
        '💬 รายงานผล LINE',
        '📜 ใบรับรองทำบุญ',
      ],
    ),
    WeeklyOrderPackage(
      id: 'premium',
      name: '👑 แพ็คพรีเมียม',
      price: 799,
      features: [
        '🪷 ชุดไหว้พื้นฐาน',
        '📸 รูปถ่าย 10 รูป',
        '🎬 วิดีโอเต็ม 3 นาที',
        '📡 Live สด (ถ้าพร้อม)',
        '💬 รายงานผล LINE',
        '📜 ใบรับรองทำบุญ',
        '🎁 ของที่ระลึก',
      ],
    ),
  ];

  /// ราคาต่ำสุดในชุดแพ็คทั้งหมด — ใช้แสดง "เริ่มต้น ฿xxx" ก่อนเข้าฟอร์ม
  static double get cheapestPrice =>
      defaultPackages.map((p) => p.price).reduce((a, b) => a < b ? a : b);

  /// หาแพ็คด้วย id — คืนค่า null ถ้าไม่พบ (กันการ throw เวลาข้อมูลไม่ตรง)
  static WeeklyOrderPackage? byId(String id) {
    for (final p in defaultPackages) {
      if (p.id == id) return p;
    }
    return null;
  }
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
      id: 'trimurti_centralworld',
      nameTh: 'พระตรีมูรติ เซ็นทรัลเวิลด์',
      nameEn: 'Trimurti Shrine CentralWorld',
      description: 'ศาลพระตรีมูรติ ด้านหลังเซ็นทรัลเวิลด์',
      belief: 'ความรัก คู่ครอง ความสัมพันธ์',
      sortOrder: 1,
    ),
    const MeritLocation(
      id: 'ganesha_huaykwang',
      nameTh: 'พระพิฆเนศ ห้วยขวาง',
      nameEn: 'Ganesha Shrine Huai Khwang',
      description: 'ศาลพระพิฆเนศที่ศักดิ์สิทธิ์ ใกล้สถานีรถไฟฟ้า MRT ห้วยขวาง',
      belief: 'ขอโชคลาภ การงาน การเรียน ขจัดอุปสรรค',
      sortOrder: 2,
    ),
    const MeritLocation(
      id: 'lakshmi_central_ladprao',
      nameTh: 'พระแม่ลักษมี เซ็นทรัลลาดพร้าว',
      nameEn: 'Lakshmi Shrine Central Ladprao',
      description: 'ศาลพระแม่ลักษมี หน้าห้างเซ็นทรัลลาดพร้าว',
      belief: 'โชคลาภ ความมั่งคั่ง ความอุดมสมบูรณ์',
      sortOrder: 3,
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
