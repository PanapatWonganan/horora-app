import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
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
        backgroundColor: Colors.green,
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
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แชร์ลิงก์แนะนำ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _referralLink == null
              ? const Center(child: Text('ไม่สามารถโหลดข้อมูลได้'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Referral code card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'รหัสแนะนำของคุณ',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _copyCode,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _referralLink!.referralCode,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.copy, color: Colors.white70, size: 20),
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
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'QR Code',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'ให้เพื่อนสแกนเพื่อสั่งฝากบุญ',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            QrImageView(
                              data: _referralLink!.qrData,
                              version: QrVersions.auto,
                              size: 200,
                              backgroundColor: Colors.white,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.roundedOuter,
                                color: AppColors.primary,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.roundedOuter,
                                color: AppColors.secondary,
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
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _referralLink!.referralLink,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: _copyLink,
                              icon: const Icon(Icons.copy, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Share buttons
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _shareLink,
                          icon: const Icon(Icons.share),
                          label: const Text('แชร์ให้เพื่อน', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _copyLink,
                          icon: const Icon(Icons.link),
                          label: const Text('คัดลอกลิงก์', style: TextStyle(fontSize: 16)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tips
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.info.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: AppColors.info, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'เทคนิคเพิ่มยอดขาย',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.info,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '1. แชร์ลิงก์ใน Social Media เช่น LINE, Facebook\n'
                              '2. โพสต์รีวิวพร้อมรูปหลักฐานการไหว้\n'
                              '3. แนะนำแพ็คเกจที่เหมาะกับความต้องการ\n'
                              '4. เน้นวันสำคัญ เช่น วันพระ ตรุษจีน สงกรานต์',
                              style: TextStyle(fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
