import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครเป็นตัวแทน'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.handshake, color: Colors.white, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'เป็นตัวแทน Horora',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'แชร์ลิงก์ให้เพื่อน เมื่อเพื่อนสั่งฝากบุญ\nคุณได้รับค่าแนะนำสูงสุด 23%',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Commission rates
              const Text(
                'อัตราค่าแนะนำ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildRateRow('ไหว้มงคล (฿199)', '15%'),
              _buildRateRow('ไหว้เสริมดวง (฿399)', '15%'),
              _buildRateRow('ไหว้ครบเครื่อง (฿699)', '12%'),
              _buildRateRow('VIP บูชาใหญ่ (฿1,299)', '10%'),
              const SizedBox(height: 8),
              Text(
                '* อัตราเริ่มต้น ระดับ Bronze - ยิ่งขายมาก ยิ่งได้มาก!',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),

              // Payment method
              const Text(
                'ข้อมูลรับเงิน',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
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
                  decoration: const InputDecoration(
                    labelText: 'เลขพร้อมเพย์',
                    hintText: 'เบอร์โทรหรือเลขบัตรประชาชน',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกเลขพร้อมเพย์' : null,
                ),
              ] else ...[
                TextFormField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'ธนาคาร',
                    hintText: 'เช่น กสิกรไทย, กรุงเทพ',
                    prefixIcon: Icon(Icons.account_balance),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อธนาคาร' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bankAccountController,
                  decoration: const InputDecoration(
                    labelText: 'เลขบัญชี',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกเลขบัญชี' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bankAccountNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อบัญชี',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
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
                    backgroundColor: AppColors.primary,
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
    );
  }

  Widget _buildRateRow(String packageName, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(packageName, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              rate,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
