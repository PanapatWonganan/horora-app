class Validators {
  // ตรวจสอบอีเมล
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegExp.hasMatch(value)) {
      return 'กรุณากรอกอีเมลให้ถูกต้อง';
    }
    
    return null;
  }
  
  // ตรวจสอบรหัสผ่าน
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    
    if (value.length < 8) {
      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร';
    }
    
    // ตรวจสอบว่ามีตัวอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัว
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'รหัสผ่านต้องมีตัวอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัว';
    }
    
    // ตรวจสอบว่ามีตัวเลขอย่างน้อย 1 ตัว
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัว';
    }
    
    // ตรวจสอบว่ามีอักขระพิเศษอย่างน้อย 1 ตัว
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'รหัสผ่านต้องมีอักขระพิเศษอย่างน้อย 1 ตัว';
    }
    
    return null;
  }
  
  // ตรวจสอบการยืนยันรหัสผ่าน
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'กรุณายืนยันรหัสผ่าน';
    }
    
    if (value != password) {
      return 'รหัสผ่านไม่ตรงกัน';
    }
    
    return null;
  }
  
  // ตรวจสอบชื่อ
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกชื่อ';
    }
    
    if (value.length < 2) {
      return 'ชื่อต้องมีความยาวอย่างน้อย 2 ตัวอักษร';
    }
    
    return null;
  }
  
  // ตรวจสอบวันเกิด
  static String? validateBirthDate(DateTime? value) {
    if (value == null) {
      return 'กรุณาเลือกวันเกิด';
    }
    
    final now = DateTime.now();
    const minimumAge = 13;
    const maximumAge = 120;
    
    // ตรวจสอบว่าอายุไม่น้อยกว่า 13 ปี
    final minimumDate = DateTime(now.year - minimumAge, now.month, now.day);
    if (value.isAfter(minimumDate)) {
      return 'คุณต้องมีอายุอย่างน้อย $minimumAge ปี';
    }
    
    // ตรวจสอบว่าอายุไม่มากกว่า 120 ปี
    final maximumDate = DateTime(now.year - maximumAge, now.month, now.day);
    if (value.isBefore(maximumDate)) {
      return 'วันเกิดไม่ถูกต้อง';
    }
    
    return null;
  }
  
  // ตรวจสอบเวลาเกิด
  static String? validateBirthTime(String? value) {
    if (value == null || value.isEmpty) {
      return null; // เวลาเกิดไม่จำเป็นต้องกรอก
    }
    
    final timeRegExp = RegExp(r'^([01]?[0-9]|2[0-3]):([0-5][0-9])$');
    
    if (!timeRegExp.hasMatch(value)) {
      return 'กรุณากรอกเวลาในรูปแบบ HH:MM';
    }
    
    return null;
  }
  
  // ตรวจสอบสถานที่เกิด
  static String? validateBirthLocation(String? value) {
    if (value == null || value.isEmpty) {
      return null; // สถานที่เกิดไม่จำเป็นต้องกรอก
    }
    
    if (value.length < 2) {
      return 'สถานที่เกิดต้องมีความยาวอย่างน้อย 2 ตัวอักษร';
    }
    
    return null;
  }
  
  // ตรวจสอบหมายเลขบัตรเครดิต
  static String? validateCreditCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกหมายเลขบัตรเครดิต';
    }
    
    // ลบช่องว่างและขีด
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!RegExp(r'^[0-9]{16}$').hasMatch(cleanValue)) {
      return 'หมายเลขบัตรเครดิตไม่ถูกต้อง';
    }
    
    // ตรวจสอบด้วยอัลกอริทึม Luhn
    int sum = 0;
    bool alternate = false;
    
    for (int i = cleanValue.length - 1; i >= 0; i--) {
      int n = int.parse(cleanValue[i]);
      
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      
      sum += n;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) {
      return 'หมายเลขบัตรเครดิตไม่ถูกต้อง';
    }
    
    return null;
  }
  
  // ตรวจสอบวันหมดอายุบัตรเครดิต
  static String? validateCreditCardExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกวันหมดอายุ';
    }
    
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
      return 'กรุณากรอกวันหมดอายุในรูปแบบ MM/YY';
    }
    
    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    
    final now = DateTime.now();
    final expiryDate = DateTime(year, month + 1, 0); // วันสุดท้ายของเดือน
    
    if (expiryDate.isBefore(now)) {
      return 'บัตรเครดิตหมดอายุแล้ว';
    }
    
    return null;
  }
  
  // ตรวจสอบรหัส CVV
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัส CVV';
    }
    
    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
      return 'รหัส CVV ไม่ถูกต้อง';
    }
    
    return null;
  }
  
  // ตรวจสอบหมายเลขโทรศัพท์
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกหมายเลขโทรศัพท์';
    }
    
    // ลบช่องว่างและขีด
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cleanValue)) {
      return 'หมายเลขโทรศัพท์ไม่ถูกต้อง';
    }
    
    return null;
  }
  
  // ตรวจสอบรหัสไปรษณีย์
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสไปรษณีย์';
    }
    
    if (!RegExp(r'^[0-9]{5}$').hasMatch(value)) {
      return 'รหัสไปรษณีย์ไม่ถูกต้อง';
    }
    
    return null;
  }
  
  // ตรวจสอบว่าเป็นตัวเลขหรือไม่
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกตัวเลข';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'กรุณากรอกเฉพาะตัวเลข';
    }
    
    return null;
  }
  
  // ตรวจสอบว่าเป็นตัวเลขที่มีค่ามากกว่า 0 หรือไม่
  static String? validatePositiveNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกตัวเลข';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'กรุณากรอกเฉพาะตัวเลข';
    }
    
    final number = int.parse(value);
    
    if (number <= 0) {
      return 'กรุณากรอกตัวเลขที่มากกว่า 0';
    }
    
    return null;
  }
  
  // ตรวจสอบว่าเป็นตัวเลขที่อยู่ในช่วงที่กำหนดหรือไม่
  static String? validateNumberRange(String? value, int min, int max) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกตัวเลข';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'กรุณากรอกเฉพาะตัวเลข';
    }
    
    final number = int.parse(value);
    
    if (number < min || number > max) {
      return 'กรุณากรอกตัวเลขระหว่าง $min ถึง $max';
    }
    
    return null;
  }
  
  // ตรวจสอบว่าเป็น URL ที่ถูกต้องหรือไม่
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอก URL';
    }
    
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      caseSensitive: false,
    );
    
    if (!urlRegExp.hasMatch(value)) {
      return 'URL ไม่ถูกต้อง';
    }
    
    return null;
  }
} 