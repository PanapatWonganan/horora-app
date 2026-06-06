import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/laravel_auth_service.dart';
import '../../../config/constants.dart';
import '../models/affiliate_models.dart';
import 'package:http/http.dart' as http;

class AffiliateService {
  static final AffiliateService _instance = AffiliateService._internal();
  factory AffiliateService() => _instance;
  AffiliateService._internal();

  String get _baseUrl => ApiConstants.baseUrl;

  Future<Map<String, String>> get _headers async {
    final token = await LaravelAuthService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Check if current user is an affiliate
  Future<AffiliateModel?> getStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/affiliate/status'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['is_affiliate'] == true && data['affiliate'] != null) {
          return AffiliateModel.fromJson(data['affiliate']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting affiliate status: $e');
      return null;
    }
  }

  /// Register as affiliate
  Future<AffiliateModel?> register({
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
    String? promptpayNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/affiliate/register'),
        headers: await _headers,
        body: json.encode({
          if (bankName != null) 'bank_name': bankName,
          if (bankAccountNumber != null) 'bank_account_number': bankAccountNumber,
          if (bankAccountName != null) 'bank_account_name': bankAccountName,
          if (promptpayNumber != null) 'promptpay_number': promptpayNumber,
        }),
      );

      debugPrint('Affiliate register response: ${response.statusCode}'); // response body removed (may contain bank account info)
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return AffiliateModel.fromJson(data['affiliate']);
      }
      return null;
    } catch (e) {
      debugPrint('Error registering affiliate: $e');
      return null;
    }
  }

  /// Get affiliate dashboard
  Future<AffiliateDashboard?> getDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/affiliate/dashboard'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AffiliateDashboard.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting affiliate dashboard: $e');
      return null;
    }
  }

  /// Get commission history
  Future<List<AffiliateCommissionModel>> getCommissions({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/affiliate/commissions?page=$page'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => AffiliateCommissionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting commissions: $e');
      return [];
    }
  }

  /// Get referral link info
  Future<AffiliateReferralLink?> getReferralLink() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/affiliate/referral-link'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AffiliateReferralLink.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting referral link: $e');
      return null;
    }
  }

  /// Request withdrawal
  Future<Map<String, dynamic>?> withdraw({
    required double amount,
    required String method,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/affiliate/withdraw'),
        headers: await _headers,
        body: json.encode({
          'amount': amount,
          'method': method,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'available_balance': data['available_balance'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'เกิดข้อผิดพลาด',
      };
    } catch (e) {
      debugPrint('Error withdrawing: $e');
      return {
        'success': false,
        'message': 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
    }
  }

  /// Get withdrawal history
  Future<List<AffiliateWithdrawalModel>> getWithdrawals({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/affiliate/withdrawals?page=$page'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'] as List<dynamic>? ?? [];
        return list
            .map((e) => AffiliateWithdrawalModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting withdrawals: $e');
      return [];
    }
  }

  /// Update payment info
  Future<bool> updatePaymentInfo({
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
    String? promptpayNumber,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/affiliate/payment-info'),
        headers: await _headers,
        body: json.encode({
          'bank_name': bankName,
          'bank_account_number': bankAccountNumber,
          'bank_account_name': bankAccountName,
          'promptpay_number': promptpayNumber,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating payment info: $e');
      return false;
    }
  }

  /// Track referral (public)
  Future<bool> trackReferral(String referralCode, {String? source}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/affiliate/track'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'referral_code': referralCode,
          'source': source ?? 'link',
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error tracking referral: $e');
      return false;
    }
  }

  // ==================== Local referral code storage ====================

  static const _referralCodeKey = 'pending_referral_code';
  static const _referralExpKey = 'referral_code_expiry';

  /// Save referral code locally (30 day attribution window)
  Future<void> saveReferralCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_referralCodeKey, code);
    final expiry = DateTime.now().add(const Duration(days: 30));
    await prefs.setString(_referralExpKey, expiry.toIso8601String());
    debugPrint('Saved referral code: $code');
  }

  /// Get saved referral code (null if expired)
  Future<String?> getSavedReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_referralCodeKey);
    final expiryStr = prefs.getString(_referralExpKey);

    if (code == null || expiryStr == null) return null;

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null || DateTime.now().isAfter(expiry)) {
      // Expired
      await clearReferralCode();
      return null;
    }

    return code;
  }

  /// Clear saved referral code
  Future<void> clearReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_referralCodeKey);
    await prefs.remove(_referralExpKey);
  }
}
