import 'package:flutter/material.dart';

/// Utility class for status mapping and formatting in Penghuni module
class PenghuniStatusMapper {
  /// Map raw tagihan status to display text
  static String mapTagihanStatus(String? rawStatus) {
    final status = (rawStatus ?? '').trim().toLowerCase();
    if (status == 'lunas') return 'Lunas';
    if (status == 'menunggu_verifikasi') return 'Menunggu Verifikasi';
    return 'Belum Dibayar';
  }

  /// Format sistem pembayaran from bulan count
  static String formatSistemPembayaranFromBulan(int bulan) {
    if (bulan <= 1) return 'Bulanan (1 bulan)';
    if (bulan == 3) return '3 Bulanan';
    if (bulan == 6) return '6 Bulanan';
    if (bulan == 12) return 'Tahunan (1 tahun)';
    if (bulan == 24) return '2 Tahunan';
    return '$bulan Bulanan';
  }

  /// Resolve siklus bulan from sistem pembayaran string
  static int resolveSiklusBulan(String sistemPembayaran) {
    final raw = sistemPembayaran.toLowerCase();
    if (raw.contains('bulanan') && raw.contains('1')) return 1;
    if (raw.contains('3')) return 3;
    if (raw.contains('6')) return 6;
    if (raw.contains('tahunan') || raw.contains('12')) return 12;
    if (raw.contains('2') && raw.contains('tahun')) return 24;
    return 1;
  }

  /// Get contract status badge widget
  static Widget getContractBadge(String status, DateTime? tanggalKeluar) {
    final now = DateTime.now();
    final isActive = status.toLowerCase() == 'aktif';

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (isActive) {
      if (tanggalKeluar != null) {
        final daysLeft = tanggalKeluar.difference(now).inDays;
        if (daysLeft <= 30 && daysLeft > 0) {
          badgeColor = const Color(0xFFFFA726);
          badgeText = 'Segera Berakhir';
          badgeIcon = Icons.warning_amber_rounded;
        } else if (daysLeft <= 0) {
          badgeColor = const Color(0xFFEF5350);
          badgeText = 'Kontrak Habis';
          badgeIcon = Icons.error_outline;
        } else {
          badgeColor = const Color(0xFF66BB6A);
          badgeText = 'Aktif';
          badgeIcon = Icons.check_circle;
        }
      } else {
        badgeColor = const Color(0xFF66BB6A);
        badgeText = 'Aktif';
        badgeIcon = Icons.check_circle;
      }
    } else {
      badgeColor = const Color(0xFF9E9E9E);
      badgeText = 'Tidak Aktif';
      badgeIcon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Get status color for tagihan
  static Color getTagihanStatusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'lunas') return const Color(0xFF66BB6A);
    if (normalized == 'menunggu_verifikasi') return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  /// Get status icon for tagihan
  static IconData getTagihanStatusIcon(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'lunas') return Icons.check_circle;
    if (normalized == 'menunggu_verifikasi') return Icons.schedule;
    return Icons.error_outline;
  }
}
