import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../core/models/horoscope_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/thai_zodiac_service.dart';
import '../../../core/utils/app_icons.dart';
import '../../shared/widgets/loading_indicator.dart';

class DailyHoroscopeCard extends StatefulWidget {
  final String zodiacSign;
  final DateTime date;
  final VoidCallback? onViewDetails;

  const DailyHoroscopeCard({
    Key? key,
    required this.zodiacSign,
    required this.date,
    this.onViewDetails,
  }) : super(key: key);

  @override
  State<DailyHoroscopeCard> createState() => _DailyHoroscopeCardState();
}

class _DailyHoroscopeCardState extends State<DailyHoroscopeCard> {
  final AuthService _authService = AuthService.instance;
  bool _isLoading = true;
  DailyHoroscope? _horoscope;
  String? _userZodiacSign;
  String? _userZodiacSignThai;
  
  @override
  void initState() {
    super.initState();
    _loadUserZodiacSign();
    _loadHoroscope();
  }
  
  Future<void> _loadUserZodiacSign() async {
    final user = _authService.currentUser;
    if (user != null) {
      // ใช้ข้อมูล thai_animal จาก Laravel user ก่อน
      if (user.thaiAnimal != null) {
        setState(() {
          _userZodiacSign = user.thaiAnimal!;
          _userZodiacSignThai = 'ปี${user.thaiAnimal}';
        });
      } else if (user.birthDate != null) {
        // ถ้าไม่มี thai_animal ให้คำนวณจากวันเกิด
        setState(() {
          final thaiZodiac = ThaiZodiacService.getThaiZodiacFromDate(user.birthDate!);
          _userZodiacSign = thaiZodiac.animalName;
          _userZodiacSignThai = thaiZodiac.thaiName;
        });
      }
    }
  }
  
  Future<void> _loadHoroscope() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // ใช้ข้อมูลจำลองเนื่องจาก API อาจยังไม่พร้อมใช้งาน
      _horoscope = _getMockHoroscope();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถโหลดดวงประจำวันได้: ${e.toString()}')),
        );
      }
    }
  }
  
  // สร้างข้อมูลดวงประจำวันจำลองสำหรับปีนักษัตรไทย
  DailyHoroscope _getMockHoroscope() {
    final now = DateTime.now();
    final thaiAnimal = _userZodiacSign ?? 'มะเมีย'; // ใช้ Thai animal name
    
    // ข้อความคำทำนายที่แตกต่างกันตามปีนักษัตรไทย
    String content = '';
    String contentTh = '';
    int loveRating = 3;
    int careerRating = 3;
    int healthRating = 3;
    String luckyNumber = '7';
    String luckyColor = 'ฟ้า';
    
    switch (thaiAnimal.toLowerCase()) {
      case 'ชวด':
        contentTh = 'วันนี้คุณจะมีโอกาสใช้ไหวพริบและความขยันหนักของคุณ การเก็บออมจะได้ผลดี งานที่ต้องใช้ความรอบคอบจะเหมาะกับคุณ';
        content = 'Today you will have the opportunity to use your wit and hard work. Saving will yield good results. Work requiring thoroughness suits you.';
        loveRating = 4;
        careerRating = 5;
        healthRating = 4;
        luckyNumber = '1, 8, 12';
        luckyColor = 'ทอง';
        break;
      case 'ฉลู':
        contentTh = 'ความมั่นคงและอดทนของคุณจะได้รับการตอบแทนวันนี้ เหมาะกับการวางแผนระยะยาวและการลงทุนที่มั่นคง';
        content = 'Your stability and patience will be rewarded today. Suitable for long-term planning and stable investments.';
        loveRating = 4;
        careerRating = 4;
        healthRating = 5;
        luckyNumber = '2, 6, 15';
        luckyColor = 'เหลือง';
        break;
      case 'ขาล':
        contentTh = 'ความกล้าหาญและการเป็นผู้นำของคุณจะโดดเด่นวันนี้ เหมาะกับการเริ่มโครงการใหม่ และการแก้ปัญหาที่ท้าทาย';
        content = 'Your courage and leadership will stand out today. Perfect for starting new projects and solving challenging problems.';
        loveRating = 5;
        careerRating = 5;
        healthRating = 3;
        luckyNumber = '3, 9, 18';
        luckyColor = 'แดง';
        break;
      case 'เถาะ':
        contentTh = 'ความอ่อนโยนและมารยาทของคุณจะช่วยสร้างความสัมพันธ์ที่ดี วันนี้เหมาะกับการทำงานเป็นทีมและการประนีประนอม';
        content = 'Your gentleness and politeness will help build good relationships. Today is suitable for teamwork and compromise.';
        loveRating = 5;
        careerRating = 4;
        healthRating = 4;
        luckyNumber = '4, 11, 20';
        luckyColor = 'เงิน';
        break;
      case 'มะโรง':
        contentTh = 'พลังและความมั่นใจของคุณจะเปล่งประกายวันนี้ เหมาะกับการแสดงความสามารถและเป็นที่สนใจของผู้อื่น';
        content = 'Your energy and confidence will shine today. Perfect for showcasing your abilities and being the center of attention.';
        loveRating = 4;
        careerRating = 5;
        healthRating = 4;
        luckyNumber = '5, 14, 23';
        luckyColor = 'เขียว';
        break;
      case 'มะเส็ง':
        contentTh = 'ปัญญาและสัญชาตญาณของคุณจะช่วยในการตัดสินใจสำคัญวันนี้ เหมาะกับการเรียนรู้สิ่งใหม่และการวิจัย';
        content = 'Your wisdom and intuition will help in making important decisions today. Suitable for learning new things and research.';
        loveRating = 3;
        careerRating = 5;
        healthRating = 4;
        luckyNumber = '6, 13, 24';
        luckyColor = 'น้ำเงิน';
        break;
      case 'มะเมีย':
        contentTh = 'ความกระฉับกระเฉงและรักเสรีภาพของคุณจะนำพาผลลัพธ์ดีวันนี้ เหมาะกับการเดินทางและการผจญภัย';
        content = 'Your agility and love of freedom will bring good results today. Suitable for travel and adventure.';
        loveRating = 4;
        careerRating = 4;
        healthRating = 5;
        luckyNumber = '7, 16, 25';
        luckyColor = 'ไฟ';
        break;
      case 'มะแม':
        contentTh = 'ความอ่อนโยนและจิตใจศิลปินของคุณจะได้รับการชื่นชมวันนี้ เหมาะกับงานสร้างสรรค์และการดูแลผู้อื่น';
        content = 'Your gentleness and artistic soul will be appreciated today. Suitable for creative work and caring for others.';
        loveRating = 5;
        careerRating = 3;
        healthRating = 4;
        luckyNumber = '8, 17, 26';
        luckyColor = 'ชมพู';
        break;
      case 'วอก':
        contentTh = 'ความฉลาดและไหวพริบของคุณจะช่วยแก้ปัญหาได้ดีวันนี้ เหมาะกับการเจรจาและการปรับเปลี่ยน';
        content = 'Your intelligence and wit will help solve problems well today. Suitable for negotiation and adaptation.';
        loveRating = 4;
        careerRating = 4;
        healthRating = 3;
        luckyNumber = '9, 18, 27';
        luckyColor = 'ม่วง';
        break;
      case 'ระกา':
        contentTh = 'ความตรงไปตรงมาและรักความสะอาดของคุณจะสร้างความน่าเชื่อถือวันนี้ เหมาะกับการจัดระเบียบและปรับปรุง';
        content = 'Your honesty and love of cleanliness will create trustworthiness today. Suitable for organizing and improving.';
        loveRating = 3;
        careerRating = 4;
        healthRating = 5;
        luckyNumber = '10, 19, 28';
        luckyColor = 'ขาว';
        break;
      case 'จอ':
        contentTh = 'ความซื่อสัตย์และความรับผิดชอบของคุณจะได้รับการยอมรับวันนี้ เหมาะกับการดูแลครอบครัวและงานที่ต้องใช้ความไว้วางใจ';
        content = 'Your honesty and responsibility will be recognized today. Suitable for family care and work requiring trust.';
        loveRating = 5;
        careerRating = 4;
        healthRating = 4;
        luckyNumber = '11, 20, 29';
        luckyColor = 'น้ำตาล';
        break;
      case 'กุน':
        contentTh = 'ใจกว้างและความเอื้อเฟื้อของคุณจะนำพาความสุขมาให้วันนี้ เหมาะกับการช่วยเหลือผู้อื่นและการสร้างความสุขสบาย';
        content = 'Your generosity and kindness will bring happiness today. Suitable for helping others and creating comfort.';
        loveRating = 4;
        careerRating = 3;
        healthRating = 5;
        luckyNumber = '12, 21, 30';
        luckyColor = 'ดำ';
        break;
      default:
        contentTh = 'วันนี้เป็นวันที่ดีสำหรับการใช้ลักษณะเฉพาะของคุณ คุณจะได้พบกับโอกาสดีๆ ในการทำงานและความสัมพันธ์';
        content = 'Today is a good day for using your unique characteristics. You will find good opportunities in work and relationships.';
        loveRating = 4;
        careerRating = 4;
        healthRating = 4;
        luckyNumber = '7, 16, 25';
        luckyColor = 'ม่วง';
    }
    
    return DailyHoroscope(
      id: 1,
      thaiAnimal: thaiAnimal,
      date: now,
      content: content,
      contentTh: contentTh,
      loveRating: loveRating,
      careerRating: careerRating,
      healthRating: healthRating,
      luckyNumber: luckyNumber,
      luckyColor: luckyColor,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: LoadingIndicator(),
        ),
      );
    }

    final horoscope = _horoscope;
    if (horoscope == null) {
      return Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'ไม่สามารถโหลดดวงประจำวันได้',
            style: GoogleFonts.kanit(
              color: AppColors.mutedText,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        // Layered shadow for real depth (ambient + tinted lift).
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.18),
            blurRadius: 22,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Soft celestial highlight glow in the corner.
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.45),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Second soft glow lower-left for the gradient-mesh feel.
            Positioned(
              bottom: -50,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.tertiary.withValues(alpha: 0.28),
                      AppColors.tertiary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Glassmorphism wash + hairline border over the whole card so the
            // content sits on frosted glass, not a flat pastel fill.
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.55),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Editorial English overline in the display serif.
                          Text(
                            'YOUR SIGN',
                            style: GoogleFonts.fraunces(
                              color: AppColors.primary.withValues(alpha: 0.85),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _userZodiacSignThai ?? widget.zodiacSign,
                            style: GoogleFonts.kanit(
                              color: AppColors.deepText,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d MMMM yyyy', 'th_TH')
                                .format(horoscope.date),
                            style: GoogleFonts.fraunces(
                              color: AppColors.deepText.withValues(alpha: 0.78),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      // Thai zodiac illustration (consistent SVG language)
                      // instead of an OS-rendered emoji. These zodiac SVGs ship
                      // their own circular gradient background, so no tint or
                      // white plate is needed — just a soft drop shadow.
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.22),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: SvgIcon(
                            AppIcons.getThaiZodiacIcon(
                              _userZodiacSign ?? 'มะเมีย',
                            ),
                            size: 54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    horoscope.contentTh,
                    style: GoogleFonts.kanit(
                      color: AppColors.deepText.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRatingItem('ความรัก', horoscope.loveRating),
                      _buildRatingItem('การงาน', horoscope.careerRating),
                      _buildRatingItem('สุขภาพ', horoscope.healthRating),
                      _buildLuckyItem('เลขนำโชค', horoscope.luckyNumber),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Align(
                  //   alignment: Alignment.centerRight,
                    // child: TextButton(
                    //   onPressed: () {
                    //     if (widget.onViewDetails != null) {
                    //       widget.onViewDetails!();
                    //     } else {
                    //       try {
                    //         // ตรวจสอบว่า _horoscope ไม่เป็น null ก่อนส่งข้อมูล
                    //         if (_horoscope != null) {
                    //           // แสดงข้อมูลเพื่อตรวจสอบ
                    //           print('Navigating to HoroscopeDetailScreen directly');
                    //           print('Horoscope data: ${_horoscope.toString()}');
                    //           print('Horoscope content: ${_horoscope!.content}');
                    //           print('Horoscope contentTh: ${_horoscope!.contentTh}');
                    //           print('Horoscope zodiacSign: ${_horoscope!.zodiacSign}');
                    //           print('ZodiacSignThai: ${_userZodiacSignThai ?? widget.zodiacSign}');
                    //           print('ZodiacSignEn: ${_userZodiacSign ?? widget.zodiacSign}');
                              
                    //           // สร้างหน้า HoroscopeDetailScreen โดยตรง
                    //           final detailScreen = HoroscopeDetailScreen(
                    //             horoscope: _horoscope!,
                    //             zodiacSignThai: _userZodiacSignThai ?? widget.zodiacSign,
                    //             zodiacSignEn: _userZodiacSign ?? widget.zodiacSign,
                    //           );
                              
                    //           // ใช้ Navigator.push โดยตรง
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(builder: (_) => detailScreen),
                    //           ).then((value) {
                    //             print('Returned from HoroscopeDetailScreen');
                    //           }).catchError((error) {
                    //             print('Error navigating to HoroscopeDetailScreen: $error');
                    //             ScaffoldMessenger.of(context).showSnackBar(
                    //               SnackBar(content: Text('เกิดข้อผิดพลาด: ${error.toString()}')),
                    //             );
                    //           });
                    //         } else {
                    //           // แสดงข้อความแจ้งเตือนเมื่อไม่มีข้อมูล
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             const SnackBar(
                    //               content: Text('ไม่สามารถโหลดข้อมูลดวงประจำวันได้'),
                    //               duration: Duration(seconds: 2),
                    //             ),
                    //           );
                    //         }
                    //       } catch (e) {
                    //         print('Exception when navigating: ${e.toString()}');
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
                    //         );
                    //       }
                    //     }
                    //   },
                      // style: TextButton.styleFrom(
                      //   foregroundColor: Colors.white,
                      //   padding: EdgeInsets.zero,
                      // ),
                      // child: Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [
                      //     // Text(
                      //     //   'ดูเพิ่มเติม',
                      //     //   style: TextStyle(
                      //     //     fontSize: 14,
                      //     //     fontWeight: FontWeight.bold,
                      //     //   ),
                      //     // ),
                      //     // SizedBox(width: 4),
                      //     // Icon(
                      //     //   Icons.arrow_forward_ios,
                      //     //   size: 12,
                      //     // ),
                      //   ],
                      // ),
                    //),
                  //),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem(String label, int rating) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.kanit(
            color: AppColors.deepText.withValues(alpha: 0.85),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: index < rating
                  ? AppColors.accent
                  : AppColors.deepText.withValues(alpha: 0.25),
              size: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.kanit(
            color: AppColors.deepText.withValues(alpha: 0.85),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.fraunces(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

}
