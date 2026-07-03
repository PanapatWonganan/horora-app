import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/routes/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../shared/widgets/gradient_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final apiClient = ApiClient();
        await apiClient.post('/auth/forgot-password', data: {
          'email': _emailController.text.trim(),
        });

        if (mounted) {
          setState(() {
            _emailSent = true;
            _isLoading = false;
          });
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่สามารถส่งอีเมลรีเซ็ตรหัสผ่าน: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SacredHeader(
              title: 'ลืมรหัสผ่าน',
              overline: 'Reset password',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child:
                      _emailSent ? _buildSuccessContent() : _buildResetForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _buildHeader(),
        const SizedBox(height: 24),
        SacredCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AuthTextField(
                  controller: _emailController,
                  hintText: 'อีเมล',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'กรุณากรอกอีเมลให้ถูกต้อง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'ส่งลิงก์รีเซ็ตรหัสผ่าน',
                  onPressed: _resetPassword,
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  width: double.infinity,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        _buildLoginLink(),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        SacredCard(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'ส่งลิงก์รีเซ็ตรหัสผ่านแล้ว',
                textAlign: TextAlign.center,
                style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'เราได้ส่งลิงก์สำหรับรีเซ็ตรหัสผ่านไปยังอีเมล ${_emailController.text} แล้ว กรุณาตรวจสอบอีเมลของคุณและทำตามคำแนะนำเพื่อรีเซ็ตรหัสผ่าน',
                textAlign: TextAlign.center,
                style: SacredText.kanit(
                  color: AppColors.mutedText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                text: 'กลับไปหน้าเข้าสู่ระบบ',
                onPressed: () {
                  AppRouter.navigateToReplacement(context, AppRoutes.login);
                },
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                width: double.infinity,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SacredTextAction(
          label: 'ลองใช้อีเมลอื่น',
          onTap: () {
            setState(() {
              _emailSent = false;
              _emailController.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ลืมรหัสผ่าน?',
          style: SacredText.kanit(
            color: AppColors.onBackdrop,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'กรุณากรอกอีเมลที่ใช้ลงทะเบียน เราจะส่งลิงก์สำหรับรีเซ็ตรหัสผ่านไปให้คุณ',
          style: SacredText.kanit(
            color: AppColors.onBackdropMuted,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'จำรหัสผ่านได้แล้ว? ',
          style: SacredText.kanit(
            color: AppColors.onBackdropMuted,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            AppRouter.navigateToReplacement(context, AppRoutes.login);
          },
          child: Text(
            'เข้าสู่ระบบ',
            style: SacredText.kanit(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}