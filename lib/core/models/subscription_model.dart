enum SubscriptionTier {
  free,
  basic,
  premium,
  ultimate
}

enum SubscriptionStatus {
  active,
  canceled,
  expired,
  pending,
  failed
}

enum PaymentMethod {
  creditCard,
  debitCard,
  promptpay,
  truemoney,
  applePay,
  googlePay,
  bankTransfer
}

class SubscriptionPlan {
  final int id;
  final String name;
  final String nameTh;
  final SubscriptionTier tier;
  final double price;
  final String currency;
  final int durationDays;
  final String description;
  final String descriptionTh;
  final List<String> features;
  final List<String> featuresTh;
  final bool isPopular;
  final double? discountPercentage;
  final DateTime? discountValidUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.nameTh,
    required this.tier,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.description,
    required this.descriptionTh,
    required this.features,
    required this.featuresTh,
    required this.isPopular,
    this.discountPercentage,
    this.discountValidUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      nameTh: json['name_th'],
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.toString().split('.').last == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      price: json['price'].toDouble(),
      currency: json['currency'],
      durationDays: json['duration_days'],
      description: json['description'],
      descriptionTh: json['description_th'],
      features: List<String>.from(json['features']),
      featuresTh: List<String>.from(json['features_th']),
      isPopular: json['is_popular'],
      discountPercentage: json['discount_percentage']?.toDouble(),
      discountValidUntil: json['discount_valid_until'] != null
          ? DateTime.parse(json['discount_valid_until'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_th': nameTh,
      'tier': tier.toString().split('.').last,
      'price': price,
      'currency': currency,
      'duration_days': durationDays,
      'description': description,
      'description_th': descriptionTh,
      'features': features,
      'features_th': featuresTh,
      'is_popular': isPopular,
      'discount_percentage': discountPercentage,
      'discount_valid_until': discountValidUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // คำนวณราคาหลังส่วนลด
  double get discountedPrice {
    if (discountPercentage == null || 
        discountValidUntil == null || 
        DateTime.now().isAfter(discountValidUntil!)) {
      return price;
    }
    
    return price * (1 - (discountPercentage! / 100));
  }

  // ตรวจสอบว่าแผนนี้มีส่วนลดที่ยังใช้งานได้หรือไม่
  bool get hasActiveDiscount {
    return discountPercentage != null && 
           discountValidUntil != null && 
           DateTime.now().isBefore(discountValidUntil!);
  }

  // คำนวณราคาต่อเดือน
  double get pricePerMonth {
    return price / (durationDays / 30);
  }

  // คำนวณราคาต่อเดือนหลังส่วนลด
  double get discountedPricePerMonth {
    return discountedPrice / (durationDays / 30);
  }
}

class UserSubscription {
  final int id;
  final int userId;
  final int planId;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SubscriptionPlan? plan;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.autoRenew,
    required this.createdAt,
    required this.updatedAt,
    this.plan,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['user_id'],
      planId: json['plan_id'],
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SubscriptionStatus.expired,
      ),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      autoRenew: json['auto_renew'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      plan: json['plan'] != null ? SubscriptionPlan.fromJson(json['plan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'status': status.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'auto_renew': autoRenew,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'plan': plan?.toJson(),
    };
  }

  // ตรวจสอบว่าการสมัครสมาชิกยังใช้งานได้หรือไม่
  bool get isActive => status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);

  // คำนวณจำนวนวันที่เหลือในการสมัครสมาชิก
  int get daysRemaining {
    if (!isActive) {
      return 0;
    }
    
    return endDate.difference(DateTime.now()).inDays;
  }

  // ตรวจสอบว่าการสมัครสมาชิกใกล้หมดอายุหรือไม่ (น้อยกว่า 7 วัน)
  bool get isExpiringSoon {
    return isActive && daysRemaining < 7;
  }

  // สร้างสำเนาของการสมัครสมาชิกพร้อมการเปลี่ยนแปลงบางส่วน
  UserSubscription copyWith({
    int? id,
    int? userId,
    int? planId,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    bool? autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
    SubscriptionPlan? plan,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      autoRenew: autoRenew ?? this.autoRenew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      plan: plan ?? this.plan,
    );
  }
}

class Payment {
  final int id;
  final int userId;
  final int? subscriptionId;
  final double amount;
  final String currency;
  final String transactionId;
  final PaymentMethod method;
  final String status;
  final String? failureReason;
  final DateTime paymentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.userId,
    this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.transactionId,
    required this.method,
    required this.status,
    this.failureReason,
    required this.paymentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user_id'],
      subscriptionId: json['subscription_id'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      transactionId: json['transaction_id'],
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['method'],
        orElse: () => PaymentMethod.creditCard,
      ),
      status: json['status'],
      failureReason: json['failure_reason'],
      paymentDate: DateTime.parse(json['payment_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subscription_id': subscriptionId,
      'amount': amount,
      'currency': currency,
      'transaction_id': transactionId,
      'method': method.toString().split('.').last,
      'status': status,
      'failure_reason': failureReason,
      'payment_date': paymentDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ตรวจสอบว่าการชำระเงินสำเร็จหรือไม่
  bool get isSuccessful => status == 'successful';

  // ตรวจสอบว่าการชำระเงินล้มเหลวหรือไม่
  bool get isFailed => status == 'failed';

  // ตรวจสอบว่าการชำระเงินกำลังดำเนินการหรือไม่
  bool get isPending => status == 'pending';

  // ตรวจสอบว่าการชำระเงินถูกคืนเงินหรือไม่
  bool get isRefunded => status == 'refunded';
} 