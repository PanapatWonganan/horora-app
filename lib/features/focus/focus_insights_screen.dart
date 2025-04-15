import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FocusInsightsScreen extends StatelessWidget {
  final int sessionDurationMinutes;
  final String sessionDate;
  final String soundscape;

  const FocusInsightsScreen({
    Key? key,
    required this.sessionDurationMinutes,
    required this.sessionDate,
    required this.soundscape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ข้อมูลเชิงลึกการนั่งสมาธิ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session summary card
              _buildSummaryCard(context),
              
              const SizedBox(height: 24.0),
              
              // Insights section
              const Text(
                'ข้อมูลเชิงลึกจากการนั่งสมาธิ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildInsightCard(
                icon: Icons.self_improvement,
                title: 'การเชื่อมต่อกับตัวเอง',
                content: 'การนั่งสมาธิครั้งนี้ช่วยให้คุณได้เชื่อมต่อกับตัวเองมากขึ้น ทำให้เกิดความสงบภายในและความชัดเจนในความคิด',
              ),
              const SizedBox(height: 16.0),
              _buildInsightCard(
                icon: Icons.psychology,
                title: 'สภาวะจิตใจ',
                content: 'ระหว่างการนั่งสมาธิ คุณได้ปล่อยวางความเครียดและความวิตกกังวล ช่วยให้จิตใจของคุณผ่อนคลายและเปิดรับพลังงานเชิงบวก',
              ),
              const SizedBox(height: 16.0),
              _buildInsightCard(
                icon: Icons.stars,
                title: 'การเชื่อมต่อกับจักรวาล',
                content: 'พลังงานของคุณได้เชื่อมต่อกับจักรวาล ทำให้เกิดความสมดุลและความกลมกลืนกับพลังงานจักรวาล ซึ่งจะช่วยนำทางคุณในวันข้างหน้า',
              ),
              
              const SizedBox(height: 24.0),
              
              // Recommendations section
              const Text(
                'คำแนะนำสำหรับการนั่งสมาธิครั้งต่อไป',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildRecommendationCard(
                title: 'เพิ่มระยะเวลา',
                content: 'ลองเพิ่มระยะเวลาการนั่งสมาธิเป็น ${sessionDurationMinutes + 5} นาทีในครั้งต่อไป เพื่อเพิ่มประสิทธิภาพของการนั่งสมาธิ',
                actionText: 'ตั้งค่าเตือน',
                onAction: () {
                  // TODO: Implement reminder setting
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ตั้งค่าเตือนสำเร็จ')),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              _buildRecommendationCard(
                title: 'ลองเสียงพื้นหลังใหม่',
                content: 'ลองเปลี่ยนเสียงพื้นหลังเป็น "พลังจักรวาล" ในครั้งต่อไป เพื่อเพิ่มประสบการณ์การนั่งสมาธิที่แตกต่าง',
                actionText: 'จดจำ',
                onAction: () {
                  // TODO: Save preference
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('บันทึกการตั้งค่าสำเร็จ')),
                  );
                },
              ),
              
              const SizedBox(height: 24.0),
              
              // Progress section
              const Text(
                'ความก้าวหน้าของคุณ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildProgressCard(),
              
              const SizedBox(height: 32.0),
              
              // Share and save buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement sharing
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('แชร์ข้อมูลเชิงลึกสำเร็จ')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('แชร์ข้อมูลเชิงลึก'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Save insights
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('บันทึกและปิด'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      color: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'สรุปการนั่งสมาธิ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  icon: Icons.timer,
                  value: '$sessionDurationMinutes นาที',
                  label: 'ระยะเวลา',
                ),
                _buildSummaryItem(
                  icon: Icons.calendar_today,
                  value: sessionDate,
                  label: 'วันที่',
                ),
                _buildSummaryItem(
                  icon: Icons.music_note,
                  value: _getThaiSoundscapeName(soundscape),
                  label: 'เสียงพื้นหลัง',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 28.0,
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      color: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24.0,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    content,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard({
    required String title,
    required String content,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Card(
      color: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                child: Text(
                  actionText,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      color: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'สถิติการนั่งสมาธิ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '7 วันล่าสุด',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              height: 150.0,
              child: _buildProgressChart(),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProgressStat(
                  value: '3',
                  label: 'จำนวนครั้ง',
                ),
                _buildProgressStat(
                  value: '45 นาที',
                  label: 'เวลารวม',
                ),
                _buildProgressStat(
                  value: '15 นาที',
                  label: 'เฉลี่ยต่อครั้ง',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    // Mock data for the chart
    final List<int> sessionMinutes = [0, 10, 0, 15, 0, 0, sessionDurationMinutes];
    final List<String> days = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final double barHeight = sessionMinutes[index] * 2.5;
        final bool isToday = index == 6;
        
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                sessionMinutes[index] > 0 ? '${sessionMinutes[index]}' : '',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10.0,
                ),
              ),
              const SizedBox(height: 4.0),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: barHeight,
                width: 20.0,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                days[index],
                style: TextStyle(
                  color: isToday ? Colors.white : Colors.white.withOpacity(0.7),
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProgressStat({
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  String _getThaiSoundscapeName(String soundscape) {
    switch (soundscape) {
      case 'cosmic_harmony':
        return 'จักรวาลกลมกลืน';
      case 'star_whispers':
        return 'ดวงดาวกระซิบ';
      case 'cosmic_energy':
        return 'พลังจักรวาล';
      case 'lunar_breeze':
        return 'สายลมจันทรา';
      case 'silent':
        return 'เสียงเงียบสงบ';
      default:
        return soundscape;
    }
  }
} 