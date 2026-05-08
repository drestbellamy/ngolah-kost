import 'package:flutter/material.dart';
import '../../models/penghuni_model.dart';
import '../../../../../repositories/tagihan_repository.dart';

class PenghuniDetailHelpers {
  static Future<List<PembayaranModel>> loadBillingHistory(
    PenghuniModel penghuni,
    TagihanRepository tagihanRepo,
  ) async {
    try {
      final rows = await tagihanRepo.getTagihanByPenghuniId(penghuni.id);
      if (rows.isEmpty) {
        return [];
      }

      final expectedKeys = _buildExpectedBillingKeys(penghuni);

      final byKey = <String, Map<String, dynamic>>{};
      for (final raw in rows) {
        final row = Map<String, dynamic>.from(raw);
        final bulan = _toInt(row['bulan']);
        final tahun = _toInt(row['tahun']);
        if (bulan < 1 || bulan > 12 || tahun <= 0) {
          continue;
        }

        final key = '$tahun-${bulan.toString().padLeft(2, '0')}';
        final status = (row['status'] ?? '').toString().toLowerCase().trim();

        final inContract = expectedKeys.contains(key);
        final isPaid = status == 'lunas';
        if (!inContract && !isPaid) {
          continue;
        }

        final existing = byKey[key];
        if (existing == null) {
          byKey[key] = row;
          continue;
        }

        final existingStatus = (existing['status'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
        final existingPaid = existingStatus == 'lunas';
        if (!existingPaid && isPaid) {
          byKey[key] = row;
        }
      }

      final filteredRows = byKey.values.toList()
        ..sort((a, b) {
          final tahunA = _toInt(a['tahun']);
          final tahunB = _toInt(b['tahun']);
          if (tahunA != tahunB) return tahunB.compareTo(tahunA);

          final bulanA = _toInt(a['bulan']);
          final bulanB = _toInt(b['bulan']);
          return bulanB.compareTo(bulanA);
        });

      if (filteredRows.isEmpty) {
        return [];
      }

      final siklusBulan = _resolveSiklusBulan(penghuni.sistemPembayaran);

      return filteredRows.map((row) {
        final bulan = _toInt(row['bulan']);
        final tahun = _toInt(row['tahun']);
        final startPeriode = (bulan >= 1 && bulan <= 12 && tahun > 0)
            ? DateTime(tahun, bulan, 1)
            : null;
        final rowSiklus = _resolveTagihanSiklusBulan(
          row,
          penghuni,
          fallbackSiklus: siklusBulan,
        );
        final periodLabel = startPeriode == null
            ? '-'
            : _formatPeriodeLabel(startPeriode, rowSiklus);
        final dueDate = startPeriode == null
            ? '-'
            : _formatDueDate(startPeriode);

        return PembayaranModel(
          bulan: periodLabel,
          jumlah: _toDouble(row['jumlah']),
          jatuhTempo: dueDate,
          status: _mapTagihanStatus(row['status']?.toString()),
          tanggalBayar: row['tanggal_bayar']?.toString(),
        );
      }).toList();
    } catch (_) {
      return penghuni.historyPembayaran;
    }
  }

  static Set<String> _buildExpectedBillingKeys(PenghuniModel penghuni) {
    final startDate = _parseDate(penghuni.tanggalMasuk);
    if (startDate == null || penghuni.durasiKontrak <= 0) {
      return <String>{};
    }

    final siklus = _resolveSiklusBulan(penghuni.sistemPembayaran);
    final total = (penghuni.durasiKontrak / siklus).ceil();
    final keys = <String>{};

    for (var i = 0; i < total; i++) {
      final periode = DateTime(
        startDate.year,
        startDate.month + (i * siklus),
        1,
      );
      keys.add('${periode.year}-${periode.month.toString().padLeft(2, '0')}');
    }

    return keys;
  }

  static ({String label, Color backgroundColor, Color textColor})
  getContractBadge(PenghuniModel penghuni) {
    final endDate = _parseDate(penghuni.tanggalBerakhir);
    if (endDate == null) {
      return (
        label: 'Aktif',
        backgroundColor: const Color(0xFF16A34A),
        textColor: const Color(0xFFFFFFFF),
      );
    }

    final today = DateTime.now();
    final diff = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).difference(DateTime(today.year, today.month, today.day));

    if (diff.inDays < 0) {
      return (
        label: 'Berakhir',
        backgroundColor: const Color(0xFFEF4444),
        textColor: const Color(0xFFFFFFFF),
      );
    }

    if (diff.inDays <= 30) {
      return (
        label: 'Segera Berakhir',
        backgroundColor: const Color(0xFFF59E0B),
        textColor: const Color(0xFFFFFFFF),
      );
    }

    return (
      label: 'Aktif',
      backgroundColor: const Color(0xFF16A34A),
      textColor: const Color(0xFFFFFFFF),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _mapTagihanStatus(String? rawStatus) {
    final status = (rawStatus ?? '').trim().toLowerCase();
    if (status == 'lunas') return 'Lunas';
    if (status == 'menunggu_verifikasi') return 'Menunggu Verifikasi';
    return 'Belum Dibayar';
  }

  static DateTime? _parseDate(String tanggal) {
    final parts = tanggal.split(RegExp(r'\s+'));
    if (parts.length < 3) return null;
    final day = int.tryParse(parts[0]);
    final month = _monthNumber(parts[1].toLowerCase());
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  static String _formatPeriodeLabel(DateTime start, int siklusBulan) {
    if (siklusBulan <= 1) {
      return _formatMonthLabel(start);
    }

    final end = DateTime(start.year, start.month + siklusBulan - 1, start.day);
    return '${_monthNames[start.month]}-\n${_monthNames[end.month]} ${end.year}';
  }

  static String _formatMonthLabel(DateTime date) {
    return '${_monthNames[date.month]} ${date.year}';
  }

  static String _formatDueDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthNames[date.month]} ${date.year}';
  }

  static int _resolveSiklusBulan(String sistemPembayaran) {
    final raw = sistemPembayaran.toLowerCase();
    if (raw.contains('24') || raw.contains('2 tahun')) return 24;
    if (raw.contains('12') || raw.contains('tahunan')) return 12;
    if (raw.contains('6')) return 6;
    if (raw.contains('3')) return 3;
    return 1;
  }

  static int _resolveTagihanSiklusBulan(
    Map<String, dynamic> row,
    PenghuniModel penghuni, {
    required int fallbackSiklus,
  }) {
    final sewaBulanan = penghuni.sewaBulanan;
    final jumlahTagihan = _toDouble(row['jumlah']);

    if (sewaBulanan <= 0 || jumlahTagihan <= 0) {
      return fallbackSiklus <= 0 ? 1 : fallbackSiklus;
    }

    final ratio = jumlahTagihan / sewaBulanan;
    final rounded = ratio.round();
    // Accept near-integer ratios to tolerate minor rounding differences.
    if (rounded > 0 && (ratio - rounded).abs() <= 0.15) {
      return rounded;
    }

    return fallbackSiklus <= 0 ? 1 : fallbackSiklus;
  }

  static int? _monthNumber(String month) {
    const monthMap = {
      'jan': 1,
      'januari': 1,
      'feb': 2,
      'februari': 2,
      'mar': 3,
      'maret': 3,
      'apr': 4,
      'april': 4,
      'mei': 5,
      'jun': 6,
      'juni': 6,
      'jul': 7,
      'juli': 7,
      'agu': 8,
      'agustus': 8,
      'sep': 9,
      'september': 9,
      'okt': 10,
      'oktober': 10,
      'nov': 11,
      'november': 11,
      'des': 12,
      'desember': 12,
    };
    return monthMap[month];
  }

  static const _monthNames = {
    1: 'Januari',
    2: 'Februari',
    3: 'Maret',
    4: 'April',
    5: 'Mei',
    6: 'Juni',
    7: 'Juli',
    8: 'Agustus',
    9: 'September',
    10: 'Oktober',
    11: 'November',
    12: 'Desember',
  };
}
