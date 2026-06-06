import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/services/thai_zodiac_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/auth_guard.dart';
import '../../core/utils/app_icons.dart';
import '../shared/widgets/gradient_button.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import '../affiliate/services/affiliate_service.dart';
import '../affiliate/screens/affiliate_dashboard_screen.dart';
import '../affiliate/screens/affiliate_register_screen.dart';
import 'widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService.instance;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // User data with default values
  Map<String, dynamic> _userData = {
    'full_name': 'ผู้ใช้งาน',
    'email': 'user@example.com',
    'birth_date': null,
    'thai_animal': null,
    'thai_year_name': null,
    'thai_element': null,
    'thai_element_full': null,
    'is_premium': false,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _guardAndLoad();
    });
  }

  /// โปรไฟล์ต้อง login (ดึงข้อมูลผู้ใช้) — gate ที่ทางเข้า
  Future<void> _guardAndLoad() async {
    if (!mounted) return;
    final allowed = await AuthGuard.requireAuth(context, intentLabel: 'profile');
    if (!mounted) return;
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เข้าสู่ระบบเพื่อดูโปรไฟล์ของคุณได้นะ'),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // ข้อมูลตัวอย่างสำหรับการแสดงผล (ใช้เมื่อไม่สามารถโหลดข้อมูลจริงได้)
      final sampleUserData = {
        'full_name': 'สมชาย ใจดี',
        'email': 'somchai@example.com',
        'birth_date': '1990-05-15',
        'thai_animal': 'มะเมีย',
        'thai_year_name': 'ปีมะเมีย',
        'thai_element': 'ทอง',
        'thai_element_full': 'ธาตุทอง',
        'is_premium': true,
        'profile_image_url': '',
      };

      // Get current user from auth
      final currentUser = _authService.currentUser;

      if (currentUser != null) {
        debugPrint('User profile loaded (id: ${currentUser.id})');

        // อัปเดตข้อมูลเบื้องต้นจาก auth
        setState(() {
          _userData['email'] = currentUser.email;

          // ดึงชื่อจาก user
          if (currentUser.name.isNotEmpty) {
            _userData['full_name'] = currentUser.name;
          }

          // ดึงวันเกิดและคำนวณปีนักษัตรไทย
          if (currentUser.birthDate != null) {
            _userData['birth_date'] = currentUser.birthDate!.toIso8601String().split('T')[0];

            // คำนวณปีนักษัตรไทยจากวันเกิดใหม่ทุกครั้ง
            final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(currentUser.birthDate!);
            _userData['thai_animal'] = thaiZodiac.animalName;
            _userData['thai_year_name'] = thaiZodiac.thaiName;
            _userData['thai_element'] = thaiZodiac.element;
            _userData['thai_element_full'] = thaiZodiac.elementThai;

            debugPrint('Calculated Thai Zodiac from birth date:');
            debugPrint('Animal: ${thaiZodiac.animalName}, Thai Name: ${thaiZodiac.thaiName}');
            debugPrint('Element: ${thaiZodiac.element}, Element Thai: ${thaiZodiac.elementThai}');
          } else if (currentUser.thaiAnimal != null) {
            // ใช้ค่าที่เก็บไว้ใน database
            _userData['thai_animal'] = currentUser.thaiAnimal;
            _userData['thai_year_name'] = currentUser.thaiYearName ?? 'ปี${currentUser.thaiAnimal}';
            _userData['thai_element'] = currentUser.thaiElement ?? '';
            _userData['thai_element_full'] = currentUser.thaiElementFull ?? '';
          }
        });
      }

      // พยายามดึงข้อมูลจากฐานข้อมูล
      try {
        final profile = await _authService.getUserProfile();

        if (profile != null) {
          setState(() {
            // อัปเดตข้อมูลจากฐานข้อมูล
            _userData = {
              ..._userData,
              ...profile,
            };

            // คำนวณปีนักษัตรไทยจากวันเกิดใหม่ทุกครั้ง (เขียนทับข้อมูลเก่า)
            if (_userData['birth_date'] != null && _userData['birth_date'].isNotEmpty) {
              try {
                final birthDate = DateTime.parse(_userData['birth_date']);
                final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(birthDate);
                _userData['thai_animal'] = thaiZodiac.animalName;
                _userData['thai_year_name'] = thaiZodiac.thaiName;
                _userData['thai_element'] = thaiZodiac.element;
                _userData['thai_element_full'] = thaiZodiac.elementThai;
                
                debugPrint('Updated Thai Zodiac from database birth date.'); // birth_date value removed from log
              } catch (e) {
                debugPrint('Error parsing birth date from profile: $e');
              }
            }
          });
        } else {
          // ถ้าไม่มีข้อมูลในฐานข้อมูล แต่มีข้อมูลจาก auth แล้ว ไม่ต้องทำอะไร
          // ถ้าไม่มีข้อมูลทั้งสองที่ ให้ใช้ข้อมูลตัวอย่าง
          if (_userData['full_name'] == 'ผู้ใช้งาน' &&
              _userData['email'] == 'user@example.com') {
            setState(() {
              _userData = sampleUserData;
            });
          }
        }
      } catch (e) {
        debugPrint('Error fetching profile from database: $e');
        // ถ้าดึงข้อมูลจากฐานข้อมูลไม่ได้ แต่มีข้อมูลจาก auth แล้ว ไม่ต้องทำอะไร
        // ถ้าไม่มีข้อมูลทั้งสองที่ ให้ใช้ข้อมูลตัวอย่าง
        if (_userData['full_name'] == 'ผู้ใช้งาน' &&
            _userData['email'] == 'user@example.com') {
          setState(() {
            _userData = sampleUserData;
          });
        }
      }

      // Check subscription status
      await _checkSubscriptionStatus();
    } catch (e) {
      debugPrint('Error in _loadUserProfile: $e');

      // ใช้ข้อมูลตัวอย่างแทนเมื่อเกิดข้อผิดพลาด
      setState(() {
        _userData = {
          'full_name': 'สมชาย ใจดี',
          'email': 'somchai@example.com',
          'birth_date': '1990-05-15',
          'thai_animal': 'มะเมีย',
          'thai_year_name': 'ปีมะเมีย',
          'thai_element': 'ทอง',
          'thai_element_full': 'ธาตุทอง',
          'is_premium': true,
          'profile_image_url': '',
        };

        // ไม่แสดงข้อความผิดพลาด แต่ใช้ข้อมูลตัวอย่างแทน
        _hasError = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      // ถ้าข้อมูลผู้ใช้มีการกำหนดสถานะพรีเมียมไว้แล้ว ให้ใช้ค่านั้น
      if (_userData.containsKey('is_premium')) {
        return; // ใช้ค่าที่มีอยู่แล้ว
      }

      // This would typically call a method to check subscription status
      // For now, we'll just simulate it
      // In a real app, you would call something like:
      // final subscription = await _authService.getUserSubscription();
      // _userData['is_premium'] = subscription != null && subscription['is_active'] == true;

      // For demonstration, set to true to show premium UI
      _userData['is_premium'] = true;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      // Default to non-premium if there's an error
      if (!_userData.containsKey('is_premium')) {
        _userData['is_premium'] = false;
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
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : _hasError
                  ? _buildErrorView()
                  : RefreshIndicator(
                      onRefresh: _loadUserProfile,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildProfileInfo(),
                            const SizedBox(height: 32),
                            _buildSubscriptionCard(),
                            const SizedBox(height: 32),
                            _buildMenuItems(),
                            const SizedBox(height: 24),
                            const SizedBox(height: 24),
                            _buildLogoutButton(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(
              AppIcons.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'ลองใหม่อีกครั้ง',
              onPressed: _loadUserProfile,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'โปรไฟล์',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: SvgIcon(
            AppIcons.settings,
            size: 24,
            color: AppColors.lightText,
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    // คำนวณวันเกิดในรูปแบบที่อ่านง่าย
    String birthDateText = 'ไม่ระบุ';
    DateTime? birthDate;

    if (_userData['birth_date'] != null && _userData['birth_date'].isNotEmpty) {
      try {
        birthDate = DateTime.parse(_userData['birth_date']);
        birthDateText = DateFormat('dd/MM/yyyy').format(birthDate);
      } catch (e) {
        debugPrint('Error parsing birth date: $e');
      }
    }

    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: _userData['profile_image_url'] != null &&
                      _userData['profile_image_url'].isNotEmpty
                  ? Image.network(
                      _userData['profile_image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => SvgIcon(
                        AppIcons.personFilled,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    )
                  : SvgIcon(
                      AppIcons.personFilled,
                      size: 40,
                      color: AppColors.primary,
                    ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userData['full_name'] ?? 'ผู้ใช้งาน',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userData['email'] ?? '',
                style: TextStyle(
                  color: AppColors.lightText.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'วันเกิด: $birthDateText',
                style: TextStyle(
                  color: AppColors.lightText.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // แสดงปีนักษัตรไทยถ้ามีวันเกิด (คำนวณจากวันเกิด)
                  if (birthDate != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ThaiZodiacIcon(
                            animal: () {
                              try {
                                if (birthDate != null) {
                                  final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(birthDate);
                                  return thaiZodiac.animalName;
                                }
                                return 'มะโรง';
                              } catch (e) {
                                return 'มะโรง';
                              }
                            }(),
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            () {
                              try {
                                if (birthDate != null) {
                                  final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(birthDate);
                                  return thaiZodiac.thaiName;
                                }
                                return 'ไม่ทราบปีนักษัตร';
                              } catch (e) {
                                return 'ไม่ทราบปีนักษัตร';
                              }
                            }(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_userData['is_premium'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.amber,
                            Colors.orange,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SvgIcon(
                            AppIcons.starFilled,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'พรีเมียม',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: SvgIcon(
            AppIcons.edit,
            size: 20,
            color: Colors.amber,
          ),
          onPressed: () async {
            final result =
                await AppRouter.navigateTo(context, AppRoutes.editProfile);
            if (result == true) {
              // Reload profile if edit was successful
              _loadUserProfile();
            }
          },
        ),
      ],
    );
  }


  Widget _buildSubscriptionCard() {
    // ถ้าเป็นผู้ใช้พรีเมียมแล้ว แสดงการ์ดแบบพรีเมียม
    if (_userData['is_premium'] == true) {
      return _buildPremiumCard();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2A2A4A),
            Color(0xFF1A1A3A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgIcon(
                AppIcons.starFilled,
                size: 24,
                color: Colors.amber,
              ),
              const SizedBox(width: 12),
              Text(
                'อัพเกรดเป็นพรีเมียม',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'รับสิทธิประโยชน์เพิ่มเติมและปลดล็อกฟีเจอร์ทั้งหมด',
            style: TextStyle(
              color: AppColors.lightText.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFeatureItem('ไม่มีโฆษณา'),
              _buildFeatureItem('ดูดวงไม่จำกัด'),
              _buildFeatureItem('ไพ่ทาโรต์ไม่จำกัด'),
            ],
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: 'อัพเกรดเป็นพรีเมียม',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: AppColors.darkSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: [
                        SvgIcon(AppIcons.info, size: 24, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'แจ้งให้ทราบ',
                          style: TextStyle(
                            color: AppColors.lightText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'กำลังพัฒนาส่วนนี้',
                      style: TextStyle(
                        color: AppColors.lightText,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'ตกลง',
                          style: TextStyle(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            gradient: const LinearGradient(
              colors: [
                Colors.amber,
                Colors.orange,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            icon: SvgIcon(
              AppIcons.starFilled,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade700,
            Colors.orange.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgIcon(
                AppIcons.diamond,
                size: 24,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              const Text(
                'สมาชิกพรีเมียม',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ขอบคุณที่เป็นสมาชิกพรีเมียม คุณสามารถใช้งานฟีเจอร์ทั้งหมดได้ไม่จำกัด',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPremiumFeatureItem('ไม่มีโฆษณา'),
              _buildPremiumFeatureItem('ดูดวงไม่จำกัด'),
              _buildPremiumFeatureItem('ไพ่ทาโรต์ไม่จำกัด'),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(
                  AppIcons.calendar,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  'สมาชิกภาพของคุณจะหมดอายุในวันที่ 31/12/2024',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Expanded(
      child: Row(
        children: [
          SvgIcon(
            AppIcons.checkCircle,
            size: 16,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatureItem(String text) {
    return Expanded(
      child: Row(
        children: [
          SvgIcon(
            AppIcons.checkCircle,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'การตั้งค่า',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // ซ่อนเมนูที่ยังไม่พร้อมใช้งาน
        // ProfileMenuItem(
        //   icon: Icons.history,
        //   title: 'ประวัติการดูดวง',
        //   onTap: () {
        //     AppRouter.navigateTo(context, AppRoutes.historyHoroscope);
        //   },
        // ),
        // ProfileMenuItem(
        //   icon: Icons.auto_awesome,
        //   title: 'ประวัติการอ่านไพ่',
        //   onTap: () {
        //     AppRouter.navigateTo(context, AppRoutes.historyTarot);
        //   },
        // ),
        // ProfileMenuItem(
        //   icon: Icons.chat_bubble_outline,
        //   title: 'ประวัติการสนทนา',
        //   onTap: () {
        //     AppRouter.navigateTo(context, AppRoutes.historyChat);
        //   },
        // ),
        // ProfileMenuItem(
        //   icon: Icons.notifications_outlined,
        //   title: 'การแจ้งเตือน',
        //   onTap: () {
        //     AppRouter.navigateTo(context, AppRoutes.notifications);
        //   },
        // ),
        ProfileMenuItem(
          icon: Icons.handshake_outlined,
          title: 'ระบบตัวแทน',
          onTap: () {
            _navigateToAffiliate();
          },
        ),
        ProfileMenuItem(
          svgIconPath: AppIcons.info,
          title: 'ช่วยเหลือและสนับสนุน',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.help);
          },
        ),
        ProfileMenuItem(
          svgIconPath: AppIcons.info,
          title: 'เกี่ยวกับแอป',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.about);
          },
        ),
      ],
    );
  }

  Future<void> _navigateToAffiliate() async {
    // ระบบตัวแทน (affiliate) ต้อง login — gate ก่อนเรียก getStatus()
    if (!await AuthGuard.requireAuth(context, intentLabel: 'affiliate')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เข้าสู่ระบบเพื่อใช้ระบบตัวแทนได้นะ'),
        ),
      );
      return;
    }
    if (!mounted) return;

    // Check if user is already an affiliate
    final affiliate = await AffiliateService().getStatus();
    if (!mounted) return;

    if (affiliate != null) {
      // Already registered - go to dashboard
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AffiliateDashboardScreen()),
      );
    } else {
      // Not registered - go to register
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AffiliateRegisterScreen()),
      );
    }
  }

  Widget _buildLogoutButton() {
    return OutlinedGradientButton(
      text: 'ออกจากระบบ',
      onPressed: () {
        _logout();
      },
      gradient: LinearGradient(
        colors: [
          Colors.red.shade300,
          Colors.red.shade500,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      icon: SvgIcon(
        AppIcons.logout,
        size: 20,
        color: Colors.red.shade400,
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: Text(
            'ยืนยันการออกจากระบบ',
            style: TextStyle(
              color: AppColors.lightText,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'คุณต้องการออกจากระบบใช่หรือไม่?',
            style: TextStyle(
              color: AppColors.lightText.withValues(alpha: 0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'ยกเลิก',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'ออกจากระบบ',
                style: TextStyle(
                  color: Colors.red.shade400,
                ),
              ),
            ),
          ],
        ),
      );

      if (shouldLogout != true) return;

      setState(() {
        _isLoading = true;
      });

      await _authService.signOut();

      if (mounted) {
        AppRouter.navigateAndClearStack(context, AppRoutes.welcome);
      }
    } catch (e) {
      debugPrint('Error logging out: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ออกจากระบบไม่สำเร็จ: ${e.toString()}'),
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
