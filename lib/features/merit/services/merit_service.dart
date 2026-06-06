import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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

  // Telegram Bot Configuration
  static String get _telegramBotToken => dotenv.env['TELEGRAM_BOT_TOKEN'] ?? '';
  static String get _telegramChatId => dotenv.env['TELEGRAM_CHAT_ID'] ?? '';

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

      // Send Telegram notification พร้อมรูป slip
      final meritOrder = _convertLaravelOrderToMeritOrder(order);
      await sendTelegramNotification(meritOrder, slipUrl: order.slipUrl, slipImage: slipFile);

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

      // Send Telegram notification พร้อมรูป slip
      final meritOrder = _convertLaravelOrderToMeritOrder(order);
      await sendTelegramNotification(meritOrder, slipUrl: order.slipUrl, slipImage: slipFile);

      return order.slipUrl;
    } catch (e) {
      debugPrint('Error uploading slip: $e');
      rethrow;
    }
  }

  // ==================== Telegram Notification ====================

  /// ส่งแจ้งเตือนไปยัง Telegram (public method)
  Future<void> sendTelegramNotification(MeritOrder order, {String? slipUrl, File? slipImage}) async {
    debugPrint('=== TELEGRAM: Starting notification ===');
    debugPrint('Order: ${order.prayerName}, Price: ${order.price}');

    try {
      final locationName = order.location?.nameTh ?? order.locationId;
      final packageName = order.package?.nameTh ?? order.packageId;

      final message = '''
🔔 คำสั่งซื้อใหม่!

📋 Order: ${order.orderNumber ?? 'N/A'}
🏛️ สถานที่: $locationName
📦 แพ็คเกจ: $packageName
💰 ราคา: ${order.priceFormatted}

👤 ผู้ขอพร: ${order.prayerName}
📅 วันเกิด: ${order.prayerBirthdate != null ? _formatDate(order.prayerBirthdate!) : '-'}
📱 เบอร์โทร: ${order.prayerPhone ?? '-'}

🙏 คำขอพร:
${order.prayerWish ?? '-'}

⏰ ${_formatDateTime(DateTime.now())}
''';

      debugPrint('=== TELEGRAM: Sending message ===');

      // ส่งข้อความ
      final msgUrl = Uri.parse(
        'https://api.telegram.org/bot$_telegramBotToken/sendMessage',
      );

      final response = await http.post(msgUrl, body: {
        'chat_id': _telegramChatId,
        'text': message,
      });

      debugPrint('=== TELEGRAM: Response status: ${response.statusCode} ===');
      debugPrint('=== TELEGRAM: Response body: ${response.body} ===');

      // ถ้ามีรูป slip ส่งรูปตามมา
      if (slipImage != null && await slipImage.exists()) {
        debugPrint('=== TELEGRAM: Sending photo ===');
        await _sendTelegramPhoto(slipImage);
      }

      debugPrint('=== TELEGRAM: Done ===');
    } catch (e, stack) {
      debugPrint('=== TELEGRAM ERROR: $e ===');
      debugPrint('=== TELEGRAM STACK: $stack ===');
    }
  }

  /// ส่งรูปไปยัง Telegram
  Future<void> _sendTelegramPhoto(File photo) async {
    try {
      final url = Uri.parse(
        'https://api.telegram.org/bot$_telegramBotToken/sendPhoto',
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['chat_id'] = _telegramChatId;
      request.fields['caption'] = '🧾 รูป Slip การโอนเงิน';
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        debugPrint('Telegram photo sent successfully');
      } else {
        debugPrint('Telegram photo failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending Telegram photo: $e');
    }
  }

  /// ส่งแจ้งเตือนทดสอบ
  Future<bool> sendTestNotification() async {
    try {
      if (_telegramBotToken.isEmpty) {
        return false;
      }

      final url = Uri.parse(
        'https://api.telegram.org/bot$_telegramBotToken/sendMessage',
      );

      final response = await http.post(url, body: {
        'chat_id': _telegramChatId,
        'text': '🧪 ทดสอบการแจ้งเตือนจาก Horora App\n\n✅ การเชื่อมต่อสำเร็จ!',
        'parse_mode': 'Markdown',
      });

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      return false;
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

  String _formatDate(DateTime date) {
    final thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    return '${date.day} ${thaiMonths[date.month - 1]} ${date.year + 543}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Generate PromptPay QR data
  String generatePromptPayQRData(double amount) {
    // PromptPay QR format (simplified)
    // In production, use proper PromptPay library
    return 'promptpay://$promptPayNumber?amount=${amount.toStringAsFixed(2)}';
  }
}
