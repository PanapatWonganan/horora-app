import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../core/models/horoscope_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/zodiac_utils.dart';
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
  late Future<DailyHoroscope> _horoscopeFuture;
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
    if (user != null && user.userMetadata != null) {
      if (user.userMetadata!['zodiac_sign'] != null) {
        setState(() {
          _userZodiacSign = user.userMetadata!['zodiac_sign'] as String;
          _userZodiacSignThai = ZodiacUtils.getZodiacSignThai(DateTime(2000, 1, 1), zodiacSign: _userZodiacSign);
        });
      } else if (user.userMetadata!['birth_date'] != null) {
        final birthDate = DateTime.parse(user.userMetadata!['birth_date'] as String);
        setState(() {
          _userZodiacSign = ZodiacUtils.getZodiacSign(birthDate);
          _userZodiacSignThai = ZodiacUtils.getZodiacSignThai(birthDate);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถโหลดดวงประจำวันได้: ${e.toString()}')),
      );
    }
  }
  
  // สร้างข้อมูลดวงประจำวันจำลอง
  DailyHoroscope _getMockHoroscope() {
    final now = DateTime.now();
    final zodiacSign = _userZodiacSign ?? widget.zodiacSign;
    
    // ข้อความคำทำนายที่แตกต่างกันตามราศี
    String content = '';
    String contentTh = '';
    int loveRating = 3;
    int careerRating = 3;
    int healthRating = 3;
    String luckyNumber = '7';
    String luckyColor = 'ฟ้า';
    
    switch (zodiacSign.toLowerCase()) {
      case 'aries':
        contentTh = 'วันนี้คุณจะมีพลังงานเต็มเปี่ยม เหมาะกับการเริ่มต้นโปรเจกต์ใหม่ๆ ความกล้าหาญของคุณจะนำพาโอกาสดีๆ มาให้';
        content = 'Today you will be full of energy, perfect for starting new projects. Your courage will bring good opportunities.';
        loveRating = 4;
        careerRating = 5;
        healthRating = 4;
        luckyNumber = '9, 18, 27';
        luckyColor = 'แดง';
        break;
      case 'taurus':
        contentTh = 'ความมั่นคงทางการเงินจะเข้ามาในชีวิตคุณ วันนี้เหมาะกับการวางแผนระยะยาว ความอดทนของคุณจะได้รับการตอบแทน';
        content = 'Financial stability will come into your life. Today is suitable for long-term planning. Your patience will be rewarded.';
        loveRating = 3;
        careerRating = 4;
        healthRating = 5;
        luckyNumber = '6, 15, 24';
        luckyColor = 'เขียว';
        break;
      case 'gemini':
        contentTh = 'การสื่อสารของคุณจะโดดเด่นในวันนี้ เป็นโอกาสดีในการเจรจาต่อรองหรือนำเสนองาน ความคิดสร้างสรรค์ของคุณจะได้รับการยอมรับ';
        content = 'Your communication will stand out today. It\'s a good opportunity for negotiation or presentation. Your creativity will be recognized.';
        loveRating = 5;
        careerRating = 4;
        healthRating = 3;
        luckyNumber = '5, 14, 23';
        luckyColor = 'เหลือง';
        break;
      case 'cancer':
        contentTh = 'ความรู้สึกไวของคุณจะช่วยให้เข้าใจคนรอบข้างได้ดีขึ้น วันนี้เหมาะกับการดูแลตัวเองและคนที่คุณรัก ครอบครัวจะนำความสุขมาให้';
        content = 'Your sensitivity will help you understand those around you better. Today is suitable for taking care of yourself and your loved ones. Family will bring happiness.';
        loveRating = 5;
        careerRating = 3;
        healthRating = 4;
        luckyNumber = '2, 11, 20';
        luckyColor = 'เงิน';
        break;
      case 'leo':
        contentTh = 'ความเป็นผู้นำของคุณจะโดดเด่นในวันนี้ เป็นโอกาสดีในการแสดงความสามารถ ความมั่นใจของคุณจะสร้างแรงบันดาลใจให้ผู้อื่น';
        content = 'Your leadership will stand out today. It\'s a good opportunity to showcase your abilities. Your confidence will inspire others.';
        loveRating = 4;
        careerRating = 5;
        healthRating = 4;
        luckyNumber = '1, 10, 19';
        luckyColor = 'ทอง';
        break;
      case 'virgo':
        contentTh = 'ความละเอียดรอบคอบของคุณจะช่วยแก้ปัญหาที่ซับซ้อนได้ วันนี้เหมาะกับการจัดระเบียบและวางแผน การวิเคราะห์ของคุณจะนำไปสู่ความสำเร็จ';
        content = 'Your attention to detail will help solve complex problems. Today is suitable for organizing and planning. Your analysis will lead to success.';
        loveRating = 3;
        careerRating = 5;
        healthRating = 4;
        luckyNumber = '3, 12, 21';
        luckyColor = 'น้ำตาล';
        break;
      case 'libra':
        contentTh = 'ความสมดุลในชีวิตจะเป็นกุญแจสำคัญในวันนี้ เหมาะกับการสร้างความสัมพันธ์ใหม่ๆ ความยุติธรรมของคุณจะได้รับการยกย่อง';
        content = 'Balance in life will be the key today. It\'s suitable for building new relationships. Your fairness will be appreciated.';
        loveRating = 5;
        careerRating = 4;
        healthRating = 4;
        luckyNumber = '7, 16, 25';
        luckyColor = 'ฟ้า';
        break;
      case 'scorpio':
        contentTh = 'พลังแห่งการเปลี่ยนแปลงจะอยู่กับคุณในวันนี้ เป็นโอกาสดีในการเริ่มต้นใหม่ ความเข้มแข็งภายในของคุณจะช่วยให้ผ่านพ้นอุปสรรค';
        content = 'The power of transformation will be with you today. It\'s a good opportunity for a new beginning. Your inner strength will help you overcome obstacles.';
        loveRating = 4;
        careerRating = 4;
        healthRating = 5;
        luckyNumber = '8, 17, 26';
        luckyColor = 'แดงเข้ม';
        break;
      case 'sagittarius':
        contentTh = 'การผจญภัยและโอกาสใหม่ๆ จะเข้ามาในชีวิตคุณ วันนี้เหมาะกับการเรียนรู้และขยายขอบเขต ความกระตือรือร้นของคุณจะนำพาความสำเร็จ';
        content = 'Adventure and new opportunities will come into your life. Today is suitable for learning and expanding your horizons. Your enthusiasm will bring success.';
        loveRating = 4;
        careerRating = 4;
        healthRating = 4;
        luckyNumber = '3, 12, 21';
        luckyColor = 'ม่วง';
        break;
      case 'capricorn':
        contentTh = 'ความมุ่งมั่นของคุณจะได้รับการตอบแทนในวันนี้ เหมาะกับการทำงานหนักเพื่อเป้าหมายระยะยาว ความรับผิดชอบของคุณจะได้รับการยอมรับ';
        content = 'Your determination will be rewarded today. It\'s suitable for working hard towards long-term goals. Your responsibility will be recognized.';
        loveRating = 3;
        careerRating = 5;
        healthRating = 4;
        luckyNumber = '4, 13, 22';
        luckyColor = 'ดำ';
        break;
      case 'aquarius':
        contentTh = 'ความคิดสร้างสรรค์และนวัตกรรมจะเฟื่องฟูในวันนี้ เป็นโอกาสดีในการแสดงความเป็นตัวของตัวเอง ความเป็นอิสระของคุณจะนำพาความสุข';
        content = 'Creativity and innovation will flourish today. It\'s a good opportunity to express your individuality. Your independence will bring happiness.';
        loveRating = 4;
        careerRating = 4;
        healthRating = 3;
        luckyNumber = '4, 13, 22';
        luckyColor = 'น้ำเงิน';
        break;
      case 'pisces':
        contentTh = 'ความเข้าอกเข้าใจและความเมตตาของคุณจะโดดเด่นในวันนี้ เหมาะกับการช่วยเหลือผู้อื่น จินตนาการของคุณจะนำพาแรงบันดาลใจ';
        content = 'Your empathy and compassion will stand out today. It\'s suitable for helping others. Your imagination will bring inspiration.';
        loveRating = 5;
        careerRating = 3;
        healthRating = 4;
        luckyNumber = '7, 16, 25';
        luckyColor = 'เขียวน้ำทะเล';
        break;
      default:
        contentTh = 'วันนี้เป็นวันที่ดีสำหรับการเริ่มต้นสิ่งใหม่ๆ คุณจะได้พบกับโอกาสดีๆ ในการทำงาน และความสัมพันธ์กับคนรอบข้างจะราบรื่น';
        content = 'Today is a good day for new beginnings. You will find good opportunities at work, and relationships with those around you will be smooth.';
        loveRating = 4;
        careerRating = 4;
        healthRating = 4;
        luckyNumber = '7, 16, 25';
        luckyColor = 'ม่วง';
    }
    
    return DailyHoroscope(
      id: 1,
      zodiacSign: zodiacSign,
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
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
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
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'ไม่สามารถโหลดดวงประจำวันได้',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userZodiacSignThai ?? widget.zodiacSign,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d MMMM yyyy', 'th_TH').format(horoscope.date),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            _getZodiacImagePath(),
                            width: 30,
                            height: 30,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 30,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    horoscope.contentTh,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 14,
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getZodiacImagePath() {
    final zodiacSign = _userZodiacSign?.toLowerCase() ?? widget.zodiacSign.toLowerCase();
    
    switch (zodiacSign) {
      case 'aries':
        return 'assets/images/zodiac/aries.png';
      case 'taurus':
        return 'assets/images/zodiac/taurus.png';
      case 'gemini':
        return 'assets/images/zodiac/gemini.png';
      case 'cancer':
        return 'assets/images/zodiac/cancer.png';
      case 'leo':
        return 'assets/images/zodiac/leo.png';
      case 'virgo':
        return 'assets/images/zodiac/virgo.png';
      case 'libra':
        return 'assets/images/zodiac/libra.png';
      case 'scorpio':
        return 'assets/images/zodiac/scorpio.png';
      case 'sagittarius':
        return 'assets/images/zodiac/sagittarius.png';
      case 'capricorn':
        return 'assets/images/zodiac/capricorn.png';
      case 'aquarius':
        return 'assets/images/zodiac/aquarius.png';
      case 'pisces':
        return 'assets/images/zodiac/pisces.png';
      default:
        return 'assets/images/zodiac/scorpio.png';
    }
  }
} 