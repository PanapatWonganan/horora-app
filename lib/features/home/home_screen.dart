import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/celestial_effects.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/guest_session_service.dart';
import '../../core/utils/app_icons.dart';
import '../merit/models/merit_models.dart';
import '../shared/widgets/app_bottom_navigation.dart';
import 'widgets/daily_horoscope_card.dart';
import 'widgets/in_app_message_dialog.dart';

// RouteObserver สำหรับตรวจจับการกลับมาที่หน้า home
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

// Static variable เก็บสถานะว่าเคยออกจาก home ไปหรือยัง
class HomeScreenState {
  static bool hasLeftHome = false;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _userName = ""; // จะถูกอัพเดทจาก user repository (ว่าง = โหมด guest)
  final DateTime _today = DateTime.now();
  final _authService = AuthService.instance;

  // Slow, continuous rotation for the celestial Lottie accent (the home
  // signature moment). Driven once — not rebuilt per frame in the tree.
  late final AnimationController _celestialRotation;

  // In-App promo content — kept as DATA only. We deliberately do NOT surface
  // this as an automatic startup popup anymore (it felt like a hard sell on a
  // spiritual companion). It now renders as a calm, dismissible in-page card
  // further down the Home feed (see [_buildGentleOffer]). The InAppMessage
  // model + dialog are retained for any future opt-in use.
  final InAppMessage _gentleOffer = const InAppMessage(
    imageUrl: 'assets/images/banners/special_offer.webp',
    title: 'ของมงคลเฉพาะคุณ',
    subtitle: 'ออกแบบจากวันเกิดและราศี เพื่อเป็นเครื่องเตือนใจในทุกวัน',
    buttonText: 'ดูรายละเอียด',
    buttonUrl: 'https://lin.ee/XIF2jaM', // LINE URL — unchanged.
  );

  // Whether the gentle in-page offer card is still shown (user can dismiss it).
  bool _showGentleOffer = true;

  @override
  void initState() {
    super.initState();
    _celestialRotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _loadUserName();

    // No automatic commercial popup on Home startup. A calm, dismissible offer
    // card lives in-page instead (see [_buildGentleOffer]).
  }

  @override
  void dispose() {
    _celestialRotation.dispose();
    // บันทึกว่าออกจากหน้า Home แล้ว
    HomeScreenState.hasLeftHome = true;
    super.dispose();
  }

  Future<void> _loadUserName() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        // (a) บัญชีที่ login แล้ว: ใช้ชื่อก่อน
        if (user.name.isNotEmpty) {
          if (mounted) setState(() => _userName = user.name);
          return;
        }
        // (b) ถ้าไม่มีชื่อ ใช้อีเมลแทน (พฤติกรรมเดิม)
        if (user.email.isNotEmpty) {
          if (mounted) {
            setState(() => _userName = user.email.split('@')[0]);
          }
          return;
        }
      }

      // (c) ไม่มีบัญชี login — fallback ไปใช้ชื่อจาก guest onboarding
      final guestData = await GuestSessionService.instance.loadOnboarding();
      final guestName = guestData?.name;
      if (guestName != null && guestName.isNotEmpty) {
        if (mounted) setState(() => _userName = guestName);
      }
      // (d) ไม่มีข้อมูลใดๆ — ปล่อย _userName ว่างไว้ (การ์ดทักทายจะ
      // fallback เป็น "สวัสดีค่ะ" อยู่แล้ว)
    } catch (e) {
      // ผิดพลาดระหว่างโหลด (account หรือ guest) — ปล่อยว่างไว้อย่างปลอดภัย
      debugPrint('HomeScreen._loadUserName error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: celestialBackdrop),
        child: Stack(
          children: [
            // ── Quiet temple-at-dusk atmosphere: two soft, restrained plum
            // glows only. Pulled back from the earlier four-corner pastel mesh
            // so the backdrop reads calm and premium, not busy/glowy.
            const Positioned(
              top: -130,
              left: -100,
              child: CelestialGlow(
                size: 300,
                color: AppColors.primary,
                intensity: 0.18,
              ),
            ),
            const Positioned(
              bottom: -120,
              right: -110,
              child: CelestialGlow(
                size: 300,
                color: AppColors.primary,
                intensity: 0.14,
              ),
            ),
            // A single faint candle-gold warmth high on the right — the one
            // gold note in the atmosphere.
            const Positioned(
              top: -70,
              right: -90,
              child: CelestialGlow(
                size: 220,
                color: AppColors.accent,
                intensity: 0.10,
              ),
            ),
            // ── Grain to kill the flat-digital look, low in the stack.
            const Positioned.fill(child: GrainOverlay(opacity: 0.026)),
            // A couple of faint scattered specks for atmosphere (was three).
            Positioned(
              top: 90,
              right: 44,
              child: _starSpeck(AppIcons.sparkle, 13, 0.28),
            ),
            Positioned(
              top: 240,
              left: 56,
              child: _starSpeck(AppIcons.sparkle, 9, 0.22),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      StaggeredReveal(index: 0, child: _buildHeader()),
                      const SizedBox(height: 32),
                      // แนวทางวันนี้ + ร่วมบุญ — astrology guidance and the
                      // suitable merit of the day, woven into one calm card.
                      StaggeredReveal(index: 1, child: _buildMeritHero()),
                      const SizedBox(height: 14),
                      // Quiet trust strip for the merit flow — sits just under
                      // the hero so the promise (real temples, full proof,
                      // trackable) is right where intent forms. Subtle, not salesy.
                      StaggeredReveal(index: 2, child: _buildTrustStrip()),
                      const SizedBox(height: 34),
                      // ดูดวงประจำวัน — daily reading.
                      StaggeredReveal(index: 3, child: _buildDailyHoroscope()),
                      const SizedBox(height: 34),
                      // ตารางร่วมบุญประจำสัปดาห์ — gentle daily-return rhythm.
                      StaggeredReveal(index: 4, child: _buildMeritWeekStrip()),
                      const SizedBox(height: 34),
                      StaggeredReveal(index: 5, child: _buildFeatures()),
                      if (_showGentleOffer) ...[
                        const SizedBox(height: 34),
                        StaggeredReveal(index: 6, child: _buildGentleOffer()),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  /// A faint decorative star/sparkle speck.
  Widget _starSpeck(String asset, double size, double opacity) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          asset,
          width: size,
          height: size,
          colorFilter:
              const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
      ),
    );
  }

  /// Display font (characterful serif) for English accents / numerals — the
  /// editorial counterpoint to the Thai Kanit headings.
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

  /// Small uppercase letter-spaced English overline for an editorial feel above
  /// Thai section titles.
  Widget _overline(String text, {Color? color}) {
    return Text(
      text.toUpperCase(),
      style: _displayStyle(
        fontSize: 11.5,
        color: color ?? AppColors.onBackdropMuted,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.6,
      ),
    );
  }

  /// Gentle press feedback: scales the child down slightly while tapped, with a
  /// soft splash. Visual-only wrapper around the original onTap.
  Widget _pressable({
    required Widget child,
    required VoidCallback onTap,
    BorderRadius? borderRadius,
  }) {
    return _PressScale(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: child,
    );
  }

  /// A section heading with an editorial overline + Thai title (Kanit) and a
  /// gentle sparkle accent. [overline] optional for the small inline use.
  Widget _sectionTitle(String title, {String? overline}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null) ...[
          _overline(overline),
          const SizedBox(height: 5),
        ],
        Row(
          children: [
            SvgPicture.asset(
              AppIcons.sparkleFilled,
              width: 18,
              height: 18,
              colorFilter:
                  const ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.kanit(
                color: AppColors.onBackdrop,
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editorial English overline + the date in the display serif.
              _overline('Today', color: AppColors.onBackdropMuted),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'th_TH').format(_today),
                style: GoogleFonts.kanit(
                  color: AppColors.onBackdropMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              // Dramatic Thai greeting — big, tight, intentional.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _userName.isEmpty
                          ? 'สวัสดีค่ะ'
                          : 'สวัสดีค่ะ คุณ$_userName',
                      style: GoogleFonts.kanit(
                        color: AppColors.onBackdrop,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        letterSpacing: -0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    AppIcons.sparkleFilled,
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                        AppColors.accent, BlendMode.srcIn),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Calm daily-guidance line — companion tone, not a sales hook.
              Text(
                'ขอให้วันนี้เป็นวันที่ใจสงบและเป็นมงคล',
                style: GoogleFonts.kanit(
                  color: AppColors.onBackdropMuted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // ── SIGNATURE MOMENT: a slowly-rotating celestial horoscope wheel,
        // haloed in pastel light, sitting beside a tappable profile avatar.
        GestureDetector(
          onTap: () {
            _showProfileOptions(context);
          },
          child: SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Soft halo behind the wheel.
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.22),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Slowly rotating celestial wheel — alive but subtle.
                IgnorePointer(
                  child: RotationTransition(
                    turns: _celestialRotation,
                    child: Opacity(
                      opacity: 0.9,
                      child: Lottie.asset(
                        'assets/animations/horowheel.json',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        animate: false,
                      ),
                    ),
                  ),
                ),
                // Avatar coin in the centre.
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightSurface,
                    ),
                    child: const Center(
                      child: SvgIcon(
                        AppIcons.personFilled,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const SvgIcon(AppIcons.person,
                    size: 24, color: AppColors.primary),
                title: Text('โปรไฟล์',
                    style: GoogleFonts.kanit(color: AppColors.deepText)),
                onTap: () {
                  Navigator.pop(context);
                  AppRouter.navigateTo(context, AppRoutes.profile);
                },
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const SvgIcon(AppIcons.settings,
                    size: 24, color: AppColors.primary),
                title: Text('ตั้งค่า',
                    style: GoogleFonts.kanit(color: AppColors.deepText)),
                onTap: () {
                  Navigator.pop(context);
                  AppRouter.navigateTo(context, AppRoutes.settings);
                },
              ),
              const Divider(color: AppColors.divider),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: const SvgIcon(AppIcons.logout,
                    size: 24, color: AppColors.error),
                title: Text('ออกจากระบบ',
                    style: GoogleFonts.kanit(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(context);
                  await _signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // Navigation will be handled by AuthWrapper
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ออกจากระบบไม่สำเร็จ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// A calm, dismissible in-page offer — replaces the old auto popup and the
  /// rotating promo banner slider. Ivory card, candle-gold icon, soft copy and
  /// a quiet "ดูรายละเอียด" CTA. No flash-sale/urgency wording.
  Widget _buildGentleOffer() {
    final offer = _gentleOffer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soft candle-gold icon chip — the single gold note here.
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.candleGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const SvgIcon(
              AppIcons.sparkleFilled,
              size: 22,
              color: AppColors.deepGoldBrown,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                if (offer.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    offer.subtitle!,
                    style: GoogleFonts.kanit(
                      color: AppColors.mutedText,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    final url = offer.buttonUrl;
                    if (url != null && url.isNotEmpty) {
                      launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        offer.buttonText ?? 'ดูรายละเอียด',
                        style: GoogleFonts.kanit(
                          color: AppColors.deepGoldBrown,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const SvgIcon(
                        AppIcons.arrowForward,
                        size: 15,
                        color: AppColors.deepGoldBrown,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Quiet dismiss — user is never trapped by the offer.
          GestureDetector(
            onTap: () => setState(() => _showGentleOffer = false),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.mutedText.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHoroscope() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ดวงประจำวันของคุณ', overline: 'Daily Reading'),
        const SizedBox(height: 16),
        DailyHoroscopeCard(
          zodiacSign: "", // Empty string since zodiac sign is removed
          date: _today,
          onViewDetails: () {
            Navigator.pushNamed(context, AppRoutes.dailyHoroscope);
          },
        ),
      ],
    );
  }

  /// Today's recommended merit place from the weekly schedule (read-only,
  /// static const data). DateTime.weekday is 1=Mon..7=Sun.
  WeeklyMeritSchedule get _todayMeritSchedule {
    final today = MeritDayX.fromWeekday(_today.weekday);
    return WeeklyMeritSchedule.defaultSchedule.firstWhere(
      (s) => s.day == today,
      orElse: () => WeeklyMeritSchedule.defaultSchedule.first,
    );
  }

  /// 🪷 GUIDANCE + MERIT — the calm centerpiece. An ivory/rice-paper card on
  /// the plum backdrop that weaves the day's astrological guidance together
  /// with the suitable place to make merit, so astrology and ร่วมบุญ feel like
  /// one companion gesture rather than separate cards + a sales banner.
  ///
  /// Gold is used sparingly — only the small icon coin, a hairline divider and
  /// the outlined CTA. No bright gold-peach fill, no heavy glow, no hard sell.
  Widget _buildMeritHero() {
    final schedule = _todayMeritSchedule;
    final dayName = MeritDayX.fromWeekday(_today.weekday).displayName;

    return _pressable(
      borderRadius: BorderRadius.circular(26),
      onTap: () => Navigator.pushNamed(context, AppRoutes.merit),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          // Warm ivory → rice-paper, the same card language as the rest of the
          // app. Calm, premium, trustworthy.
          gradient: const LinearGradient(
            colors: [AppColors.ivorySilk, AppColors.ricePaper],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.warmCardBorder.withValues(alpha: 0.7),
            width: 1,
          ),
          boxShadow: [
            // Single soft plum lift — no orange glow.
            BoxShadow(
              color: AppColors.templeIndigo.withValues(alpha: 0.20),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // A single faint temple watermark for depth — quiet, low opacity.
            const Positioned(
              right: -28,
              top: -28,
              child: Opacity(
                opacity: 0.05,
                child: SvgIcon(
                  AppIcons.temple,
                  size: 150,
                  color: AppColors.deepGoldBrown,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _overline('Guidance for Today',
                    color: AppColors.deepGoldBrown.withValues(alpha: 0.85)),
                const SizedBox(height: 12),
                // Daily guidance — the belief/intent of today, framed gently.
                Text(
                  'แนวทางวันนี้',
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$dayName เป็นวันที่เหมาะกับการตั้งจิต'
                  'เรื่อง${schedule.belief}',
                  style: GoogleFonts.kanit(
                    color: AppColors.mutedText,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                // Gold hairline divider — one of the few gold notes.
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.candleGold.withValues(alpha: 0.55),
                        AppColors.candleGold.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Suitable merit, tied to the guidance above.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Small candle-gold icon coin — sparing gold accent.
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AppColors.candleGold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const SvgIcon(
                        AppIcons.temple,
                        size: 24,
                        color: AppColors.deepGoldBrown,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ร่วมบุญที่เหมาะกับวันนี้',
                            style: GoogleFonts.kanit(
                              color: AppColors.softInk,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            schedule.locationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.kanit(
                              color: AppColors.deepText,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Quiet outlined CTA — gold edge + ink label, not a loud fill.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.candleGold.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.candleGold.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ร่วมบุญอย่างสบายใจ',
                        style: GoogleFonts.kanit(
                          color: AppColors.deepGoldBrown,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SvgIcon(
                        AppIcons.arrowForward,
                        size: 18,
                        color: AppColors.deepGoldBrown,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Trust line — proof at every step, calmly stated.
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 14,
                        color: AppColors.bodhiGreen.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ดูหลักฐานทุกขั้นตอน',
                        style: GoogleFonts.kanit(
                          color: AppColors.softInk,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🤍 TRUST STRIP — three quiet chips that state the merit promise: real
  /// temples/foundations, full proof at every step, trackable status. Sits just
  /// under the hero. Plum-tinted translucent chips on the indigo backdrop with a
  /// small bodhi-green check — calm reassurance, never a sales pitch.
  Widget _buildTrustStrip() {
    const items = <(IconData, String)>[
      // Proof/trust motifs — calm temple + badge-check + document-check line
      // icons. (track_changes read as a techy target reticle; fact_check is a
      // gentler "status you can follow" mark.)
      (Icons.temple_buddhist_outlined, 'วัด/มูลนิธิจริง'),
      (Icons.verified_outlined, 'หลักฐานครบทุกขั้นตอน'),
      (Icons.fact_check_outlined, 'ติดตามสถานะได้'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (icon, label) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              // Faint ivory-on-plum chip — readable on the indigo backdrop
              // without competing with the cards above.
              color: AppColors.onBackdrop.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.onBackdrop.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: AppColors.bodhiGreen.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.kanit(
                    color: AppColors.onBackdropMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 📅 Weekly merit schedule mini-strip — a horizontal row of 7 day chips,
  /// each showing that day's merit place. Highlights today and drives the
  /// daily-return habit. Reads the static const schedule; taps go to merit.
  Widget _buildMeritWeekStrip() {
    final todayWeekday = _today.weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ร่วมบุญประจำสัปดาห์', overline: 'Weekly Merit'),
        const SizedBox(height: 14),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 4),
            itemCount: WeeklyMeritSchedule.defaultSchedule.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final s = WeeklyMeritSchedule.defaultSchedule[i];
              final isToday = s.day.weekdayNumber == todayWeekday;
              return _meritDayChip(s, isToday);
            },
          ),
        ),
      ],
    );
  }

  Widget _meritDayChip(WeeklyMeritSchedule s, bool isToday) {
    return _pressable(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.pushNamed(context, AppRoutes.merit),
      child: Container(
        width: 102,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          // Both states stay on calm ivory — "today" is marked with a candle-
          // gold hairline border and a soft gold wash, not a bright gradient.
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isToday
                ? AppColors.candleGold.withValues(alpha: 0.85)
                : AppColors.divider.withValues(alpha: 0.55),
            width: isToday ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.templeIndigo
                  .withValues(alpha: isToday ? 0.14 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.candleGold.withValues(alpha: 0.20)
                        : AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    s.day.shortName,
                    style: GoogleFonts.kanit(
                      color:
                          isToday ? AppColors.deepGoldBrown : AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 6),
                  const SvgIcon(
                    AppIcons.temple,
                    size: 14,
                    color: AppColors.deepGoldBrown,
                  ),
                ],
              ],
            ),
            Text(
              s.locationName,
              maxLines: 2,
              overflow: TextOverflow.fade,
              softWrap: true,
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('บริการอื่นๆ', overline: 'Explore'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallFeatureCard(
                title: 'ไพ่ทาโรต์',
                svgIconPath: AppIcons.sparkleFilled,
                // Tarot — same code as Dashboard's tarotMajor (muted gilt).
                tileGradient: const [AppColors.tarotMajor, AppColors.deepGoldBrown],
                onTap: () => Navigator.pushNamed(context, AppRoutes.tarot),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallFeatureCard(
                title: 'พ่อหมอโหรา',
                svgIconPath: AppIcons.chatFilled,
                // Chat — same code as Dashboard's chatBubble (soft plum).
                tileGradient: const [AppColors.chatBubble, AppColors.nightPlum],
                onTap: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.chat),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallFeatureCard(
                title: 'โหราศาสตร์',
                svgIconPath: AppIcons.starFilled,
                // Horoscope — same code as Dashboard's zodiacFire (ember vermilion).
                tileGradient: const [AppColors.zodiacFire, AppColors.deepGoldBrown],
                onTap: () => Navigator.pushNamed(context, AppRoutes.horoscope),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Premium feature tile: a clean white glyph on a per-feature temple-toned
  /// gradient chip (with a matching colored shadow) above a deep-ink label.
  /// [tileGradient] is the 2-stop ramp for this feature's icon chip — the same
  /// feature color Dashboard uses (tarotMajor / chatBubble / zodiacFire), so
  /// Home and Dashboard code the same features identically.
  Widget _buildSmallFeatureCard({
    required String title,
    required String svgIconPath,
    required List<Color> tileGradient,
    required VoidCallback onTap,
  }) {
    final borderRadius = BorderRadius.circular(20);
    final shadowColor = tileGradient.last;

    final inner = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: tileGradient,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.40),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          // Pure-white glyph reads crisply on the saturated pastel chip and
          // unifies the visual language (was a mix of tinted line/illustration
          // SVGs at size 24 in pale circles).
          child: Center(
            child: SvgIcon(
              svgIconPath,
              size: 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    return _pressable(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.16),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: inner,
      ),
    );
  }
}

/// Gentle press-scale + soft splash wrapper. Tasteful micro-interaction for
/// tappable cards — scales down briefly on press, then springs back.
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
