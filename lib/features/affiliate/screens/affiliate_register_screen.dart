import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/sacred_ui.dart';
import '../services/affiliate_service.dart';
import 'affiliate_dashboard_screen.dart';

class AffiliateRegisterScreen extends StatefulWidget {
  const AffiliateRegisterScreen({super.key});

  @override
  State<AffiliateRegisterScreen> createState() => _AffiliateRegisterScreenState();
}

class _AffiliateRegisterScreenState extends State<AffiliateRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AffiliateService();
  bool _isLoading = false;

  String _paymentMethod = 'promptpay';
  final _promptpayController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankAccountNameController = TextEditingController();

  @override
  void dispose() {
    _promptpayController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankAccountNameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final affiliate = await _service.register(
      bankName: _paymentMethod == 'bank' ? _bankNameController.text : null,
      bankAccountNumber: _paymentMethod == 'bank' ? _bankAccountController.text : null,
      bankAccountName: _paymentMethod == 'bank' ? _bankAccountNameController.text : null,
      promptpayNumber: _paymentMethod == 'promptpay' ? _promptpayController.text : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (affiliate != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('สมัครสำเร็จ! รหัสแนะนำของคุณ: ${affiliate.referralCode}'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AffiliateDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถสมัครได้ กรุณาลองใหม่'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SacredScaffold(
      showSpecks: false,
      body: SafeArea(
        child: Column(
          children: [
            const SacredHeader(
              title: 'สมัครเป็นตัวแทน',
              overline: 'JOIN AFFILIATE',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              // Benefits card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.handshake, color: AppColors.candleGold, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'เป็นตัวแทน Horora',
                      style: SacredText.kanit(
                        color: AppColors.onBackdrop,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'แชร์ลิงก์ให้เพื่อน เมื่อเพื่อนสั่งฝากบุญ\nคุณได้รับค่าแนะนำสูงสุด 23%',
                      style: SacredText.kanit(
                          color: AppColors.onBackdropMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Commission rates
              Text(
                'อัตราค่าแนะนำ',
                style: SacredText.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildRateRow('ไหว้มงคล (฿199)', '15%'),
              _buildRateRow('ไหว้เสริมดวง (฿399)', '15%'),
              _buildRateRow('ไหว้ครบเครื่อง (฿699)', '12%'),
              _buildRateRow('VIP บูชาใหญ่ (฿1,299)', '10%'),
              const SizedBox(height: 8),
              Text(
                '* อัตราเริ่มต้น ระดับ Bronze - ยิ่งขายมาก ยิ่งได้มาก!',
                style: SacredText.kanit(
                    fontSize: 12, color: AppColors.onBackdropMuted),
              ),
              const SizedBox(height: 24),

              // Payment method
              Text(
                'ข้อมูลรับเงิน',
                style: SacredText.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  foregroundColor: AppColors.onBackdropMuted,
                  selectedForegroundColor: AppColors.deepText,
                  selectedBackgroundColor: AppColors.candleGold.withValues(alpha: 0.85),
                  side: BorderSide(
                      color: AppColors.candleGold.withValues(alpha: 0.5)),
                ),
                segments: const [
                  ButtonSegment(value: 'promptpay', label: Text('พร้อมเพย์')),
                  ButtonSegment(value: 'bank', label: Text('โอนธนาคาร')),
                ],
                selected: {_paymentMethod},
                onSelectionChanged: (v) => setState(() => _paymentMethod = v.first),
              ),
              const SizedBox(height: 16),

              if (_paymentMethod == 'promptpay') ...[
                TextFormField(
                  controller: _promptpayController,
                  style: SacredText.kanit(color: AppColors.deepText, fontSize: 14),
                  decoration: sacredInputDecoration(
                    label: 'เลขพร้อมเพย์',
                    hint: 'เบอร์โทรหรือเลขบัตรประชาชน',
                    prefixIcon: const Icon(Icons.phone_android,
                        color: AppColors.deepGoldBrown),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกเลขพร้อมเพย์' : null,
                ),
              ] else ...[
                TextFormField(
                  controller: _bankNameController,
                  style: SacredText.kanit(color: AppColors.deepText, fontSize: 14),
                  decoration: sacredInputDecoration(
                    label: 'ธนาคาร',
                    hint: 'เช่น กสิกรไทย, กรุงเทพ',
                    prefixIcon: const Icon(Icons.account_balance,
                        color: AppColors.deepGoldBrown),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อธนาคาร' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bankAccountController,
                  style: SacredText.kanit(color: AppColors.deepText, fontSize: 14),
                  decoration: sacredInputDecoration(
                    label: 'เลขบัญชี',
                    prefixIcon: const Icon(Icons.credit_card,
                        color: AppColors.deepGoldBrown),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกเลขบัญชี' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bankAccountNameController,
                  style: SacredText.kanit(color: AppColors.deepText, fontSize: 14),
                  decoration: sacredInputDecoration(
                    label: 'ชื่อบัญชี',
                    prefixIcon: const Icon(Icons.person,
                        color: AppColors.deepGoldBrown),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อบัญชี' : null,
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepGoldBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('สมัครเป็นตัวแทน', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateRow(String packageName, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(packageName,
              style: SacredText.kanit(
                  color: AppColors.onBackdrop, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.candleGold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              rate,
              style: SacredText.kanit(
                color: AppColors.candleGold,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
