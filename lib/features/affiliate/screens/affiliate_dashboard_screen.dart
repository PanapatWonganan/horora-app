import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/affiliate_models.dart';
import '../services/affiliate_service.dart';
import 'affiliate_share_screen.dart';
import 'affiliate_withdraw_screen.dart';

class AffiliateDashboardScreen extends StatefulWidget {
  const AffiliateDashboardScreen({super.key});

  @override
  State<AffiliateDashboardScreen> createState() => _AffiliateDashboardScreenState();
}

class _AffiliateDashboardScreenState extends State<AffiliateDashboardScreen> {
  final _service = AffiliateService();
  AffiliateDashboard? _dashboard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final dashboard = await _service.getDashboard();
    if (mounted) {
      setState(() {
        _dashboard = dashboard;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ระบบตัวแทน'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AffiliateShareScreen()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dashboard == null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBalanceCard(),
                        const SizedBox(height: 16),
                        _buildStatsGrid(),
                        const SizedBox(height: 16),
                        _buildTierCard(),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildRecentCommissions(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('ไม่สามารถโหลดข้อมูลได้'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboard,
            child: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    final stats = _dashboard!.stats;
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ยอดคงเหลือ',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '฿${stats.availableBalance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (stats.pendingCommission > 0)
            Text(
              'รอดำเนินการ ฿${stats.pendingCommission.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AffiliateWithdrawScreen(
                          availableBalance: stats.availableBalance,
                          affiliate: _dashboard!.affiliate,
                        ),
                      ),
                    );
                    _loadDashboard();
                  },
                  icon: const Icon(Icons.account_balance_wallet, size: 18),
                  label: const Text('ถอนเงิน'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AffiliateShareScreen()),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('แชร์ลิงก์'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _dashboard!.stats;
    return Row(
      children: [
        Expanded(child: _buildStatItem('ออเดอร์ทั้งหมด', '${stats.totalOrders}', Icons.receipt_long)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('คอมมิชชั่นรวม', '฿${stats.totalEarned.toStringAsFixed(0)}', Icons.monetization_on)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('เดือนนี้', '฿${stats.monthlyEarnings.toStringAsFixed(0)}', Icons.trending_up)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard() {
    final stats = _dashboard!.stats;
    final tierColor = _getTierColor(stats.tier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tierColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tierColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.workspace_premium, color: tierColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ระดับ ${_getTierLabel(stats.tier)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: tierColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ออเดอร์เดือนนี้: ${stats.monthlyOrders} รายการ',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  _getNextTierMessage(stats.tier, stats.monthlyOrders),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เมนู',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildActionItem(
          icon: Icons.history,
          title: 'ประวัติคอมมิชชั่น',
          subtitle: 'ดูรายละเอียดค่าคอมฯ ทั้งหมด',
          onTap: () {
            // TODO: Navigate to commission history
          },
        ),
        _buildActionItem(
          icon: Icons.account_balance,
          title: 'ประวัติถอนเงิน',
          subtitle: 'ดูสถานะการถอนเงิน',
          onTap: () {
            // TODO: Navigate to withdrawal history
          },
        ),
        _buildActionItem(
          icon: Icons.people,
          title: 'ผู้ใช้ที่แนะนำ',
          subtitle: '${_dashboard!.stats.totalReferrals} คน',
          onTap: () {
            // TODO: Navigate to referred users
          },
        ),
        _buildActionItem(
          icon: Icons.credit_card,
          title: 'ข้อมูลรับเงิน',
          subtitle: _dashboard!.affiliate.hasBankInfo
              ? '${_dashboard!.affiliate.bankName} ${_dashboard!.affiliate.bankAccountNumber}'
              : 'ยังไม่ได้ตั้งค่า',
          onTap: () {
            // TODO: Navigate to payment info edit
          },
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentCommissions() {
    final commissions = _dashboard!.recentCommissions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'คอมมิชชั่นล่าสุด',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (commissions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Text(
              'ยังไม่มีคอมมิชชั่น\nเริ่มแชร์ลิงก์เพื่อรับค่าแนะนำ!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          )
        else
          ...commissions.map((c) => _buildCommissionItem(c)),
      ],
    );
  }

  Widget _buildCommissionItem(AffiliateCommissionModel commission) {
    final statusColor = switch (commission.status) {
      'approved' => AppColors.success,
      'paid' => AppColors.info,
      'cancelled' => AppColors.error,
      _ => AppColors.warning,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.receipt, color: statusColor, size: 20),
        ),
        title: Text(
          commission.orderLocationName,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          '${commission.rateFormatted} of ${commission.orderAmountFormatted} - ${commission.statusLabel}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          commission.commissionFormatted,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ),
    );
  }

  Color _getTierColor(String tier) => switch (tier) {
    'platinum' => const Color(0xFF607D8B),
    'gold' => const Color(0xFFFFB300),
    'silver' => const Color(0xFF9E9E9E),
    _ => const Color(0xFFCD7F32),
  };

  String _getTierLabel(String tier) => switch (tier) {
    'platinum' => 'Platinum',
    'gold' => 'Gold',
    'silver' => 'Silver',
    _ => 'Bronze',
  };

  String _getNextTierMessage(String tier, int monthlyOrders) {
    // Clamp at 0 so users who already exceeded the threshold (but haven't been
    // promoted yet) don't see a negative "remaining orders" count.
    int remaining(int target) => (target - monthlyOrders).clamp(0, target);
    return switch (tier) {
      'platinum' => 'คุณอยู่ระดับสูงสุดแล้ว!',
      'gold' => 'อีก ${remaining(50)} ออเดอร์ถึง Platinum',
      'silver' => 'อีก ${remaining(31)} ออเดอร์ถึง Gold',
      _ => 'อีก ${remaining(11)} ออเดอร์ถึง Silver',
    };
  }
}
