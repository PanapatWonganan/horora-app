// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// API related exceptions
class ApiException extends AppException {
  ApiException(String message, {String? code}) : super(message, code: code);
}

class NetworkException extends ApiException {
  NetworkException(String message, {String? code}) : super(message, code: code);
}

class ServerException extends ApiException {
  ServerException({String message = 'Server error', String? code})
      : super(message, code: code);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized access', String? code})
      : super(message, code: code);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message, {String? code})
      : super(message, code: code);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = 'Resource not found', String? code})
      : super(message, code: code);
}

// Authentication related exceptions
class AuthException extends ApiException {
  AuthException(String message, {String? code}) : super(message, code: code);
}

// Data related exceptions
class DataException extends ApiException {
  DataException(String message, {String? code}) : super(message, code: code);
}

// Validation related exceptions
class ValidationException extends ApiException {
  ValidationException(String message, {String? code})
      : super(message, code: code);
}

// Cache related exceptions
class CacheException extends ApiException {
  CacheException(String message, {String? code}) : super(message, code: code);
}

// Payment related exceptions
class PaymentException extends AppException {
  PaymentException(String message, {String? code}) : super(message, code: code);
}

class PaymentFailedException extends PaymentException {
  PaymentFailedException(String message, {String? code})
      : super(message, code: code);
}

class SubscriptionException extends PaymentException {
  SubscriptionException(String message, {String? code})
      : super(message, code: code);
}

// Feature related exceptions
class FeatureException extends AppException {
  FeatureException(String message, {String? code}) : super(message, code: code);
}

class PremiumFeatureException extends FeatureException {
  PremiumFeatureException(String message, {String? code})
      : super(message, code: code);
}

class UnsupportedFeatureException extends FeatureException {
  UnsupportedFeatureException(String message, {String? code})
      : super(message, code: code);
}

// Device related exceptions
class DeviceException extends AppException {
  DeviceException(String message, {String? code}) : super(message, code: code);
}

class PermissionDeniedException extends DeviceException {
  PermissionDeniedException(String message, {String? code})
      : super(message, code: code);
}

class StorageException extends DeviceException {
  StorageException(String message, {String? code}) : super(message, code: code);
}

class TimeoutException extends AppException {
  TimeoutException({String message = 'Request timeout', String? code})
      : super(message, code: code);
}

class NoInternetException extends NetworkException {
  NoInternetException({String message = 'No internet connection', String? code})
      : super(message, code: code);
}

class FormatException extends DataException {
  FormatException({String message = 'Invalid format', String? code})
      : super(message, code: code);
}

// Helper function to get user-friendly error message
String getErrorMessage(Exception exception) {
  if (exception is NetworkException) {
    return 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณ';
  } else if (exception is ServerException) {
    return 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์ โปรดลองอีกครั้งในภายหลัง';
  } else if (exception is UnauthorizedException) {
    return 'คุณไม่ได้รับอนุญาตให้เข้าถึงข้อมูลนี้ โปรดเข้าสู่ระบบอีกครั้ง';
  } else if (exception is ForbiddenException) {
    return 'คุณไม่มีสิทธิ์เข้าถึงข้อมูลนี้';
  } else if (exception is NotFoundException) {
    return 'ไม่พบข้อมูลที่คุณต้องการ';
  } else if (exception is ValidationException) {
    return 'ข้อมูลไม่ถูกต้อง โปรดตรวจสอบข้อมูลของคุณ';
  } else if (exception is CacheException) {
    return 'เกิดข้อผิดพลาดในการจัดการข้อมูลแคช';
  } else if (exception is PaymentFailedException) {
    return 'การชำระเงินล้มเหลว โปรดตรวจสอบข้อมูลการชำระเงินของคุณ';
  } else if (exception is SubscriptionException) {
    return 'เกิดข้อผิดพลาดในการจัดการการสมัครสมาชิก';
  } else if (exception is PremiumFeatureException) {
    return 'คุณสมบัตินี้สำหรับสมาชิกพรีเมียมเท่านั้น';
  } else if (exception is UnsupportedFeatureException) {
    return 'คุณสมบัตินี้ไม่รองรับบนอุปกรณ์ของคุณ';
  } else if (exception is PermissionDeniedException) {
    return 'แอปพลิเคชันไม่ได้รับอนุญาตให้เข้าถึงคุณสมบัตินี้';
  } else if (exception is StorageException) {
    return 'เกิดข้อผิดพลาดในการเข้าถึงพื้นที่จัดเก็บข้อมูล';
  } else if (exception is TimeoutException) {
    return 'คุณต้องรอนานเกินไป โปรดลองอีกครั้งในภายหลัง';
  } else if (exception is NoInternetException) {
    return 'ไม่สามารถเชื่อมต่อกับอินเทอร์เน็ต โปรดตรวจสอบสถานะอินเทอร์เน็ตของคุณ';
  } else if (exception is FormatException) {
    return 'รูปแบบข้อมูลไม่ถูกต้อง โปรดตรวจสอบข้อมูลของคุณ';
  } else {
    return 'เกิดข้อผิดพลาดที่ไม่คาดคิด โปรดลองอีกครั้งในภายหลัง';
  }
}
