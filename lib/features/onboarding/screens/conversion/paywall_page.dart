import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/constants.dart';
import '../../../../core/services/analytics_service.dart';
import '../../services/ab_test_service.dart';
import 'conversion_style.dart';

/// Standalone full-screen route target for the deferred-paywall placement
/// (AppRoutes.paywall) — reuses [PaywallPage] as-is, wiring its callbacks to
/// ABTestService funnel events (tagged with placement=afterFirstReading via
/// [ABTestService.trackPaywallEvent]) and to Navigator.pop instead of
/// finishing onboarding, since this is opened mid-app (from a full-version
/// lock tap), not from the onboarding PageView.
///
/// Fires paywall_shown once when it opens. Skip/close/start-trial all pop
/// back to wherever the user was (the lock they tapped) — this route never
/// double-shows the paywall and never re-triggers onboarding completion.
class DeferredPaywallScreen extends StatefulWidget {
  const DeferredPaywallScreen({super.key});

  @override
  State<DeferredPaywallScreen> createState() => _DeferredPaywallScreenState();
}

class _DeferredPaywallScreenState extends State<DeferredPaywallScreen> {
  final ABTestService _abTest = ABTestService.instance;
  PaywallVariant _paywallVariant = PaywallVariant.control;

  @override
  void initState() {
    super.initState();
    _abTest.getPaywallVariant().then((variant) {
      if (mounted) setState(() => _paywallVariant = variant);
    });
    _abTest.trackPaywallEvent('paywall_shown');
    // paywall โผล่แบบ deferred (afterFirstReading) — ตำแหน่ง onboardingEnd
    // ยิงจาก _onPaywallShown ใน ConversionOnboardingScreen แทน
    AnalyticsService.instance.log('paywall_view');
  }

  void _close() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  /// เปิด LINE OA ให้คุยกับทีมงานเพื่อเริ่มทดลองใช้ฟรี 7 วัน
  Future<void> _openTrialLineOA() async {
    AnalyticsService.instance.log('line_link_tap', {'source': 'trial'});
    try {
      final url = Uri.parse(LineOAConstants.mainOA);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // เปิด LINE ไม่ได้ (เช่นในเทสต์/ไม่มีแอป) — ไม่ขวางการปิดหน้า
      debugPrint('openTrialLineOA failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CvColors.bgBottom,
      body: CvBackground(
        child: SafeArea(
          bottom: false,
          child: PaywallPage(
            paywallVariant: _paywallVariant,
            onPlanSelected: (plan) =>
                _abTest.trackPaywallEvent('paywall_plan_selected', detail: plan),
            onStartTrialTapped: () {
              _abTest.trackPaywallEvent('paywall_start_trial_tapped');
              _openTrialLineOA();
              _close();
            },
            onSkipped: () {
              _abTest.trackPaywallEvent('paywall_skipped');
              _close();
            },
            onClosed: () {
              _abTest.trackPaywallEvent('paywall_closed');
              _close();
            },
          ),
        ),
      ),
    );
  }
}

/// The soft paywall page (placeholder — no payment SDK), extracted from
/// [ConversionOnboardingScreen] screen 11 so it can be reused both as the
/// last page of the onboarding PageView (placement: onboardingEnd) and as a
/// standalone full-screen route (placement: afterFirstReading). Pure move:
/// same widget tree/copy as before, parameterized by the callbacks the host
/// needs to wire (funnel tracking + navigation), and by [paywallVariant] to
/// render the dormant softGate delta.
class PaywallPage extends StatelessWidget {
  final PaywallVariant paywallVariant;
  final ValueChanged<String> onPlanSelected;
  final VoidCallback onStartTrialTapped;
  final VoidCallback onSkipped;
  final VoidCallback onClosed;

  const PaywallPage({
    super.key,
    required this.paywallVariant,
    required this.onPlanSelected,
    required this.onStartTrialTapped,
    required this.onSkipped,
    required this.onClosed,
  });

  // สิทธิ์ Premium อ้างเฉพาะของที่มีจริงในแอป (วอลเปเปอร์ = สินค้าขายจริง
  // ฿199/คอลเลคชั่น, กล่อง L2 = milestone premiumOnly ในเส้นทางสายมู) —
  // benefit ที่จับต้องไม่ได้ทำให้ paywall เลื่อนลอยและ conversion ตก
  static const _paywallBenefits = [
    'ดวงรายวันเฉพาะคุณ ฉบับเต็ม',
    'วอลเปเปอร์มงคลคอลเลคชั่นพรีเมียม (มูลค่า ฿199)',
    'กล่องรางวัล Level 2 ในเส้นทางสายมู',
    'หลักฐานไหว้ + ใบอนุโมทนาครบทุกออเดอร์',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onClosed,
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
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onPlanSelected('yearly'),
                          child: const _PlanCard(
                            title: 'รายปี',
                            price: '฿599',
                            per: '฿50/เดือน',
                            badge: 'ประหยัด 50%',
                            highlighted: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onPlanSelected('monthly'),
                          child: const _PlanCard(
                            title: 'รายเดือน',
                            price: '฿99',
                            per: 'ต่อเดือน',
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
                  label: 'เริ่มทดลองฟรี 7 วัน',
                  onPressed: () {
                    // ยิงที่นี่จุดเดียว ครอบทั้ง host onboarding และ deferred
                    AnalyticsService.instance.log('trial_cta_tap');
                    onStartTrialTapped();
                  }),
              const SizedBox(height: 9),
              Text('จากนั้น ฿599/ปี · ยกเลิกได้ทุกเมื่อ',
                  style: CvType.body(12, color: CvColors.creamA(0.65))),
              // Dormant softGate delta: only rendered when the paywall
              // experiment assigns PaywallVariant.softGate (never true today
              // — kPaywallSoftGateWeight is 0.0). Control's skip link below
              // is unchanged either way.
              if (paywallVariant == PaywallVariant.softGate) ...[
                const SizedBox(height: 4),
                Text('ทดลองดูดวงฟรีวันนี้',
                    style: CvType.body(12,
                        weight: FontWeight.w500, color: CvColors.goldSoft)),
              ],
              CvTextLink(label: 'ข้ามไปก่อน', onPressed: onSkipped),
            ],
          ),
        ),
      ],
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
