import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/utils/app_icons.dart';
import '../models/merit_models.dart';
import '../services/merit_service.dart';
import '../widgets/merit_ui.dart';
import 'merit_order_status_screen.dart';

/// หน้าชำระเงินและ Upload slip
class MeritPaymentScreen extends StatefulWidget {
  final MeritOrder order;

  // ── Optional display-only breakdown params ──────────────────────────────
  // These are purely presentational: `widget.order.price` remains the single
  // source of truth for the amount actually charged/shown in ยอดชำระ. When
  // absent (any caller other than MeritWeeklyOrderScreen), the summary renders
  // exactly as before — a single "แพ็คเกจ" line is skipped and only the
  // existing rows show.
  final String? packageName;
  final double? packagePrice;
  final List<MeritAddon>? selectedAddons;

  /// The date the merit visit is scheduled for (widget.selectedDate on the
  /// order form) — used only to render the "ขั้นตอนถัดไป" card's third step.
  /// Optional so older/other call sites keep working unchanged.
  final DateTime? scheduledDate;

  /// Thai day label (e.g. "วันศุกร์") for the scheduled date, shown alongside
  /// [scheduledDate] in the "ขั้นตอนถัดไป" card.
  final String? scheduledDayLabel;

  const MeritPaymentScreen({
    Key? key,
    required this.order,
    this.packageName,
    this.packagePrice,
    this.selectedAddons,
    this.scheduledDate,
    this.scheduledDayLabel,
  }) : super(key: key);

  @override
  State<MeritPaymentScreen> createState() => _MeritPaymentScreenState();
}

class _MeritPaymentScreenState extends State<MeritPaymentScreen> {
  final MeritService _meritService = MeritService.instance;
  final ImagePicker _picker = ImagePicker();

  File? _slipImage;
  MeritOrder? _createdOrder;
  bool _isCreatingOrder = false;
  bool _isUploading = false;
  bool _orderCreated = false;

  // Tracks whether the slip has been successfully submitted yet. Drives the
  // PopScope back-guard: before a successful submit, leaving the screen shows
  // a confirmation dialog (the order already exists server-side, so nothing
  // is "lost", but the slip step is easy to forget). After a successful
  // submit, back/pop behaves normally.
  bool _slipSubmitted = false;

  // Set right before the error-path `Navigator.pop(context)` in
  // `_createOrder()` fires, so the PopScope guard (which only listens for
  // *user-initiated* back gestures) does not intercept that programmatic pop.
  bool _leavingAfterCreateFailure = false;

  @override
  void initState() {
    super.initState();
    _createOrder();
  }

  Future<void> _createOrder() async {
    setState(() => _isCreatingOrder = true);
    try {
      // ใช้ createWeeklyOrder สำหรับ flow ตารางประจำสัปดาห์ (ไม่ต้อง login)
      final order = await _meritService.createWeeklyOrder(widget.order);
      setState(() {
        _createdOrder = order;
        _orderCreated = true;
        _isCreatingOrder = false;
      });
    } catch (e) {
      debugPrint('Error creating order: $e');
      setState(() => _isCreatingOrder = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถสร้างคำสั่งบุญได้: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
        // Mark this as a programmatic "leave" so PopScope's onPopInvokedWithResult
        // doesn't treat it as a user back-gesture and show the leave-guard dialog
        // — there is no slip to lose here, order creation itself failed.
        _leavingAfterCreateFailure = true;
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickSlipImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _slipImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เลือกรูปไม่สำเร็จ: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _takeSlipPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _slipImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ถ่ายรูปไม่สำเร็จ: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _uploadSlip() async {
    if (_slipImage == null || _createdOrder == null) return;

    setState(() => _isUploading = true);
    try {
      // ใช้ uploadWeeklySlip สำหรับ weekly order flow
      // ส่ง single-use token จากตอนสร้าง order เพื่อยืนยันสิทธิ์ (กัน IDOR)
      await _meritService.uploadWeeklySlip(
        _createdOrder!.id!,
        _slipImage!,
        uploadToken: _createdOrder!.slipUploadToken,
      );

      _slipSubmitted = true;
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _isUploading = false);
      debugPrint('Upload failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('อัพโหลดสลิปไม่สำเร็จ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: MeritColors.accentGradient,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'อนุโมทนาบุญ · ส่งหลักฐานสำเร็จ',
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'เลขที่คำสั่งบุญ: ${_createdOrder?.orderNumber}',
              style: GoogleFonts.kanit(
                color: MeritColors.accentDark,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ทีมงานจะดำเนินการไหว้ให้ภายใน 24-48 ชั่วโมง',
              style: GoogleFonts.kanit(
                color: AppColors.mutedText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse(LineOAConstants.mainOA);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B900).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00B900).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B900),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.chat_bubble, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'รับภาพและวิดีโอการทำบุญผ่าน',
                            style: GoogleFonts.kanit(
                              color: AppColors.deepText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'LINE OA @horora',
                            style: GoogleFonts.kanit(
                              color: const Color(0xFF00B900),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.open_in_new,
                      color: Color(0xFF00B900),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_createdOrder != null) ...[
              SacredPrimaryButton(
                label: 'ดูสถานะคำสั่งบุญ',
                onTap: () {
                  // ใช้วัด/แพ็คตามที่ผู้ใช้เลือกจริงจาก widget.order —
                  // backend คืน default มาเมื่อไม่รู้จัก id ของ flow รายสัปดาห์
                  final displayOrder = _createdOrder!.copyWith(
                    location: widget.order.location,
                    package: widget.order.package,
                    price: widget.order.price,
                    prayerName: widget.order.prayerName,
                    prayerWish: widget.order.prayerWish,
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          MeritOrderStatusScreen(order: displayOrder),
                    ),
                  );
                },
                filled: true,
              ),
              const SizedBox(height: 12),
            ],
            SacredPrimaryButton(
              label: 'กลับหน้าหลัก',
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              filled: false,
            ),
          ],
        ),
      ),
    );
  }

  void _copyPromptPayNumber() {
    Clipboard.setData(const ClipboardData(text: '2251635334'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกเลขบัญชีกสิกรแล้ว'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyTransferAmount() {
    // Copy the raw numeric amount (no currency symbol/formatting) so it can
    // be pasted straight into a banking app's transfer-amount field.
    Clipboard.setData(
      ClipboardData(text: widget.order.price.toStringAsFixed(0)),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกยอดโอนแล้ว'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Guards leaving the screen before the slip has been submitted. The order
  /// already exists server-side by this point (created in `_createOrder` on
  /// entry), so nothing is lost — but the slip step is easy to forget, so we
  /// confirm before letting the user navigate away.
  ///
  /// Returns true if the pop should proceed.
  Future<bool> _confirmLeave() async {
    if (_slipSubmitted || _leavingAfterCreateFailure) return true;

    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'ยังไม่ได้แนบสลิป',
          style: GoogleFonts.kanit(
            color: AppColors.deepText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'คำสั่งบุญของคุณถูกบันทึกไว้แล้ว โอนแล้วกลับมาแนบสลิปได้ที่ ประวัติการร่วมบุญ',
          style: GoogleFonts.kanit(
            color: AppColors.mutedText,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'ออกไปก่อน',
              style: GoogleFonts.kanit(color: AppColors.mutedText),
            ),
          ),
          SacredPrimaryButton(
            label: 'อยู่ต่อ',
            onTap: () => Navigator.of(context).pop(true),
            filled: true,
          ),
        ],
      ),
    );
    return leave == false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _slipSubmitted || _leavingAfterCreateFailure,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _confirmLeave();
        if (shouldPop && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        body: SilkCandleBackdrop(
          warmHero: false,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isCreatingOrder
                      ? const SacredLoader.large(label: 'กำลังสร้างคำสั่งบุญ…')
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOrderSummary(),
                              const SizedBox(height: 24),
                              _buildPromptPaySection(),
                              const SizedBox(height: 24),
                              _buildSlipUploadSection(),
                              const SizedBox(height: 24),
                              _buildNextStepsCard(),
                              const SizedBox(height: 32),
                              _buildSubmitButton(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              if (_slipSubmitted || _leavingAfterCreateFailure) {
                Navigator.pop(context);
                return;
              }
              final shouldPop = await _confirmLeave();
              if (shouldPop && mounted) Navigator.pop(context);
            },
            icon: const SvgIcon(AppIcons.arrowBack, size: 20, color: AppColors.onBackdrop),
            tooltip: 'ย้อนกลับ',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SacredOverline('Merit · ร่วมบุญอย่างสบายใจ', color: AppColors.onBackdropMuted, fontSize: 12, letterSpacing: 2.8),
                const SizedBox(height: 2),
                Text(
                  'ชำระเงิน',
                  style: GoogleFonts.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 20,
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

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สรุปคำสั่งบุญ',
            style: GoogleFonts.kanit(
              color: AppColors.deepText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(color: AppColors.divider, height: 24),
          if (_createdOrder?.orderNumber != null)
            _buildSummaryRow('เลขที่', _createdOrder!.orderNumber!, isHighlight: true),
          _buildSummaryRow('สถานที่', widget.order.location?.nameTh ?? widget.order.locationId),
          if (widget.packageName == null)
            _buildSummaryRow('แพ็คเกจ', widget.order.package?.nameTh ?? widget.order.packageId),
          _buildSummaryRow('ผู้ขอพร', widget.order.prayerName),
          if (widget.packageName != null) ...[
            const Divider(color: AppColors.divider, height: 24),
            _buildSummaryRow(
              'แพ็คเกจ',
              '${widget.packageName} · ฿${(widget.packagePrice ?? 0).toStringAsFixed(0)}',
            ),
            for (final addon in widget.selectedAddons ?? const <MeritAddon>[])
              _buildSummaryRow(addon.name, '+${addon.priceFormatted}'),
          ],
          const Divider(color: AppColors.divider, height: 24),
          _buildSummaryRow('ยอดชำระ', widget.order.priceFormatted, isBold: true, isPrice: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isPrice = false, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.kanit(
              color: AppColors.mutedText,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: isPrice
                ? GoogleFonts.fraunces(
                    color: MeritColors.price,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  )
                : GoogleFonts.kanit(
                    color: isHighlight ? MeritColors.accentDark : AppColors.deepText,
                    fontSize: 14,
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptPaySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MeritColors.accent.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MeritColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.deepGoldBrown,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ธ.กสิกรไทย',
                      style: GoogleFonts.kanit(
                        color: AppColors.deepText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'โอนเงินผ่านบัญชีธนาคาร',
                      style: GoogleFonts.kanit(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MeritColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MeritColors.accent.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/promptpay_qr.jpg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  MeritService.promptPayName,
                  style: GoogleFonts.kanit(
                    color: AppColors.deepText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  button: true,
                  label: 'คัดลอกเลขบัญชี',
                  child: GestureDetector(
                    onTap: _copyPromptPayNumber,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      // ≥44px hit area padded around the visually-unchanged
                      // number + icon (was a small tap target sitting right
                      // next to the number).
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            MeritService.promptPayNumber,
                            style: GoogleFonts.fraunces(
                              color: AppColors.deepGoldBrown,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy, color: AppColors.deepGoldBrown, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  button: true,
                  label: 'คัดลอกยอดโอน',
                  child: GestureDetector(
                    onTap: _copyTransferAmount,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: MeritColors.price,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ยอดโอน ${widget.order.priceFormatted}',
                            style: GoogleFonts.kanit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy, color: Colors.white, size: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlipUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'อัพโหลดหลักฐานการโอน',
          style: GoogleFonts.kanit(
            color: AppColors.onBackdrop,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (_slipImage != null)
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_slipImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                // Anchored flush to the Stack's own edges (0, 0) rather
                // than the old (8, 8) inset so the full 44x44 hit area
                // stays inside the Stack's clip bounds (default
                // Clip.hardEdge would otherwise trim a negative-offset
                // box). The visible 28px chip is centered inside this
                // region via alignment, so it sits ~6px further from the
                // corner than before — a small, deliberate trade-off to
                // avoid clipping the accessible hit area.
                top: 0,
                right: 0,
                child: Semantics(
                  button: true,
                  label: 'ลบรูปหลักฐานการโอน',
                  child: GestureDetector(
                    onTap: () => setState(() => _slipImage = null),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.photo_library,
                  label: 'เลือกรูป',
                  onTap: _pickSlipImage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.camera_alt,
                  label: 'ถ่ายรูป',
                  onTap: _takeSlipPhoto,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MeritColors.accent.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.deepGoldBrown, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _slipImage != null && _orderCreated && !_isUploading;

    return SacredPrimaryButton(
      label: 'ส่งหลักฐานการโอน',
      onTap: _uploadSlip,
      enabled: canSubmit,
      filled: true,
      isLoading: _isUploading,
    );
  }

  /// "ขั้นตอนถัดไป" — a calm, ivory reassurance card walking the user through
  /// what happens after they submit the slip. Purely informational; reuses
  /// the existing ivory/gold-hairline card language (matches
  /// [_buildOrderSummary] / [MeritWishInput]) rather than inventing a new
  /// visual style.
  Widget _buildNextStepsCard() {
    final scheduledDate = widget.scheduledDate;
    final dayLabel = widget.scheduledDayLabel;
    final String thirdStep;
    if (scheduledDate != null && dayLabel != null) {
      final dateStr = DateFormat('d MMMM yyyy', 'th_TH').format(scheduledDate);
      thirdStep = 'ไหว้ให้ใน$dayLabelที่ $dateStr พร้อมส่งรูป/วิดีโอยืนยันถึงคุณ';
    } else if (scheduledDate != null) {
      final dateStr = DateFormat('d MMMM yyyy', 'th_TH').format(scheduledDate);
      thirdStep = 'ไหว้ให้ในวันที่ $dateStr พร้อมส่งรูป/วิดีโอยืนยันถึงคุณ';
    } else {
      thirdStep = 'ไหว้ให้ตามกำหนด พร้อมส่งรูป/วิดีโอยืนยันถึงคุณ';
    }

    final steps = <String>[
      'โอนเงินและแนบสลิปด้านบน',
      'ทีมงานตรวจสอบและยืนยันภายใน 24 ชม.',
      thirdStep,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ivorySilk,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MeritColors.accent.withValues(alpha: 0.35)),
        boxShadow: MeritUI.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ขั้นตอนถัดไป',
            style: GoogleFonts.kanit(
              color: AppColors.deepText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < steps.length; i++) ...[
            _buildNextStepRow(i + 1, steps[i]),
            if (i != steps.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildNextStepRow(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: MeritColors.accentGradient),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: GoogleFonts.kanit(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
