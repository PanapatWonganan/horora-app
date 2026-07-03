import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/sacred_ui.dart';
import '../../core/routes/app_routes.dart';
import '../../core/routes/app_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/app_icons.dart';
import '../shared/widgets/gradient_button.dart';

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
            backgroundColor: AppColors.error,
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
    return SacredScaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SacredHeader(
                    title: 'การตั้งค่า',
                    overline: 'SETTINGS',
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                ],
              ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: SacredOverline(label),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('บัญชีผู้ใช้'),
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
    // All app-setting entries are currently disabled (see commented routes in
    // history below); render nothing so the section label doesn't appear alone.
    return const SizedBox.shrink();
  }

  Widget _buildSupportSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('ความช่วยเหลือ'),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SacredCard(
      onTap: onTap,
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.candleGold.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: svgIconPath != null
                  ? SvgIcon(
                      svgIconPath,
                      size: 20,
                      color: AppColors.deepGoldBrown,
                    )
                  : Icon(
                      icon ?? Icons.circle,
                      color: AppColors.deepGoldBrown,
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: SacredText.kanit(
                color: AppColors.deepText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SvgIcon(
            AppIcons.arrowForward,
            size: 16,
            color: AppColors.mutedText.withValues(alpha: 0.6),
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
      child: OutlinedGradientButton(
        text: 'ออกจากระบบ',
        onPressed: _logout,
        gradient: LinearGradient(
          colors: [
            AppColors.error.withValues(alpha: 0.85),
            AppColors.error,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        icon: const SvgIcon(
          AppIcons.logout,
          size: 20,
          color: AppColors.error,
        ),
      ),
    );
  }
}
