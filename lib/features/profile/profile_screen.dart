import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/sacred_ui.dart';
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

  // ค่าเริ่มต้นที่เป็นกลาง — ใช้จนกว่าจะโหลดข้อมูลจริงจาก auth/ฐานข้อมูลสำเร็จ
  Map<String, dynamic> _userData = {
    'full_name': 'ผู้ใช้งาน',
    'email': '',
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
        }
        // ถ้าไม่มีข้อมูลในฐานข้อมูล แต่มีข้อมูลจาก auth แล้ว ให้ใช้ข้อมูลจาก auth ต่อไป
        // (ไม่มีข้อมูลตัวอย่างมาแทนที่แล้ว — เหลือเป็นค่าเริ่มต้นที่เป็นกลาง)
      } catch (e) {
        debugPrint('Error fetching profile from database: $e');
        // ถ้าดึงข้อมูลจากฐานข้อมูลไม่ได้ ให้ใช้ข้อมูลจาก auth ที่มีอยู่แล้วต่อไป
      }

      // Check subscription status
      await _checkSubscriptionStatus();
    } catch (e) {
      debugPrint('Error in _loadUserProfile: $e');
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
      // ถ้าข้อมูลผู้ใช้ (จาก auth หรือฐานข้อมูล) มีการกำหนดสถานะพรีเมียมไว้แล้ว
      // ให้เคารพค่านั้น — ไม่บังคับเป็น true
      if (_userData['is_premium'] is bool) {
        return;
      }

      // TODO: เชื่อมต่อ endpoint ตรวจสอบสถานะสมาชิกจริงเมื่อพร้อมใช้งาน
      // final subscription = await _authService.getUserSubscription();
      // _userData['is_premium'] = subscription != null && subscription['is_active'] == true;

      // ไม่มีข้อมูลสถานะสมาชิก — ค่าเริ่มต้นคือไม่ใช่พรีเมียม
      _userData['is_premium'] = false;
    } catch (e) {
      debugPrint('Error checking subscription status: $e');
      // Default to non-premium if there's an error
      _userData['is_premium'] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 4),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              )
            : _hasError
                ? _buildErrorView()
                : RefreshIndicator(
                    onRefresh: _loadUserProfile,
                    color: AppColors.deepGoldBrown,
                    backgroundColor: AppColors.ivorySilk,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildProfileInfo(),
                          const SizedBox(height: 28),
                          _buildSubscriptionCard(),
                          const SizedBox(height: 28),
                          _buildMenuItems(),
                          const SizedBox(height: 28),
                          _buildLogoutButton(),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SvgIcon(
              AppIcons.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: SacredText.kanit(
                color: AppColors.onBackdrop,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'ลองใหม่อีกครั้ง',
              onPressed: _loadUserProfile,
              gradient: const LinearGradient(
                colors: AppColors.goldGradient,
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SacredOverline('MY PROFILE'),
              const SizedBox(height: 3),
              Text(
                'โปรไฟล์',
                style: SacredText.kanit(
                  color: AppColors.onBackdrop,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.onBackdrop.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.onBackdrop.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: const Center(
                child: SvgIcon(
                  AppIcons.settings,
                  size: 22,
                  color: AppColors.onBackdrop,
                ),
              ),
            ),
          ),
        ],
      ),
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

    return SacredCard(
      radius: 22,
      child: Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.candleGold,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.candleGold.withValues(alpha: 0.18),
              child: _userData['profile_image_url'] != null &&
                      _userData['profile_image_url'].isNotEmpty
                  ? Image.network(
                      _userData['profile_image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SvgIcon(
                        AppIcons.personFilled,
                        size: 40,
                        color: AppColors.deepGoldBrown,
                      ),
                    )
                  : const SvgIcon(
                      AppIcons.personFilled,
                      size: 40,
                      color: AppColors.deepGoldBrown,
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
                style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userData['email'] ?? '',
                style: SacredText.kanit(
                  color: AppColors.mutedText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'วันเกิด: $birthDateText',
                style: SacredText.kanit(
                  color: AppColors.mutedText,
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
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 1,
                        ),
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
                            style: SacredText.kanit(
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
                            AppColors.candleGold,
                            AppColors.deepGoldBrown,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SvgIcon(
                            AppIcons.starFilled,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'พรีเมียม',
                            style: SacredText.kanit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
          icon: const SvgIcon(
            AppIcons.edit,
            size: 20,
            color: AppColors.deepGoldBrown,
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
      ),
    );
  }


  Widget _buildSubscriptionCard() {
    // ถ้าเป็นผู้ใช้พรีเมียมแล้ว แสดงการ์ดแบบพรีเมียม
    if (_userData['is_premium'] == true) {
      return _buildPremiumCard();
    }

    return SacredCard(
      radius: 18,
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SacredIconCoin(AppIcons.starFilled, size: 22, padding: 9),
              const SizedBox(width: 12),
              Text(
                'อัพเกรดเป็นพรีเมียม',
                style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'รับสิทธิประโยชน์เพิ่มเติมและปลดล็อกฟีเจอร์ทั้งหมด',
            style: SacredText.kanit(
              color: AppColors.mutedText,
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
                    backgroundColor: AppColors.lightSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Row(
                      children: [
                        const SvgIcon(AppIcons.info, size: 24, color: AppColors.deepGoldBrown),
                        const SizedBox(width: 8),
                        Text(
                          'แจ้งให้ทราบ',
                          style: SacredText.kanit(
                            color: AppColors.deepText,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'กำลังพัฒนาส่วนนี้',
                      style: SacredText.kanit(
                        color: AppColors.deepText,
                        fontSize: 14,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'ตกลง',
                          style: SacredText.kanit(
                            color: AppColors.deepGoldBrown,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            gradient: const LinearGradient(
              colors: AppColors.goldGradient,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            icon: const SvgIcon(
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
        gradient: const LinearGradient(
          colors: [
            AppColors.candleGold,
            AppColors.deepGoldBrown,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGoldBrown.withValues(alpha: 0.35),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SvgIcon(
                AppIcons.diamond,
                size: 24,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                'สมาชิกพรีเมียม',
                style: SacredText.kanit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ขอบคุณที่เป็นสมาชิกพรีเมียม คุณสามารถใช้งานฟีเจอร์ทั้งหมดได้ไม่จำกัด',
            style: SacredText.kanit(
              color: Colors.white.withValues(alpha: 0.92),
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
                const SvgIcon(
                  AppIcons.calendar,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'สมาชิกภาพของคุณจะหมดอายุในวันที่ 31/12/2024',
                  style: SacredText.kanit(
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
          const SvgIcon(
            AppIcons.checkCircle,
            size: 16,
            color: AppColors.bodhiGreen,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: SacredText.kanit(
                color: AppColors.deepText,
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
          const SvgIcon(
            AppIcons.checkCircle,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: SacredText.kanit(
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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: SacredSectionTitle('การตั้งค่า', overline: 'SETTINGS'),
        ),
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
    );
  }

  Future<void> _logout() async {
    try {
      // Show confirmation dialog
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'ยืนยันการออกจากระบบ',
            style: SacredText.kanit(
              color: AppColors.deepText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'คุณต้องการออกจากระบบใช่หรือไม่?',
            style: SacredText.kanit(
              color: AppColors.mutedText,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'ยกเลิก',
                style: SacredText.kanit(
                  color: AppColors.mutedText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'ออกจากระบบ',
                style: SacredText.kanit(
                  color: AppColors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
