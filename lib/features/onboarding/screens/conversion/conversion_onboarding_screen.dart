import 'dart:async';

import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:flutter/material.dart' as material show TimeOfDay;

import '../../../../core/routes/app_routes.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/guest_session_service.dart';
import '../../models/onboarding_models.dart';
import '../../services/ab_test_service.dart';
import 'conversion_style.dart';
import 'conversion_widgets.dart';

typedef FlutterTimeOfDay = material.TimeOfDay;

/// High-conversion onboarding flow (11 screens) translated 1:1 from the
/// imported "Onboarding Flow" Claude Design.
///
/// Phases: Hook (1) → Personalize (2–6) → Aha + Trust (7–9) → Commit (10–11),
/// then guest-first entry to Home. Trial paywall is a UI placeholder; both its
/// CTA and "skip" enter Home (no payment SDK wired yet).
class ConversionOnboardingScreen extends StatefulWidget {
  const ConversionOnboardingScreen({super.key});

  @override
  State<ConversionOnboardingScreen> createState() =>
      _ConversionOnboardingScreenState();
}

class _ConversionOnboardingScreenState extends State<ConversionOnboardingScreen> {
  final PageController _pageController = PageController();
  final ABTestService _abTest = ABTestService.instance;
  final TextEditingController _nameController = TextEditingController();

  static const int _totalPages = 11;

  /// Steps shown by the personalize progress bar (screens 2–6 → 5 steps).
  static const int _progressSteps = 5;

  int _page = 0;
  OnboardingData _data = const OnboardingData();

  @override
  void initState() {
    super.initState();
    _abTest.trackFunnelStep('cv_started');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ---- Navigation ----------------------------------------------------------

  void _next() {
    if (_page < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_page > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishAsGuest() async {
    _data = _data.copyWith(name: _nameController.text.trim());
    await _abTest.completeOnboarding();
    await GuestSessionService.instance.saveOnboarding(_data);
    await GuestSessionService.instance.markOnboardingCompleted();
    if (mounted) {
      AppRouter.navigateAndClearStack(context, AppRoutes.home);
    }
  }

  void _goToLogin() =>
      Navigator.pushReplacementNamed(context, AppRoutes.login);

  // ---- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CvColors.bgBottom,
      body: CvBackground(
        child: SafeArea(
          bottom: false,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) {
              FocusScope.of(context).unfocus();
              setState(() => _page = i);
              _abTest.trackFunnelStep('cv_page_$i');
              if (i == 6) _runAnalyzing(); // screen 7 = analyzing
            },
            children: [
              _welcome(), // 1
              _howDidYouHear(), // 2
              _goal(), // 3
              _name(), // 4
              _birthdate(), // 5
              _frequency(), // 6
              _analyzing(), // 7
              _resultReveal(), // 8
              _trust(), // 9
              _notifications(), // 10
              _paywall(), // 11
            ],
          ),
        ),
      ),
    );
  }

  // ---- Shared chrome -------------------------------------------------------

  /// Header for personalize screens: back chevron + 5-step progress.
  Widget _personalizeHeader(int step) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _back,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('‹',
                  style: CvType.display(26,
                      weight: FontWeight.w300, color: CvColors.creamA(0.7))),
            ),
          ),
          Expanded(
            child: CvProgressBar(current: step, total: _progressSteps),
          ),
        ],
      ),
    );
  }

  /// A page scaffold with a pinned bottom CTA over a soft scrim.
  Widget _pageWithCta({
    required Widget header,
    required Widget body,
    required Widget cta,
    bool scrim = true,
  }) {
    return Column(
      children: [
        header,
        Expanded(child: body),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
          decoration: scrim
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x001F1733), CvColors.bgFooter],
                    stops: [0.0, 0.5],
                  ),
                )
              : null,
          child: cta,
        ),
      ],
    );
  }

  // ========================================================================
  // SCREEN 1 — WELCOME
  // ========================================================================
  Widget _welcome() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
            child: Column(
              children: [
                const SizedBox(height: 42),
                _glowOrb(),
                const SizedBox(height: 30),
                Text('WELCOME',
                    style: CvType.eyebrow(size: 11).copyWith(letterSpacing: 4)),
                const SizedBox(height: 14),
                Text('ทำบุญ ดูดวง\nอย่างสบายใจ',
                    textAlign: TextAlign.center,
                    style: CvType.display(29, height: 1.28)),
                const SizedBox(height: 16),
                Text(
                  'ร่วมบุญกับวัดและมูลนิธิจริง พร้อมหลักฐานครบทุกขั้นตอน '
                  'และดวงประจำวันเฉพาะคุณ',
                  textAlign: TextAlign.center,
                  style: CvType.body(14, color: CvColors.creamA(0.66)),
                ),
                const Spacer(),
                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _Pill('วัด/มูลนิธิจริง'),
                    _Pill('หลักฐานครบ'),
                    _Pill('ปลอดภัย'),
                  ],
                ),
                const SizedBox(height: 22),
                CvGoldButton(label: 'เริ่มต้น', onPressed: _next),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _goToLogin,
                  child: Text.rich(
                    TextSpan(
                      text: 'มีบัญชีอยู่แล้ว? ',
                      style:
                          CvType.body(14, color: CvColors.creamA(0.65)),
                      children: [
                        TextSpan(
                          text: 'เข้าสู่ระบบ',
                          style: CvType.body(14,
                              weight: FontWeight.w600, color: CvColors.gold),
                        ),
                      ],
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

  Widget _glowOrb() {
    return Container(
      width: 78,
      height: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(0, -0.24),
          colors: [Color(0xFFF7DF9C), Color(0xFFC9983D)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD6AA50).withValues(alpha: 0.5),
            blurRadius: 46,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Text('✦',
          style: TextStyle(fontSize: 36, color: Color(0xFF5B4318))),
    );
  }

  // ========================================================================
  // SCREEN 2 — HOW DID YOU HEAR
  // ========================================================================
  Widget _howDidYouHear() {
    Widget chip(ReferralSource s) {
      switch (s) {
        case ReferralSource.tiktok:
          return const CvBrandChip(glyph: '♪', background: Color(0xFF111111));
        case ReferralSource.instagram:
          return const CvBrandChip(
              glyph: '◎',
              background: Color(0xFFE1306C)); // simplified IG gradient
        case ReferralSource.facebook:
          return const CvBrandChip(
              glyph: 'f',
              background: Color(0xFF1877F2),
              textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700));
        case ReferralSource.youtube:
          return const CvBrandChip(glyph: '▶', background: Color(0xFFFF0000));
        case ReferralSource.friend:
          return CvBrandChip(
              glyph: '♥',
              background: CvColors.goldA(0.25),
              foreground: CvColors.goldSoft);
        case ReferralSource.appStore:
          return CvBrandChip(
              glyph: '⌕',
              background: CvColors.whiteA(0.12),
              foreground: CvColors.creamA(0.8));
      }
    }

    return _pageWithCta(
      header: _personalizeHeader(1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('คุณรู้จักเรา\nจากที่ไหน?',
                style: CvType.display(23, height: 1.32)),
            const SizedBox(height: 9),
            Text('ช่วยบอกเราหน่อย เพื่อพัฒนาให้ดียิ่งขึ้น',
                style: CvType.body(13, color: CvColors.creamA(0.6))),
            const SizedBox(height: 20),
            ...ReferralSource.values.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: CvSelectRow(
                    leading: chip(s),
                    title: s.thaiName,
                    selected: _data.referralSource == s,
                    onTap: () => setState(
                        () => _data = _data.copyWith(referralSource: s)),
                  ),
                )),
          ],
        ),
      ),
      cta: CvGoldButton(
        label: 'ถัดไป',
        onPressed: _data.referralSource != null ? _next : null,
      ),
    );
  }

  // ========================================================================
  // SCREEN 3 — GOAL (multi-select)
  // ========================================================================
  Widget _goal() {
    const tiles = [
      (PrimaryInterest.finance, '✦', 'โชคลาภ การเงิน'),
      (PrimaryInterest.love, '♥', 'ความรัก'),
      (PrimaryInterest.health, '✛', 'สุขภาพ'),
      (PrimaryInterest.career, '▲', 'การงาน'),
    ];

    void toggle(PrimaryInterest i) {
      final next = Set<PrimaryInterest>.from(_data.interests);
      next.contains(i) ? next.remove(i) : next.add(i);
      setState(() => _data = _data.copyWith(interests: next));
    }

    return _pageWithCta(
      header: _personalizeHeader(2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ตอนนี้ คุณอยากเสริม\nเรื่องใดมากที่สุด?',
                style: CvType.display(23, height: 1.32)),
            const SizedBox(height: 10),
            Text('เลือกได้มากกว่า 1 ข้อ เพื่อให้เราจัดแนวทางให้เหมาะกับคุณ',
                style: CvType.body(13, color: CvColors.creamA(0.6))),
            const SizedBox(height: 24),
            // 2×2 grid built from Rows so each tile sizes to its content
            // (avoids fixed-aspect overflow on short viewports).
            for (var r = 0; r < tiles.length; r += 2) ...[
              if (r > 0) const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var c = 0; c < 2 && r + c < tiles.length; c++) ...[
                      if (c > 0) const SizedBox(width: 12),
                      Expanded(
                        child: CvGoalTile(
                          glyph: tiles[r + c].$2,
                          label: tiles[r + c].$3,
                          selected: _data.interests.contains(tiles[r + c].$1),
                          onTap: () => toggle(tiles[r + c].$1),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      cta: CvGoldButton(
        label: 'ถัดไป',
        onPressed: _data.interests.isNotEmpty ? _next : null,
      ),
    );
  }

  // ========================================================================
  // SCREEN 4 — NAME
  // ========================================================================
  Widget _name() {
    return _pageWithCta(
      scrim: false,
      header: _personalizeHeader(3),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เราจะเรียกคุณ\nว่าอะไรดี?',
                style: CvType.display(24, height: 1.32)),
            const SizedBox(height: 10),
            Text('เพื่อคำทักทายและแนวทางเฉพาะคุณในทุกวัน',
                style: CvType.body(13, color: CvColors.creamA(0.6))),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4EAD7),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: TextField(
                controller: _nameController,
                cursorColor: CvColors.goldDeep,
                onChanged: (_) => setState(() {}),
                style: CvType.body(18,
                    weight: FontWeight.w600, color: const Color(0xFF3D2F1F)),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 17),
                  hintText: 'พิมพ์ชื่อหรือชื่อเล่น',
                  hintStyle: CvType.body(18,
                      color: const Color(0xFF3D2F1F).withValues(alpha: 0.4)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('🔒  ',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8AA05A))),
                Expanded(
                  child: Text(
                    'ข้อมูลของคุณถูกเก็บเป็นความลับ ใช้เพื่อ personalize เท่านั้น',
                    style: CvType.body(12, color: CvColors.creamA(0.65)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      cta: CvGoldButton(
        label: 'ถัดไป',
        onPressed: _nameController.text.trim().isNotEmpty ? _next : null,
      ),
    );
  }

  // ========================================================================
  // SCREEN 5 — BIRTHDATE
  // ========================================================================
  Widget _birthdate() {
    final hasDate = _data.birthDate != null;
    return _pageWithCta(
      scrim: false,
      header: _personalizeHeader(4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('วันเกิดของคุณ', style: CvType.display(24)),
            const SizedBox(height: 10),
            Text('เพื่อคำนวณดวงและฤกษ์มงคลเฉพาะคุณ ยิ่งละเอียด ยิ่งแม่นยำ',
                style: CvType.body(13, color: CvColors.creamA(0.6))),
            const SizedBox(height: 24),
            // Date "picker" surface — opens native picker on tap.
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CvColors.whiteA(0.04),
                  border: Border.all(color: CvColors.goldA(0.3)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  hasDate
                      ? _formatThaiDate(_data.birthDate!)
                      : 'แตะเพื่อเลือกวันเกิด',
                  style: CvType.body(19,
                      weight: FontWeight.w600,
                      color: hasDate ? CvColors.cream : CvColors.creamA(0.65)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EAD7),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Text(
                        _data.birthTime != null
                            ? '${_data.birthTime} น.'
                            : 'เลือกเวลา',
                        style: CvType.body(15,
                            weight: FontWeight.w600,
                            color: const Color(0xFF3D2F1F)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () =>
                      setState(() => _data = _data.copyWith(birthTime: null)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 13),
                    decoration: BoxDecoration(
                      color: CvColors.whiteA(0.05),
                      border: Border.all(color: CvColors.whiteA(0.1)),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Text('ไม่ทราบเวลา',
                        style: CvType.body(13,
                            weight: FontWeight.w500,
                            color: CvColors.creamA(0.7))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: CvColors.goldA(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔒  ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      'ใช้สำหรับคำนวณดวงเท่านั้น — ไม่เปิดเผยต่อผู้อื่น',
                      style: CvType.body(12, color: CvColors.creamA(0.62)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      cta: CvGoldButton(
        label: 'ถัดไป',
        onPressed: hasDate ? _next : null,
      ),
    );
  }

  // ========================================================================
  // SCREEN 6 — FREQUENCY
  // ========================================================================
  Widget _frequency() {
    // Design labels mapped onto the existing MeritFrequency enum, preserving
    // order: ทุกวัน / สัปดาห์ละครั้ง / เดือนละครั้ง / เมื่อสะดวก.
    final items = <(MeritFrequency, String, String?)>[
      (MeritFrequency.weekly, 'ทุกวัน', 'เสริมดวงอย่างต่อเนื่อง'),
      (MeritFrequency.monthly, 'สัปดาห์ละครั้ง', 'ยอดนิยม · สม่ำเสมอกำลังดี'),
      (MeritFrequency.occasionally, 'เดือนละครั้ง', null),
      (MeritFrequency.rarely, 'เมื่อสะดวก', null),
    ];

    return _pageWithCta(
      header: _personalizeHeader(5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('อยากทำบุญ\nบ่อยแค่ไหน?',
                style: CvType.display(24, height: 1.34)),
            const SizedBox(height: 10),
            Text('เราจะเตือนเบาๆ ในวันมงคล ไม่รบกวน',
                style: CvType.body(13, color: CvColors.creamA(0.6))),
            const SizedBox(height: 24),
            ...items.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CvSelectRow(
                    title: o.$2,
                    subtitle: o.$3,
                    selected: _data.meritFrequency == o.$1,
                    onTap: () => setState(
                        () => _data = _data.copyWith(meritFrequency: o.$1)),
                  ),
                )),
          ],
        ),
      ),
      cta: CvGoldButton(
        label: 'ดูแนวทางของฉัน',
        onPressed: _data.meritFrequency != null ? _next : null,
      ),
    );
  }

  // ========================================================================
  // SCREEN 7 — ANALYZING
  // ========================================================================
  double _analyzeProgress = 0;
  Timer? _analyzeTimer;
  int _analyzeStep = 0; // 0,1 done as it climbs; 2 completes at end

  void _runAnalyzing() {
    _analyzeTimer?.cancel();
    _analyzeProgress = 0;
    _analyzeStep = 0;
    const tick = Duration(milliseconds: 40);
    _analyzeTimer = Timer.periodic(tick, (t) {
      if (!mounted) return;
      setState(() {
        _analyzeProgress += 0.012;
        if (_analyzeProgress >= 0.35) _analyzeStep = 1;
        if (_analyzeProgress >= 0.7) _analyzeStep = 2;
        if (_analyzeProgress >= 1) {
          _analyzeProgress = 1;
          t.cancel();
        }
      });
    });
    // auto-advance to the reveal after the ring fills
    Future.delayed(const Duration(milliseconds: 3400), () {
      if (mounted && _page == 6) _next();
    });
  }

  Widget _analyzing() {
    final pct = (_analyzeProgress * 100).clamp(0, 100).round();
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AnalyzeRing(progress: _analyzeProgress, label: '$pct%'),
                const SizedBox(height: 34),
                Text('กำลังจัดทำแนวทาง\nเฉพาะคุณ',
                    textAlign: TextAlign.center,
                    style: CvType.display(21, height: 1.35)),
                const SizedBox(height: 30),
                CvCheckRow(
                    title: 'คำนวณดวงประจำวันของคุณ',
                    done: _analyzeStep >= 1),
                const SizedBox(height: 14),
                CvCheckRow(
                    title: 'จับคู่วัด/มูลนิธิที่เหมาะกับเป้าหมาย',
                    done: _analyzeStep >= 2),
                const SizedBox(height: 14),
                CvCheckRow(
                    title: 'ตั้งเตือนฤกษ์มงคล…',
                    done: _analyzeProgress >= 1,
                    pulsing: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================================
  // SCREEN 8 — RESULT REVEAL (Aha)
  // ========================================================================
  Widget _resultReveal() {
    final name = _nameController.text.trim();
    final greetName = name.isEmpty ? '' : ' คุณ$name';
    final temple = _recommendedTemple();

    return _pageWithCta(
      header: const SizedBox.shrink(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR GUIDANCE', style: CvType.eyebrow(size: 11)),
            const SizedBox(height: 6),
            Text.rich(TextSpan(
              text: 'สวัสดีค่ะ$greetName ',
              style: CvType.display(24),
              children: const [
                TextSpan(text: '✦', style: TextStyle(color: CvColors.gold)),
              ],
            )),
            const SizedBox(height: 16),
            _dailyReadingCard(),
            const SizedBox(height: 14),
            _templeTeaser(temple),
          ],
        ),
      ),
      cta: CvGoldButton(label: 'ดูแนวทางทั้งหมด', onPressed: _next),
    );
  }

  Widget _dailyReadingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CvColors.ivory,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DAILY READING',
                  style: CvType.eyebrow(color: const Color(0xFFA07F3A), size: 11)
                      .copyWith(letterSpacing: 2)),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF4C9C1),
                ),
                child: const Text('🐴', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('ดวงวันนี้ของคุณ',
              style: CvType.display(19, color: CvColors.ivoryInk)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.82,
                    minHeight: 8,
                    backgroundColor: Color(0xFFE3D3B3),
                    valueColor: AlwaysStoppedAnimation(CvColors.goldMid),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('82',
                  style: CvType.body(13,
                      weight: FontWeight.w700,
                      color: const Color(0xFFA07F3A))),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              _IvoryChip('สีมงคล · ทอง'),
              SizedBox(width: 8),
              _IvoryChip('เลข · 9'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'วันนี้เป็นวันที่ดีต่อเรื่องการเงิน เหมาะตั้งจิตขอพรเรื่องโชคลาภ…',
            style: CvType.body(12,
                color: CvColors.ivoryInk.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 10),
          Text('🔒 ดูฉบับเต็ม',
              style: CvType.body(12,
                  weight: FontWeight.w600, color: const Color(0xFFA07F3A))),
        ],
      ),
    );
  }

  Widget _templeTeaser(String temple) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CvColors.goldA(0.14),
        border: Border.all(color: CvColors.goldA(0.32)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [CvColors.goldLight, CvColors.goldMid],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('☖', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('เหมาะกับเป้าหมายของคุณ',
                    style: CvType.body(12, color: CvColors.creamA(0.65))),
                Text(temple,
                    style: CvType.body(15,
                        weight: FontWeight.w700, color: CvColors.cream)),
              ],
            ),
          ),
          const Text('›',
              style: TextStyle(color: CvColors.gold, fontSize: 20)),
        ],
      ),
    );
  }

  // ========================================================================
  // SCREEN 9 — TRUST
  // ========================================================================
  Widget _trust() {
    return _pageWithCta(
      header: const SizedBox.shrink(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ทำไมคนไทยกว่า\n200,000 คน ไว้ใจเรา',
                style: CvType.display(23, height: 1.34)),
            const SizedBox(height: 26),
            const CvCheckRow(
              title: 'วัด/มูลนิธิจริง',
              subtitle: 'ตรวจสอบและรับรองทุกแห่งก่อนขึ้นระบบ',
            ),
            const SizedBox(height: 14),
            const CvCheckRow(
              title: 'หลักฐานครบทุกขั้นตอน',
              subtitle: 'รูปถ่าย + ใบอนุโมทนาบุญ ส่งถึงคุณทุกครั้ง',
            ),
            const SizedBox(height: 14),
            const CvCheckRow(
              title: 'ติดตามสถานะได้',
              subtitle: 'รู้ทุกความเคลื่อนไหวของบุญที่คุณร่วม',
            ),
            const SizedBox(height: 24),
            _testimonial(),
          ],
        ),
      ),
      cta: CvGoldButton(label: 'ดำเนินการต่อ', onPressed: _next),
    );
  }

  Widget _testimonial() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CvColors.ivory,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('★★★★★',
              style: CvType.body(15, color: CvColors.goldMid)
                  .copyWith(letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('“ทำบุญง่าย สบายใจ ได้ใบอนุโมทนาจริง ไม่ต้องเดินทาง”',
              style: CvType.body(13,
                  weight: FontWeight.w500,
                  color: CvColors.ivoryInk,
                  height: 1.6)),
          const SizedBox(height: 8),
          Text('— คุณมนัสนันท์, กรุงเทพฯ',
              style: CvType.body(12,
                  color: CvColors.ivoryInk.withValues(alpha: 0.65))),
        ],
      ),
    );
  }

  // ========================================================================
  // SCREEN 10 — NOTIFICATIONS
  // ========================================================================
  Widget _notifications() {
    return _pageWithCta(
      scrim: false,
      header: const SizedBox.shrink(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('อย่าพลาด\nวันมงคลของคุณ',
                style: CvType.display(24, height: 1.34)),
            const SizedBox(height: 10),
            Text('รับเตือนวันพระ ฤกษ์ดี และดวงรายวัน เฉพาะคุณ',
                style: CvType.body(13, color: CvColors.creamA(0.6))),
            const SizedBox(height: 28),
            _notifPreview(
              glyph: '🔔',
              glyphGold: true,
              title: 'พรุ่งนี้วันพระ',
              subtitle: 'เหมาะเสริมเรื่องการเงิน · 06:00',
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: _notifPreview(
                glyph: '✦',
                glyphGold: false,
                title: 'ดวงประจำวันของคุณพร้อมแล้ว',
                subtitle: 'เปิดดูเลย · ตอนนี้',
                dim: true,
              ),
            ),
          ],
        ),
      ),
      cta: Column(
        children: [
          CvGoldButton(
            label: 'เปิดการแจ้งเตือน',
            onPressed: () {
              setState(() => _data = _data.copyWith(wantsNotifications: true));
              // TODO: request OS notification permission via NotificationService
              _next();
            },
          ),
          CvTextLink(
            label: 'ไว้ทีหลัง',
            onPressed: () {
              setState(() => _data = _data.copyWith(wantsNotifications: false));
              _next();
            },
          ),
        ],
      ),
    );
  }

  Widget _notifPreview({
    required String glyph,
    required bool glyphGold,
    required String title,
    required String subtitle,
    bool dim = false,
  }) {
    return Opacity(
      opacity: dim ? 0.85 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CvColors.ivory,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: glyphGold
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [CvColors.goldLight, CvColors.goldMid])
                    : null,
                color: glyphGold ? null : const Color(0xFFF4C9C1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(glyph, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: CvType.body(13,
                          weight: FontWeight.w600, color: CvColors.ivoryInk)),
                  Text(subtitle,
                      style: CvType.body(12,
                          color: CvColors.ivoryInk.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // SCREEN 11 — SOFT PAYWALL (placeholder — no payment SDK)
  // ========================================================================
  Widget _paywall() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _finishAsGuest,
              child: Text('✕',
                  style: CvType.body(14, color: CvColors.creamA(0.65))),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ทดลองฟรี 7 วัน', style: CvType.eyebrow(size: 11)),
                const SizedBox(height: 6),
                Text('ปลดล็อกแนวทาง\nเต็มทุกวัน',
                    style: CvType.display(24, height: 1.3)),
                const SizedBox(height: 18),
                ..._paywallBenefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: Row(
                        children: [
                          const Text('✦  ',
                              style: TextStyle(
                                  color: CvColors.goldMid, fontSize: 15)),
                          Expanded(
                            child: Text(b,
                                style: CvType.body(13,
                                    weight: FontWeight.w500,
                                    color: CvColors.creamA(0.9))),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                const IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _PlanCard(
                          title: 'รายปี',
                          price: '฿599',
                          per: '฿50/เดือน',
                          badge: 'ประหยัด 50%',
                          highlighted: true,
                        ),
                      ),
                      SizedBox(width: 11),
                      Expanded(
                        child: _PlanCard(
                          title: 'รายเดือน',
                          price: '฿99',
                          per: 'ต่อเดือน',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x001F1733), CvColors.bgFooter],
              stops: [0.0, 0.4],
            ),
          ),
          child: Column(
            children: [
              // Placeholder: both trial + skip enter Home as guest for now.
              CvGoldButton(
                  label: 'เริ่มทดลองฟรี 7 วัน', onPressed: _finishAsGuest),
              const SizedBox(height: 9),
              Text('จากนั้น ฿599/ปี · ยกเลิกได้ทุกเมื่อ',
                  style: CvType.body(12, color: CvColors.creamA(0.65))),
              CvTextLink(label: 'ข้ามไปก่อน', onPressed: _finishAsGuest),
            ],
          ),
        ),
      ],
    );
  }

  static const _paywallBenefits = [
    'ดวงรายวันเฉพาะคุณ ฉบับเต็ม',
    'จับคู่วัด/พิธีที่เหมาะกับคุณ',
    'เตือนฤกษ์มงคลไม่จำกัด',
    'หลักฐาน + ใบอนุโมทนาครบ',
  ];

  // ---- Helpers -------------------------------------------------------------

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data.birthDate ?? DateTime(1991, 6, 15),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: CvColors.goldDeep,
            onPrimary: Colors.white,
            surface: CvColors.ivory,
            onSurface: CvColors.ivoryInk,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _data = _data.copyWith(birthDate: picked));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const FlutterTimeOfDay(hour: 6, minute: 45),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: CvColors.goldDeep,
            onPrimary: Colors.white,
            surface: CvColors.ivory,
            onSurface: CvColors.ivoryInk,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _data = _data.copyWith(
          birthTime: BirthTime(hour: picked.hour, minute: picked.minute)));
    }
  }

  String _recommendedTemple() {
    switch (_data.primaryInterest) {
      case PrimaryInterest.finance:
        return 'วัดระฆังโฆสิตาราม';
      case PrimaryInterest.love:
        return 'ศาลพระตรีมูรติ';
      case PrimaryInterest.career:
        return 'พระพิฆเนศ เซ็นทรัลเวิลด์';
      case PrimaryInterest.health:
        return 'วัดพระศรีมหาอุมาเทวี';
      default:
        return 'ท้าวมหาพรหม เอราวัณ';
    }
  }

  String _formatThaiDate(DateTime date) {
    const months = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return '${date.day}  ${months[date.month - 1]}  ${date.year + 543}';
  }
}

// ---------------------------------------------------------------------------
// Small private presentational widgets
// ---------------------------------------------------------------------------

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: CvColors.whiteA(0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text,
          style: CvType.body(12,
              weight: FontWeight.w500, color: CvColors.creamA(0.65))),
    );
  }
}

class _IvoryChip extends StatelessWidget {
  final String text;
  const _IvoryChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFECE0C8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: CvType.body(12,
              weight: FontWeight.w500, color: CvColors.ivoryInkSoft)),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String per;
  final String? badge;
  final bool highlighted;
  const _PlanCard({
    required this.title,
    required this.price,
    required this.per,
    this.badge,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    // Reserve a uniform strip at the top of every card so the body lines up
    // whether or not a badge sits over the border.
    const badgeReserve = 9.0;

    // Card is the sizing child (top margin reserves space for the badge so
    // both cards' borders align); badge is overlaid on top.
    final card = Container(
      margin: const EdgeInsets.only(top: badgeReserve),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: highlighted ? CvColors.goldA(0.16) : CvColors.whiteA(0.05),
        border: Border.all(
          color: highlighted ? CvColors.gold : CvColors.whiteA(0.1),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: CvType.body(13,
                  weight: FontWeight.w600,
                  color: highlighted
                      ? CvColors.cream
                      : CvColors.creamA(0.85))),
          const SizedBox(height: 4),
          Text(price, style: CvType.display(19)),
          Text(per,
              style: CvType.body(12,
                  color: CvColors.creamA(highlighted ? 0.65 : 0.65))),
        ],
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        card,
        if (badge != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CvColors.goldMid,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge!,
                    style: CvType.body(12,
                            weight: FontWeight.w700,
                            color: const Color(0xFF3A2C0E))
                        .copyWith(letterSpacing: 1)),
              ),
            ),
          ),
      ],
    );
  }
}

/// Conic-gradient progress ring with a pulsing centre percentage.
class _AnalyzeRing extends StatelessWidget {
  final double progress; // 0..1
  final String label;
  const _AnalyzeRing({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: CustomPaint(
        painter: _RingPainter(progress),
        child: Center(
          child: Container(
            width: 118,
            height: 118,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                colors: [Color(0xFF2C2142), Color(0xFF1D1530)],
              ),
            ),
            child: Text(label, style: CvType.display(30)),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 11.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = CvColors.goldMid;
    const start = -1.5707963; // -90°
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      6.2831853 * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
