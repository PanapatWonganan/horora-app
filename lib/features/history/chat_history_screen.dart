import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการสนทนากับนักพยากรณ์'),
        backgroundColor: AppColors.darkSurface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10, // Mock data count
        itemBuilder: (context, index) {
          return _buildHistoryItem(context, index);
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, int index) {
    // Mock data
    final date = DateTime.now().subtract(Duration(days: index));
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final time = '${(10 + index % 12)}:${(index * 5) % 60 < 10 ? '0' : ''}${(index * 5) % 60} ${index % 2 == 0 ? 'AM' : 'PM'}';
    
    final astrologers = ['อาจารย์มีน', 'หมอดูแม่มณี', 'อาจารย์เมษ', 'หมอช้าง', 'อาจารย์กุ๊กไก่'];
    final astrologer = astrologers[index % astrologers.length];
    
    final topics = ['ดวงความรัก', 'ดวงการงาน', 'ดวงการเงิน', 'ดวงครอบครัว', 'ดวงสุขภาพ'];
    final topic = topics[index % topics.length];
    
    final durations = ['15 นาที', '30 นาที', '45 นาที', '60 นาที'];
    final duration = durations[index % durations.length];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  astrologer,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$formattedDate, $time',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    topic,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'สรุปการสนทนา',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'คุณได้รับคำแนะนำเกี่ยวกับการวางแผนชีวิตในอนาคต โดยนักพยากรณ์แนะนำให้ระมัดระวังเรื่องการเงินในช่วง 3 เดือนข้างหน้า และควรหมั่นทำบุญเพื่อเสริมดวงชะตา',
              style: TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 16.0),
            OutlinedButton(
              onPressed: () {
                // TODO: Navigate to full conversation
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
              ),
              child: const Text('ดูบทสนทนาทั้งหมด'),
            ),
          ],
        ),
      ),
    );
  }
} 