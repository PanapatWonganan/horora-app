import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../api/api_client.dart';
import 'laravel_auth_service.dart';

class ReportService {
  final ApiClient _apiClient;

  ReportService() : _apiClient = LaravelAuthService.instance.apiClient;

  Future<bool> reportContent({
    required String contentId,
    required String contentType,
    required ReportReason reason,
    String? additionalDetails,
    String? contentSnapshot,
  }) async {
    try {
      final isLoggedIn = await LaravelAuthService.instance.isLoggedIn();
      if (!isLoggedIn) {
        throw Exception('User must be logged in to report content');
      }

      final user = LaravelAuthService.instance.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to report content');
      }

      await _apiClient.post('/reports', data: {
        'content_id': contentId,
        'content_type': contentType,
        'reason': reason.value,
        'additional_details': additionalDetails,
        'content_snapshot': contentSnapshot,
      });

      return true;
    } catch (e) {
      debugPrint('Error reporting content: $e');
      return false;
    }
  }

  Future<List<ContentReport>> getUserReports() async {
    try {
      final isLoggedIn = await LaravelAuthService.instance.isLoggedIn();
      if (!isLoggedIn) {
        return [];
      }

      final response = await _apiClient.get('/reports');
      final List<dynamic> data = response as List;
      return data.map((json) => ContentReport.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching user reports: $e');
      return [];
    }
  }

  Future<bool> hasUserReportedContent(String contentId) async {
    try {
      final isLoggedIn = await LaravelAuthService.instance.isLoggedIn();
      if (!isLoggedIn) return false;

      final response = await _apiClient.get('/reports/check/$contentId');
      return response['reported'] == true;
    } catch (e) {
      debugPrint('Error checking report status: $e');
      return false;
    }
  }
}
