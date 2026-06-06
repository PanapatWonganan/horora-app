import 'package:flutter/material.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
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
    return Scaffold(
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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isVerifying) ...[
                    const CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _message,
                      style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess ? Colors.green : AppColors.error,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _message,
                      style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (!_isSuccess)
                      ElevatedButton(
                        onPressed: () {
                          AppRouter.navigateAndClearStack(context, AppRoutes.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'กลับไปยังหน้าเข้าสู่ระบบ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
