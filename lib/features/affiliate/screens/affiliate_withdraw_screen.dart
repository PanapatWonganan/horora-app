import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/sacred_ui.dart';
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
        const SnackBar(content: Text('จำนวนขั้นต่ำ ฿300'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (amount > widget.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยอดเงินไม่เพียงพอ'), backgroundColor: AppColors.error),
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
              title: 'ถอนเงิน',
              overline: 'WITHDRAW',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // Balance info
            SacredCard(
              radius: 16,
              highlight: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('ยอดคงเหลือ',
                      style: SacredText.kanit(
                          color: AppColors.mutedText, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '฿${widget.availableBalance.toStringAsFixed(0)}',
                    style: SacredText.display(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepGoldBrown,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount input
            Text('จำนวนเงินที่ต้องการถอน',
                style: SacredText.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              decoration: sacredInputDecoration(
                hint: 'ขั้นต่ำ 300 บาท',
              ).copyWith(prefixText: '฿ '),
              keyboardType: TextInputType.number,
              style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 24,
                  fontWeight: FontWeight.w700),
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
            Text('วิธีรับเงิน',
                style: SacredText.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'กรุณาเพิ่มข้อมูลรับเงินก่อนถอน',
                  style: SacredText.kanit(color: AppColors.error, fontSize: 14),
                ),
              ),

            const SizedBox(height: 32),
            SacredPrimaryButton(
              label: 'ยืนยันถอนเงิน',
              onTap: _withdraw,
              filled: true,
              isLoading: _isLoading,
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

  Widget _buildMethodTile(String value, String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SacredCard(
        radius: 14,
        padding: EdgeInsets.zero,
        child: RadioListTile<String>(
          value: value,
          groupValue: _method,
          activeColor: AppColors.deepGoldBrown,
          onChanged: (v) => setState(() => _method = v!),
          title: Text(title,
              style: SacredText.kanit(
                  color: AppColors.deepText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle,
              style: SacredText.kanit(
                  color: AppColors.mutedText, fontSize: 12)),
          secondary: Icon(icon, color: AppColors.deepGoldBrown),
        ),
      ),
    );
  }
}
