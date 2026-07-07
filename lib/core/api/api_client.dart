import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/exceptions.dart' as ex;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../config/constants.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Map<String, String> _defaultHeaders;

  /// เรียกเมื่อ server ตอบ 401 (token หมดอายุ/ถูกเพิกถอน)
  /// ใช้ให้ฝั่ง auth เคลียร์ session โดยไม่ต้อง import กันเป็นวง
  void Function()? onUnauthorized;

  ApiClient({
    String? baseUrl,
    http.Client? httpClient,
    Map<String, String>? defaultHeaders,
    this.onUnauthorized,
  })  : baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _httpClient = httpClient ?? http.Client(),
        _defaultHeaders =
            defaultHeaders ?? {'Content-Type': 'application/json', 'Accept': 'application/json'};

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
      return !connectivityResult.contains(ConnectivityResult.none);
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
      {Map<String, dynamic>? body, Map<String, dynamic>? data, Map<String, String>? headers}) async {
    return _sendRequest('POST', endpoint, body: data ?? body, headers: headers);
  }

  // ส่งคำขอ PUT
  Future<dynamic> put(String endpoint,
      {Map<String, dynamic>? body, Map<String, dynamic>? data, Map<String, String>? headers}) async {
    return _sendRequest('PUT', endpoint, body: data ?? body, headers: headers);
  }

  // ส่งคำขอ PATCH
  Future<dynamic> patch(String endpoint,
      {Map<String, dynamic>? body, Map<String, dynamic>? data, Map<String, String>? headers}) async {
    return _sendRequest('PATCH', endpoint, body: data ?? body, headers: headers);
  }

  // ส่งคำขอ DELETE
  Future<dynamic> delete(String endpoint,
      {Map<String, dynamic>? body, Map<String, dynamic>? data, Map<String, String>? headers}) async {
    return _sendRequest('DELETE', endpoint, body: data ?? body, headers: headers);
  }

  // สร้าง MultipartFile จากไฟล์
  Future<http.MultipartFile> createMultipartFile(String filePath, {String fieldName = 'file'}) async {
    final file = File(filePath);
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();

    // กำหนด content type ตามนามสกุลไฟล์
    MediaType? contentType;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = MediaType('image', 'jpeg');
        break;
      case 'png':
        contentType = MediaType('image', 'png');
        break;
      case 'gif':
        contentType = MediaType('image', 'gif');
        break;
      case 'pdf':
        contentType = MediaType('application', 'pdf');
        break;
      default:
        contentType = MediaType('application', 'octet-stream');
    }

    return http.MultipartFile.fromPath(
      fieldName,
      filePath,
      filename: fileName,
      contentType: contentType,
    );
  }

  // ส่งคำขอ POST แบบ Multipart (สำหรับอัปโหลดไฟล์)
  Future<dynamic> postMultipart(String endpoint, {
    Map<String, dynamic>? formData,
    Map<String, String>? headers,
  }) async {
    final hasConnectivity = await _checkConnectivity();
    if (!hasConnectivity) {
      throw ex.NoInternetException();
    }

    try {
      final Uri uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // เพิ่ม headers
      final Map<String, String> requestHeaders = {..._defaultHeaders};
      requestHeaders.remove('Content-Type'); // ให้ http package จัดการ Content-Type เอง
      if (headers != null) {
        requestHeaders.addAll(headers);
      }
      request.headers.addAll(requestHeaders);

      // เพิ่มข้อมูลใน form
      if (formData != null) {
        for (final entry in formData.entries) {
          if (entry.value is http.MultipartFile) {
            request.files.add(entry.value as http.MultipartFile);
          } else if (entry.value != null) {
            request.fields[entry.key] = entry.value.toString();
          }
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw ex.TimeoutException(),
      );

      final response = await http.Response.fromStream(streamedResponse);
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
      case 422:
        // Laravel validation error — ดึง message ภาษาไทยจาก server มาโชว์ตรงๆ
        // (เช่น "สิทธิ์มูฟรีใช้ได้ 1 ครั้งต่อผู้ใช้ค่ะ") + แนบ code (ถ้ามี)
        // ให้ฝั่งเรียกแยกเคสธุรกิจ (เช่น 'free_trial_used') จาก error ทั่วไป
        throw ex.ValidationException(
          _extractMessage(response.body) ??
              'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง',
          code: _extractField(response.body, 'code'),
        );
      case 401:
        // token หมดอายุ/ถูกเพิกถอน → แจ้งให้ auth เคลียร์ session (กัน stale login)
        clearAuthToken();
        onUnauthorized?.call();
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

  // ดึงฟิลด์ message จาก error body (รูปแบบ Laravel) — null ถ้า parse ไม่ได้
  String? _extractMessage(String body) => _extractField(body, 'message');

  // ดึง string field ใดๆ จาก error body (top-level) — null ถ้าไม่มี/parse ไม่ได้
  String? _extractField(String body, String field) {
    try {
      final decoded = jsonDecode(body);
      final value = decoded is Map<String, dynamic> ? decoded[field] : null;
      return value is String && value.isNotEmpty ? value : null;
    } catch (_) {
      return null;
    }
  }

  // ปิดการเชื่อมต่อ
  void dispose() {
    _httpClient.close();
  }
}
