import 'base/base_repository.dart';

/// Repository for dashboard statistics and aggregated data
/// Composes multiple repositories to provide dashboard insights
class DashboardRepository extends BaseRepository {
  // Dependencies - injected via constructor
  final dynamic _kostRepository;
  final dynamic _kamarRepository;
  final dynamic _penghuniRepository;
  // Note: _tagihanRepository and _pembayaranRepository are kept for future extensibility
  // but currently unused as we use direct queries for performance
  final dynamic _tagihanRepository;
  final dynamic _pembayaranRepository;

  DashboardRepository({
    required dynamic kostRepository,
    required dynamic kamarRepository,
    required dynamic penghuniRepository,
    required dynamic tagihanRepository,
    required dynamic pembayaranRepository,
  }) : _kostRepository = kostRepository,
       _kamarRepository = kamarRepository,
       _penghuniRepository = penghuniRepository,
       _tagihanRepository = tagihanRepository,
       _pembayaranRepository = pembayaranRepository;

  @override
  String get repositoryName => 'DashboardRepository';

  /// Get admin dashboard statistics
  ///
  /// Aggregates data from multiple repositories to provide:
  /// - Total kost count
  /// - Total kamar count
  /// - Kamar kosong count
  /// - Total active penghuni count
  /// - Tagihan belum bayar count
  /// - Tagihan menunggu verifikasi count
  ///
  /// Returns map with statistics
  ///
  /// Returns zero values on error
  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    logDebug('Getting admin dashboard statistics');

    try {
      // Get total kost
      final kostList = await _kostRepository.getKostList();
      final totalKost = kostList.length;

      // Get total kamar and kamar kosong
      int totalKamar = 0;
      int kamarKosong = 0;
      int totalPenghuni = 0;

      for (final kost in kostList) {
        final kamarList = await _kamarRepository.getKamarByKostId(kost.id);
        totalKamar += kamarList.length as int;

        for (final kamar in kamarList) {
          final status = (kamar['status']?.toString() ?? '').toLowerCase();
          if (status == 'kosong') {
            kamarKosong++;
          }

          // Count active penghuni
          final kamarId = kamar['id']?.toString() ?? '';
          if (kamarId.isNotEmpty) {
            final penghuniList = await _penghuniRepository.getPenghuniByKamarId(
              kamarId,
              onlyActive: true,
            );
            totalPenghuni += penghuniList.length as int;
          }
        }
      }

      // Get tagihan statistics
      // Note: getTagihanList requires a lookup function, so we'll use a direct query instead
      final tagihanRaw = await supabase.from('tagihan').select('id, status');

      final tagihanList = tagihanRaw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final tagihanBelumBayar = tagihanList.where((t) {
        final status = (t['status']?.toString() ?? '').toLowerCase();
        return status == 'belum_dibayar';
      }).length;

      final menungguVerifikasi = tagihanList.where((t) {
        final status = (t['status']?.toString() ?? '').toLowerCase();
        return status == 'menunggu_verifikasi';
      }).length;

      final stats = {
        'totalKost': totalKost,
        'totalKamar': totalKamar,
        'kamarKosong': kamarKosong,
        'totalPenghuni': totalPenghuni,
        'tagihanBelumBayar': tagihanBelumBayar,
        'menungguVerifikasi': menungguVerifikasi,
      };

      logInfo('Successfully retrieved admin dashboard stats', stats);

      return stats;
    } catch (e) {
      logError('Failed to get admin dashboard stats', {'error': e.toString()});

      // Return zero values on error
      return {
        'totalKost': 0,
        'totalKamar': 0,
        'kamarKosong': 0,
        'totalPenghuni': 0,
        'tagihanBelumBayar': 0,
        'menungguVerifikasi': 0,
      };
    }
  }

  /// Get user dashboard statistics
  ///
  /// Provides user-specific dashboard data:
  /// - User's penghuni information
  /// - Room information
  /// - Unpaid tagihan count
  /// - Pending payment count
  ///
  /// Parameters:
  /// - [userId]: User ID
  ///
  /// Returns map with user statistics or null if user not found
  Future<Map<String, dynamic>?> getUserDashboardStats(String userId) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID wajib diisi');
    }

    logDebug('Getting user dashboard stats', {'userId': userId});

    try {
      // Get penghuni data for user
      final penghuniData = await _penghuniRepository.getPenghuniByUserId(
        userId,
      );

      if (penghuniData == null) {
        logInfo('User not found or not a penghuni', {'userId': userId});
        return null;
      }

      final penghuniId = penghuniData['id']?.toString() ?? '';

      // Get unpaid tagihan count
      final tagihanRaw = await supabase
          .from('tagihan')
          .select('id, status')
          .eq('penghuni_id', penghuniId);

      final tagihanList = tagihanRaw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final unpaidCount = tagihanList.where((t) {
        final status = (t['status']?.toString() ?? '').toLowerCase();
        return status == 'belum_dibayar';
      }).length;

      final pendingCount = tagihanList.where((t) {
        final status = (t['status']?.toString() ?? '').toLowerCase();
        return status == 'menunggu_verifikasi';
      }).length;

      final stats = {
        'penghuniId': penghuniId,
        'nama': penghuniData['nama'] ?? '',
        'nomorKamar': penghuniData['nomor_kamar'] ?? '',
        'namaKost': penghuniData['nama_kost'] ?? '',
        'unpaidTagihanCount': unpaidCount,
        'pendingPaymentCount': pendingCount,
        'totalTagihanCount': tagihanList.length,
      };

      logInfo('Successfully retrieved user dashboard stats', {
        'userId': userId,
        'penghuniId': penghuniId,
      });

      return stats;
    } catch (e) {
      logError('Failed to get user dashboard stats', {
        'userId': userId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Get occupancy statistics for a kost
  ///
  /// Provides room occupancy analysis:
  /// - Total rooms
  /// - Occupied rooms
  /// - Empty rooms
  /// - Full rooms
  /// - Occupancy percentage
  ///
  /// Parameters:
  /// - [kostId]: Kost ID
  ///
  /// Returns map with occupancy statistics
  Future<Map<String, dynamic>> getOccupancyStats(String kostId) async {
    if (kostId.trim().isEmpty) {
      throw Exception('Kost ID wajib diisi');
    }

    logDebug('Getting occupancy stats', {'kostId': kostId});

    try {
      final kamarList = await _kamarRepository.getKamarByKostId(kostId);
      final totalRooms = kamarList.length;

      int emptyRooms = 0;
      int occupiedRooms = 0;
      int fullRooms = 0;

      for (final kamar in kamarList) {
        final status = (kamar['status']?.toString() ?? '').toLowerCase();
        if (status == 'kosong') {
          emptyRooms++;
        } else if (status == 'terisi') {
          occupiedRooms++;
        } else if (status == 'penuh') {
          fullRooms++;
        }
      }

      final occupancyPercentage = totalRooms > 0
          ? ((occupiedRooms + fullRooms) / totalRooms * 100).round()
          : 0;

      final stats = {
        'totalRooms': totalRooms,
        'emptyRooms': emptyRooms,
        'occupiedRooms': occupiedRooms,
        'fullRooms': fullRooms,
        'occupancyPercentage': occupancyPercentage,
      };

      logInfo('Successfully retrieved occupancy stats', {
        'kostId': kostId,
        ...stats,
      });

      return stats;
    } catch (e) {
      logError('Failed to get occupancy stats', {
        'kostId': kostId,
        'error': e.toString(),
      });

      // Return zero values on error
      return {
        'totalRooms': 0,
        'emptyRooms': 0,
        'occupiedRooms': 0,
        'fullRooms': 0,
        'occupancyPercentage': 0,
      };
    }
  }

  /// Get payment statistics for a period
  ///
  /// Provides payment analysis:
  /// - Total payments
  /// - Verified payments
  /// - Pending payments
  /// - Rejected payments
  /// - Total amount
  ///
  /// Parameters:
  /// - [kostId]: Kost ID (optional, for filtering)
  /// - [startDate]: Start date filter (optional)
  /// - [endDate]: End date filter (optional)
  /// - [bulan]: Month filter (1-12) (optional)
  /// - [tahun]: Year filter (optional)
  ///
  /// Returns map with payment statistics
  Future<Map<String, dynamic>> getPaymentStats({
    String? kostId,
    DateTime? startDate,
    DateTime? endDate,
    int? bulan,
    int? tahun,
  }) async {
    logDebug('Getting payment stats', {
      'kostId': kostId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'bulan': bulan,
      'tahun': tahun,
    });

    try {
      // Build query
      dynamic query = supabase
          .from('pembayaran')
          .select('id, status, jumlah, tanggal');

      // Apply filters
      if (kostId != null && kostId.trim().isNotEmpty) {
        // Note: pembayaran doesn't have direct kost_id, need to join through penghuni
        // For now, we'll get all and filter in memory
      }

      final raw = await query;

      var pembayaranList = raw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      // Apply date filters
      if (startDate != null) {
        pembayaranList = pembayaranList.where((item) {
          final tanggal = item['tanggal'];
          if (tanggal == null) return false;
          try {
            final date = DateTime.parse(tanggal.toString());
            return date.isAfter(startDate.subtract(const Duration(days: 1)));
          } catch (_) {
            return false;
          }
        }).toList();
      }

      if (endDate != null) {
        pembayaranList = pembayaranList.where((item) {
          final tanggal = item['tanggal'];
          if (tanggal == null) return false;
          try {
            final date = DateTime.parse(tanggal.toString());
            return date.isBefore(endDate.add(const Duration(days: 1)));
          } catch (_) {
            return false;
          }
        }).toList();
      }

      if (bulan != null && bulan >= 1 && bulan <= 12) {
        pembayaranList = pembayaranList.where((item) {
          final tanggal = item['tanggal'];
          if (tanggal == null) return false;
          try {
            final date = DateTime.parse(tanggal.toString());
            return date.month == bulan;
          } catch (_) {
            return false;
          }
        }).toList();
      }

      if (tahun != null) {
        pembayaranList = pembayaranList.where((item) {
          final tanggal = item['tanggal'];
          if (tanggal == null) return false;
          try {
            final date = DateTime.parse(tanggal.toString());
            return date.year == tahun;
          } catch (_) {
            return false;
          }
        }).toList();
      }

      // Calculate statistics
      final totalPayments = pembayaranList.length;

      final verifiedCount = pembayaranList.where((p) {
        final status = (p['status']?.toString() ?? '').toLowerCase();
        return status == 'verified';
      }).length;

      final pendingCount = pembayaranList.where((p) {
        final status = (p['status']?.toString() ?? '').toLowerCase();
        return status == 'pending';
      }).length;

      final rejectedCount = pembayaranList.where((p) {
        final status = (p['status']?.toString() ?? '').toLowerCase();
        return status == 'rejected';
      }).length;

      final totalAmount = pembayaranList.fold<double>(0.0, (sum, item) {
        return sum + (toDouble(item['jumlah']) ?? 0.0);
      });

      final stats = {
        'totalPayments': totalPayments,
        'verifiedCount': verifiedCount,
        'pendingCount': pendingCount,
        'rejectedCount': rejectedCount,
        'totalAmount': totalAmount,
      };

      logInfo('Successfully retrieved payment stats', stats);

      return stats;
    } catch (e) {
      logError('Failed to get payment stats', {'error': e.toString()});

      // Return zero values on error
      return {
        'totalPayments': 0,
        'verifiedCount': 0,
        'pendingCount': 0,
        'rejectedCount': 0,
        'totalAmount': 0.0,
      };
    }
  }

  /// Get revenue statistics for a date range
  ///
  /// Provides revenue analysis from pemasukan and pengeluaran:
  /// - Total pemasukan
  /// - Total pengeluaran
  /// - Net profit (laba bersih)
  /// - Revenue by month (if date range spans multiple months)
  ///
  /// Parameters:
  /// - [kostId]: Kost ID (required)
  /// - [startDate]: Start date (optional)
  /// - [endDate]: End date (optional)
  ///
  /// Returns map with revenue statistics
  Future<Map<String, dynamic>> getRevenueStats({
    required String kostId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('Kost ID wajib diisi');
    }

    logDebug('Getting revenue stats', {
      'kostId': kostId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    });

    try {
      // Use KeuanganRepository methods through direct query
      // since we don't have KeuanganRepository as a dependency yet

      // Get pemasukan
      final pemasukanRaw = await supabase
          .from('pemasukan')
          .select('''
            id, 
            jumlah, 
            tanggal,
            penghuni:penghuni_id(
              kamar:kamar_id(
                kost_id
              )
            )
          ''')
          .order('tanggal', ascending: false);

      var pemasukanList = pemasukanRaw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      // Filter by kost_id
      pemasukanList = pemasukanList.where((item) {
        try {
          final penghuni = item['penghuni'];
          if (penghuni is Map) {
            final kamar = penghuni['kamar'];
            if (kamar is Map) {
              return kamar['kost_id'] == kostId.trim();
            }
          }
          return false;
        } catch (_) {
          return false;
        }
      }).toList();

      // Get pengeluaran
      var pengeluaranList = await supabase
          .from('pengeluaran')
          .select('id, jumlah, tanggal')
          .eq('kost_id', kostId.trim())
          .order('tanggal', ascending: false);

      pengeluaranList = pengeluaranList
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      // Apply date filters
      if (startDate != null) {
        pemasukanList = pemasukanList.where((item) {
          final tanggal = item['tanggal'];
          if (tanggal == null) return false;
          try {
            final date = DateTime.parse(tanggal.toString());
            return date.isAfter(startDate.subtract(const Duration(days: 1)));
          } catch (_) {
            return false;
          }
        }).toList();

        pengeluaranList = pengeluaranList.where((item) {
          final tanggal = item['tanggal'];
          if (tanggal == null) return false;
          try {
            final date = DateTime.parse(tanggal.toString());
            return date.isAfter(startDate.subtract(const Duration(days: 1)));
          } catch (_) {
            return false;
          }
        }).toList();
      }

      if (endDate != null) {
        pemasukanList = pemasukanList.where((item) {
          final tanggal = item['tanggal'];
          if (tanggal == null) return false;
          try {
            final date = DateTime.parse(tanggal.toString());
            return date.isBefore(endDate.add(const Duration(days: 1)));
          } catch (_) {
            return false;
          }
        }).toList();

        pengeluaranList = pengeluaranList.where((item) {
          final tanggal = item['tanggal'];
          if (tanggal == null) return false;
          try {
            final date = DateTime.parse(tanggal.toString());
            return date.isBefore(endDate.add(const Duration(days: 1)));
          } catch (_) {
            return false;
          }
        }).toList();
      }

      // Calculate totals
      final totalPemasukan = pemasukanList.fold<double>(0.0, (sum, item) {
        return sum + (toDouble(item['jumlah']) ?? 0.0);
      });

      final totalPengeluaran = pengeluaranList.fold<double>(0.0, (sum, item) {
        return sum + (toDouble(item['jumlah']) ?? 0.0);
      });

      final labaBersih = totalPemasukan - totalPengeluaran;

      final stats = {
        'totalPemasukan': totalPemasukan,
        'totalPengeluaran': totalPengeluaran,
        'labaBersih': labaBersih,
        'pemasukanCount': pemasukanList.length,
        'pengeluaranCount': pengeluaranList.length,
      };

      logInfo('Successfully retrieved revenue stats', {
        'kostId': kostId,
        ...stats,
      });

      return stats;
    } catch (e) {
      logError('Failed to get revenue stats', {
        'kostId': kostId,
        'error': e.toString(),
      });

      // Return zero values on error
      return {
        'totalPemasukan': 0.0,
        'totalPengeluaran': 0.0,
        'labaBersih': 0.0,
        'pemasukanCount': 0,
        'pengeluaranCount': 0,
      };
    }
  }
}
