import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/guest_session_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/celestial_effects.dart';
import '../../../core/theme/sacred_ui.dart';
import '../models/faith_models.dart';
import '../services/faith_points_service.dart';

/// หน้า "เส้นทางสายมู" — ขีดเลเวล + สถานีรางวัลของระบบ retention
///
/// เข้าจาก chip พลังศรัทธาบน Home header เท่านั้น (เป็น value ไม่ใช่ ask —
/// ไม่เพิ่ม primary ask ใหม่บนหน้า Home ตามกฎ monetization)
class FaithJourneyScreen extends StatefulWidget {
  const FaithJourneyScreen({super.key});

  @override
  State<FaithJourneyScreen> createState() => _FaithJourneyScreenState();
}

class _FaithJourneyScreenState extends State<FaithJourneyScreen> {
  FaithState? _state;
  DateTime? _birthDate;
  bool _isHolyDay = false; // วันนี้เป็นวันพระ (แต้มคูณ 2)

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.log('faith_journey_view');
    _load();
  }

  Future<void> _load() async {
    final state = await FaithPointsService.instance.loadState();
    // วันเกิดใช้สร้างเลขนำโชค/บทสวด — ลำดับเดียวกับ merit prefill:
    // บัญชีจริงก่อน แล้วค่อย guest onboarding
    DateTime? birth = AuthService.instance.currentUser?.birthDate;
    if (birth == null) {
      try {
        birth = (await GuestSessionService.instance.loadOnboarding())
            ?.birthDate;
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _state = state;
        _birthDate = birth;
        _isHolyDay = faithIsHolyDay(DateTime.now());
      });
    }
  }

  // ── Claim actions ──────────────────────────────────────────────────────────

  Future<void> _claim(FaithMilestone m) async {
    switch (m.reward) {
      case FaithRewardType.wallpaperTeaser:
        await _showRewardDialog(
          emoji: '🖼️',
          title: 'วอลเปเปอร์มงคล 1 ภาพ',
          body: 'ภาพตัวอย่างจากคอลเลคชั่นมงคล มูลค่า ฿199\n'
              'กดปุ่มด้านล่างเพื่อรับภาพผ่าน LINE ได้เลยค่ะ',
          actionLabel: 'รับภาพใน LINE',
          onAction: () => _openLineOA('wallpaper'),
        );
        break;
      case FaithRewardType.luckyNumbers:
        final numbers =
            faithLuckyNumbers(birthDate: _birthDate, now: DateTime.now());
        final mantra = faithMantraForWeekday(_birthDate?.weekday);
        await _showRewardDialog(
          emoji: '🔢',
          title: 'เลขนำโชคประจำสัปดาห์',
          body: 'เลขมงคลของคุณ: ${numbers.join(', ')}\n\n'
              'บทสวดเสริมดวงตามวันเกิด\n$mantra',
        );
        break;
      case FaithRewardType.meritCoupon:
        // ขอโค้ดรายคนจาก server (FAITH-XXXX ผูกเครื่อง กันแชร์ต่อ)
        final coupon = await FaithPointsService.instance.requestCoupon();
        AnalyticsService.instance
            .log('coupon_issued', {'ok': coupon.isSuccess ? 1 : 0});
        if (!mounted) return;
        if (!coupon.isSuccess) {
          // ออกโค้ดไม่สำเร็จ — ไม่มาร์ค claimed เพื่อให้กดรับใหม่ได้
          // (return ก่อนถึง markMilestoneClaimed ท้ายเมธอด)
          await _showRewardDialog(
            emoji: '🎟️',
            title: 'ส่วนลดฝากมู ฿30',
            body: 'ระบบกำลังออกโค้ดส่วนลดให้คุณ '
                'กรุณาเช็คสัญญาณเน็ตแล้วกด "รับรางวัล" อีกครั้งนะคะ',
          );
          return;
        }
        await _showRewardDialog(
          emoji: '🎟️',
          title: 'ส่วนลดฝากมู ฿30',
          body: 'โค้ด: ${coupon.code} (ใช้ได้ภายใน '
              '$kFaithMeritCouponDays วัน)\n'
              'แจ้งโค้ดนี้กับทีมงานใน LINE ตอนยืนยันยอดฝากมู '
              'เพื่อรับส่วนลดทันที',
          actionLabel: 'คัดลอกโค้ด',
          closeOnAction: false,
          onAction: () async {
            await Clipboard.setData(ClipboardData(text: coupon.code!));
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('คัดลอกโค้ดแล้ว')),
              );
            }
          },
        );
        break;
      case FaithRewardType.level2Box:
        await _showRewardDialog(
          emoji: '👑',
          title: 'คอลเลคชั่นวอลเปเปอร์มงคล',
          body: 'ยินดีด้วยค่ะ คุณถึง Level 2 · ${faithLevelName(2)} แล้ว!\n\n'
              'รับคอลเลคชั่นวอลเปเปอร์มงคลเต็มชุด มูลค่า ฿199 '
              'สำหรับสมาชิก Premium — แจ้งรับใน LINE ได้เลย '
              'หรือเริ่มทดลอง Premium ฟรี 7 วันก่อนก็ได้ค่ะ',
          actionLabel: 'รับสิทธิ์ใน LINE',
          onAction: () => _openLineOA('level2_box'),
        );
        break;
    }
    await FaithPointsService.instance.markMilestoneClaimed(m.id);
    // รับรางวัลสถานีสำเร็จ (บันทึกสถานะ claimed แล้ว)
    AnalyticsService.instance.log('milestone_claimed', {'id': m.id});
    await _load();
  }

  /// [source] ระบุบริบทที่กดเปิด LINE (เช่น 'wallpaper'/'level2_box')
  /// เพื่อแยกที่มาใน funnel event `line_link_tap`
  Future<void> _openLineOA(String source) async {
    AnalyticsService.instance.log('line_link_tap', {'source': source});
    try {
      final url = Uri.parse(LineOAConstants.mainOA);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('FaithJourneyScreen._openLineOA failed: $e');
    }
  }

  Future<void> _showRewardDialog({
    required String emoji,
    required String title,
    required String body,
    String? actionLabel,
    Future<void> Function()? onAction,
    bool closeOnAction = true,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.ivorySilk,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('$emoji  $title'),
        content: Text(
          body,
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontSize: 14.5,
            height: 1.5,
          ),
        ),
        actions: [
          if (actionLabel != null)
            TextButton(
              onPressed: () async {
                if (closeOnAction && dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                await onAction?.call();
              },
              child: Text(
                actionLabel,
                style: GoogleFonts.kanit(
                  color: AppColors.deepGoldBrown,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'ปิด',
              style: GoogleFonts.kanit(
                  color: AppColors.deepText.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: celestialBackdrop),
        child: Stack(
          children: [
            const Positioned(
              top: -120,
              right: -90,
              child: CelestialGlow(
                  size: 300, color: AppColors.candleGold, intensity: 0.25),
            ),
            const Positioned(
              bottom: -80,
              left: -80,
              child: CelestialGlow(
                  size: 280, color: AppColors.primary, intensity: 0.18),
            ),
            const Positioned.fill(child: GrainOverlay()),
            SafeArea(
              child: state == null
                  ? const Center(child: SacredLoader())
                  : Column(
                      children: [
                        _buildHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(20, 4, 20, 36),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StaggeredReveal(
                                    index: 0,
                                    child: _buildLevelCard(state)),
                                if (_isHolyDay) ...[
                                  const SizedBox(height: 12),
                                  StaggeredReveal(
                                      index: 1,
                                      child: _buildHolyDayChip()),
                                ],
                                const SizedBox(height: 16),
                                StaggeredReveal(
                                    index: 1, child: _buildEarnHints()),
                                const SizedBox(height: 26),
                                StaggeredReveal(
                                    index: 2,
                                    child: _buildMilestonePath(state)),
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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_ios_new,
                  color: AppColors.onBackdrop, size: 20),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MU JOURNEY',
                style: GoogleFonts.fraunces(
                  color: AppColors.onBackdropMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.6,
                ),
              ),
              Text(
                'เส้นทางสายมู',
                style: GoogleFonts.kanit(
                  color: AppColors.onBackdrop,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(FaithState state) {
    final toNext =
        (kFaithLevel2Points - state.points).clamp(0, kFaithLevel2Points);
    final progress =
        (state.points / kFaithLevel2Points).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ivorySilk,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.candleGold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.templeIndigo.withValues(alpha: 0.18),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    AppColors.candleGold,
                    AppColors.deepGoldBrown
                  ]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Level ${state.level} · ${state.levelName}',
                  style: GoogleFonts.kanit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '🔥 ${state.streak} วันติด',
                style: GoogleFonts.kanit(
                  color: AppColors.deepGoldBrown,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '✦ ${state.points}',
                style: GoogleFonts.fraunces(
                  color: AppColors.deepText,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'พลังศรัทธา',
                  style: GoogleFonts.kanit(
                      color: AppColors.mutedText, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.ricePaper,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.candleGold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.level >= 2
                ? 'ถึง Level 2 แล้ว — รางวัลใหญ่รอคุณอยู่ด้านล่าง'
                : 'อีก $toNext ✦ ถึง Level 2 · ${faithLevelName(2)}',
            style: GoogleFonts.kanit(
                color: AppColors.mutedText, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  /// Chip แจ้งว่าวันนี้เป็นวันพระ — ทุกกิจกรรมได้แต้มคูณ 2
  Widget _buildHolyDayChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.candleGold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.candleGold.withValues(alpha: 0.55)),
      ),
      child: Text(
        '🪷 วันนี้วันพระ — แต้มคูณ 2',
        style: GoogleFonts.kanit(
          color: AppColors.candleGold,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEarnHints() {
    Widget chip(String text) => Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.ivorySilk.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.candleGold.withValues(alpha: 0.35)),
          ),
          child: Text(
            text,
            style: GoogleFonts.kanit(
                color: AppColors.onBackdrop, fontSize: 12),
          ),
        );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip('☀️ เช็คดวงทุกวัน +$kFaithDailyCheckin'),
        chip('💬 ถาม AI +$kFaithActivityPoints'),
        chip('🃏 เปิดไพ่ +$kFaithActivityPoints'),
        chip('🏛️ ฝากมู +$kFaithMeritPoints'),
        chip('🔥 3 วันติด +$kFaithStreak3Bonus · 7 วันติด '
            '+$kFaithStreak7Bonus'),
      ],
    );
  }

  Widget _buildMilestonePath(FaithState state) {
    const items = FaithMilestone.defaults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'รางวัลระหว่างทาง',
          style: GoogleFonts.kanit(
            color: AppColors.onBackdrop,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < items.length; i++)
          _buildStation(
            state,
            items[i],
            isLast: i == items.length - 1,
          ),
      ],
    );
  }

  Widget _buildStation(FaithState state, FaithMilestone m,
      {required bool isLast}) {
    final status = faithMilestoneState(
      milestone: m,
      points: state.points,
      claimedIds: state.claimedMilestoneIds,
      hasMeritOrder: state.hasMeritOrder,
    );
    final isLocked = status == FaithMilestoneState.locked;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // เส้นทาง + วงสถานี
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLocked
                        ? AppColors.ivorySilk.withValues(alpha: 0.14)
                        : AppColors.ivorySilk,
                    border: Border.all(
                      color: status == FaithMilestoneState.claimed
                          ? AppColors.success
                          : AppColors.candleGold
                              .withValues(alpha: isLocked ? 0.35 : 0.9),
                      width: 1.4,
                    ),
                  ),
                  child: Center(
                    child: Text(m.emoji,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color:
                          AppColors.candleGold.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // การ์ดสถานี
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isLocked
                    ? AppColors.ivorySilk.withValues(alpha: 0.10)
                    : AppColors.ivorySilk,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color:
                      AppColors.candleGold.withValues(alpha: 0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.title,
                          style: GoogleFonts.kanit(
                            color: isLocked
                                ? AppColors.onBackdrop
                                : AppColors.deepText,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (m.premiumOnly)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.candleGold
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '👑 Premium',
                            style: GoogleFonts.kanit(
                              color: isLocked
                                  ? AppColors.onBackdrop
                                  : AppColors.deepGoldBrown,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.description,
                    style: GoogleFonts.kanit(
                      color: isLocked
                          ? AppColors.onBackdropMuted
                          : AppColors.mutedText,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  switch (status) {
                    FaithMilestoneState.locked => Text(
                        m.requiresMeritOrder && !state.hasMeritOrder
                            ? 'อีก ${m.points - state.points} ✦ '
                                '+ ฝากมู 1 ครั้ง ปลดล็อก'
                            : 'อีก ${m.points - state.points} ✦ ปลดล็อก '
                                '(${m.points} ✦)',
                        style: GoogleFonts.kanit(
                          color: AppColors.onBackdropMuted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    // แต้มถึงแล้วแต่ยังไม่เคยฝากมู — จุด upsell ของเส้นทาง:
                    // พาไปหน้าฝากมูตรงๆ (ออเดอร์แรกได้ +50 ✦ ด้วย)
                    FaithMilestoneState.lockedNeedsMerit => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'แต้มถึงแล้ว — ฝากมูอย่างน้อย 1 ครั้ง'
                            'เพื่อปลดล็อกรางวัลนี้',
                            style: GoogleFonts.kanit(
                              color: AppColors.deepGoldBrown,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: SacredPrimaryButton(
                              label: 'ไปฝากมู · ร่วมบุญ',
                              filled: true,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.merit),
                            ),
                          ),
                        ],
                      ),
                    FaithMilestoneState.claimable => SizedBox(
                        width: double.infinity,
                        child: SacredPrimaryButton(
                          label: 'รับรางวัล',
                          filled: true,
                          onTap: () => _claim(m),
                        ),
                      ),
                    FaithMilestoneState.claimed => Text(
                        '✓ รับแล้ว',
                        style: GoogleFonts.kanit(
                          color: AppColors.success,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
