import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/app_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService.instance;
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signOut();
      // Navigate to login screen after successful logout
      if (mounted) {
        AppRouter.navigateAndClearStack(context, AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการออกจากระบบ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'การตั้งค่า',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.lightText,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingsHeader(),
                      const SizedBox(height: 24),
                      _buildAccountSettings(),
                      const SizedBox(height: 24),
                      _buildAppSettings(),
                      const SizedBox(height: 24),
                      _buildSupportSettings(),
                      const SizedBox(height: 32),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSettingsHeader() {
    return const Text(
      'การตั้งค่าทั่วไป',
      style: TextStyle(
        color: AppColors.lightText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'บัญชีผู้ใช้',
          style: TextStyle(
            color: AppColors.lightText.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          svgIconPath: AppIcons.person,
          title: 'โปรไฟล์ของฉัน',
          onTap: () {
            AppRouter.navigateTo(context, AppRoutes.profile);
          },
        ),
        _buildSettingItem(
          icon: Icons.edit_outlined,
          title: 'แก้ไขข้อมูลส่วนตัว',
          onTap: () {
            AppRouter.navigateTo(context, AppRoutes.editProfile);
          },
        ),
        // _buildSettingItem(
        //   icon: Icons.notifications_outlined,
        //   title: 'การแจ้งเตือน',
        //   onTap: () {
        //     AppRouter.navigateTo(context, AppRoutes.notifications);
        //   },
        // ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'แอปพลิเคชัน',
          style: TextStyle(
            color: AppColors.lightText.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // _buildSettingItem(
        //   icon: Icons.language,
        //   title: 'ภาษา',
        //   onTap: () {
        //     AppRouter.navigateTo(context, AppRoutes.language);
        //   },
        // ),
        // _buildSettingItem(
        //   icon: Icons.history,
        //   title: 'ประวัติการดูดวง',
        //   onTap: () {
        //     AppRouter.navigateTo(context, AppRoutes.historyHoroscope);
        //   },
        // ),
        // _buildSettingItem(
        //   icon: Icons.auto_awesome,
        //   title: 'ประวัติการอ่านไพ่',
        //   onTap: () {
        //     AppRouter.navigateTo(context, AppRoutes.historyTarot);
        //   },
        // ),
        // _buildSettingItem(
        //   icon: Icons.chat_bubble_outline,
        //   title: 'ประวัติการสนทนา',
        //   onTap: () {
        //     AppRouter.navigateTo(context, AppRoutes.historyChat);
        //   },
        // ),
      ],
    );
  }

  Widget _buildSupportSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ความช่วยเหลือ',
          style: TextStyle(
            color: AppColors.lightText.withValues(alpha: 0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.help_outline,
          title: 'ช่วยเหลือและสนับสนุน',
          onTap: () {
            AppRouter.navigateTo(context, AppRoutes.help);
          },
        ),
        _buildSettingItem(
          svgIconPath: AppIcons.info,
          title: 'เกี่ยวกับแอป',
          onTap: () {
            AppRouter.navigateTo(context, AppRoutes.about);
          },
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    String? svgIconPath,
    IconData? icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: svgIconPath != null
                    ? SvgIcon(
                        svgIconPath,
                        size: 20,
                        color: AppColors.primary,
                      )
                    : Icon(
                        icon ?? Icons.circle,
                        color: AppColors.primary,
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.lightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SvgIcon(
              AppIcons.arrowForward,
              size: 16,
              color: AppColors.lightText.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'ออกจากระบบ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
