import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Centralized SVG Icon paths and helper widget
class AppIcons {
  static const String _basePath = 'assets/images/zodiac';

  // Western Zodiac Signs
  static const String aries = '$_basePath/aries.svg';
  static const String taurus = '$_basePath/taurus.svg';
  static const String gemini = '$_basePath/gemini.svg';
  static const String cancer = '$_basePath/cancer.svg';
  static const String leo = '$_basePath/leo.svg';
  static const String virgo = '$_basePath/virgo.svg';
  static const String libra = '$_basePath/libra.svg';
  static const String scorpio = '$_basePath/scorpio.svg';
  static const String sagittarius = '$_basePath/sagittarius.svg';
  static const String capricorn = '$_basePath/capricorn.svg';
  static const String aquarius = '$_basePath/aquarius.svg';
  static const String pisces = '$_basePath/pisces.svg';

  // Thai Zodiac Animals (12 นักษัตร)
  static const String rat = '$_basePath/rat.svg';         // ชวด
  static const String ox = '$_basePath/ox.svg';           // ฉลู
  static const String tiger = '$_basePath/tiger.svg';     // ขาล
  static const String rabbit = '$_basePath/rabbit.svg';   // เถาะ
  static const String dragon = '$_basePath/dragon.svg';   // มะโรง
  static const String snake = '$_basePath/snake.svg';     // มะเส็ง
  static const String horse = '$_basePath/horse.svg';     // มะเมีย
  static const String goat = '$_basePath/goat.svg';       // มะแม
  static const String monkey = '$_basePath/monkey.svg';   // วอก
  static const String rooster = '$_basePath/rooster.svg'; // ระกา
  static const String dog = '$_basePath/dog.svg';         // จอ
  static const String pig = '$_basePath/pig.svg';         // กุน

  // Elements (ธาตุ)
  static const String fire = '$_basePath/fire.svg';
  static const String earth = '$_basePath/earth.svg';
  static const String water = '$_basePath/water.svg';
  static const String air = '$_basePath/air.svg';

  // Navigation Icons
  static const String home = '$_basePath/home.svg';
  static const String homeFilled = '$_basePath/home_filled.svg';
  static const String chat = '$_basePath/chat.svg';
  static const String chatFilled = '$_basePath/chat_filled.svg';
  static const String person = '$_basePath/person.svg';
  static const String personFilled = '$_basePath/person_filled.svg';
  static const String sparkle = '$_basePath/sparkle.svg';
  static const String sparkleFilled = '$_basePath/sparkle_filled.svg';

  // Feature Icons
  static const String love = '$_basePath/love.svg';
  static const String career = '$_basePath/career.svg';
  static const String finance = '$_basePath/finance.svg';
  static const String health = '$_basePath/health.svg';
  static const String fortune = '$_basePath/fortune.svg';
  static const String divination = '$_basePath/divination.svg';
  static const String meditation = '$_basePath/meditation.svg';
  static const String pray = '$_basePath/pray.svg';
  static const String temple = '$_basePath/temple.svg';
  static const String amulet = '$_basePath/amulet.svg';

  // UI Icons
  static const String star = '$_basePath/star.svg';
  static const String starFilled = '$_basePath/star_filled.svg';
  static const String starOutline = '$_basePath/star_outline.svg';
  static const String heart = '$_basePath/heart.svg';
  static const String heartOutline = '$_basePath/heart_outline.svg';
  static const String bookmark = '$_basePath/bookmark.svg';
  static const String bookmarkOutline = '$_basePath/bookmark_outline.svg';
  static const String settings = '$_basePath/settings.svg';
  static const String history = '$_basePath/history.svg';
  static const String calendar = '$_basePath/calendar.svg';
  static const String clock = '$_basePath/clock.svg';
  static const String notification = '$_basePath/notification.svg';
  static const String info = '$_basePath/info.svg';
  static const String lock = '$_basePath/lock.svg';
  static const String check = '$_basePath/check.svg';
  static const String close = '$_basePath/close.svg';
  static const String arrowBack = '$_basePath/arrow_back.svg';
  static const String arrowForward = '$_basePath/arrow_forward.svg';
  static const String send = '$_basePath/send.svg';
  static const String share = '$_basePath/share.svg';
  static const String copy = '$_basePath/copy.svg';
  static const String flag = '$_basePath/flag.svg';
  static const String pin = '$_basePath/pin.svg';
  static const String gallery = '$_basePath/gallery.svg';
  static const String camera = '$_basePath/camera.svg';
  static const String qrCode = '$_basePath/qr_code.svg';
  static const String work = '$_basePath/work.svg';
  static const String money = '$_basePath/money.svg';
  static const String color = '$_basePath/color.svg';
  static const String diamond = '$_basePath/diamond.svg';
  static const String numbers = '$_basePath/numbers.svg';
  static const String palette = '$_basePath/palette.svg';
  static const String visibility = '$_basePath/visibility.svg';
  static const String visibilityOff = '$_basePath/visibility_off.svg';
  static const String email = '$_basePath/email.svg';
  static const String family = '$_basePath/family.svg';
  static const String education = '$_basePath/education.svg';
  static const String edit = '$_basePath/edit.svg';
  static const String checkCircle = '$_basePath/check_circle.svg';
  static const String logout = '$_basePath/logout.svg';
  static const String error = '$_basePath/error.svg';

  // Social Icons
  static const String google = '$_basePath/google.svg';
  static const String facebook = '$_basePath/facebook.svg';

  // Flag Icons (Languages)
  static const String flagTh = '$_basePath/th.svg';
  static const String flagGb = '$_basePath/gb.svg';
  static const String flagCn = '$_basePath/cn.svg';
  static const String flagJp = '$_basePath/jp.svg';
  static const String flagKr = '$_basePath/kr.svg';

  // Map Thai zodiac animal names to SVG paths
  static const Map<String, String> thaiZodiacIcons = {
    'ชวด': rat,
    'ฉลู': ox,
    'ขาล': tiger,
    'เถาะ': rabbit,
    'มะโรง': dragon,
    'มะเส็ง': snake,
    'มะเมีย': horse,
    'มะแม': goat,
    'วอก': monkey,
    'ระกา': rooster,
    'จอ': dog,
    'กุน': pig,
  };

  /// Get Thai zodiac icon path by animal name
  static String getThaiZodiacIcon(String animal) {
    return thaiZodiacIcons[animal] ?? dragon;
  }

  // Map Western zodiac names to SVG paths
  static const Map<String, String> westernZodiacIcons = {
    'aries': aries,
    'taurus': taurus,
    'gemini': gemini,
    'cancer': cancer,
    'leo': leo,
    'virgo': virgo,
    'libra': libra,
    'scorpio': scorpio,
    'sagittarius': sagittarius,
    'capricorn': capricorn,
    'aquarius': aquarius,
    'pisces': pisces,
  };

  /// Get Western zodiac icon path by sign name
  static String getWesternZodiacIcon(String sign) {
    return westernZodiacIcons[sign.toLowerCase()] ?? aries;
  }
}

/// A convenient widget for displaying SVG icons
class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  const SvgIcon(
    this.assetPath, {
    Key? key,
    this.size,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = width ?? size ?? 24;
    final h = height ?? size ?? 24;

    return SvgPicture.asset(
      assetPath,
      width: w,
      height: h,
      fit: fit,
      alignment: alignment,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}

/// A widget that displays Thai zodiac animal icon
class ThaiZodiacIcon extends StatelessWidget {
  final String animal;
  final double size;
  final Color? color;

  const ThaiZodiacIcon({
    Key? key,
    required this.animal,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgIcon(
      AppIcons.getThaiZodiacIcon(animal),
      size: size,
      color: color,
    );
  }
}

/// A widget that displays Western zodiac sign icon
class WesternZodiacIcon extends StatelessWidget {
  final String sign;
  final double size;
  final Color? color;

  const WesternZodiacIcon({
    Key? key,
    required this.sign,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgIcon(
      AppIcons.getWesternZodiacIcon(sign),
      size: size,
      color: color,
    );
  }
}
