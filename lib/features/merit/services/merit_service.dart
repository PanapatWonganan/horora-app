import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/repositories/laravel_merit_repository.dart' as laravel;
import '../../../core/services/laravel_auth_service.dart';
import '../../affiliate/services/affiliate_service.dart';
import '../models/merit_models.dart';

/// Service สำหรับจัดการระบบทำบุญออนไลน์
/// ใช้ Laravel API
class MeritService {
  static final MeritService _instance = MeritService._internal();
  static MeritService get instance => _instance;

  MeritService._internal();

  final _meritRepo = laravel.LaravelMeritRepository.instance;
  final _apiClient = LaravelAuthService.instance.apiClient;

  // หมายเหตุ: Telegram bot token ถูกย้ายไปอยู่ฝั่ง backend แล้ว
  // (backend ส่งแจ้งเตือนเองตอนสร้าง order / อัปโหลดสลิป) เพื่อไม่ให้ secret หลุดใน client

  // PromptPay Configuration
  static const String promptPayNumber = '225-1-63533-4'; // เลขบัญชีกสิกร
  static const String promptPayName = 'ธ.กสิกรไทย'; // ชื่อบัญชี

  // ==================== Locations ====================

  /// ดึงรายการสถานที่ทั้งหมด
  Future<List<MeritLocation>> getLocations() async {
    try {
      final locations = await _meritRepo.getLocations();
      return locations.map((loc) => MeritLocation(
        id: loc.id,
        nameTh: loc.nameTh,
        nameEn: loc.nameEn,
        description: loc.description,
        belief: loc.belief,
        address: loc.address,
        imageUrl: loc.imageUrl,
        isActive: loc.isActive,
        sortOrder: loc.sortOrder,
      )).toList();
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      // Return default locations as fallback
      return MeritLocation.defaultLocations;
    }
  }

  /// ดึงข้อมูลสถานที่ตาม ID
  Future<MeritLocation?> getLocationById(String id) async {
    try {
      final loc = await _meritRepo.getLocation(id);
      return MeritLocation(
        id: loc.id,
        nameTh: loc.nameTh,
        nameEn: loc.nameEn,
        description: loc.description,
        belief: loc.belief,
        address: loc.address,
        imageUrl: loc.imageUrl,
        isActive: loc.isActive,
        sortOrder: loc.sortOrder,
      );
    } catch (e) {
      debugPrint('Error fetching location: $e');
      return MeritLocation.defaultLocations.firstWhere(
        (l) => l.id == id,
        orElse: () => MeritLocation.defaultLocations.first,
      );
    }
  }

  // ==================== Packages ====================

  /// ดึงรายการแพ็คเกจทั้งหมด
  Future<List<MeritPackage>> getPackages() async {
    try {
      final packages = await _meritRepo.getPackages();
      return packages.map((pkg) => MeritPackage(
        id: pkg.id,
        nameTh: pkg.nameTh,
        nameEn: pkg.nameEn,
        description: pkg.description,
        items: pkg.items ?? [],
        price: pkg.price,
        photoCount: pkg.photoCount,
        hasVideo: pkg.hasVideo,
        hasLive: pkg.hasLive,
        isActive: pkg.isActive,
        sortOrder: pkg.sortOrder,
      )).toList();
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      return MeritPackage.defaultPackages;
    }
  }

  /// ดึงข้อมูลแพ็คเกจตาม ID
  Future<MeritPackage?> getPackageById(String id) async {
    try {
      final packages = await _meritRepo.getPackages();
      final pkg = packages.firstWhere((p) => p.id == id);
      return MeritPackage(
        id: pkg.id,
        nameTh: pkg.nameTh,
        nameEn: pkg.nameEn,
        description: pkg.description,
        items: pkg.items ?? [],
        price: pkg.price,
        photoCount: pkg.photoCount,
        hasVideo: pkg.hasVideo,
        hasLive: pkg.hasLive,
        isActive: pkg.isActive,
        sortOrder: pkg.sortOrder,
      );
    } catch (e) {
      debugPrint('Error fetching package: $e');
      return MeritPackage.defaultPackages.firstWhere(
        (p) => p.id == id,
        orElse: () => MeritPackage.defaultPackages.first,
      );
    }
  }

  // ==================== Orders ====================

  /// สร้างคำสั่งซื้อใหม่ (ต้อง login)
  Future<MeritOrder?> createOrder(MeritOrder order) async {
    try {
      final isLoggedIn = await LaravelAuthService.instance.isLoggedIn();
      if (!isLoggedIn) {
        throw Exception('User not logged in');
      }

      // Get saved referral code (if any)
      final referralCode = await AffiliateService().getSavedReferralCode();

      final laravelOrder = await _meritRepo.createOrder(
        locationId: order.locationId,
        packageId: order.packageId,
        prayerName: order.prayerName,
        prayerBirthdate: order.prayerBirthdate,
        prayerWish: order.prayerWish,
        prayerPhone: order.prayerPhone,
        referralCode: referralCode,
      );

      // Clear referral code after successful order
      if (referralCode != null) {
        await AffiliateService().clearReferralCode();
      }

      return _convertLaravelOrderToMeritOrder(laravelOrder);
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  /// สร้างคำสั่งซื้อจากตารางประจำสัปดาห์ (ไม่ต้อง login, flexible validation)
  Future<MeritOrder?> createWeeklyOrder(MeritOrder order) async {
    try {
      final locationName = order.location?.nameTh ?? order.locationId;
      final packageName = order.package?.nameTh ?? order.packageId;

      // Get saved referral code (if any)
      final referralCode = await AffiliateService().getSavedReferralCode();

      final laravelOrder = await _meritRepo.createWeeklyOrder(
        locationName: locationName,
        packageName: packageName,
        prayerName: order.prayerName,
        prayerBirthdate: order.prayerBirthdate,
        prayerWish: order.prayerWish,
        prayerPhone: order.prayerPhone,
        price: order.price,
        referralCode: referralCode,
      );

      // Clear referral code after successful order
      if (referralCode != null) {
        await AffiliateService().clearReferralCode();
      }

      return _convertLaravelOrderToMeritOrder(laravelOrder);
    } catch (e) {
      debugPrint('Error creating weekly order: $e');
      rethrow;
    }
  }

  /// Upload slip สำหรับ weekly order (ไม่ต้อง login)
  Future<String?> uploadWeeklySlip(String orderId, File slipFile) async {
    try {
      final order = await _meritRepo.uploadWeeklySlip(orderId, slipFile.path);

      // หมายเหตุ: การแจ้งเตือน Telegram ทำที่ฝั่ง backend แล้ว
      // (token อยู่ที่ server เท่านั้น เพื่อไม่ให้ secret หลุดไปอยู่ใน client)
      return order.slipUrl;
    } catch (e) {
      debugPrint('Error uploading weekly slip: $e');
      rethrow;
    }
  }

  /// อัพเดทคำสั่งซื้อ
  Future<MeritOrder?> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/merit/orders/$orderId', data: updates);
      if (response != null) {
        return MeritOrder.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating order: $e');
      rethrow;
    }
  }

  /// ดึงคำสั่งซื้อของผู้ใช้ปัจจุบัน
  Future<List<MeritOrder>> getMyOrders() async {
    try {
      final isLoggedIn = await LaravelAuthService.instance.isLoggedIn();
      if (!isLoggedIn) {
        return [];
      }

      final orders = await _meritRepo.getMyOrders();
      return orders.map((o) => _convertLaravelOrderToMeritOrder(o)).toList();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return [];
    }
  }

  /// ดึงคำสั่งซื้อตาม ID
  Future<MeritOrder?> getOrderById(String orderId) async {
    try {
      final order = await _meritRepo.getOrder(orderId);
      return _convertLaravelOrderToMeritOrder(order);
    } catch (e) {
      debugPrint('Error fetching order: $e');
      return null;
    }
  }

  // ==================== Slip Upload ====================

  /// Upload slip และอัพเดทคำสั่งซื้อ
  Future<String?> uploadSlip(String orderId, File slipFile) async {
    try {
      final isLoggedIn = await LaravelAuthService.instance.isLoggedIn();
      if (!isLoggedIn) {
        throw Exception('User not logged in');
      }

      final order = await _meritRepo.uploadSlip(orderId, slipFile.path);

      // หมายเหตุ: การแจ้งเตือน Telegram ทำที่ฝั่ง backend แล้ว
      return order.slipUrl;
    } catch (e) {
      debugPrint('Error uploading slip: $e');
      rethrow;
    }
  }

  // ==================== Helpers ====================

  MeritOrder _convertLaravelOrderToMeritOrder(laravel.MeritOrder order) {
    MeritLocation? location;
    if (order.location != null) {
      location = MeritLocation(
        id: order.location!.id,
        nameTh: order.location!.nameTh,
        nameEn: order.location!.nameEn,
        description: order.location!.description,
        belief: order.location!.belief,
        address: order.location!.address,
        imageUrl: order.location!.imageUrl,
        isActive: order.location!.isActive,
        sortOrder: order.location!.sortOrder,
      );
    }

    MeritPackage? package;
    if (order.package != null) {
      package = MeritPackage(
        id: order.package!.id,
        nameTh: order.package!.nameTh,
        nameEn: order.package!.nameEn,
        description: order.package!.description,
        items: order.package!.items ?? [],
        price: order.package!.price,
        photoCount: order.package!.photoCount,
        hasVideo: order.package!.hasVideo,
        hasLive: order.package!.hasLive,
        isActive: order.package!.isActive,
        sortOrder: order.package!.sortOrder,
      );
    }

    return MeritOrder(
      id: order.id,
      orderNumber: order.orderNumber,
      locationId: order.locationId,
      packageId: order.packageId,
      prayerName: order.prayerName,
      prayerBirthdate: order.prayerBirthdate,
      prayerWish: order.prayerWish,
      prayerPhone: order.prayerPhone,
      price: order.price,
      slipUrl: order.slipUrl,
      paidAt: order.paidAt,
      status: _parseOrderStatus(order.status),
      proofUrls: order.proofUrls,
      proofVideoUrl: order.proofVideoUrl,
      completedAt: order.completedAt,
      adminNote: order.adminNote,
      createdAt: order.createdAt,
      location: location,
      package: package,
    );
  }

  /// แปลง String status เป็น MeritOrderStatus enum
  MeritOrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return MeritOrderStatus.pending;
      case 'paid':
        return MeritOrderStatus.paid;
      case 'processing':
        return MeritOrderStatus.processing;
      case 'completed':
        return MeritOrderStatus.completed;
      case 'cancelled':
        return MeritOrderStatus.cancelled;
      default:
        return MeritOrderStatus.pending;
    }
  }

  /// Generate PromptPay QR data
  String generatePromptPayQRData(double amount) {
    // PromptPay QR format (simplified)
    // In production, use proper PromptPay library
    return 'promptpay://$promptPayNumber?amount=${amount.toStringAsFixed(2)}';
  }
}
