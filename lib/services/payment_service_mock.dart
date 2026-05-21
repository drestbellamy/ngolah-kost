import '../models/payment_detail_model.dart';

/// Mock Payment Service untuk testing tanpa backend
/// Gunakan ini sementara backend belum siap
class PaymentServiceMock {
  /// Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Mock data untuk berbagai status pembayaran
  final Map<String, Map<String, dynamic>> _mockData = {
    'payment_verified': {
      'id': 'payment_verified',
      'user_id': 'user_123',
      'month': 'Juli 2026',
      'payment_method': 'BCA',
      'amount': 2000000,
      'status': 'verified',
      'proof_image_url': 'https://picsum.photos/seed/verified/400/600',
      'payment_date': '2026-07-15T10:30:00Z',
      'created_at': '2026-07-15T10:30:00Z',
      'verified_at': '2026-07-16T14:20:00Z',
      'verified_by': 'admin_789',
      'rejection_reason': null,
    },
    'payment_pending': {
      'id': 'payment_pending',
      'user_id': 'user_123',
      'month': 'Agustus 2026',
      'payment_method': 'BCA',
      'amount': 2000000,
      'status': 'pending',
      'proof_image_url': 'https://picsum.photos/seed/pending/400/600',
      'payment_date': '2026-08-15T10:30:00Z',
      'created_at': '2026-08-15T10:30:00Z',
      'verified_at': null,
      'verified_by': null,
      'rejection_reason': null,
    },
    'payment_rejected': {
      'id': 'payment_rejected',
      'user_id': 'user_123',
      'month': 'Juni 2026',
      'payment_method': 'BCA',
      'amount': 2000000,
      'status': 'rejected',
      'proof_image_url': 'https://picsum.photos/seed/rejected/400/600',
      'payment_date': '2026-06-15T10:30:00Z',
      'created_at': '2026-06-15T10:30:00Z',
      'verified_at': null,
      'verified_by': 'admin_789',
      'rejection_reason':
          'Bukti transfer tidak jelas. Mohon upload ulang dengan kualitas yang lebih baik dan pastikan semua informasi terlihat jelas.',
    },
  };

  /// Fetch payment detail by ID (Mock)
  Future<PaymentDetail> getPaymentDetail(String paymentId) async {
    await _simulateDelay();

    // Cek apakah ada mock data untuk ID ini
    if (_mockData.containsKey(paymentId)) {
      return PaymentDetail.fromJson(_mockData[paymentId]!);
    }

    // Default mock data jika ID tidak ditemukan
    return PaymentDetail.fromJson({
      'id': paymentId,
      'user_id': 'user_123',
      'month': 'Juli 2026',
      'payment_method': 'BCA',
      'amount': 2000000,
      'status': 'verified',
      'proof_image_url': 'https://picsum.photos/seed/$paymentId/400/600',
      'payment_date': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
      'verified_at': DateTime.now().toIso8601String(),
      'verified_by': 'admin_123',
      'rejection_reason': null,
    });
  }

  /// Fetch all payment history (Mock)
  Future<List<PaymentDetail>> getPaymentHistory(String userId) async {
    await _simulateDelay();

    return _mockData.values
        .map((data) => PaymentDetail.fromJson(data))
        .toList();
  }
}
