import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../../config/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/celestial_effects.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/utils/app_icons.dart';
import '../../../core/widgets/sacred_showcase.dart';
import '../models/merit_models.dart';
import '../widgets/merit_ui.dart';
import 'merit_weekly_order_screen.dart';

/// หน้าแสดงตารางการไปมูประจำสัปดาห์ — "ทำบุญออนไลน์" hero screen.
///
/// This is the app's core feature surface, so it gets the full elevated
/// "Soft Celestial" treatment (celestial backdrop + layered glows + grain +
/// staggered reveals + press micro-interactions) with a warm gold/peach merit
/// accent. All schedule data, selection logic and order-flow navigation are
/// preserved exactly from the original screen.
class WeeklyScheduleScreen extends StatefulWidget {
  const WeeklyScheduleScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  final List<WeeklyMeritSchedule> _schedules =
      WeeklyMeritSchedule.defaultSchedule;
  MeritDay? _selectedDay;

  // Showcase จุดเดียว (contextual) ชี้แถบเลือกวันไหว้ — โชว์ครั้งแรก
  // ที่เข้าหน้านี้เท่านั้น ช่วยให้ผู้ใช้ใหม่รู้ว่าแต่ละวันเลือกดูได้
  late final ShowcaseView _showcaseView;
  final GlobalKey _scWeekSelector = GlobalKey();

  // Showcase ขั้นที่สอง: หลังผู้ใช้ "กดเลือกวัน" เองครั้งแรก ชี้ปุ่ม
  // ฝากมู · ร่วมบุญ ให้รู้ขั้นตอนถัดไป (ไม่ยิงตอนวันถูกเลือกอัตโนมัติ)
  final GlobalKey _scOrderButton = GlobalKey();

  // ยังมีสิทธิ์ "มูฟรีครั้งแรก" อยู่ไหม — ใช้สลับข้อความ pill ราคา
  bool _freeTrialEligible = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.log('merit_landing_view');
    _selectedDay = _defaultSelectedDay();
    _loadFreeTrialEligibility();

    _showcaseView = ShowcaseView.register(
      scope: SacredShowcase.meritScope,
      enableAutoScroll: true,
      // ปุ่มเท่านั้นที่เลื่อน tour ได้ — barrier tap ไม่ข้าม step
      disableBarrierInteraction: true,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartShowcase());
  }

  /// เช็คสิทธิ์มูฟรีครั้งแรก — ผิดพลาดถือว่าไม่มีสิทธิ์ (แสดงราคาปกติ)
  Future<void> _loadFreeTrialEligibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final used = prefs.getBool(StorageConstants.freeMeritUsed) ?? false;
      if (mounted && !used) setState(() => _freeTrialEligible = true);
    } catch (e) {
      debugPrint('WeeklyScheduleScreen._loadFreeTrialEligibility error: $e');
    }
  }

  /// โชว์ครั้งเดียวต่อเครื่อง — บันทึก "เห็นแล้ว" ตั้งแต่ตอนเริ่ม
  /// (แนวเดียวกับ tour หน้า Home) และหน่วงให้ StaggeredReveal เล่นจบก่อน
  Future<void> _maybeStartShowcase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(StorageConstants.meritShowcaseSeen) ?? false) return;
      await prefs.setBool(StorageConstants.meritShowcaseSeen, true);
      if (!mounted) return;
      _showcaseView.startShowCase(
        [_scWeekSelector],
        delay: const Duration(milliseconds: 900),
      );
    } catch (e) {
      debugPrint('WeeklyScheduleScreen._maybeStartShowcase error: $e');
    }
  }

  /// เด้งครั้งเดียว "หลังผู้ใช้กดเลือกวันเอง" — ชี้ปุ่มฝากมูเพื่อบอก
  /// ขั้นตอนถัดไป จะเริ่มเฉพาะเมื่อวันที่เลือกมีรอบมู (มีปุ่มให้ชี้จริง)
  /// และยังไม่ consume flag ถ้าผู้ใช้กดวันว่าง — รอวันที่มีรอบครั้งถัดไป
  Future<void> _maybeShowDayPickedShowcase() async {
    if (_selectedSchedule == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(StorageConstants.meritDayShowcaseSeen) ?? false) {
        return;
      }
      await prefs.setBool(StorageConstants.meritDayShowcaseSeen, true);
      if (!mounted) return;
      // รอเฟรมให้ detail ของวันที่เลือก build เสร็จก่อนค่อยชี้ปุ่ม
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showcaseView.startShowCase(
          [_scOrderButton],
          delay: const Duration(milliseconds: 350),
        );
      });
    } catch (e) {
      debugPrint('WeeklyScheduleScreen._maybeShowDayPickedShowcase error: $e');
    }
  }

  @override
  void dispose() {
    _showcaseView.unregister();
    super.dispose();
  }

  /// ค่าเริ่มต้นของวันที่เลือก: วันนี้ถ้ามีรอบมู มิเช่นนั้นเลือกวันที่มีรอบมู
  /// ที่ใกล้ที่สุดถัดไป — กันไม่ให้ผู้ใช้เปิดมาเจอ empty state ทั้งที่สัปดาห์นี้
  /// ยังมีรอบอื่นให้ร่วมบุญอยู่
  MeritDay _defaultSelectedDay() {
    final today = MeritDayX.fromWeekday(DateTime.now().weekday);
    if (_schedules.any((s) => s.day == today)) {
      return today;
    }
    // หาวันที่มีรอบมูซึ่ง "รอบถัดไป" ใกล้วันนี้ที่สุด
    WeeklyMeritSchedule? nearest;
    DateTime? nearestDate;
    for (final schedule in _schedules) {
      final date = schedule.day.nextOccurrenceDate();
      if (nearestDate == null || date.isBefore(nearestDate)) {
        nearest = schedule;
        nearestDate = date;
      }
    }
    return nearest?.day ?? today;
  }

  WeeklyMeritSchedule? get _selectedSchedule {
    if (_selectedDay == null) return null;
    try {
      return _schedules.firstWhere((s) => s.day == _selectedDay);
    } catch (_) {
      return null;
    }
  }

  // ── Typography helpers (match the home / welcome hero screens) ──────────────

  /// Display serif (Fraunces) for English overlines / numerals — the editorial
  /// counterpoint to the Thai Kanit headings.
  TextStyle _displayStyle({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0.2,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      color: color ?? AppColors.deepText,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: 1.0,
    );
  }

  /// Small uppercase letter-spaced English overline above Thai section titles.
  ///
  /// These overlines sit directly on the dark celestial backdrop, so they use a
  /// light muted-lilac tone for legibility.
  Widget _overline(String text, {Color? color, double size = 11.5}) {
    return Text(
      text.toUpperCase(),
      style: _displayStyle(
        fontSize: size,
        color: color ?? AppColors.onBackdropMuted,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.6,
      ),
    );
  }

  /// Section header drawn directly on the dark backdrop: light ivory title with
  /// a candle-gold leading icon and muted-lilac overline.
  Widget _sectionTitle(String title, {String? overline, String? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null) ...[
          _overline(overline),
          const SizedBox(height: 6),
        ],
        Row(
          children: [
            SvgIcon(
              icon ?? AppIcons.sparkle,
              size: 18,
              color: MeritColors.accent,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.kanit(
                  color: AppColors.onBackdrop,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedSchedule;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateBackSafely();
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: celestialBackdrop),
          child: Stack(
            children: [
              // Layered ambient glows — gold / peach / lavender mesh atmosphere.
              const Positioned(
                top: -120,
                right: -90,
                child: CelestialGlow(
                  size: 320,
                  color: MeritColors.accent,
                  intensity: 0.42,
                ),
              ),
              Positioned(
                top: 180,
                left: -110,
                child: CelestialGlow(
                  size: 300,
                  color: AppColors.secondary.withValues(alpha: 1),
                  intensity: 0.30,
                ),
              ),
              const Positioned(
                bottom: -60,
                right: -60,
                child: CelestialGlow(
                  size: 280,
                  color: AppColors.primary,
                  intensity: 0.18,
                ),
              ),
              const Positioned.fill(child: GrainOverlay()),

              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const StaggeredReveal(
                                index: 0, child: _HeroValueCard()),
                            const SizedBox(height: 26),
                            StaggeredReveal(
                              index: 1,
                              child: _sectionTitle(
                                'ตารางฝากมูประจำสัปดาห์',
                                overline: 'Weekly schedule',
                                icon: AppIcons.calendar,
                              ),
                            ),
                            const SizedBox(height: 14),
                            StaggeredReveal(
                              index: 2,
                              child: SacredShowcase.wrap(
                                showcaseKey: _scWeekSelector,
                                scope: SacredShowcase.meritScope,
                                title: 'เลือกวันไหว้ของคุณ',
                                description:
                                    'แต่ละวันมีพิธีและความเชื่อต่างกัน '
                                    'แตะวันที่ต้องการเพื่อดูรายละเอียด '
                                    'แล้วกดร่วมบุญได้เลย',
                                targetBorderRadius: BorderRadius.circular(22),
                                actions:
                                    SacredShowcase.finishAction('เข้าใจแล้ว'),
                                child: _buildWeekSelector(),
                              ),
                            ),
                            const SizedBox(height: 22),
                            if (selected != null)
                              StaggeredReveal(
                                index: 3,
                                child: _buildScheduleDetail(selected),
                              )
                            else
                              StaggeredReveal(
                                  index: 3, child: _buildNoSchedule()),
                            const SizedBox(height: 34),
                            // ── ผลบุญ / proof-of-merit trust section ──
                            const StaggeredReveal(
                              index: 4,
                              child: _ProofOfMeritSection(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The merit entry can be opened from both a pushed Home card and the raised
  /// bottom tab. In the tab case the route may be the root route, so a raw
  /// `Navigator.pop` leaves Android on a blank/exiting state that feels like a
  /// freeze. Prefer popping when there is a previous route; otherwise return to
  /// Home explicitly.
  void _navigateBackSafely() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.home);
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _navigateBackSafely,
            icon: const SvgIcon(AppIcons.arrowBack,
                size: 20, color: AppColors.onBackdrop),
            tooltip: 'ย้อนกลับ',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _overline('Merit · ทำบุญออนไลน์', size: 12),
                const SizedBox(height: 2),
                Text(
                  'ฝากดวงใจไหว้ให้',
                  style: GoogleFonts.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: MeritColors.accentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: MeritColors.accent.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child:
                const SvgIcon(AppIcons.temple, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── Week selector ───────────────────────────────────────────────────────────

  Widget _buildWeekSelector() {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: MeritDay.values.length,
        itemBuilder: (context, index) {
          final day = MeritDay.values[index];
          final hasSchedule = _schedules.any((s) => s.day == day);
          final isSelected = _selectedDay == day;
          final isToday = DateTime.now().weekday == day.weekdayNumber;

          // วันที่ของ "รอบถัดไป" ของชิปนี้ — วันนี้ถ้าตรงกัน (ยังทันอยู่)
          // มิเช่นนั้นวันที่ตรงกันถัดไปในอีก 1-6 วันข้างหน้า (ไม่ใช่แค่สัปดาห์
          // ปฏิทินนี้ ซึ่งอาจเป็นวันที่ผ่านไปแล้ว)
          final date = day.nextOccurrenceDate();

          return _PressScale(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              AnalyticsService.instance
                  .log('merit_day_selected', {'has_schedule': hasSchedule});
              setState(() {
                _selectedDay = day;
              });
              _maybeShowDayPickedShowcase();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 62,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.ricePaper
                    : MeritColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? MeritColors.accent.withValues(alpha: 0.8)
                      : (isToday
                          ? MeritColors.accent.withValues(alpha: 0.6)
                          : AppColors.divider),
                  width: isSelected ? 1.2 : (isToday ? 1.6 : 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? MeritColors.accent.withValues(alpha: 0.18)
                        : AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: isSelected ? 16 : 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.shortName,
                    style: GoogleFonts.kanit(
                      color: isSelected
                          ? MeritColors.accentDark
                          : AppColors.mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: _displayStyle(
                      fontSize: 20,
                      color:
                          isSelected ? AppColors.deepText : AppColors.deepText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (hasSchedule)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: MeritColors.accentDark,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 7),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoSchedule() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(
            AppIcons.calendar,
            size: 64,
            color: AppColors.mutedText.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedDay != null
                ? 'ไม่มีรอบมูใน${_selectedDay!.displayName}'
                : 'ไม่มีรอบมูในวันนี้',
            style: GoogleFonts.kanit(
              color: AppColors.deepText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'กรุณาเลือกวันที่มีจุดสีทอง',
            style: GoogleFonts.kanit(
              color: AppColors.mutedText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Schedule detail ─────────────────────────────────────────────────────────

  Widget _buildScheduleDetail(WeeklyMeritSchedule schedule) {
    // หาวันที่ของรอบถัดไป — ใช้ helper เดียวกับชิปวันที่ (single source of truth)
    final now = DateTime.now();
    final nextDate = schedule.day.nextOccurrenceDate();
    final dateStr = DateFormat('d MMMM yyyy', 'th_TH').format(nextDate);
    final isToday = schedule.day.weekdayNumber == now.weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero temple card — warm rice-paper card with gold accents only. The
        // earlier full gold slab felt too heavy next to the Home source-of-truth.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.ricePaper,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
                color: MeritColors.accent.withValues(alpha: 0.45), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.templeIndigo.withValues(alpha: 0.16),
                blurRadius: 18,
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
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: MeritColors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: MeritColors.accent.withValues(alpha: 0.32)),
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
                        Row(
                          children: [
                            Text(
                              schedule.day.displayName,
                              style: GoogleFonts.kanit(
                                color:
                                    AppColors.deepText.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: MeritColors.accent
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'วันนี้',
                                  style: GoogleFonts.kanit(
                                    color: MeritColors.accentDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          schedule.locationName,
                          style: GoogleFonts.kanit(
                            color: AppColors.deepText,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.ivorySilk,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: MeritColors.accent.withValues(alpha: 0.22)),
                ),
                child: Row(
                  children: [
                    const SvgIcon(AppIcons.sparkle,
                        size: 16, color: AppColors.deepText),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.belief,
                        style: GoogleFonts.kanit(
                          color: AppColors.deepText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  SvgIcon(
                    AppIcons.clock,
                    size: 15,
                    color: AppColors.deepText.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'รอบถัดไป: $dateStr',
                      style: GoogleFonts.kanit(
                        color: AppColors.deepText.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStartingPricePill(schedule),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ชุดไหว้พื้นฐาน
        _sectionTitle('ชุดไหว้พื้นฐาน (รวมในราคา)', icon: AppIcons.checkCircle),
        const SizedBox(height: 12),
        _buildRequiredItemsCard(schedule.requiredItems),
        // (ปุ่มฝากมูด้านล่างถูกห่อด้วย showcase "ขั้นตอนถัดไป" —
        // เด้งครั้งแรกที่ผู้ใช้กดเลือกวันเอง ดู _maybeShowDayPickedShowcase)

        const SizedBox(height: 28),

        // ปุ่มสั่งจอง
        SacredShowcase.wrap(
          showcaseKey: _scOrderButton,
          scope: SacredShowcase.meritScope,
          title: 'ขั้นตอนถัดไป',
          description: 'เลือกวันไหว้ได้แล้ว กดปุ่มนี้เพื่อเลือกชุดร่วมบุญ '
              'และกรอกคำอธิษฐาน แล้วเราจะไหว้แทนคุณ '
              'พร้อมส่งรูปยืนยันถึงมือ',
          targetBorderRadius: BorderRadius.circular(18),
          actions: SacredShowcase.finishAction('เข้าใจแล้ว'),
          child: _buildOrderButton(schedule, nextDate),
        ),
      ],
    );
  }

  Widget _buildRequiredItemsCard(List<MeritOfferingItem> items) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MeritColors.accent.withValues(alpha: 0.18),
                  AppColors.secondary.withValues(alpha: 0.14),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: MeritColors.accent.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SvgIcon(
                  AppIcons.checkCircle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  item.name,
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// "เริ่มต้น ฿xxx" gold pill — แสดงราคาต่ำสุดของแพ็คที่เลือกได้ในฟอร์ม
  /// สั่งจอง คำนวณจากชุดข้อมูลเดียวกับหน้าฟอร์ม ([WeeklyOrderPackage]) ไม่
  /// hardcode ซ้ำ ให้ราคาบนหน้า landing กับหน้าฟอร์มตรงกันเสมอ
  Widget _buildStartingPricePill(WeeklyMeritSchedule schedule) {
    final price = schedule.cheapestPackagePrice;
    // ยังมีสิทธิ์มูฟรีครั้งแรก → ชูข้อเสนอฟรีแทนราคาเริ่มต้น (hook เข้า
    // funnel ตั้งแต่หน้า landing; การ์ดแพ็คฟรีจริงอยู่ในหน้าฟอร์ม)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: MeritColors.accentGradient,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _freeTrialEligible
            ? '🎁 ครั้งแรก มูฟรี'
            : 'เริ่มต้น ฿${price.toStringAsFixed(0)}',
        style: GoogleFonts.kanit(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildOrderButton(WeeklyMeritSchedule schedule, DateTime date) {
    return _PressScale(
      borderRadius: BorderRadius.circular(18),
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
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: MeritColors.accentGradient,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: MeritColors.accent.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SvgIcon(AppIcons.temple, size: 20, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'ฝากมู · ร่วมบุญ',
              style: GoogleFonts.kanit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero value card ───────────────────────────────────────────────────────────

/// The warm rice-paper value-proposition card that opens the merit screen.
class _HeroValueCard extends StatelessWidget {
  const _HeroValueCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.ricePaper,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: MeritColors.accent.withValues(alpha: 0.45), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.templeIndigo.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Medallion with pray/temple icon.
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Center(
              child:
                  SvgIcon(AppIcons.temple, size: 30, color: AppColors.deepText),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ฝากเราไหว้ให้',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ทุกที่ศักดิ์สิทธิ์ทั่วไทย พร้อมส่งรูป/วิดีโอยืนยันให้คุณทุกออเดอร์ 🙏',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText.withValues(alpha: 0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── ผลบุญ / Proof-of-merit section ───────────────────────────────────────────

/// Static, presentational "ผลบุญที่ส่งมอบแล้ว" trust section.
///
/// This builds social proof + retention: a horizontal scroller of recent merit
/// deliveries plus a trust strip. The data here is SAMPLE/placeholder content
/// for the UI only.
///
/// TODO(backend): replace [_ProofSample.samples] with real proofs fetched from
/// the backend (e.g. `GET /merit/proofs`) — each item should carry a temple
/// name, completed date, caption and an image/video proof URL coming from
/// completed [MeritOrder]s (see MeritOrder.proofUrls / proofVideoUrl). Do NOT
/// hardcode these once the endpoint exists.
class _ProofOfMeritSection extends StatelessWidget {
  const _ProofOfMeritSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROOF OF MERIT',
              style: GoogleFonts.fraunces(
                fontSize: 11.5,
                color: AppColors.onBackdropMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.6,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SvgIcon(AppIcons.heart,
                    size: 18, color: MeritColors.accent),
                const SizedBox(width: 8),
                Text(
                  'ผลบุญที่ส่งมอบแล้ว',
                  style: GoogleFonts.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Horizontal scroller of proof cards.
        SizedBox(
          height: 232,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: _ProofSample.samples.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return _ProofCard(sample: _ProofSample.samples[index]);
            },
          ),
        ),

        const SizedBox(height: 18),

        // Trust strip — shared faith-service signals (ดูหลักฐาน / ปลายทางชัดเจน /
        // ใบอนุโมทนา) for consistency across the whole merit flow.
        const MeritTrustStrip(),

        const SizedBox(height: 28),

        // ── บุญของคุณไปถึงไหน — honest transparency / fee-split centrepiece. ──
        const MeritSectionTitle(
          'ความโปร่งใส',
          overline: 'Transparency',
          icon: AppIcons.info,
        ),
        const SizedBox(height: 14),
        const MeritTransparencyBlock(),
      ],
    );
  }
}

/// Sample proof data (placeholder, UI only).
class _ProofSample {
  final String temple;
  final String date;
  final String caption;
  final List<Color> gradient;

  const _ProofSample({
    required this.temple,
    required this.date,
    required this.caption,
    required this.gradient,
  });

  static const List<_ProofSample> samples = [
    _ProofSample(
      temple: 'ท้าวมหาพรหม เอราวัณ',
      date: '5 มิ.ย. 2569',
      caption: 'ไหว้ขอพรเรียบร้อย 🙏 พร้อมส่งรูปให้คุณ',
      gradient: [Color(0xFFF2C879), Color(0xFFFFB0A0)],
    ),
    _ProofSample(
      temple: 'วัดเล่งเน่ยยี่',
      date: '3 มิ.ย. 2569',
      caption: 'ถวายของไหว้ครบชุด พร้อมวิดีโอยืนยัน 🎥',
      gradient: [Color(0xFFBFA06B), Color(0xFF8C86A8)], // bronze → plum-grey
    ),
    _ProofSample(
      temple: 'พระพิฆเนศ ห้วยขวาง',
      date: '1 มิ.ย. 2569',
      caption: 'จุดธูปบูชาเสร็จสิ้น ขอให้สมหวังนะคะ ✨',
      gradient: [Color(0xFFFFD7C2), Color(0xFFF2C879)], // peach-sand → gilt
    ),
    _ProofSample(
      temple: 'ท้าวเวสสุวรรณ สำเพ็ง',
      date: '29 พ.ค. 2569',
      caption: 'ปิดทอง ถวายพวงมาลัยเรียบร้อย 🌺',
      gradient: [
        Color(0xFF8FA98F),
        Color(0xFF8C86A8)
      ], // bodhi-green → plum-grey
    ),
  ];
}

class _ProofCard extends StatelessWidget {
  final _ProofSample sample;

  const _ProofCard({required this.sample});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder image area — gradient + temple icon medallion.
          // TODO(backend): render the real proof image/video thumbnail here.
          Container(
            height: 116,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: sample.gradient,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    child: const SvgIcon(
                      AppIcons.temple,
                      size: 30,
                      color: AppColors.deepText,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SvgIcon(
                          AppIcons.checkCircle,
                          size: 13,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'สำเร็จ',
                          style: GoogleFonts.kanit(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sample.temple,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const SvgIcon(
                      AppIcons.calendar,
                      size: 12,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      sample.date,
                      style: GoogleFonts.kanit(
                        color: AppColors.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  sample.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText.withValues(alpha: 0.78),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Press-scale micro-interaction (matches home screen) ──────────────────────

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _PressScale({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (mounted && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
