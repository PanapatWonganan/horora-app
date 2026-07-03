import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/celestial_effects.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/utils/app_icons.dart';
import '../models/merit_models.dart';
import '../widgets/merit_ui.dart';

/// หน้าสถานะคำสั่งบุญ (Merit order status) — "ผ้าไหม + แสงเทียน".
///
/// The trust + emotional payoff surface of the merit flow. It shows, for a
/// single [MeritOrder]:
///   • the destination temple/foundation (where the merit actually goes),
///   • a candle-lit status timeline (คำสั่งบุญ → ทำบุญ → หลักฐาน → อนุโมทนา),
///   • the proof gallery (ดูหลักฐาน) — images/video from the visit,
///   • a shareable digital ใบอนุโมทนา certificate once completed.
///
/// This screen is purely presentational: it reads the passed-in [order] and
/// renders it. It does NOT call any network/auth/payment APIs. Where the order
/// has no proof yet (early statuses), candle-gradient placeholders + reassuring
/// copy are shown instead.
class MeritOrderStatusScreen extends StatelessWidget {
  final MeritOrder order;

  const MeritOrderStatusScreen({super.key, required this.order});

  // ── Derive timeline position from the order status ──────────────────────────

  int get _currentStepIndex {
    switch (order.status) {
      case MeritOrderStatus.pending:
        return 0;
      case MeritOrderStatus.paid:
        return 1;
      case MeritOrderStatus.processing:
        return 2;
      case MeritOrderStatus.completed:
        return 4; // all four steps done
      case MeritOrderStatus.cancelled:
        return 0;
    }
  }

  bool get _isCompleted => order.status == MeritOrderStatus.completed;

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('d MMM yyyy · HH:mm', 'th').format(dt);
  }

  List<MeritTimelineStep> _buildSteps() {
    return [
      MeritTimelineStep(
        title: 'รับคำสั่งบุญแล้ว',
        subtitle: 'เราได้รับคำสั่งบุญของคุณเรียบร้อย',
        timestamp: _fmt(order.createdAt),
        icon: AppIcons.checkCircle,
      ),
      MeritTimelineStep(
        title: 'ยืนยันการร่วมบุญ',
        subtitle: 'ยืนยันยอดร่วมบุญและจัดเตรียมของถวาย',
        timestamp: order.paidAt != null ? _fmt(order.paidAt) : null,
        icon: AppIcons.heart,
      ),
      const MeritTimelineStep(
        title: 'ทีมงานเดินทางไปทำบุญ',
        subtitle: 'นำของถวายไปยังวัด/ศาล และกล่าวคำอธิษฐานแทนคุณ',
        icon: AppIcons.temple,
      ),
      const MeritTimelineStep(
        title: 'บันทึกภาพ/วิดีโอหลักฐาน',
        subtitle: 'ถ่ายภาพและวิดีโอขณะถวาย เพื่อส่งให้คุณ',
        icon: AppIcons.camera,
      ),
      MeritTimelineStep(
        title: 'ออกใบอนุโมทนา',
        subtitle: 'ทำบุญสำเร็จ พร้อมใบอนุโมทนาและเลขอ้างอิง',
        timestamp: order.completedAt != null ? _fmt(order.completedAt) : null,
        icon: AppIcons.sparkle,
      ),
    ];
  }

  List<MeritProofItem> _buildProofs() {
    // Real proofs from the completed order, if present.
    final urls = order.proofUrls ?? const [];
    if (urls.isNotEmpty) {
      return [
        if (order.proofVideoUrl != null)
          MeritProofItem(
            imageUrl: order.proofVideoUrl,
            isVideo: true,
            caption: 'วิดีโอขณะถวาย ณ ${order.location?.nameTh ?? 'สถานที่ปลายทาง'}',
          ),
        ...urls.map(
          (u) => MeritProofItem(
            imageUrl: u,
            caption: 'ภาพหลักฐานการทำบุญ ณ ${order.location?.nameTh ?? 'สถานที่ปลายทาง'}',
          ),
        ),
      ];
    }

    // UI-only placeholder proofs for completed orders without real URLs yet.
    // TODO(backend): once the proof endpoint returns media, these placeholders
    // are bypassed by the `urls.isNotEmpty` branch above.
    // Muted temple-tone placeholders (gilt, bronze, plum-grey, bodhi-green) —
    // no candy pastels, so unloaded proofs still read as calm/premium.
    const gradients = [
      [Color(0xFFF2C879), Color(0xFFFFB0A0)], // gilt → warm salmon
      [Color(0xFFBFA06B), Color(0xFF8C86A8)], // bronze → plum-grey
      [Color(0xFFFFD7C2), Color(0xFFF2C879)], // peach-sand → gilt
      [Color(0xFF8FA98F), Color(0xFF8C86A8)], // bodhi-green tint → plum-grey
      [Color(0xFFFFB0A0), Color(0xFFBFA06B)], // warm salmon → bronze
      [Color(0xFF8C86A8), Color(0xFF8FA98F)], // plum-grey → bodhi-green tint
    ];
    final temple = order.location?.nameTh ?? 'สถานที่ปลายทาง';
    return List.generate(
      6,
      (i) => MeritProofItem(
        isVideo: i == 0,
        placeholderGradient: gradients[i % gradients.length],
        caption: i == 0
            ? 'วิดีโอขณะถวาย ณ $temple'
            : 'ภาพหลักฐานการทำบุญ ณ $temple',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temple = order.location?.nameTh ?? order.locationId;
    final belief = order.location?.belief ?? 'ขอพร เสริมสิริมงคล';

    return Scaffold(
      body: SilkCandleBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StaggeredReveal(
                        index: 0,
                        child: _buildOrderSummary(temple),
                      ),
                      const SizedBox(height: 22),
                      StaggeredReveal(
                        index: 1,
                        child: MeritDestinationBanner(
                          templeName: temple,
                          belief: belief,
                          subline: order.package?.nameTh != null
                              ? 'ชุดบุญ: ${order.package!.nameTh}'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const StaggeredReveal(
                        index: 2,
                        child: MeritSectionTitle(
                          'สถานะคำสั่งบุญ',
                          overline: 'Merit progress',
                          icon: AppIcons.clock,
                        ),
                      ),
                      const SizedBox(height: 14),
                      StaggeredReveal(
                        index: 3,
                        child: MeritStatusTimeline(
                          steps: _buildSteps(),
                          currentIndex: _currentStepIndex,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Proof + อนุโมทนา only once completed.
                      if (_isCompleted) ...[
                        const StaggeredReveal(
                          index: 4,
                          child: MeritSectionTitle(
                            'หลักฐานการทำบุญ',
                            overline: 'Proof of merit',
                            icon: AppIcons.gallery,
                          ),
                        ),
                        const SizedBox(height: 14),
                        StaggeredReveal(
                          index: 5,
                          child: MeritProofGallery(items: _buildProofs()),
                        ),
                        const SizedBox(height: 28),
                        StaggeredReveal(
                          index: 6,
                          child: MeritAnumothanaCard(
                            templeName: temple,
                            dedicatedTo: order.prayerName,
                            wish: order.prayerWish,
                            referenceNo: order.orderNumber ?? _fallbackRef(),
                            completedAt: _fmt(order.completedAt ?? order.createdAt),
                            onViewProof: () => _proofHint(context),
                            onShare: () => _showShareSheet(context, temple),
                          ),
                        ),
                      ] else ...[
                        StaggeredReveal(
                          index: 4,
                          child: _buildPendingProofNote(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const StaggeredReveal(
                        index: 7,
                        child: MeritTrustStrip(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fallbackRef() {
    // Deterministic, human-readable reference derived from existing fields so we
    // never invent randomness (no real id yet → readable placeholder).
    final base = (order.id ?? order.prayerName).hashCode.abs() % 1000000;
    return 'MERIT-${base.toString().padLeft(6, '0')}';
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const SvgIcon(AppIcons.arrowBack, size: 20, color: AppColors.onBackdrop),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SacredOverline('Merit · คำสั่งบุญ', color: AppColors.onBackdropMuted, fontSize: 12, letterSpacing: 2.8),
                const SizedBox(height: 2),
                Text(
                  'บุญของฉัน',
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
        ],
      ),
    );
  }

  Widget _buildOrderSummary(String temple) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(MeritUI.cardRadius),
        border: Border.all(color: AppColors.divider),
        boxShadow: MeritUI.softShadow(),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เลขคำสั่งบุญ',
                style: GoogleFonts.kanit(
                  color: AppColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                order.orderNumber ?? _fallbackRef(),
                style: GoogleFonts.fraunces(
                  color: AppColors.deepText,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          _StatusPill(status: order.status),
        ],
      ),
    );
  }

  Widget _buildPendingProofNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(MeritUI.cardRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MeritColors.accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const SvgIcon(AppIcons.camera, size: 28, color: MeritColors.accentDark),
          ),
          const SizedBox(height: 14),
          Text(
            'หลักฐานจะปรากฏที่นี่เมื่อทำบุญสำเร็จ',
            textAlign: TextAlign.center,
            style: GoogleFonts.kanit(
              color: AppColors.deepText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ทีมงานจะส่งภาพและวิดีโอขณะถวาย พร้อมใบอนุโมทนาให้คุณทันทีที่เสร็จสิ้น',
            textAlign: TextAlign.center,
            style: GoogleFonts.kanit(
              color: AppColors.mutedText,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  void _proofHint(BuildContext context) {
    // The gallery already sits above this card; surface a gentle hint instead
    // of complex scroll control. Tapping a thumb opens the fullscreen viewer.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'แตะภาพในแกลเลอรีด้านบนเพื่อดูหลักฐานแบบเต็มจอ',
          style: GoogleFonts.kanit(color: AppColors.deepText),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, String temple) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: MeritColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const SvgIcon(AppIcons.share, size: 32, color: MeritColors.accentDark),
            const SizedBox(height: 14),
            Text(
              'แบ่งปันอนุโมทนา',
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ขออนุโมทนาบุญร่วมกัน 🙏\nทำบุญ ณ $temple ผ่านดวงใจเรียบร้อยแล้ว',
              textAlign: TextAlign.center,
              style: GoogleFonts.kanit(
                color: AppColors.mutedText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // TODO(integration): wire to share_plus / image export when ready.
            SizedBox(
              width: double.infinity,
              child: MeritPressScale(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: MeritUI.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: MeritUI.goldGlow(blur: 14, y: 6, alpha: 0.4),
                  ),
                  child: Center(
                    child: Text(
                      'เรียบร้อย',
                      style: GoogleFonts.kanit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status pill matching the merit accent system.
class _StatusPill extends StatelessWidget {
  final MeritOrderStatus status;

  const _StatusPill({required this.status});

  Color get _color {
    switch (status) {
      case MeritOrderStatus.pending:
        return MeritColors.accentDark;
      case MeritOrderStatus.paid:
        return AppColors.info;
      case MeritOrderStatus.processing:
        return MeritColors.accent;
      case MeritOrderStatus.completed:
        return AppColors.success;
      case MeritOrderStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            status.displayName,
            style: GoogleFonts.kanit(
              color: _color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
