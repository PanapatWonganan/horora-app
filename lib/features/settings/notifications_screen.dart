import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../shared/widgets/gradient_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // สถานะการเปิด/ปิดการแจ้งเตือนต่างๆ
  bool _dailyHoroscopeEnabled = true;
  bool _weeklyHoroscopeEnabled = true;
  bool _tarotReminderEnabled = false;
  bool _chatNotificationsEnabled = true;
  bool _promotionsEnabled = false;
  bool _appUpdatesEnabled = true;
  
  // เวลาที่จะรับการแจ้งเตือนดวงประจำวัน
  TimeOfDay _dailyHoroscopeTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'การแจ้งเตือน',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.lightText,
        ),
      ),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('การแจ้งเตือนดวงชะตา'),
                const SizedBox(height: 16),
                _buildNotificationSwitch(
                  'ดวงประจำวัน',
                  'รับการแจ้งเตือนดวงประจำวันของคุณทุกเช้า',
                  _dailyHoroscopeEnabled,
                  (value) {
                    setState(() {
                      _dailyHoroscopeEnabled = value;
                    });
                  },
                ),
                if (_dailyHoroscopeEnabled) _buildTimeSelector(),
                _buildNotificationSwitch(
                  'ดวงประจำสัปดาห์',
                  'รับการแจ้งเตือนดวงประจำสัปดาห์ทุกวันจันทร์',
                  _weeklyHoroscopeEnabled,
                  (value) {
                    setState(() {
                      _weeklyHoroscopeEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('การแจ้งเตือนไพ่ทาโรต์'),
                const SizedBox(height: 16),
                _buildNotificationSwitch(
                  'เตือนให้อ่านไพ่',
                  'รับการแจ้งเตือนให้อ่านไพ่ทาโรต์ประจำวัน',
                  _tarotReminderEnabled,
                  (value) {
                    setState(() {
                      _tarotReminderEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('การแจ้งเตือนการสนทนา'),
                const SizedBox(height: 16),
                _buildNotificationSwitch(
                  'ข้อความใหม่',
                  'รับการแจ้งเตือนเมื่อมีข้อความใหม่จากนักพยากรณ์',
                  _chatNotificationsEnabled,
                  (value) {
                    setState(() {
                      _chatNotificationsEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('การแจ้งเตือนอื่นๆ'),
                const SizedBox(height: 16),
                _buildNotificationSwitch(
                  'โปรโมชั่นและข้อเสนอพิเศษ',
                  'รับการแจ้งเตือนเกี่ยวกับโปรโมชั่นและข้อเสนอพิเศษ',
                  _promotionsEnabled,
                  (value) {
                    setState(() {
                      _promotionsEnabled = value;
                    });
                  },
                ),
                _buildNotificationSwitch(
                  'อัปเดตแอปพลิเคชัน',
                  'รับการแจ้งเตือนเมื่อมีการอัปเดตแอปพลิเคชัน',
                  _appUpdatesEnabled,
                  (value) {
                    setState(() {
                      _appUpdatesEnabled = value;
                    });
                  },
                ),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.lightText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.lightText.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เวลาที่ต้องการรับการแจ้งเตือน',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ดวงประจำวันจะถูกส่งในเวลานี้',
                  style: TextStyle(
                    color: AppColors.lightText.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTimeOfDay(_dailyHoroscopeTime),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyHoroscopeTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.darkSurface,
              onSurface: AppColors.lightText,
            ), dialogTheme: DialogThemeData(backgroundColor: AppColors.darkSurface),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _dailyHoroscopeTime) {
      setState(() {
        _dailyHoroscopeTime = picked;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildSaveButton() {
    return GradientButton(
      text: 'บันทึกการตั้งค่า',
      onPressed: _saveSettings,
      gradient: LinearGradient(
        colors: AppColors.primaryGradient,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      width: double.infinity,
    );
  }

  void _saveSettings() {
    // ในแอปจริง ควรบันทึกการตั้งค่าลงใน SharedPreferences หรือฐานข้อมูล
    // และอาจต้องลงทะเบียนหรือยกเลิกการลงทะเบียนกับ Firebase Cloud Messaging
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกการตั้งค่าการแจ้งเตือนเรียบร้อยแล้ว'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop();
  }
} 