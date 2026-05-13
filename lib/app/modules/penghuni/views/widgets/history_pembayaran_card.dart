import 'package:flutter/material.dart';
import '../../models/penghuni_model.dart';
import 'history_item_widget.dart';

class HistoryPembayaranCard extends StatelessWidget {
  final Future<List<PembayaranModel>> billingFuture;

  const HistoryPembayaranCard({super.key, required this.billingFuture});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 20,
                color: Color(0xFF6B8E7F),
              ),
              SizedBox(width: 8),
              Text(
                'History Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<PembayaranModel>>(
            future: billingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final billingHistory = snapshot.data ?? const [];
              if (billingHistory.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Belum ada data history pembayaran.',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: billingHistory.length,
                itemBuilder: (context, index) {
                  final history = billingHistory[index];
                  return HistoryItemWidget(history: history, index: index);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
