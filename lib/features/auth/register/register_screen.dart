import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/routes/routes.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/zodiac_utils.dart';
import '../../shared/widgets/gradient_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();

  DateTime? _selectedDate;
  String? _zodiacSign;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  final _authService = AuthService.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.darkSurface,
              onSurface: AppColors.lightText,
            ),
            dialogBackgroundColor: AppColors.darkSurface,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);

        // คำนวณราศีจากวันเกิด
        _zodiacSign = ZodiacUtils.getZodiacSignThai(picked);
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('กรุณายอมรับข้อกำหนดและเงื่อนไขการใช้งาน'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Implement registration logic with Supabase
        final response = await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          birthDate: _selectedDate,
        );

        // Check if registration was successful
        if (response.user != null) {
          // แสดง popup ให้ยืนยันอีเมล
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ลงทะเบียนสำเร็จ! ยินดีต้อนรับสู่แอปพลิเคชัน'),
                backgroundColor: Colors.green,
              ),
            );

            // แสดง popup และนำทางไปยังหน้า home หลังจากปิด popup
            _showVerifyEmailDialog();
          }
        } else {
          // Show error message if registration failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('ลงทะเบียนไม่สำเร็จ กรุณาลองใหม่อีกครั้ง'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } on AuthException catch (e) {
        // Handle Supabase auth exceptions
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ลงทะเบียนไม่สำเร็จ: ${e.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        // Show error message for other exceptions
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ลงทะเบียนไม่สำเร็จ: ${e.toString()}'),
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

  Future<void> _registerWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _authService.signInWithGoogle();

      // Navigation will be handled by auth state listener
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลงทะเบียนด้วย Google ไม่สำเร็จ: ${e.toString()}'),
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

  Future<void> _registerWithFacebook() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _authService.signInWithFacebook();

      // Navigation will be handled by auth state listener
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลงทะเบียนด้วย Facebook ไม่สำเร็จ: ${e.toString()}'),
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

  Future<void> _registerWithApple() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _authService.signInWithApple();

      // Navigation will be handled by auth state listener
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลงทะเบียนด้วย Apple ไม่สำเร็จ: ${e.toString()}'),
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

  // เพิ่มฟังก์ชันแสดง popup เตือนให้ยืนยันอีเมล
  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.email_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'ยืนยันอีเมลของคุณ',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เราได้ส่งลิงก์ยืนยันไปยังอีเมล ${_emailController.text}',
                style: TextStyle(color: AppColors.lightText),
              ),
              const SizedBox(height: 12),
              Text(
                'โปรดยืนยันอีเมลของคุณเพื่อให้สามารถดูดวงในราศีของคุณได้อย่างเต็มที่',
                style: TextStyle(color: AppColors.lightText.withOpacity(0.8)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'หากไม่พบอีเมล โปรดตรวจสอบในโฟลเดอร์สแปมของคุณ',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // นำทางไปยังหน้า home หลังจากปิด popup
                AppRouter.navigateAndClearStack(context, AppRoutes.home);
              },
              child: Text(
                'ฉันเข้าใจแล้ว',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildRegisterForm(),
                  const SizedBox(height: 24),
                  _buildTermsAndConditions(),
                  const SizedBox(height: 32),
                  _buildSocialLogin(),
                  const SizedBox(height: 32),
                  _buildLoginLink(),
                  const SizedBox(height: 20),
                ],
              ),
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
        Text(
          'สมัครสมาชิก',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'สร้างบัญชีเพื่อเริ่มต้นการเดินทางค้นหาดวงดาวของคุณ',
          style: TextStyle(
            color: AppColors.lightText.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthTextField(
            controller: _nameController,
            hintText: 'ชื่อ-นามสกุล',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอกชื่อ-นามสกุล';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _emailController,
            hintText: 'อีเมล',
            icon: Icons.email_outlined,
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
            icon: Icons.lock_outline,
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
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.lightText.withOpacity(0.7),
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmPasswordController,
            hintText: 'ยืนยันรหัสผ่าน',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณายืนยันรหัสผ่าน';
              }
              if (value != _passwordController.text) {
                return 'รหัสผ่านไม่ตรงกัน';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.lightText.withOpacity(0.7),
              ),
              onPressed: _toggleConfirmPasswordVisibility,
            ),
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _birthDateController,
            hintText: 'วันเกิด (วว/ดด/ปปปป)',
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: () => _selectDate(context),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณาเลือกวันเกิด';
              }
              return null;
            },
          ),
          if (_zodiacSign != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    ZodiacUtils.getZodiacIcon(
                      ZodiacUtils.getZodiacSign(_selectedDate!),
                    ),
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _zodiacSign!,
                          style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ZodiacUtils.getZodiacDateRange(
                            ZodiacUtils.getZodiacSign(_selectedDate!),
                          ),
                          style: TextStyle(
                            color: AppColors.lightText.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          GradientButton(
            text: 'สมัครสมาชิก',
            onPressed: _register,
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            width: double.infinity,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return Colors.transparent;
            }),
            side: BorderSide(
              color: AppColors.lightText.withOpacity(0.7),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'ฉันยอมรับ ',
              style: TextStyle(
                color: AppColors.lightText.withOpacity(0.7),
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'ข้อกำหนดและเงื่อนไขการใช้งาน',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                color: AppColors.lightText.withOpacity(0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'หรือสมัครสมาชิกด้วย',
                style: TextStyle(
                  color: AppColors.lightText.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.lightText.withOpacity(0.3),
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
              onPressed: _registerWithGoogle,
            ),
            const SizedBox(width: 16),
            SocialLoginButton(
              icon: const Icon(
                Icons.facebook,
                size: 24,
                color: Colors.white,
              ),
              onPressed: _registerWithFacebook,
            ),
            const SizedBox(width: 16),
            SocialLoginButton(
              icon: const Icon(
                Icons.apple,
                size: 24,
                color: Colors.white,
              ),
              onPressed: _registerWithApple,
            ),
          ],
        ),
      ],
    );
    */
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'มีบัญชีอยู่แล้ว? ',
          style: TextStyle(
            color: AppColors.lightText.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            AppRouter.navigateToReplacement(context, AppRoutes.login);
          },
          child: Text(
            'เข้าสู่ระบบ',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
