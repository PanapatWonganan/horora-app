import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/utils/app_icons.dart';
import '../models/merit_models.dart';
import 'merit_weekly_order_screen.dart';

/// หน้าแสดงตารางการไปมูประจำสัปดาห์
class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  final List<WeeklyMeritSchedule> _schedules = WeeklyMeritSchedule.defaultSchedule;
  MeritDay? _selectedDay;

  @override
  void initState() {
    super.initState();
    // เลือกวันปัจจุบันเป็นค่าเริ่มต้น
    final today = DateTime.now().weekday;
    _selectedDay = MeritDayX.fromWeekday(today);
  }

  WeeklyMeritSchedule? get _selectedSchedule {
    if (_selectedDay == null) return null;
    try {
      return _schedules.firstWhere((s) => s.day == _selectedDay);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBackground,
              AppColors.cream,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildWeekSelector(),
              Expanded(
                child: _selectedSchedule != null
                    ? _buildScheduleDetail(_selectedSchedule!)
                    : _buildNoSchedule(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const SvgIcon(AppIcons.arrowBack, size: 20, color: AppColors.deepText),
          ),
          const Expanded(
            child: Text(
              'ตารางฝากมูประจำสัปดาห์',
              style: TextStyle(
                color: AppColors.deepText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: MeritDay.values.length,
        itemBuilder: (context, index) {
          final day = MeritDay.values[index];
          final hasSchedule = _schedules.any((s) => s.day == day);
          final isSelected = _selectedDay == day;
          final isToday = DateTime.now().weekday == day.weekdayNumber;

          // หาวันที่ของสัปดาห์นี้
          final now = DateTime.now();
          final diff = day.weekdayNumber - now.weekday;
          final date = now.add(Duration(days: diff));

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
              });
            },
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: MeritColors.accentGradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected ? null : MeritColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isToday
                            ? AppColors.primary
                            : AppColors.divider,
                        width: isToday ? 2 : 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.shortName,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.deepText
                          : AppColors.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.deepText
                          : AppColors.deepText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasSchedule)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.deepText
                            : MeritColors.accentDark,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoSchedule() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(
            AppIcons.calendar,
            size: 80,
            color: AppColors.mutedText.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่มีรอบมูในวัน${_selectedDay?.displayName ?? "นี้"}',
            style: const TextStyle(
              color: AppColors.deepText,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'กรุณาเลือกวันที่มีจุดสีทอง',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleDetail(WeeklyMeritSchedule schedule) {
    // หาวันที่ของรอบถัดไป
    final now = DateTime.now();
    final diff = schedule.day.weekdayNumber - now.weekday;
    final nextDate = diff >= 0
        ? now.add(Duration(days: diff))
        : now.add(Duration(days: 7 + diff));
    final dateStr = DateFormat('d MMMM yyyy', 'th_TH').format(nextDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: MeritColors.accentGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: MeritColors.accent.withValues(alpha: 0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const SvgIcon(
                        AppIcons.temple,
                        size: 28,
                        color: AppColors.deepText,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.day.displayName,
                            style: TextStyle(
                              color: AppColors.deepText.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            schedule.locationName,
                            style: const TextStyle(
                              color: AppColors.deepText,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const SvgIcon(AppIcons.sparkle, size: 16, color: AppColors.deepText),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule.belief,
                          style: const TextStyle(
                            color: AppColors.deepText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'รอบถัดไป: $dateStr',
                  style: TextStyle(
                    color: AppColors.deepText.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ชุดไหว้พื้นฐาน
          _buildSectionTitle('ชุดไหว้พื้นฐาน (รวมในราคา)'),
          const SizedBox(height: 12),
          _buildRequiredItemsCard(schedule.requiredItems),

          const SizedBox(height: 24),

          // Add-ons
          if (schedule.addons.isNotEmpty) ...[
            _buildSectionTitle('ของไหว้เพิ่มเติม (Add-ons)'),
            const SizedBox(height: 12),
            ...schedule.addons.map((addon) => _buildAddonCard(addon)),
          ],

          const SizedBox(height: 32),

          // ปุ่มสั่งจอง
          _buildOrderButton(schedule, nextDate),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.deepText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRequiredItemsCard(List<MeritOfferingItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: MeritColors.accentDark,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      color: AppColors.deepText,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SvgIcon(
                  AppIcons.checkCircle,
                  size: 20,
                  color: AppColors.success,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getAddonEmoji(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('กระดาษ') || lower.contains('ไหว้เจ้า')) return '📜';
    if (lower.contains('ส้ม') || lower.contains('ผลไม้')) return '🍊';
    if (lower.contains('ธูป') || lower.contains('หอม')) return '🪔';
    if (lower.contains('เทียน')) return '🕯️';
    if (lower.contains('ดอกไม้') || lower.contains('มาลัย') || lower.contains('พวง')) return '💐';
    if (lower.contains('น้ำ')) return '💧';
    if (lower.contains('ข้าว')) return '🍚';
    if (lower.contains('ขนม')) return '🍡';
    return '🙏';
  }

  Widget _buildAddonCard(MeritAddon addon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MeritColors.accent.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MeritColors.accent.withValues(alpha: 0.25),
                  AppColors.secondary.withValues(alpha: 0.25),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MeritColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Center(
              child: Text(
                _getAddonEmoji(addon.name),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addon.name,
                  style: const TextStyle(
                    color: AppColors.deepText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (addon.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    addon.description!,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: MeritColors.accent.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${addon.priceFormatted}',
              style: const TextStyle(
                color: MeritColors.accentDark,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton(WeeklyMeritSchedule schedule, DateTime date) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeritWeeklyOrderScreen(
              schedule: schedule,
              selectedDate: date,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: MeritColors.accentGradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MeritColors.accent.withValues(alpha: 0.45),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgIcon(AppIcons.heart, size: 20, color: AppColors.deepText),
            SizedBox(width: 8),
            Text(
              'สั่งจองฝากมู',
              style: TextStyle(
                color: AppColors.deepText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
