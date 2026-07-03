import 'package:flutter/material.dart';

import '../../../core/routes/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_icons.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _authService = AuthService.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Login succeeded (signIn throws on failure); navigate to home
        if (mounted) {
          AppRouter.navigateAndClearStack(context, AppRoutes.home);
        }
      } catch (e) {
        // Show error message for other exceptions
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เข้าสู่ระบบไม่สำเร็จ: ${e.toString()}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 28),
                SacredCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLoginForm(),
                      const SizedBox(height: 16),
                      _buildForgotPassword(),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _buildSocialLogin(),
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SacredOverline('Welcome back'),
        const SizedBox(height: 6),
        Text(
          'เข้าสู่ระบบ',
          style: SacredText.kanit(
            color: AppColors.onBackdrop,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ยินดีต้อนรับกลับมา! กรุณาเข้าสู่ระบบเพื่อใช้งาน',
          style: SacredText.kanit(
            color: AppColors.onBackdropMuted,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthTextField(
            controller: _emailController,
            hintText: 'อีเมล',
            svgIconPath: AppIcons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกอีเมล';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'กรุณากรอกอีเมลให้ถูกต้อง';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hintText: 'รหัสผ่าน',
            svgIconPath: AppIcons.lock,
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกรหัสผ่าน';
              }
              if (value.length < 6) {
                return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: SvgIcon(
                _obscurePassword
                    ? AppIcons.visibility
                    : AppIcons.visibilityOff,
                size: 20,
                color: AppColors.lightText.withValues(alpha: 0.7),
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 24),
          SacredPrimaryButton(
            label: 'เข้าสู่ระบบ',
            onTap: _login,
            filled: true,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: SacredTextAction(
        label: 'ลืมรหัสผ่าน?',
        onTap: () {
          AppRouter.navigateTo(context, AppRoutes.forgotPassword);
        },
      ),
    );
  }

  Widget _buildSocialLogin() {
    // ซ่อน social login buttons ชั่วคราว
    return const SizedBox.shrink();

    // เก็บ code ไว้เผื่อต้องการใช้ในอนาคต
    /*
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppColors.lightText.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'หรือเข้าสู่ระบบด้วย',
                style: TextStyle(
                  color: AppColors.lightText.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.lightText.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialLoginButton(
              icon: const Icon(
                Icons.g_mobiledata,
                size: 24,
                color: Colors.white,
              ),
              onPressed: _loginWithGoogle,
            ),
            const SizedBox(width: 16),
            SocialLoginButton(
              icon: const Icon(
                Icons.facebook,
                size: 24,
                color: Colors.white,
              ),
              onPressed: _loginWithFacebook,
            ),
            const SizedBox(width: 16),
            SocialLoginButton(
              icon: const Icon(
                Icons.apple,
                size: 24,
                color: Colors.white,
              ),
              onPressed: _loginWithApple,
            ),
          ],
        ),
      ],
    );
    */
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ยังไม่มีบัญชี? ',
          style: SacredText.kanit(
            color: AppColors.onBackdropMuted,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            AppRouter.navigateToReplacement(context, AppRoutes.register);
          },
          child: Text(
            'สมัครสมาชิก',
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
