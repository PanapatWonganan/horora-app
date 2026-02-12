/// Models สำหรับระบบตัวแทน (Affiliate)

class AffiliateModel {
  final String id;
  final int userId;
  final String referralCode;
  final String tier;
  final String status;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? promptpayNumber;
  final int totalReferrals;
  final int totalOrders;
  final double totalCommissionEarned;
  final double totalCommissionPaid;
  final double availableBalance;
  final int monthlyOrders;
  final String? monthlyPeriod;
  final DateTime? createdAt;

  const AffiliateModel({
    required this.id,
    required this.userId,
    required this.referralCode,
    this.tier = 'bronze',
    this.status = 'pending',
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.promptpayNumber,
    this.totalReferrals = 0,
    this.totalOrders = 0,
    this.totalCommissionEarned = 0,
    this.totalCommissionPaid = 0,
    this.availableBalance = 0,
    this.monthlyOrders = 0,
    this.monthlyPeriod,
    this.createdAt,
  });

  factory AffiliateModel.fromJson(Map<String, dynamic> json) {
    return AffiliateModel(
      id: json['id'] as String,
      userId: json['user_id'] as int,
      referralCode: json['referral_code'] as String,
      tier: json['tier'] as String? ?? 'bronze',
      status: json['status'] as String? ?? 'pending',
      bankName: json['bank_name'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankAccountName: json['bank_account_name'] as String?,
      promptpayNumber: json['promptpay_number'] as String?,
      totalReferrals: json['total_referrals'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalCommissionEarned: _toDouble(json['total_commission_earned']),
      totalCommissionPaid: _toDouble(json['total_commission_paid']),
      availableBalance: _toDouble(json['available_balance']),
      monthlyOrders: json['monthly_orders'] as int? ?? 0,
      monthlyPeriod: json['monthly_period'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get hasBankInfo => bankName != null && bankAccountNumber != null;
  bool get hasPromptpay => promptpayNumber != null && promptpayNumber!.isNotEmpty;

  String get tierLabel => switch (tier) {
    'platinum' => 'Platinum',
    'gold' => 'Gold',
    'silver' => 'Silver',
    _ => 'Bronze',
  };

  String get statusLabel => switch (status) {
    'active' => 'ใช้งาน',
    'suspended' => 'ระงับ',
    _ => 'รอตรวจสอบ',
  };

  String get balanceFormatted => '฿${availableBalance.toStringAsFixed(0)}';
  String get totalEarnedFormatted => '฿${totalCommissionEarned.toStringAsFixed(0)}';
}

class AffiliateDashboard {
  final AffiliateModel affiliate;
  final AffiliateStats stats;
  final List<AffiliateCommissionModel> recentCommissions;

  const AffiliateDashboard({
    required this.affiliate,
    required this.stats,
    required this.recentCommissions,
  });

  factory AffiliateDashboard.fromJson(Map<String, dynamic> json) {
    return AffiliateDashboard(
      affiliate: AffiliateModel.fromJson(json['affiliate'] as Map<String, dynamic>),
      stats: AffiliateStats.fromJson(json['stats'] as Map<String, dynamic>),
      recentCommissions: (json['recent_commissions'] as List<dynamic>?)
              ?.map((e) => AffiliateCommissionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AffiliateStats {
  final int totalReferrals;
  final int totalOrders;
  final double totalEarned;
  final double totalPaid;
  final double availableBalance;
  final double pendingCommission;
  final double monthlyEarnings;
  final int monthlyOrders;
  final String tier;
  final String referralCode;

  const AffiliateStats({
    required this.totalReferrals,
    required this.totalOrders,
    required this.totalEarned,
    required this.totalPaid,
    required this.availableBalance,
    required this.pendingCommission,
    required this.monthlyEarnings,
    required this.monthlyOrders,
    required this.tier,
    required this.referralCode,
  });

  factory AffiliateStats.fromJson(Map<String, dynamic> json) {
    return AffiliateStats(
      totalReferrals: json['total_referrals'] as int? ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalEarned: AffiliateModel._toDouble(json['total_earned']),
      totalPaid: AffiliateModel._toDouble(json['total_paid']),
      availableBalance: AffiliateModel._toDouble(json['available_balance']),
      pendingCommission: AffiliateModel._toDouble(json['pending_commission']),
      monthlyEarnings: AffiliateModel._toDouble(json['monthly_earnings']),
      monthlyOrders: json['monthly_orders'] as int? ?? 0,
      tier: json['tier'] as String? ?? 'bronze',
      referralCode: json['referral_code'] as String? ?? '',
    );
  }
}

class AffiliateCommissionModel {
  final String id;
  final String affiliateId;
  final String orderId;
  final double orderAmount;
  final double commissionRate;
  final double commissionAmount;
  final String status;
  final DateTime? availableAt;
  final DateTime? createdAt;
  // Nested order info
  final Map<String, dynamic>? order;

  const AffiliateCommissionModel({
    required this.id,
    required this.affiliateId,
    required this.orderId,
    required this.orderAmount,
    required this.commissionRate,
    required this.commissionAmount,
    this.status = 'pending',
    this.availableAt,
    this.createdAt,
    this.order,
  });

  factory AffiliateCommissionModel.fromJson(Map<String, dynamic> json) {
    return AffiliateCommissionModel(
      id: json['id'] as String,
      affiliateId: json['affiliate_id'] as String,
      orderId: json['order_id'] as String,
      orderAmount: AffiliateModel._toDouble(json['order_amount']),
      commissionRate: AffiliateModel._toDouble(json['commission_rate']),
      commissionAmount: AffiliateModel._toDouble(json['commission_amount']),
      status: json['status'] as String? ?? 'pending',
      availableAt: json['available_at'] != null
          ? DateTime.parse(json['available_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      order: json['order'] as Map<String, dynamic>?,
    );
  }

  String get statusLabel => switch (status) {
    'approved' => 'อนุมัติแล้ว',
    'paid' => 'จ่ายแล้ว',
    'cancelled' => 'ยกเลิก',
    _ => 'รอตรวจสอบ',
  };

  String get commissionFormatted => '฿${commissionAmount.toStringAsFixed(0)}';
  String get orderAmountFormatted => '฿${orderAmount.toStringAsFixed(0)}';
  String get rateFormatted => '${commissionRate.toStringAsFixed(0)}%';

  // Get order location name from nested data
  String get orderLocationName {
    if (order == null) return '-';
    final location = order!['location'] as Map<String, dynamic>?;
    return location?['name_th'] as String? ?? '-';
  }
}

class AffiliateWithdrawalModel {
  final String id;
  final String affiliateId;
  final double amount;
  final String method;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? promptpayNumber;
  final String status;
  final String? transferSlipUrl;
  final String? adminNote;
  final DateTime? processedAt;
  final DateTime? createdAt;

  const AffiliateWithdrawalModel({
    required this.id,
    required this.affiliateId,
    required this.amount,
    this.method = 'bank_transfer',
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.promptpayNumber,
    this.status = 'pending',
    this.transferSlipUrl,
    this.adminNote,
    this.processedAt,
    this.createdAt,
  });

  factory AffiliateWithdrawalModel.fromJson(Map<String, dynamic> json) {
    return AffiliateWithdrawalModel(
      id: json['id'] as String,
      affiliateId: json['affiliate_id'] as String,
      amount: AffiliateModel._toDouble(json['amount']),
      method: json['method'] as String? ?? 'bank_transfer',
      bankName: json['bank_name'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankAccountName: json['bank_account_name'] as String?,
      promptpayNumber: json['promptpay_number'] as String?,
      status: json['status'] as String? ?? 'pending',
      transferSlipUrl: json['transfer_slip_url'] as String?,
      adminNote: json['admin_note'] as String?,
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  String get statusLabel => switch (status) {
    'processing' => 'กำลังดำเนินการ',
    'completed' => 'โอนแล้ว',
    'rejected' => 'ปฏิเสธ',
    _ => 'รอดำเนินการ',
  };

  String get amountFormatted => '฿${amount.toStringAsFixed(0)}';
  String get methodLabel => method == 'promptpay' ? 'พร้อมเพย์' : 'โอนธนาคาร';
}

class AffiliateReferralLink {
  final String referralCode;
  final String referralLink;
  final String deepLink;
  final String qrData;
  final String tier;

  const AffiliateReferralLink({
    required this.referralCode,
    required this.referralLink,
    required this.deepLink,
    required this.qrData,
    required this.tier,
  });

  factory AffiliateReferralLink.fromJson(Map<String, dynamic> json) {
    return AffiliateReferralLink(
      referralCode: json['referral_code'] as String,
      referralLink: json['referral_link'] as String,
      deepLink: json['deep_link'] as String,
      qrData: json['qr_data'] as String,
      tier: json['tier'] as String? ?? 'bronze',
    );
  }
}
