import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/sacred_ui.dart';

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
    return SacredScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SacredHeader(
              title: 'การแจ้งเตือน',
              overline: 'NOTIFICATIONS',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                      'ข่าวสารและสิ่งดีๆ',
                      'รับการแจ้งเตือนข่าวสารและสิ่งดีๆ ที่คัดสรรมาเพื่อคุณ',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SacredSectionTitle(title);
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SacredCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SacredText.kanit(
                      color: AppColors.deepText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: SacredText.kanit(
                      color: AppColors.mutedText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.candleGold,
              activeTrackColor: AppColors.candleGold.withValues(alpha: 0.35),
              inactiveThumbColor: AppColors.mutedText.withValues(alpha: 0.6),
              inactiveTrackColor: AppColors.mutedText.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SacredCard(
        radius: 16,
        highlight: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เวลาที่ต้องการรับการแจ้งเตือน',
                    style: SacredText.kanit(
                      color: AppColors.deepText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ดวงประจำวันจะถูกส่งในเวลานี้',
                    style: SacredText.kanit(
                      color: AppColors.mutedText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.candleGold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatTimeOfDay(_dailyHoroscopeTime),
                  style: SacredText.kanit(
                    color: AppColors.deepGoldBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
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
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepGoldBrown,
              onPrimary: Colors.white,
              surface: AppColors.lightSurface,
              onSurface: AppColors.deepText,
            ),
            dialogTheme:
                const DialogThemeData(backgroundColor: AppColors.lightSurface),
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
    return SacredPrimaryButton(
      label: 'บันทึกการตั้งค่า',
      onTap: _saveSettings,
      filled: true,
    );
  }

  void _saveSettings() {
    // ในแอปจริง ควรบันทึกการตั้งค่าลงใน SharedPreferences หรือฐานข้อมูล
    // และอาจต้องลงทะเบียนหรือยกเลิกการลงทะเบียนกับ Firebase Cloud Messaging

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('บันทึกการตั้งค่าการแจ้งเตือนเรียบร้อยแล้ว'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).pop();
  }
}
