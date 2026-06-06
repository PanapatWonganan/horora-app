import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/affiliate_models.dart';
import '../services/affiliate_service.dart';

class AffiliateWithdrawScreen extends StatefulWidget {
  final double availableBalance;
  final AffiliateModel affiliate;

  const AffiliateWithdrawScreen({
    super.key,
    required this.availableBalance,
    required this.affiliate,
  });

  @override
  State<AffiliateWithdrawScreen> createState() => _AffiliateWithdrawScreenState();
}

class _AffiliateWithdrawScreenState extends State<AffiliateWithdrawScreen> {
  final _service = AffiliateService();
  final _amountController = TextEditingController();
  String _method = 'promptpay';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-select method based on available info
    if (widget.affiliate.hasPromptpay) {
      _method = 'promptpay';
    } else if (widget.affiliate.hasBankInfo) {
      _method = 'bank_transfer';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('จำนวนขั้นต่ำ ฿300'), backgroundColor: Colors.red),
      );
      return;
    }

    if (amount > widget.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยอดเงินไม่เพียงพอ'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _service.withdraw(amount: amount, method: _method);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'ส่งคำขอถอนเงินสำเร็จ'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['message'] ?? 'เกิดข้อผิดพลาด'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ถอนเงิน'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  const Text('ยอดคงเหลือ', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    '฿${widget.availableBalance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount input
            const Text('จำนวนเงินที่ต้องการถอน', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                prefixText: '฿ ',
                hintText: 'ขั้นต่ำ 300 บาท',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Quick amount buttons
            Wrap(
              spacing: 8,
              children: [300, 500, 1000].map((amount) {
                return ActionChip(
                  label: Text('฿$amount'),
                  onPressed: widget.availableBalance >= amount
                      ? () => _amountController.text = '$amount'
                      : null,
                );
              }).toList()
                ..add(
                  ActionChip(
                    label: const Text('ทั้งหมด'),
                    onPressed: widget.availableBalance >= 300
                        ? () => _amountController.text = '${widget.availableBalance.toInt()}'
                        : null,
                  ),
                ),
            ),
            const SizedBox(height: 24),

            // Payment method
            const Text('วิธีรับเงิน', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (widget.affiliate.hasPromptpay)
              _buildMethodTile(
                'promptpay',
                'พร้อมเพย์',
                widget.affiliate.promptpayNumber ?? '',
                Icons.phone_android,
              ),
            if (widget.affiliate.hasBankInfo)
              _buildMethodTile(
                'bank_transfer',
                'โอนธนาคาร',
                '${widget.affiliate.bankName} ${widget.affiliate.bankAccountNumber}',
                Icons.account_balance,
              ),
            if (!widget.affiliate.hasPromptpay && !widget.affiliate.hasBankInfo)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'กรุณาเพิ่มข้อมูลรับเงินก่อนถอน',
                  style: TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _withdraw,
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
                    : const Text('ยืนยันถอนเงิน', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(String value, String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<String>(
        value: value,
        groupValue: _method,
        onChanged: (v) => setState(() => _method = v!),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        secondary: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
