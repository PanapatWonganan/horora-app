import 'package:flutter/foundation.dart';
import '../../core/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  String? _userZodiacSign;
  String? get userZodiacSign => _userZodiacSign;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  UserProvider({
    required UserRepository userRepository,
  })  : _userRepository = userRepository;

  // เริ่มต้นโหลดข้อมูลผู้ใช้
  Future<void> initialize() async {
    try {
      _setLoading(true);

      // โหลดข้อมูลผู้ใช้ (ถ้ามี)
      final user = await _userRepository.getCurrentUser();
      if (user != null && user.birthDate != null) {
        _userZodiacSign = _calculateZodiacSign(user.birthDate!);
      }

      _setLoading(false);
    } catch (e) {
      _setError('ไม่สามารถโหลดข้อมูลผู้ใช้: ${e.toString()}');
    }
  }

  // คำนวณราศีจากวันเกิด
  String _calculateZodiacSign(DateTime birthDate) {
    final int day = birthDate.day;
    final int month = birthDate.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'aries';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'taurus';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) {
      return 'gemini';
    } else if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) {
      return 'cancer';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 'leo';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 'virgo';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) {
      return 'libra';
    } else if ((month == 10 && day >= 24) || (month == 11 && day <= 21)) {
      return 'scorpio';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'sagittarius';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'capricorn';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'aquarius';
    } else {
      return 'pisces';
    }
  }

  // ตั้งค่าราศีของผู้ใช้
  void setUserZodiacSign(String sign) {
    _userZodiacSign = sign;
    notifyListeners();
  }

  // ตั้งค่าสถานะกำลังโหลด
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    _error = null;
    notifyListeners();
  }

  // ตั้งค่าข้อผิดพลาด
  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
