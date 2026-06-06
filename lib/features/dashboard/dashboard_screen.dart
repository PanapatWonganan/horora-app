import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../shared/widgets/cosmic_background.dart';
import 'widgets/daily_horoscope_card.dart';
import 'widgets/feature_card.dart';
import 'widgets/zodiac_profile_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_activity_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show app bar title when scrolled past a certain point
    if (_scrollController.offset > 100 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 100 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cosmic background
          const CosmicBackground(),
          
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App bar
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.darkSurface.withValues(alpha: _showAppBarTitle ? 1.0 : 0.0),
                elevation: _showAppBarTitle ? 4.0 : 0.0,
                title: AnimatedOpacity(
                  opacity: _showAppBarTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Text('แดชบอร์ด'),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 8.0),
                    alignment: Alignment.bottomLeft,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'สวัสดี, คุณเมษ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'ยินดีต้อนรับกลับมา',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // Navigate to notifications
                      Navigator.pushNamed(context, AppRoutes.notifications);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () {
                      // Navigate to profile
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                  ),
                ],
              ),
              
              // Main content
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Zodiac profile card
                    const ZodiacProfileCard(
                      zodiacSign: 'ราศีเมษ',
                      element: 'ไฟ',
                      planet: 'ดาวอังคาร',
                    ),
                    
                    const SizedBox(height: 24.0),
                    
                    // Daily horoscope card
                    const DailyHoroscopeCard(
                      date: '15 มีนาคม 2567',
                      overview: 'วันนี้เป็นวันที่ดีสำหรับการเริ่มต้นสิ่งใหม่ๆ พลังงานของดาวอังคารจะช่วยเสริมความมั่นใจและความกล้าหาญให้กับคุณ',
                      loveRating: 4,
                      careerRating: 3,
                      healthRating: 5,
                      luckyNumber: '3, 7, 12',
                      luckyColor: 'แดง, ส้ม',
                    ),
                    
                    const SizedBox(height: 24.0),
                    
                    // Quick actions
                    const QuickActions(),
                    
                    const SizedBox(height: 24.0),
                    
                    // Features section
                    const Text(
                      'บริการของเรา',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16.0),
                    
                    // Feature cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      children: [
                        FeatureCard(
                          title: 'ดูดวงจากราศี',
                          description: 'ดูดวงประจำวัน สัปดาห์ และรายเดือน',
                          icon: Icons.auto_awesome,
                          color: AppColors.zodiacFire,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.horoscope);
                          },
                        ),
                        FeatureCard(
                          title: 'ไพ่ทาโร่',
                          description: 'เปิดไพ่ทาโร่เพื่อทำนายอนาคต',
                          icon: Icons.style,
                          color: AppColors.tarotMajor,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.tarot);
                          },
                        ),
                        FeatureCard(
                          title: 'สนทนากับนักพยากรณ์',
                          description: 'ปรึกษาปัญหากับนักพยากรณ์ AI',
                          icon: Icons.chat_bubble_outline,
                          color: AppColors.chatBubble,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.chat);
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24.0),
                    
                    // Recent activity section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'กิจกรรมล่าสุด',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to history
                          },
                          child: const Text(
                            'ดูทั้งหมด',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16.0),
                    
                    // Recent activity cards
                    const RecentActivityCard(
                      title: 'ดูดวงประจำวัน',
                      subtitle: 'ราศีเมษ - 14 มีนาคม 2567',
                      icon: Icons.auto_awesome,
                      color: AppColors.zodiacFire,
                      time: '1 ชั่วโมงที่แล้ว',
                    ),
                    
                    const SizedBox(height: 12.0),
                    
                    const RecentActivityCard(
                      title: 'เปิดไพ่ทาโร่',
                      subtitle: 'การเปิดไพ่แบบ 3 ใบ - ความรัก',
                      icon: Icons.style,
                      color: AppColors.tarotMajor,
                      time: '3 ชั่วโมงที่แล้ว',
                    ),
                    
                    const SizedBox(height: 12.0),
                    
                    const RecentActivityCard(
                      title: 'สนทนากับนักพยากรณ์',
                      subtitle: 'หัวข้อ: ดวงความรัก',
                      icon: Icons.chat_bubble_outline,
                      color: AppColors.chatBubble,
                      time: '1 วันที่แล้ว',
                    ),
                    
                    const SizedBox(height: 24.0),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 