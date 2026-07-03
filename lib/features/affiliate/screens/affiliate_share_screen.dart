import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/utils/app_icons.dart';
import '../models/affiliate_models.dart';
import '../services/affiliate_service.dart';

class AffiliateShareScreen extends StatefulWidget {
  const AffiliateShareScreen({super.key});

  @override
  State<AffiliateShareScreen> createState() => _AffiliateShareScreenState();
}

class _AffiliateShareScreenState extends State<AffiliateShareScreen> {
  final _service = AffiliateService();
  AffiliateReferralLink? _referralLink;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferralLink();
  }

  Future<void> _loadReferralLink() async {
    final link = await _service.getReferralLink();
    if (mounted) {
      setState(() {
        _referralLink = link;
        _isLoading = false;
      });
    }
  }

  void _copyLink() {
    if (_referralLink == null) return;
    Clipboard.setData(ClipboardData(text: _referralLink!.referralLink));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกลิงก์แล้ว'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareLink() {
    if (_referralLink == null) return;
    Share.share(
      'ฝากบุญออนไลน์กับ Horora! ไหว้พระ ขอพร สะดวกสบาย\n'
      'สั่งผ่านลิงก์นี้: ${_referralLink!.referralLink}\n'
      'รหัสแนะนำ: ${_referralLink!.referralCode}',
      subject: 'Horora - ฝากบุญออนไลน์',
    );
  }

  void _copyCode() {
    if (_referralLink == null) return;
    Clipboard.setData(ClipboardData(text: _referralLink!.referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกรหัสแล้ว'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SacredHeader(
              title: 'แชร์ลิงก์แนะนำ',
              overline: 'REFERRAL',
            ),
            Expanded(
              child: _isLoading
                  ? const SacredLoader.large()
                  : _referralLink == null
                      ? Center(
                          child: Text(
                            'ไม่สามารถโหลดข้อมูลได้',
                            style: SacredText.kanit(
                                color: AppColors.onBackdrop, fontSize: 15),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: AppSpacing.pagePadding.copyWith(top: 8, bottom: 24),
                          child: Column(
                    children: [
                      // Referral code card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.softPlum, AppColors.nightPlum],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.candleGold.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'รหัสแนะนำของคุณ',
                              style: SacredText.kanit(
                                  color: AppColors.onBackdropMuted, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _copyCode,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.ivorySilk,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _referralLink!.referralCode,
                                      style: SacredText.display(
                                        color: AppColors.deepText,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.copy, color: AppColors.deepGoldBrown.withValues(alpha: 0.7), size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'QR Code',
                              style: SacredText.kanit(
                                  color: AppColors.deepText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ให้เพื่อนสแกนเพื่อสั่งฝากบุญ',
                              style: SacredText.kanit(
                                  color: AppColors.mutedText, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            QrImageView(
                              data: _referralLink!.qrData,
                              version: QrVersions.auto,
                              size: 200,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: AppColors.templeIndigo,
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: AppColors.deepGoldBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Link
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.ricePaper,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warmCardBorder.withValues(alpha: 0.7),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _referralLink!.referralLink,
                                style: SacredText.kanit(
                                    color: AppColors.deepText, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: _copyLink,
                              icon: const Icon(Icons.copy,
                                  size: 20, color: AppColors.deepGoldBrown),
                              tooltip: 'คัดลอกลิงก์',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Share buttons
                      SacredPrimaryButton(
                        label: 'แชร์ให้เพื่อน',
                        onTap: _shareLink,
                        trailingSvg: AppIcons.share,
                        filled: true,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _copyLink,
                          icon: const Icon(Icons.link),
                          label: Text('คัดลอกลิงก์',
                              style: SacredText.kanit(fontSize: 16, fontWeight: FontWeight.w500)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.onBackdrop,
                            side: BorderSide(
                                color: AppColors.candleGold.withValues(alpha: 0.55)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tips
                      SacredCard(
                        radius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lightbulb,
                                    color: AppColors.deepGoldBrown, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'เทคนิคเพิ่มยอดขาย',
                                  style: SacredText.kanit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.deepGoldBrown,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '1. แชร์ลิงก์ใน Social Media เช่น LINE, Facebook\n'
                              '2. โพสต์รีวิวพร้อมรูปหลักฐานการไหว้\n'
                              '3. แนะนำแพ็คเกจที่เหมาะกับความต้องการ\n'
                              '4. เน้นวันสำคัญ เช่น วันพระ ตรุษจีน สงกรานต์',
                              style: SacredText.kanit(
                                color: AppColors.deepText,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                          ),
            ),
          ],
        ),
      ),
    );
  }
}
