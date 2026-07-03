import 'package:flutter/material.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/sacred_ui.dart';
import '../../core/services/laravel_auth_service.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String? token;
  final String? type;

  const EmailConfirmationScreen({
    Key? key,
    this.token,
    this.type,
  }) : super(key: key);

  @override
  State<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isVerifying = true;
  bool _isSuccess = false;
  String _message = 'กำลังยืนยันอีเมลของคุณ...';

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    try {
      // Check if user is already logged in after email confirmation
      final isLoggedIn = await LaravelAuthService.instance.isLoggedIn();

      if (isLoggedIn) {
        setState(() {
          _isVerifying = false;
          _isSuccess = true;
          _message = 'ยืนยันอีเมลสำเร็จ!';
        });

        // Wait a moment before navigating
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          // Navigate to home screen
          AppRouter.navigateAndClearStack(context, AppRoutes.home);
        }
      } else {
        setState(() {
          _isVerifying = false;
          _isSuccess = false;
          _message = 'กรุณาเข้าสู่ระบบอีกครั้ง';
        });
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _isSuccess = false;
        _message = 'เกิดข้อผิดพลาด: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SacredCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isVerifying) ...[
                    const CircularProgressIndicator(
                      color: AppColors.deepGoldBrown,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _message,
                      style: SacredText.kanit(
                        color: AppColors.deepText,
                        fontSize: 17,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (_isSuccess
                                ? AppColors.success
                                : AppColors.error)
                            .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isSuccess ? Icons.check_circle : Icons.error,
                        color: _isSuccess ? AppColors.success : AppColors.error,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _message,
                      style: SacredText.kanit(
                        color: AppColors.deepText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    if (!_isSuccess)
                      SacredPrimaryButton(
                        label: 'กลับไปยังหน้าเข้าสู่ระบบ',
                        filled: true,
                        onTap: () {
                          AppRouter.navigateAndClearStack(
                              context, AppRoutes.login);
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
