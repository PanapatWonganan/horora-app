import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/merit_colors.dart';
import '../../../core/theme/sacred_ui.dart';
import '../../../core/utils/app_icons.dart';
import '../models/merit_models.dart';
import '../services/merit_service.dart';
import '../widgets/merit_ui.dart';

/// หน้าประวัติการสั่งซื้อ
class MeritHistoryScreen extends StatefulWidget {
  const MeritHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MeritHistoryScreen> createState() => _MeritHistoryScreenState();
}

class _MeritHistoryScreenState extends State<MeritHistoryScreen> {
  final MeritService _meritService = MeritService.instance;
  List<MeritOrder> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _meritService.getMyOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
                child: _isLoading
                    ? const SacredLoader.large()
                    : _orders.isEmpty
                        ? _buildEmptyState()
                        : _buildOrderList(),
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
            tooltip: 'ย้อนกลับ',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SacredOverline('Merit · บุญของฉัน', color: AppColors.onBackdropMuted, fontSize: 12, letterSpacing: 2.8),
                const SizedBox(height: 2),
                Text(
                  'บุญของฉัน',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            // Scroll/timeline status motif — rounded line, not a receipt.
            Icons.history_rounded,
            size: 80,
            color: AppColors.onBackdropMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีบุญที่ร่วมไว้',
            style: GoogleFonts.kanit(
              color: AppColors.onBackdrop,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: MeritColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(_orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(MeritOrder order) {
    return GestureDetector(
      onTap: () => _showOrderDetail(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MeritColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor(order.status).withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: MeritColors.accent.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber ?? '-',
                  style: GoogleFonts.fraunces(
                    color: MeritColors.accentDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: MeritColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    // Outlined temple — matches the calm line-icon language.
                    Icons.temple_buddhist_outlined,
                    color: MeritColors.accentDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.location?.nameTh ?? order.locationId,
                        style: GoogleFonts.kanit(
                          color: AppColors.deepText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        order.package?.nameTh ?? order.packageId,
                        style: GoogleFonts.kanit(
                          color: AppColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  order.priceFormatted,
                  style: GoogleFonts.fraunces(
                    color: MeritColors.price,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: 4),
                Text(
                  order.prayerName,
                  style: GoogleFonts.kanit(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: 4),
                Text(
                  order.createdAt != null
                      ? DateFormat('d MMM yyyy HH:mm', 'th').format(order.createdAt!)
                      : '-',
                  style: GoogleFonts.kanit(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MeritOrderStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withValues(alpha: 0.7), width: 1.5),
      ),
      child: Text(
        status.displayName,
        style: GoogleFonts.kanit(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Calm, temple-toned status palette (same mapping/logic — only the color
  /// VALUES are tuned to the Sacred Astrology temple tones).
  Color _getStatusColor(MeritOrderStatus status) {
    switch (status) {
      case MeritOrderStatus.pending:
        return AppColors.mutedGold; // awaiting — muted gold
      case MeritOrderStatus.paid:
        return AppColors.softPlum; // paid — soft plum
      case MeritOrderStatus.processing:
        return AppColors.candleGold; // in progress — candle gold
      case MeritOrderStatus.completed:
        return AppColors.bodhiGreen; // delivered — bodhi green
      case MeritOrderStatus.cancelled:
        return AppColors.error; // failed — temple vermilion
    }
  }

  void _showOrderDetail(MeritOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _OrderDetailSheet(order: order),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final MeritOrder order;

  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: MeritColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'รายละเอียดคำสั่งบุญ',
            style: GoogleFonts.kanit(
              color: AppColors.deepText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('เลขที่', order.orderNumber ?? '-'),
          _buildDetailRow('สถานที่', order.location?.nameTh ?? order.locationId),
          _buildDetailRow('แพ็คเกจ', order.package?.nameTh ?? order.packageId),
          _buildDetailRow('ราคา', order.priceFormatted),
          const Divider(color: AppColors.divider, height: 32),
          _buildDetailRow('ผู้ขอพร', order.prayerName),
          if (order.prayerBirthdate != null)
            _buildDetailRow(
              'วันเกิด',
              DateFormat('d MMMM yyyy', 'th').format(order.prayerBirthdate!),
            ),
          if (order.prayerPhone != null)
            _buildDetailRow('เบอร์โทร', order.prayerPhone!),
          if (order.prayerWish != null && order.prayerWish!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'คำอธิษฐาน',
              style: GoogleFonts.kanit(
                color: AppColors.mutedText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              order.prayerWish!,
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 14,
              ),
            ),
          ],
          if (order.proofUrls != null && order.proofUrls!.isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 32),
            Text(
              'หลักฐานการไหว้',
              style: GoogleFonts.kanit(
                color: AppColors.deepText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: order.proofUrls!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(order.proofUrls![index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          SacredPrimaryButton(
            label: 'ปิด',
            onTap: () => Navigator.pop(context),
            filled: true,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
            style: GoogleFonts.kanit(
              color: AppColors.deepText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
