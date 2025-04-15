import 'package:intl/intl.dart';

class Formatters {
  // แปลงวันที่เป็นรูปแบบ dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  // แปลงวันที่เป็นรูปแบบ dd MMM yyyy (ภาษาไทย)
  static String formatDateThai(DateTime date) {
    final thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    
    return '${date.day} ${thaiMonths[date.month - 1]} ${date.year + 543}';
  }
  
  // แปลงวันที่เป็นรูปแบบ dd MMM yyyy (ภาษาอังกฤษ)
  static String formatDateEnglish(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
  
  // แปลงเวลาเป็นรูปแบบ HH:mm
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
  
  // แปลงวันที่และเวลาเป็นรูปแบบ dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  // แปลงวันที่และเวลาเป็นรูปแบบ dd MMM yyyy, HH:mm (ภาษาไทย)
  static String formatDateTimeThai(DateTime dateTime) {
    final thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    
    return '${dateTime.day} ${thaiMonths[dateTime.month - 1]} ${dateTime.year + 543}, ${DateFormat('HH:mm').format(dateTime)}';
  }
  
  // แปลงวันที่และเวลาเป็นรูปแบบ dd MMM yyyy, HH:mm (ภาษาอังกฤษ)
  static String formatDateTimeEnglish(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }
  
  // แปลงวันที่เป็นรูปแบบ "เมื่อ x นาที/ชั่วโมง/วัน/สัปดาห์/เดือน/ปีที่แล้ว"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'เมื่อสักครู่';
    } else if (difference.inMinutes < 60) {
      return 'เมื่อ ${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours < 24) {
      return 'เมื่อ ${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays < 7) {
      return 'เมื่อ ${difference.inDays} วันที่แล้ว';
    } else if (difference.inDays < 30) {
      return 'เมื่อ ${(difference.inDays / 7).floor()} สัปดาห์ที่แล้ว';
    } else if (difference.inDays < 365) {
      return 'เมื่อ ${(difference.inDays / 30).floor()} เดือนที่แล้ว';
    } else {
      return 'เมื่อ ${(difference.inDays / 365).floor()} ปีที่แล้ว';
    }
  }
  
  // แปลงจำนวนเงินเป็นรูปแบบ #,##0.00
  static String formatCurrency(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }
  
  // แปลงจำนวนเงินเป็นรูปแบบ #,##0.00 บาท
  static String formatCurrencyThai(double amount) {
    return '${NumberFormat('#,##0.00').format(amount)} บาท';
  }
  
  // แปลงจำนวนเงินเป็นรูปแบบ ฿#,##0.00
  static String formatCurrencySymbol(double amount) {
    return '฿${NumberFormat('#,##0.00').format(amount)}';
  }
  
  // แปลงเปอร์เซ็นต์เป็นรูปแบบ #0.0%
  static String formatPercentage(double percentage) {
    return NumberFormat('#0.0%').format(percentage / 100);
  }
  
  // แปลงเวลาเป็นรูปแบบ HH:mm:ss
  static String formatTimeWithSeconds(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }
  
  // แปลงเวลาในรูปแบบวินาทีเป็นรูปแบบ mm:ss
  static String formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  // แปลงเวลาในรูปแบบวินาทีเป็นรูปแบบ hh:mm:ss
  static String formatDurationLong(int seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final remainingSeconds = seconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  // แปลงเวลาในรูปแบบวินาทีเป็นข้อความ (เช่น 1 ชั่วโมง 30 นาที)
  static String formatDurationText(int seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final remainingSeconds = seconds % 60;
    
    String result = '';
    
    if (hours > 0) {
      result += '$hours ชั่วโมง ';
    }
    
    if (minutes > 0) {
      result += '$minutes นาที ';
    }
    
    if (remainingSeconds > 0 && hours == 0) {
      result += '$remainingSeconds วินาที';
    }
    
    return result.trim();
  }
  
  // แปลงหมายเลขบัตรเครดิตเป็นรูปแบบ **** **** **** 1234
  static String formatCreditCardNumber(String cardNumber) {
    // ลบช่องว่างและขีด
    final cleanNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cleanNumber.length < 4) {
      return cleanNumber;
    }
    
    final lastFourDigits = cleanNumber.substring(cleanNumber.length - 4);
    return '**** **** **** $lastFourDigits';
  }
  
  // แปลงหมายเลขโทรศัพท์เป็นรูปแบบ 0xx-xxx-xxxx
  static String formatPhoneNumber(String phoneNumber) {
    // ลบช่องว่างและขีด
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cleanNumber.length != 10) {
      return phoneNumber;
    }
    
    return '${cleanNumber.substring(0, 3)}-${cleanNumber.substring(3, 6)}-${cleanNumber.substring(6)}';
  }
  
  // แปลงขนาดไฟล์เป็นรูปแบบ KB, MB, GB
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      final gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} GB';
    }
  }
  
  // แปลงจำนวนเป็นข้อความตัวเลขไทย
  static String formatNumberToThai(int number) {
    final thaiDigits = ['๐', '๑', '๒', '๓', '๔', '๕', '๖', '๗', '๘', '๙'];
    final numberString = number.toString();
    
    String result = '';
    for (int i = 0; i < numberString.length; i++) {
      final digit = int.parse(numberString[i]);
      result += thaiDigits[digit];
    }
    
    return result;
  }
  
  // แปลงวันที่เป็นวันในสัปดาห์ภาษาไทย
  static String formatDayOfWeekThai(DateTime date) {
    final thaiDaysOfWeek = [
      'อาทิตย์', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์'
    ];
    
    return 'วัน${thaiDaysOfWeek[date.weekday % 7]}';
  }
  
  // แปลงวันที่เป็นวันในสัปดาห์ภาษาอังกฤษ
  static String formatDayOfWeekEnglish(DateTime date) {
    return DateFormat('EEEE').format(date);
  }
} 