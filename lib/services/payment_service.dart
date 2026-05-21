import 'package:dio/dio.dart';
import '../models/payment_detail_model.dart';

class PaymentService {
  final Dio _dio;
  final String baseUrl;

  PaymentService({
    Dio? dio,
    this.baseUrl = 'https://your-api-url.com/api', // Ganti dengan URL backend Anda
  }) : _dio = dio ?? Dio();

  /// Fetch payment detail by ID
  Future<PaymentDetail> getPaymentDetail(String paymentId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/payments/$paymentId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // Tambahkan token jika perlu
            // 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PaymentDetail.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load payment detail: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Error: ${e.response?.data['message'] ?? e.message}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch all payment history for a user
  Future<List<PaymentDetail>> getPaymentHistory(String userId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/payments/user/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PaymentDetail.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payment history');
      }
    } catch (e) {
      throw Exception('Error fetching payment history: $e');
    }
  }
}
