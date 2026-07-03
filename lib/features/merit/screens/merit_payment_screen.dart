import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/utils/app_icons.dart';
import '../models/merit_models.dart';
import '../services/merit_service.dart';
import '../widgets/merit_ui.dart';

/// หน้าชำระเงินและ Upload slip
class MeritPaymentScreen extends StatefulWidget {
  final MeritOrder order;

  const MeritPaymentScreen({
    Key? key,
    required this.order,
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
                final Uri url = Uri.parse('https://lin.ee/ysvOInz');
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
            SacredPrimaryButton(
              label: 'กลับหน้าหลัก',
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              filled: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

  Widget _buildHeader() {
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
                const MeritOverline('Merit · ร่วมบุญอย่างสบายใจ', color: AppColors.onBackdropMuted),
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
          _buildSummaryRow('แพ็คเกจ', widget.order.package?.nameTh ?? widget.order.packageId),
          _buildSummaryRow('ผู้ขอพร', widget.order.prayerName),
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
                GestureDetector(
                  onTap: _copyPromptPayNumber,
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
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: MeritColors.price,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ยอดโอน ${widget.order.priceFormatted}',
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _slipImage = null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
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
}
