import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/app_icons.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import 'widgets/daily_horoscope_card.dart';
import 'widgets/promo_banner_slider.dart';
import 'widgets/in_app_message_dialog.dart';

// RouteObserver สำหรับตรวจจับการกลับมาที่หน้า home
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

// Static variable เก็บสถานะว่าเคยออกจาก home ไปหรือยัง
class HomeScreenState {
  static bool hasLeftHome = false;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "คุณ"; // จะถูกอัพเดทจาก user repository
  final DateTime _today = DateTime.now();
  final _authService = AuthService.instance;

  // รายการแบนเนอร์โปรโมชั่น - สามารถแก้ไขได้ตามต้องการ
  final List<PromoBanner> _promoBanners = [
    const PromoBanner(
      imageUrl: 'assets/images/banners/banner_new_year.webp',
      linkUrl: 'https://lin.ee/XIF2jaM',
    ),
    const PromoBanner(
      imageUrl: 'assets/images/banners/promo1.webp',
      linkUrl: 'https://lin.ee/XIF2jaM',
    ),
    const PromoBanner(
      imageUrl: 'assets/images/banners/special_offer.webp',
      linkUrl: 'https://lin.ee/XIF2jaM',
    ),
  ];

  // In-App Messages - สามารถแก้ไขข้อความได้ตามต้องการ
  final List<InAppMessage> _inAppMessages = [
    const InAppMessage(
      imageUrl: 'assets/images/banners/special_offer.webp',
      title: '✨ วอลเปเปอร์มงคลส่วนบุคคล ✨',
      subtitle: 'เสริมดวง เรียกทรัพย์ ด้วยวอลเปเปอร์ที่ออกแบบเฉพาะคุณ! คำนวณจากวันเกิดและราศีของคุณโดยเฉพาะ พลังแห่งโชคลาภจะอยู่ในมือคุณทุกวัน',
      buttonText: 'สั่งซื้อเลย',
      buttonUrl: 'https://lin.ee/XIF2jaM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();

    // แสดง In-App Message ทุกครั้งที่เข้าหน้า Home
    _showInAppMessage();
  }

  @override
  void dispose() {
    // บันทึกว่าออกจากหน้า Home แล้ว
    HomeScreenState.hasLeftHome = true;
    super.dispose();
  }

  void _showInAppMessage() {
    if (_inAppMessages.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          InAppMessageDialog.show(
            context,
            message: _inAppMessages[0],
          );
        }
      });
    }
  }

  Future<void> _loadUserName() async {
    final user = _authService.currentUser;
    if (user != null) {
      if (user.name.isNotEmpty) {
        setState(() {
          _userName = user.name;
        });
      } else if (user.email.isNotEmpty) {
        // ถ้าไม่มีชื่อ ใช้อีเมลแทน
        setState(() {
          _userName = user.email.split('@')[0]; // ใช้ส่วนแรกของอีเมลก่อน @
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBackground,
              AppColors.cream,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Soft celestial wash — gentle pastel glows drifting behind content.
            Positioned(
              top: -90,
              right: -70,
              child: _softGlow(220, AppColors.primaryGradient.first),
            ),
            Positioned(
              top: 160,
              left: -90,
              child: _softGlow(200, AppColors.mysticalGradient.last),
            ),
            // Faint scattered stars for atmosphere.
            Positioned(
              top: 70,
              left: 30,
              child: _starSpeck(AppIcons.star, 12, 0.35),
            ),
            Positioned(
              top: 130,
              right: 50,
              child: _starSpeck(AppIcons.sparkle, 16, 0.4),
            ),
            Positioned(
              top: 240,
              left: 60,
              child: _starSpeck(AppIcons.sparkle, 10, 0.3),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildPromoBanners(),
                      const SizedBox(height: 28),
                      // ทำบุญออนไลน์ - Main Feature
                      _buildMeritHighlight(),
                      const SizedBox(height: 28),
                      _buildDailyHoroscope(),
                      const SizedBox(height: 28),
                      _buildFeatures(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  /// A soft circular pastel glow used as ambient background atmosphere.
  Widget _softGlow(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.35),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  /// A faint decorative star/sparkle speck.
  Widget _starSpeck(String asset, double size, double opacity) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          asset,
          width: size,
          height: size,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
      ),
    );
  }

  /// Display font used for English words / numerals in section headings.
  TextStyle _displayStyle({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      color: color ?? AppColors.deepText,
      fontWeight: fontWeight,
      letterSpacing: 0.2,
    );
  }

  /// A small section heading: Thai title (Kanit) with a gentle sparkle accent.
  Widget _sectionTitle(String title) {
    return Row(
      children: [
        SvgPicture.asset(
          AppIcons.sparkleFilled,
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'สวัสดีค่ะ',
                    style: GoogleFonts.kanit(
                      color: AppColors.mutedText,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    AppIcons.sparkleFilled,
                    width: 15,
                    height: 15,
                    colorFilter:
                        const ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'คุณ$_userName',
                style: GoogleFonts.kanit(
                  color: AppColors.deepText,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'th_TH').format(_today),
                style: GoogleFonts.kanit(
                  color: AppColors.mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            _showProfileOptions(context);
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightSurface,
              ),
              child: const Center(
                child: SvgIcon(
                  AppIcons.personFilled,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const SvgIcon(AppIcons.person,
                    size: 24, color: AppColors.primary),
                title: Text('โปรไฟล์',
                    style: GoogleFonts.kanit(color: AppColors.deepText)),
                onTap: () {
                  Navigator.pop(context);
                  AppRouter.navigateTo(context, AppRoutes.profile);
                },
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const SvgIcon(AppIcons.settings,
                    size: 24, color: AppColors.primary),
                title: Text('ตั้งค่า',
                    style: GoogleFonts.kanit(color: AppColors.deepText)),
                onTap: () {
                  Navigator.pop(context);
                  AppRouter.navigateTo(context, AppRoutes.settings);
                },
              ),
              const Divider(color: AppColors.divider),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const SvgIcon(AppIcons.logout,
                    size: 24, color: AppColors.error),
                title: Text('ออกจากระบบ',
                    style: GoogleFonts.kanit(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(context);
                  await _signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // Navigation will be handled by AuthWrapper
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ออกจากระบบไม่สำเร็จ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildPromoBanners() {
    return PromoBannerSlider(
      banners: _promoBanners,
      height: 130,
      autoPlayDuration: const Duration(seconds: 4),
    );
  }

  Widget _buildDailyHoroscope() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today',
          style: _displayStyle(
            fontSize: 15,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ).copyWith(letterSpacing: 1.5),
        ),
        const SizedBox(height: 2),
        _sectionTitle('ดวงประจำวันของคุณ'),
        const SizedBox(height: 16),
        DailyHoroscopeCard(
          zodiacSign: "", // Empty string since zodiac sign is removed
          date: _today,
          onViewDetails: () {
            Navigator.pushNamed(context, AppRoutes.dailyHoroscope);
          },
        ),
      ],
    );
  }

  Widget _buildMeritHighlight() {
    return GestureDetector(
      onTap: () {
        // ไม่แสดงโฆษณาเพราะเป็น flow การซื้อของ
        Navigator.pushNamed(context, AppRoutes.merit);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFE6B8), // soft gold
              Color(0xFFFFD0AE), // warm peach-gold
              Color(0xFFFFC1B0), // blush peach
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            const Positioned(
              right: -28,
              top: -28,
              child: Opacity(
                opacity: 0.18,
                child: SvgIcon(
                  AppIcons.temple,
                  size: 150,
                  color: Color(0xFFFF8C5A),
                ),
              ),
            ),
            const Positioned(
              left: -18,
              bottom: -18,
              child: Opacity(
                opacity: 0.16,
                child: SvgIcon(
                  AppIcons.sparkleFilled,
                  size: 80,
                  color: Color(0xFFFF8C5A),
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8C5A).withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const SvgIcon(
                        AppIcons.temple,
                        size: 32,
                        color: Color(0xFFE07A4A),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ทำบุญออนไลน์',
                            style: GoogleFonts.kanit(
                              color: const Color(0xFF5C3A24),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'สะดวก รวดเร็ว ได้บุญจริง',
                            style: GoogleFonts.kanit(
                              color: const Color(0xFF7A5238),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'ไหว้พระ ขอพร สถานที่ศักดิ์สิทธิ์ทั่วไทย\nเสริมดวง เรียกทรัพย์ ชีวิตรุ่งเรือง',
                  style: GoogleFonts.kanit(
                    color: const Color(0xFF6B4A33),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8C5A).withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SvgIcon(
                        AppIcons.heart,
                        size: 20,
                        color: Color(0xFFE07A4A),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'เริ่มทำบุญเลย',
                        style: GoogleFonts.kanit(
                          color: const Color(0xFFD4683A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SvgIcon(
                        AppIcons.arrowForward,
                        size: 20,
                        color: Color(0xFFE07A4A),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('บริการอื่นๆ'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallFeatureCard(
                title: 'ไพ่ทาโรต์',
                svgIconPath: AppIcons.divination,
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.tarot),
                useIconColor: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallFeatureCard(
                title: 'พ่อหมอโหรา',
                svgIconPath: AppIcons.chatFilled,
                color: AppColors.primary,
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.chat),
                useIconColor: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallFeatureCard(
                title: 'โหราศาสตร์',
                svgIconPath: AppIcons.starFilled,
                color: AppColors.accent,
                onTap: () => Navigator.pushNamed(context, AppRoutes.horoscope),
                useIconColor: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSmallFeatureCard({
    required String title,
    required String svgIconPath,
    required Color color,
    required VoidCallback onTap,
    bool useIconColor = false, // ถ้า true จะไม่ใส่สีทับ (ใช้สีจาก SVG)
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.28),
                    color.withValues(alpha: 0.14),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: SvgIcon(
                svgIconPath,
                size: 24,
                color: useIconColor ? null : color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
