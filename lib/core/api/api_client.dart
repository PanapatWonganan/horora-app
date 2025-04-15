import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/exceptions.dart' as ex;
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Map<String, String> _defaultHeaders;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    Map<String, String>? defaultHeaders,
  })  : _httpClient = httpClient ?? http.Client(),
        _defaultHeaders =
            defaultHeaders ?? {'Content-Type': 'application/json'};

  // เพิ่ม token สำหรับการยืนยันตัวตน
  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  // ล้าง token เมื่อออกจากระบบ
  void clearAuthToken() {
    _defaultHeaders.remove('Authorization');
  }

  // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // ส่งคำขอ GET
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    return _sendRequest('GET', endpoint,
        queryParams: queryParams, headers: headers);
  }

  // ส่งคำขอ POST
  Future<dynamic> post(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _sendRequest('POST', endpoint, body: body, headers: headers);
  }

  // ส่งคำขอ PUT
  Future<dynamic> put(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _sendRequest('PUT', endpoint, body: body, headers: headers);
  }

  // ส่งคำขอ PATCH
  Future<dynamic> patch(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _sendRequest('PATCH', endpoint, body: body, headers: headers);
  }

  // ส่งคำขอ DELETE
  Future<dynamic> delete(String endpoint,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _sendRequest('DELETE', endpoint, body: body, headers: headers);
  }

  // เมธอดหลักสำหรับส่งคำขอ
  Future<dynamic> _sendRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
    final hasConnectivity = await _checkConnectivity();
    if (!hasConnectivity) {
      throw ex.NoInternetException();
    }

    try {
      // สร้าง URI
      final Uri uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );

      // รวมส่วนหัว
      final Map<String, String> requestHeaders = {..._defaultHeaders};
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      http.Response response;

      // ส่งคำขอตามประเภท
      switch (method) {
        case 'GET':
          response = await _httpClient
              .get(uri, headers: requestHeaders)
              .timeout(const Duration(seconds: 30),
                  onTimeout: () => throw ex.TimeoutException());
          break;
        case 'POST':
          response = await _httpClient
              .post(uri,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(const Duration(seconds: 30),
                  onTimeout: () => throw ex.TimeoutException());
          break;
        case 'PUT':
          response = await _httpClient
              .put(uri,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(const Duration(seconds: 30),
                  onTimeout: () => throw ex.TimeoutException());
          break;
        case 'PATCH':
          response = await _httpClient
              .patch(uri,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(const Duration(seconds: 30),
                  onTimeout: () => throw ex.TimeoutException());
          break;
        case 'DELETE':
          response = await _httpClient
              .delete(uri,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null)
              .timeout(const Duration(seconds: 30),
                  onTimeout: () => throw ex.TimeoutException());
          break;
        default:
          throw ex.AppException('Unsupported HTTP method: $method');
      }

      // แปลงคำตอบ
      return _handleResponse(response);
    } on SocketException {
      throw ex.NetworkException('Network error occurred');
    } on HttpException {
      throw ex.NetworkException('HTTP error occurred');
    } on FormatException {
      throw ex.FormatException();
    } catch (e) {
      if (e is ex.AppException) {
        rethrow;
      }
      throw ex.AppException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // จัดการการตอบกลับจาก API
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    switch (statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        if (response.body.isEmpty) {
          return {};
        }
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return response.body;
        }
      case 400:
        throw ex.ValidationException('Bad request: ${response.body}');
      case 401:
        throw ex.UnauthorizedException();
      case 403:
        throw ex.ForbiddenException('Access forbidden');
      case 404:
        throw ex.NotFoundException();
      case 500:
      case 502:
      case 503:
      case 504:
        throw ex.ServerException();
      default:
        throw ex.ApiException('API error with status code: $statusCode');
    }
  }

  // ปิดการเชื่อมต่อ
  void dispose() {
    _httpClient.close();
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ValidationException extends ApiException {
  final dynamic errors;

  ValidationException(String message, this.errors) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class RequestCancelledException extends ApiException {
  RequestCancelledException(String message) : super(message);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class UnknownException extends ApiException {
  UnknownException(String message) : super(message);
}
