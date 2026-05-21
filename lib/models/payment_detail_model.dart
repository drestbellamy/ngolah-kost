class PaymentDetail {
  final String id;
  final String userId;
  final String month;
  final String paymentMethod;
  final double amount;
  final String status;
  final DateTime paymentDate;
  final String proofImageUrl;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final String? rejectionReason;

  PaymentDetail({
    required this.id,
    required this.userId,
    required this.month,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    required this.paymentDate,
    required this.proofImageUrl,
    required this.createdAt,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] as double? ?? 0.0),
      status: json['status']?.toString() ?? 'pending',
      proofImageUrl: json['proof_image_url']?.toString() ?? '',
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'].toString())
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'].toString())
          : null,
      verifiedBy: json['verified_by']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'month': month,
      'payment_method': paymentMethod,
      'amount': amount,
      'status': status,
      'proof_image_url': proofImageUrl,
      'payment_date': paymentDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'rejection_reason': rejectionReason,
    };
  }
}
