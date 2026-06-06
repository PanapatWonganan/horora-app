import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/celestial_effects.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _userName = "คุณ"; // จะถูกอัพเดทจาก user repository
  final DateTime _today = DateTime.now();
  final _authService = AuthService.instance;

  // Slow, continuous rotation for the celestial Lottie accent (the home
  // signature moment). Driven once — not rebuilt per frame in the tree.
  late final AnimationController _celestialRotation;

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
    _celestialRotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _loadUserName();

    // แสดง In-App Message ทุกครั้งที่เข้าหน้า Home
    _showInAppMessage();
  }

  @override
  void dispose() {
    _celestialRotation.dispose();
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
        decoration: const BoxDecoration(gradient: celestialBackdrop),
        child: Stack(
          children: [
            // ── Gradient-mesh atmosphere: layered pastel glows at the corners.
            const Positioned(
              top: -120,
              left: -90,
              child: CelestialGlow(
                size: 300,
                color: AppColors.primary,
                intensity: 0.30,
              ),
            ),
            const Positioned(
              top: -80,
              right: -100,
              child: CelestialGlow(
                size: 280,
                color: AppColors.secondary,
                intensity: 0.28,
              ),
            ),
            const Positioned(
              bottom: -110,
              left: -60,
              child: CelestialGlow(
                size: 320,
                color: AppColors.tertiary,
                intensity: 0.22,
              ),
            ),
            const Positioned(
              bottom: 120,
              right: -120,
              child: CelestialGlow(
                size: 260,
                color: AppColors.accent,
                intensity: 0.18,
              ),
            ),
            // ── Grain to kill the flat-digital look, low in the stack.
            const Positioned.fill(child: GrainOverlay(opacity: 0.030)),
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
                      StaggeredReveal(index: 0, child: _buildHeader()),
                      const SizedBox(height: 24),
                      StaggeredReveal(index: 1, child: _buildPromoBanners()),
                      const SizedBox(height: 28),
                      // ทำบุญออนไลน์ - Main Feature
                      StaggeredReveal(index: 2, child: _buildMeritHighlight()),
                      const SizedBox(height: 28),
                      StaggeredReveal(index: 3, child: _buildDailyHoroscope()),
                      const SizedBox(height: 28),
                      StaggeredReveal(index: 4, child: _buildFeatures()),
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

  /// Display font (characterful serif) for English accents / numerals — the
  /// editorial counterpoint to the Thai Kanit headings.
  TextStyle _displayStyle({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0.2,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      color: color ?? AppColors.deepText,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: 1.0,
    );
  }

  /// Small uppercase letter-spaced English overline for an editorial feel above
  /// Thai section titles.
  Widget _overline(String text, {Color? color}) {
    return Text(
      text.toUpperCase(),
      style: _displayStyle(
        fontSize: 11.5,
        color: color ?? AppColors.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.6,
      ),
    );
  }

  /// Gentle press feedback: scales the child down slightly while tapped, with a
  /// soft splash. Visual-only wrapper around the original onTap.
  Widget _pressable({
    required Widget child,
    required VoidCallback onTap,
    BorderRadius? borderRadius,
  }) {
    return _PressScale(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: child,
    );
  }

  /// A section heading with an editorial overline + Thai title (Kanit) and a
  /// gentle sparkle accent. [overline] optional for the small inline use.
  Widget _sectionTitle(String title, {String? overline}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null) ...[
          _overline(overline),
          const SizedBox(height: 5),
        ],
        Row(
          children: [
            SvgPicture.asset(
              AppIcons.sparkleFilled,
              width: 18,
              height: 18,
              colorFilter:
                  const ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
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
              // Editorial English overline + the date in the display serif.
              _overline('Today', color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'th_TH').format(_today),
                style: GoogleFonts.kanit(
                  color: AppColors.mutedText,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              // Dramatic Thai greeting — big, tight, intentional.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'สวัสดีค่ะ คุณ$_userName',
                      style: GoogleFonts.kanit(
                        color: AppColors.deepText,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        letterSpacing: -0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    AppIcons.sparkleFilled,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                        AppColors.accent, BlendMode.srcIn),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // ── SIGNATURE MOMENT: a slowly-rotating celestial horoscope wheel,
        // haloed in pastel light, sitting beside a tappable profile avatar.
        GestureDetector(
          onTap: () {
            _showProfileOptions(context);
          },
          child: SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Soft halo behind the wheel.
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.22),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Slowly rotating celestial wheel — alive but subtle.
                IgnorePointer(
                  child: RotationTransition(
                    turns: _celestialRotation,
                    child: Opacity(
                      opacity: 0.9,
                      child: Lottie.asset(
                        'assets/animations/horowheel.json',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        animate: false,
                      ),
                    ),
                  ),
                ),
                // Avatar coin in the centre.
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
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
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
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
        _sectionTitle('ดวงประจำวันของคุณ', overline: 'Daily Reading'),
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
    return _pressable(
      borderRadius: BorderRadius.circular(24),
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
        _sectionTitle('บริการอื่นๆ', overline: 'Explore'),
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
                glass: true,
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
    bool glass = false, // ถ้า true ใช้ glassmorphism surface
  }) {
    final borderRadius = BorderRadius.circular(20);

    final inner = Column(
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
    );

    // Glassmorphism surface: blurred translucent white with a hairline border
    // and layered shadow for real depth.
    if (glass) {
      return _pressable(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.75),
                    width: 1,
                  ),
                ),
                child: inner,
              ),
            ),
          ),
        ),
      );
    }

    return _pressable(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: inner,
      ),
    );
  }
}

/// Gentle press-scale + soft splash wrapper. Tasteful micro-interaction for
/// tappable cards — scales down briefly on press, then springs back.
class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _PressScale({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (mounted && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
