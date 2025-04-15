import 'package:flutter/material.dart';

/// ฟังก์ชันสำหรับคำนวณราศีจากวันเกิด
class ZodiacUtils {
  /// คำนวณราศีจากวันเกิด
  static String getZodiacSign(DateTime birthDate) {
    int day = birthDate.day;
    int month = birthDate.month;

    // คำนวณราศีตามวันและเดือนเกิด
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return 'aries'; // ราศีเมษ (21 มีนาคม - 19 เมษายน)
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return 'taurus'; // ราศีพฤษภ (20 เมษายน - 20 พฤษภาคม)
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return 'gemini'; // ราศีเมถุน (21 พฤษภาคม - 20 มิถุนายน)
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return 'cancer'; // ราศีกรกฎ (21 มิถุนายน - 22 กรกฎาคม)
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return 'leo'; // ราศีสิงห์ (23 กรกฎาคม - 22 สิงหาคม)
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return 'virgo'; // ราศีกันย์ (23 สิงหาคม - 22 กันยายน)
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return 'libra'; // ราศีตุลย์ (23 กันยายน - 22 ตุลาคม)
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return 'scorpio'; // ราศีพิจิก (23 ตุลาคม - 21 พฤศจิกายน)
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return 'sagittarius'; // ราศีธนู (22 พฤศจิกายน - 21 ธันวาคม)
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return 'capricorn'; // ราศีมังกร (22 ธันวาคม - 19 มกราคม)
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return 'aquarius'; // ราศีกุมภ์ (20 มกราคม - 18 กุมภาพันธ์)
    } else {
      return 'pisces'; // ราศีมีน (19 กุมภาพันธ์ - 20 มีนาคม)
    }
  }

  /// คำนวณราศีจากวันเกิดและคืนค่าเป็นชื่อราศีภาษาไทย
  static String getZodiacSignThai(DateTime birthDate, {String? zodiacSign}) {
    // ถ้ามีการส่ง zodiacSign มา ให้ใช้ค่านั้นเลย ไม่ต้องคำนวณจากวันเกิด
    final sign = zodiacSign ?? getZodiacSign(birthDate);
    
    switch (sign) {
      case 'aries':
        return 'ราศีเมษ';
      case 'taurus':
        return 'ราศีพฤษภ';
      case 'gemini':
        return 'ราศีเมถุน';
      case 'cancer':
        return 'ราศีกรกฎ';
      case 'leo':
        return 'ราศีสิงห์';
      case 'virgo':
        return 'ราศีกันย์';
      case 'libra':
        return 'ราศีตุลย์';
      case 'scorpio':
        return 'ราศีพิจิก';
      case 'sagittarius':
        return 'ราศีธนู';
      case 'capricorn':
        return 'ราศีมังกร';
      case 'aquarius':
        return 'ราศีกุมภ์';
      case 'pisces':
        return 'ราศีมีน';
      default:
        return 'ไม่ทราบราศี';
    }
  }

  /// คำนวณราศีจากวันเกิดและคืนค่าเป็นไอคอนที่เหมาะสม
  static IconData getZodiacIcon(String zodiacSign) {
    switch (zodiacSign.toLowerCase()) {
      case 'aries':
        return Icons.local_fire_department; // ราศีเมษ - ธาตุไฟ
      case 'taurus':
        return Icons.landscape; // ราศีพฤษภ - ธาตุดิน
      case 'gemini':
        return Icons.air; // ราศีเมถุน - ธาตุลม
      case 'cancer':
        return Icons.water_drop; // ราศีกรกฎ - ธาตุน้ำ
      case 'leo':
        return Icons.local_fire_department; // ราศีสิงห์ - ธาตุไฟ
      case 'virgo':
        return Icons.landscape; // ราศีกันย์ - ธาตุดิน
      case 'libra':
        return Icons.air; // ราศีตุลย์ - ธาตุลม
      case 'scorpio':
        return Icons.water_drop; // ราศีพิจิก - ธาตุน้ำ
      case 'sagittarius':
        return Icons.local_fire_department; // ราศีธนู - ธาตุไฟ
      case 'capricorn':
        return Icons.landscape; // ราศีมังกร - ธาตุดิน
      case 'aquarius':
        return Icons.air; // ราศีกุมภ์ - ธาตุลม
      case 'pisces':
        return Icons.water_drop; // ราศีมีน - ธาตุน้ำ
      default:
        return Icons.star; // ค่าเริ่มต้น
    }
  }

  /// คำนวณช่วงวันที่ของราศี
  static String getZodiacDateRange(String zodiacSign) {
    switch (zodiacSign.toLowerCase()) {
      case 'aries':
        return '21 มี.ค. - 19 เม.ย.';
      case 'taurus':
        return '20 เม.ย. - 20 พ.ค.';
      case 'gemini':
        return '21 พ.ค. - 20 มิ.ย.';
      case 'cancer':
        return '21 มิ.ย. - 22 ก.ค.';
      case 'leo':
        return '23 ก.ค. - 22 ส.ค.';
      case 'virgo':
        return '23 ส.ค. - 22 ก.ย.';
      case 'libra':
        return '23 ก.ย. - 22 ต.ค.';
      case 'scorpio':
        return '23 ต.ค. - 21 พ.ย.';
      case 'sagittarius':
        return '22 พ.ย. - 21 ธ.ค.';
      case 'capricorn':
        return '22 ธ.ค. - 19 ม.ค.';
      case 'aquarius':
        return '20 ม.ค. - 18 ก.พ.';
      case 'pisces':
        return '19 ก.พ. - 20 มี.ค.';
      default:
        return '';
    }
  }
} 