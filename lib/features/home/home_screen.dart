import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/services/auth_service.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import 'widgets/daily_horoscope_card.dart';
import 'widgets/feature_card.dart';
import '../../ui/screens/horoscope_demo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "คุณ"; // จะถูกอัพเดทจาก user repository
  final DateTime _today = DateTime.now();
  final _authService = AuthService.instance;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = _authService.currentUser;
    if (user != null && user.userMetadata != null) {
      if (user.userMetadata!['full_name'] != null) {
        setState(() {
          _userName = user.userMetadata!['full_name'] as String;
        });
      } else if (user.userMetadata!['name'] != null) {
        setState(() {
          _userName = user.userMetadata!['name'] as String;
        });
      } else if (user.email != null) {
        // ถ้าไม่มีชื่อ ใช้อีเมลแทน
        setState(() {
          _userName = user.email!.split('@')[0]; // ใช้ส่วนแรกของอีเมลก่อน @
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
                  const SizedBox(height: 24),
                  _buildDailyHoroscope(),
                  const SizedBox(height: 32),
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
                color: AppColors.lightText.withOpacity(0.7),
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
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Icon(
              Icons.person,
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
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: const Text('โปรไฟล์',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  AppRouter.navigateTo(context, AppRoutes.profile);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.settings_outlined, color: Colors.white),
                title: const Text('ตั้งค่า',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  AppRouter.navigateTo(context, AppRoutes.settings);
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ออกจากระบบไม่สำเร็จ: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
            AppRouter.navigateTo(context, AppRoutes.dailyHoroscope);
          },
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'บริการของเรา',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                title: 'ไพ่ทาโรต์',
                icon: Icons.auto_awesome,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE91E63),
                    Color(0xFF9C27B0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  AppRouter.navigateTo(context, AppRoutes.tarot);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FeatureCard(
                title: 'สนทนา AI',
                icon: Icons.chat_bubble_outline,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2196F3),
                    Color(0xFF673AB7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  AppRouter.navigateToReplacement(context, AppRoutes.chat);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                title: 'โหราศาสตร์',
                icon: Icons.star_outline,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF9800),
                    Color(0xFFFF5722),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  AppRouter.navigateTo(context, AppRoutes.horoscope);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FeatureCard(
                title: 'โหมดสมาธิ',
                icon: Icons.self_improvement,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF009688),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  AppRouter.navigateTo(context, AppRoutes.focusSession);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Demo button for testing the daily horoscope feature
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HoroscopeDemoScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('ทดสอบดูดวงประจำวัน'),
          ),
        ),
      ],
    );
  }
}
