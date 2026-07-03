import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/sacred_ui.dart';
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
    return SacredScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SacredHeader(
              title: 'ระบบตัวแทน',
              overline: 'AFFILIATE',
              trailing: Semantics(
                button: true,
                label: 'แชร์ลิงก์แนะนำเพื่อน',
                child: SizedBox(
                  // Host is a real 44x44 (matches SacredHeader's back chip,
                  // which has the same padding room to absorb it without
                  // the header growing visibly). The 40x40 visual chip is
                  // centered inside.
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AffiliateShareScreen()),
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.onBackdrop.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: AppColors.onBackdrop.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.share,
                          size: 18,
                          color: AppColors.onBackdrop,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const SacredLoader.large()
                  : _dashboard == null
                      ? _buildError()
                      : RefreshIndicator(
                          onRefresh: _loadDashboard,
                          color: AppColors.deepGoldBrown,
                          backgroundColor: AppColors.ivorySilk,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: AppSpacing.pagePadding.copyWith(top: 8, bottom: 24),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: AppColors.onBackdropMuted),
          const SizedBox(height: 16),
          Text(
            'ไม่สามารถโหลดข้อมูลได้',
            style: SacredText.kanit(
              color: AppColors.onBackdrop,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            child: SacredPrimaryButton(
              label: 'ลองใหม่',
              onTap: _loadDashboard,
              filled: true,
            ),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.templeIndigo.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ยอดคงเหลือ',
            style: SacredText.kanit(
                color: AppColors.onBackdropMuted, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '฿${stats.availableBalance.toStringAsFixed(0)}',
            style: SacredText.display(
              color: AppColors.candleGold,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          if (stats.pendingCommission > 0)
            Text(
              'รอดำเนินการ ฿${stats.pendingCommission.toStringAsFixed(0)}',
              style: SacredText.kanit(
                  color: AppColors.onBackdropMuted, fontSize: 13),
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
                    foregroundColor: AppColors.onBackdrop,
                    side: BorderSide(
                        color: AppColors.candleGold.withValues(alpha: 0.55)),
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
                    foregroundColor: AppColors.onBackdrop,
                    side: BorderSide(
                        color: AppColors.candleGold.withValues(alpha: 0.55)),
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
    return SacredCard(
      radius: 14,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: AppColors.deepGoldBrown, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: SacredText.kanit(
              color: AppColors.deepText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: SacredText.kanit(fontSize: 12, color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard() {
    final stats = _dashboard!.stats;
    final tierColor = _getTierColor(stats.tier);

    return SacredCard(
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.12),
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
                  style: SacredText.kanit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tierColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ออเดอร์เดือนนี้: ${stats.monthlyOrders} รายการ',
                  style: SacredText.kanit(
                      fontSize: 13, color: AppColors.mutedText),
                ),
                const SizedBox(height: 4),
                Text(
                  _getNextTierMessage(stats.tier, stats.monthlyOrders),
                  style: SacredText.kanit(
                      fontSize: 12,
                      color: AppColors.mutedText),
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
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: SacredSectionTitle('เมนู'),
        ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SacredCard(
        onTap: onTap,
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.candleGold.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.deepGoldBrown, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SacredText.kanit(
                      color: AppColors.deepText,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: SacredText.kanit(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.mutedText.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCommissions() {
    final commissions = _dashboard!.recentCommissions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: SacredSectionTitle('คอมมิชชั่นล่าสุด'),
        ),
        if (commissions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Text(
              'ยังไม่มีคอมมิชชั่น\nเริ่มแชร์ลิงก์เพื่อรับค่าแนะนำ!',
              textAlign: TextAlign.center,
              style: SacredText.kanit(
                  color: AppColors.onBackdropMuted, fontSize: 14),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SacredCard(
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.12),
              child: Icon(Icons.receipt, color: statusColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commission.orderLocationName,
                    style: SacredText.kanit(
                      color: AppColors.deepText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${commission.rateFormatted} of ${commission.orderAmountFormatted} - ${commission.statusLabel}',
                    style: SacredText.kanit(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              commission.commissionFormatted,
              style: SacredText.kanit(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tier accents — kept distinct/metallic but toned toward the temple palette
  // so the gold tier sits beside the app's candle gold without clashing.
  Color _getTierColor(String tier) => switch (tier) {
    'platinum' => const Color(0xFF6E7A8A), // muted slate
    'gold' => AppColors.candleGold, // candle gold (matches app accent)
    'silver' => const Color(0xFF9A938A), // warm grey
    _ => AppColors.deepGoldBrown, // bronze → deep gold-brown
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
