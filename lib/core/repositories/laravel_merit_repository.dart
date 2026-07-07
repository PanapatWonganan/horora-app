import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../services/laravel_auth_service.dart';

/// Merit Location model
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

  MeritLocation({
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
      id: json['id'].toString(),
      nameTh: json['name_th'] ?? '',
      nameEn: json['name_en'],
      description: json['description'],
      belief: json['belief'],
      address: json['address'],
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Merit Package model
class MeritPackage {
  final String id;
  final String nameTh;
  final String? nameEn;
  final String? description;
  final List<String>? items;
  final double price;
  final int photoCount;
  final bool hasVideo;
  final bool hasLive;
  final bool isActive;
  final int sortOrder;

  MeritPackage({
    required this.id,
    required this.nameTh,
    this.nameEn,
    this.description,
    this.items,
    required this.price,
    this.photoCount = 3,
    this.hasVideo = false,
    this.hasLive = false,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory MeritPackage.fromJson(Map<String, dynamic> json) {
    List<String>? itemsList;
    if (json['items'] != null) {
      if (json['items'] is List) {
        itemsList = List<String>.from(json['items']);
      } else if (json['items'] is String) {
        try {
          final decoded = json['items'];
          if (decoded is List) {
            itemsList = List<String>.from(decoded);
          }
        } catch (_) {}
      }
    }

    // Parse price from String or num
    double price = 0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        price = (json['price'] as num).toDouble();
      } else if (json['price'] is String) {
        price = double.tryParse(json['price']) ?? 0;
      }
    }

    return MeritPackage(
      id: json['id'].toString(),
      nameTh: json['name_th'] ?? '',
      nameEn: json['name_en'],
      description: json['description'],
      items: itemsList,
      price: price,
      photoCount: (json['photo_count'] as num?)?.toInt() ?? 3,
      hasVideo: json['has_video'] ?? false,
      hasLive: json['has_live'] ?? false,
      isActive: json['is_active'] ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  String get priceFormatted => '฿${price.toStringAsFixed(0)}';
}

/// Merit Order model
class MeritOrder {
  final String id;
  final String orderNumber;
  final String locationId;
  final String packageId;
  final String prayerName;
  final DateTime? prayerBirthdate;
  final String? prayerWish;
  final String? prayerPhone;
  final double price;
  final String? slipUrl;
  final String? slipUploadToken;
  final DateTime? paidAt;
  final String status;
  final List<String>? proofUrls;
  final String? proofVideoUrl;
  final DateTime? completedAt;
  final String? adminNote;
  final DateTime createdAt;
  final MeritLocation? location;
  final MeritPackage? package;

  MeritOrder({
    required this.id,
    required this.orderNumber,
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
    required this.status,
    this.proofUrls,
    this.proofVideoUrl,
    this.completedAt,
    this.adminNote,
    required this.createdAt,
    this.location,
    this.package,
  });

  factory MeritOrder.fromJson(Map<String, dynamic> json) {
    // Parse price from String or num
    double price = 0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        price = (json['price'] as num).toDouble();
      } else if (json['price'] is String) {
        price = double.tryParse(json['price']) ?? 0;
      }
    }

    return MeritOrder(
      id: json['id'].toString(),
      orderNumber: json['order_number'] ?? '',
      locationId: json['location_id'].toString(),
      packageId: json['package_id'].toString(),
      prayerName: json['prayer_name'] ?? '',
      prayerBirthdate: json['prayer_birthdate'] != null
          ? DateTime.tryParse(json['prayer_birthdate'])
          : null,
      prayerWish: json['prayer_wish'],
      prayerPhone: json['prayer_phone'],
      price: price,
      slipUrl: json['slip_url'],
      slipUploadToken: json['slip_upload_token'],
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      status: json['status'] ?? 'pending',
      proofUrls: json['proof_urls'] is List
          ? (json['proof_urls'] as List).map((e) => e.toString()).toList()
          : null,
      proofVideoUrl: json['proof_video_url'],
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      adminNote: json['admin_note'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      location: json['location'] != null
          ? MeritLocation.fromJson(json['location'])
          : null,
      package: json['package'] != null
          ? MeritPackage.fromJson(json['package'])
          : null,
    );
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'รอชำระเงิน';
      case 'paid':
        return 'รอดำเนินการ';
      case 'processing':
        return 'กำลังไหว้';
      case 'completed':
        return 'เสร็จสิ้น';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status;
    }
  }
}

/// Weekly Schedule item
class WeeklyScheduleItem {
  final String day;
  final MeritLocation location;

  WeeklyScheduleItem({
    required this.day,
    required this.location,
  });

  factory WeeklyScheduleItem.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleItem(
      day: json['day'] ?? '',
      location: MeritLocation.fromJson(json['location']),
    );
  }
}

/// Laravel Merit Repository
class LaravelMeritRepository {
  static LaravelMeritRepository? _instance;
  final ApiClient _apiClient;

  // Singleton
  static LaravelMeritRepository get instance {
    _instance ??= LaravelMeritRepository._();
    return _instance!;
  }

  LaravelMeritRepository._()
      : _apiClient = LaravelAuthService.instance.apiClient;

  // Get all locations
  Future<List<MeritLocation>> getLocations() async {
    try {
      final response = await _apiClient.get('/merit/locations');
      final List<dynamic> data = response as List;
      return data.map((json) => MeritLocation.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      rethrow;
    }
  }

  // Get single location
  Future<MeritLocation> getLocation(String id) async {
    try {
      final response = await _apiClient.get('/merit/locations/$id');
      return MeritLocation.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching location: $e');
      rethrow;
    }
  }

  // Get all packages
  Future<List<MeritPackage>> getPackages({String? locationId}) async {
    try {
      final queryParams = locationId != null ? {'location_id': locationId} : null;
      final response = await _apiClient.get('/merit/packages', queryParams: queryParams);
      final List<dynamic> data = response as List;
      return data.map((json) => MeritPackage.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      rethrow;
    }
  }

  // Get weekly schedule
  Future<List<WeeklyScheduleItem>> getWeeklySchedule() async {
    try {
      final response = await _apiClient.get('/merit/schedule');
      final List<dynamic> data = response as List;
      return data.map((json) => WeeklyScheduleItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
      rethrow;
    }
  }

  // Create order
  Future<MeritOrder> createOrder({
    required String locationId,
    required String packageId,
    required String prayerName,
    DateTime? prayerBirthdate,
    String? prayerWish,
    String? prayerPhone,
    String? referralCode,
    String? deviceId,
  }) async {
    try {
      final response = await _apiClient.post('/merit/orders', data: {
        'location_id': locationId,
        'package_id': packageId,
        'prayer_name': prayerName,
        'prayer_birthdate': prayerBirthdate?.toIso8601String().split('T')[0],
        'prayer_wish': prayerWish,
        'prayer_phone': prayerPhone,
        if (referralCode != null) 'referral_code': referralCode,
        // device_id ผูกออเดอร์กับเครื่อง (target push แจ้งภาพพร้อม)
        if (deviceId != null) 'device_id': deviceId,
      });
      return MeritOrder.fromJson(response);
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  // Get my orders
  Future<List<MeritOrder>> getMyOrders() async {
    try {
      final response = await _apiClient.get('/merit/orders');
      final List<dynamic> data = response as List;
      return data.map((json) => MeritOrder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      rethrow;
    }
  }

  // Get single order
  Future<MeritOrder> getOrder(String id) async {
    try {
      final response = await _apiClient.get('/merit/orders/$id');
      return MeritOrder.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching order: $e');
      rethrow;
    }
  }

  // Upload slip
  Future<MeritOrder> uploadSlip(String orderId, String filePath) async {
    try {
      final file = await _apiClient.createMultipartFile(filePath, fieldName: 'slip');
      final response = await _apiClient.postMultipart(
        '/merit/orders/$orderId/slip',
        formData: {'slip': file},
      );
      return MeritOrder.fromJson(response);
    } catch (e) {
      debugPrint('Error uploading slip: $e');
      rethrow;
    }
  }

  // Create weekly order (flexible validation - no strict location/package IDs required)
  Future<MeritOrder> createWeeklyOrder({
    required String locationName,
    required String packageName,
    required String prayerName,
    DateTime? prayerBirthdate,
    String? prayerWish,
    String? prayerPhone,
    required double price,
    String? referralCode,
    String? packageId,
    String? deviceId,
  }) async {
    try {
      final response = await _apiClient.post('/merit/weekly-orders', data: {
        'location_name': locationName,
        'package_name': packageName,
        'prayer_name': prayerName,
        'prayer_birthdate': prayerBirthdate?.toIso8601String().split('T')[0],
        'prayer_wish': prayerWish,
        'prayer_phone': prayerPhone,
        'price': price,
        if (referralCode != null) 'referral_code': referralCode,
        // package_id ให้ server แยกออเดอร์ฟรี ('free_trial') ได้ชัดเจน
        if (packageId != null) 'package_id': packageId,
        // device_id ผูกออเดอร์กับเครื่อง — server ใช้กันสิทธิ์มูฟรีซ้ำ
        // และเป็น target ของ push "ภาพไหว้มาแล้ว"
        if (deviceId != null) 'device_id': deviceId,
      });
      return MeritOrder.fromJson(response);
    } catch (e) {
      debugPrint('Error creating weekly order: $e');
      rethrow;
    }
  }

  // Get weekly order status as guest (no auth).
  // authorize ด้วย device_id ที่ผูกออเดอร์ — ตรง → 200 คืน order เต็ม
  // (location/package/proof_urls); ไม่ตรง/null → 403
  Future<MeritOrder> getWeeklyOrderStatus(
    String orderId,
    String deviceId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/merit/weekly-orders/$orderId/status',
        queryParams: {'device_id': deviceId},
      );
      return MeritOrder.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching weekly order status: $e');
      rethrow;
    }
  }

  // Upload slip for weekly order (no auth required).
  // [uploadToken] authorizes this upload against the order (IDOR mitigation);
  // it is the single-use token returned when the order was created.
  Future<MeritOrder> uploadWeeklySlip(
    String orderId,
    String filePath, {
    String? uploadToken,
  }) async {
    try {
      final file = await _apiClient.createMultipartFile(filePath, fieldName: 'slip');
      final response = await _apiClient.postMultipart(
        '/merit/weekly-orders/$orderId/slip',
        formData: {
          'slip': file,
          if (uploadToken != null) 'upload_token': uploadToken,
        },
      );
      return MeritOrder.fromJson(response);
    } catch (e) {
      debugPrint('Error uploading weekly slip: $e');
      rethrow;
    }
  }
}
