import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/models.dart';
import '../utils/exceptions.dart';

class SubscriptionRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  
  // Key constants for SharedPreferences
  static const String _subscriptionPlansKey = 'subscription_plans';
  static const String _userSubscriptionKey = 'user_subscription';
  static const String _paymentHistoryKey = 'payment_history';
  
  SubscriptionRepository({
    required ApiClient apiClient,
    required SharedPreferences prefs,
  }) : _apiClient = apiClient, _prefs = prefs;
  
  // ดึงข้อมูลแผนการสมัครสมาชิกทั้งหมด
  Future<List<SubscriptionPlan>> getAllSubscriptionPlans() async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String? cachedData = _prefs.getString(_subscriptionPlansKey);
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => SubscriptionPlan.fromJson(item)).toList();
      }
      
      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      final response = await _apiClient.get('/subscriptions/plans');
      
      final List<SubscriptionPlan> plans = (response as List)
          .map((item) => SubscriptionPlan.fromJson(item))
          .toList();
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_subscriptionPlansKey, jsonEncode(plans.map((plan) => plan.toJson()).toList()));
      
      return plans;
    } catch (e) {
      throw DataException('Failed to get subscription plans: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลแผนการสมัครสมาชิกตาม ID
  Future<SubscriptionPlan> getSubscriptionPlanById(int planId) async {
    try {
      final List<SubscriptionPlan> allPlans = await getAllSubscriptionPlans();
      
      final SubscriptionPlan plan = allPlans.firstWhere(
        (plan) => plan.id == planId,
        orElse: () => throw DataException('Subscription plan not found: $planId'),
      );
      
      return plan;
    } catch (e) {
      throw DataException('Failed to get subscription plan: ${e.toString()}');
    }
  }
  
  // ดึงข้อมูลการสมัครสมาชิกของผู้ใช้ปัจจุบัน
  Future<UserSubscription?> getCurrentUserSubscription() async {
    try {
      // ตรวจสอบว่ามีข้อมูลในแคชหรือไม่
      final String? cachedData = _prefs.getString(_userSubscriptionKey);
      
      if (cachedData != null) {
        return UserSubscription.fromJson(jsonDecode(cachedData));
      }
      
      // ถ้าไม่มีข้อมูลในแคช ให้ดึงจาก API
      final response = await _apiClient.get('/subscriptions/current');
      
      if (response == null) {
        return null;
      }
      
      final subscription = UserSubscription.fromJson(response);
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_userSubscriptionKey, jsonEncode(subscription.toJson()));
      
      return subscription;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      if (e is NotFoundException) {
        // ถ้าไม่พบการสมัครสมาชิก ให้คืนค่า null
        return null;
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to get user subscription: ${e.toString()}');
    }
  }
  
  // สมัครสมาชิกแผนใหม่
  Future<UserSubscription> subscribeToNewPlan(int planId, PaymentMethod paymentMethod) async {
    try {
      final data = {
        'plan_id': planId,
        'payment_method': paymentMethod.toString().split('.').last,
      };
      
      final response = await _apiClient.post('/subscriptions/subscribe', data: data);
      final subscription = UserSubscription.fromJson(response);
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_userSubscriptionKey, jsonEncode(subscription.toJson()));
      
      return subscription;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw PaymentException('Failed to subscribe to plan: ${e.toString()}');
    }
  }
  
  // ยกเลิกการสมัครสมาชิก
  Future<void> cancelSubscription() async {
    try {
      await _apiClient.post('/subscriptions/cancel');
      
      // อัปเดตแคช
      final String? cachedData = _prefs.getString(_userSubscriptionKey);
      
      if (cachedData != null) {
        final UserSubscription subscription = UserSubscription.fromJson(jsonDecode(cachedData));
        final updatedSubscription = subscription.copyWith(
          status: SubscriptionStatus.canceled,
          autoRenew: false,
        );
        
        await _prefs.setString(_userSubscriptionKey, jsonEncode(updatedSubscription.toJson()));
      }
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to cancel subscription: ${e.toString()}');
    }
  }
  
  // เปิดใช้งานการต่ออายุอัตโนมัติ
  Future<UserSubscription> enableAutoRenew() async {
    try {
      final response = await _apiClient.post('/subscriptions/auto-renew/enable');
      final subscription = UserSubscription.fromJson(response);
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_userSubscriptionKey, jsonEncode(subscription.toJson()));
      
      return subscription;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to enable auto-renew: ${e.toString()}');
    }
  }
  
  // ปิดใช้งานการต่ออายุอัตโนมัติ
  Future<UserSubscription> disableAutoRenew() async {
    try {
      final response = await _apiClient.post('/subscriptions/auto-renew/disable');
      final subscription = UserSubscription.fromJson(response);
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_userSubscriptionKey, jsonEncode(subscription.toJson()));
      
      return subscription;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      throw DataException('Failed to disable auto-renew: ${e.toString()}');
    }
  }
  
  // ดึงประวัติการชำระเงิน
  Future<List<Payment>> getPaymentHistory() async {
    try {
      // ดึงข้อมูลจาก API
      final response = await _apiClient.get('/subscriptions/payments');
      
      final List<Payment> payments = (response as List)
          .map((item) => Payment.fromJson(item))
          .toList();
      
      // บันทึกข้อมูลลงในแคช
      await _prefs.setString(_paymentHistoryKey, jsonEncode(payments.map((payment) => payment.toJson()).toList()));
      
      return payments;
    } on ApiException catch (e) {
      if (e is UnauthorizedException) {
        throw AuthException('User not authenticated');
      }
      rethrow;
    } catch (e) {
      // ถ้ามีข้อผิดพลาด แต่มีข้อมูลในแคช ให้ใช้ข้อมูลจากแคช
      final String? cachedData = _prefs.getString(_paymentHistoryKey);
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((item) => Payment.fromJson(item)).toList();
      }
      
      throw DataException('Failed to get payment history: ${e.toString()}');
    }
  }
  
  // ตรวจสอบว่าผู้ใช้มีการสมัครสมาชิกที่ใช้งานได้หรือไม่
  Future<bool> hasActiveSubscription() async {
    try {
      final UserSubscription? subscription = await getCurrentUserSubscription();
      
      if (subscription == null) {
        return false;
      }
      
      return subscription.isActive;
    } catch (e) {
      return false;
    }
  }
  
  // ตรวจสอบว่าผู้ใช้มีสิทธิ์ใช้งานฟีเจอร์พรีเมียมหรือไม่
  Future<bool> hasPremiumAccess() async {
    try {
      final UserSubscription? subscription = await getCurrentUserSubscription();
      
      if (subscription == null) {
        return false;
      }
      
      if (!subscription.isActive) {
        return false;
      }
      
      // ตรวจสอบว่าแผนการสมัครสมาชิกเป็นแผนพรีเมียมหรือไม่
      if (subscription.plan != null) {
        return subscription.plan!.tier == SubscriptionTier.premium || 
               subscription.plan!.tier == SubscriptionTier.ultimate;
      }
      
      // ถ้าไม่มีข้อมูลแผน ให้ดึงข้อมูลแผนจาก API
      final SubscriptionPlan plan = await getSubscriptionPlanById(subscription.planId);
      
      return plan.tier == SubscriptionTier.premium || 
             plan.tier == SubscriptionTier.ultimate;
    } catch (e) {
      return false;
    }
  }
  
  // ล้างแคชทั้งหมดของ SubscriptionRepository
  Future<void> clearAllCache() async {
    try {
      await _prefs.remove(_subscriptionPlansKey);
      await _prefs.remove(_userSubscriptionKey);
      await _prefs.remove(_paymentHistoryKey);
    } catch (e) {
      throw CacheException('Failed to clear subscription cache: ${e.toString()}');
    }
  }
} 