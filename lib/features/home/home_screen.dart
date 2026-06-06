import 'package:flutter/material.dart';
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              const Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildPromoBanners(),
                  const SizedBox(height: 24),
                  // ทำบุญออนไลน์ - Main Feature
                  _buildMeritHighlight(),
                  const SizedBox(height: 24),
                  _buildDailyHoroscope(),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  _buildFeatures(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สวัสดีคุณ, $_userName',
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'th_TH').format(_today),
              style: TextStyle(
                color: AppColors.lightText.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            _showProfileOptions(context);
          },
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: SvgIcon(
              AppIcons.personFilled,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: SvgIcon(AppIcons.person, size: 24, color: Colors.white),
                title: const Text('โปรไฟล์',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  AppRouter.navigateTo(context, AppRoutes.profile);
                },
              ),
              ListTile(
                leading: SvgIcon(AppIcons.settings, size: 24, color: Colors.white),
                title: const Text('ตั้งค่า',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  AppRouter.navigateTo(context, AppRoutes.settings);
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: SvgIcon(AppIcons.logout, size: 24, color: Colors.redAccent),
                title: const Text('ออกจากระบบ',
                    style: TextStyle(color: Colors.redAccent)),
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
          'ดวงประจำวันของคุณ',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFF8C00),
              Color(0xFFFF6B00),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -30,
              top: -30,
              child: Opacity(
                opacity: 0.15,
                child: SvgIcon(
                  AppIcons.temple,
                  size: 150,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Opacity(
                opacity: 0.1,
                child: SvgIcon(
                  AppIcons.sparkleFilled,
                  size: 80,
                  color: Colors.white,
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
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SvgIcon(
                        AppIcons.temple,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ทำบุญออนไลน์',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'สะดวก รวดเร็ว ได้บุญจริง',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
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
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgIcon(
                        AppIcons.heart,
                        size: 20,
                        color: const Color(0xFFFF6B00),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'เริ่มทำบุญเลย',
                        style: TextStyle(
                          color: Color(0xFFFF6B00),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgIcon(
                        AppIcons.arrowForward,
                        size: 20,
                        color: const Color(0xFFFF6B00),
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
        Text(
          'บริการอื่นๆ',
          style: TextStyle(
            color: AppColors.lightText.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallFeatureCard(
                title: 'ไพ่ทาโรต์',
                svgIconPath: AppIcons.divination,
                color: const Color(0xFFE91E63),
                onTap: () => Navigator.pushNamed(context, AppRoutes.tarot),
                useIconColor: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallFeatureCard(
                title: 'พ่อหมอโหรา',
                svgIconPath: AppIcons.chatFilled,
                color: const Color(0xFF2196F3),
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.chat),
                useIconColor: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallFeatureCard(
                title: 'โหราศาสตร์',
                svgIconPath: AppIcons.starFilled,
                color: const Color(0xFFFF9800),
                onTap: () => Navigator.pushNamed(context, AppRoutes.horoscope),
                useIconColor: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: SvgIcon(
                svgIconPath,
                size: 22,
                color: useIconColor ? null : color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
