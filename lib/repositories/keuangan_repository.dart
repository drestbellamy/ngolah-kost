import 'package:supabase_flutter/supabase_flutter.dart';
import 'base/base_repository.dart';
import 'base/constants.dart';

/// Repository for financial operations (pemasukan and pengeluaran)
/// Handles CRUD operations for income and expense tracking
class KeuanganRepository extends BaseRepository {
  @override
  String get repositoryName => 'KeuanganRepository';

  /// Get all pemasukan (income) with optional filters
  ///
  /// Uses graceful degradation pattern with multiple select attempts
  /// to handle different database schema versions
  ///
  /// Parameters:
  /// - [kostId]: Filter by kost ID (required)
  /// - [startDate]: Optional start date filter
  /// - [endDate]: Optional end date filter
  /// - [bulan]: Optional month filter (1-12)
  /// - [tahun]: Optional year filter
  ///
  /// Returns list of pemasukan maps with enriched data (nama_penghuni)
  ///
  /// Throws [Exception] if kostId is empty or all attempts fail
  Future<List<Map<String, dynamic>>> getPemasukanList({
    required String kostId,
    DateTime? startDate,
    DateTime? endDate,
    int? bulan,
    int? tahun,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('Kost ID wajib diisi');
    }

    logDebug('Getting pemasukan list', {
      'kostId': kostId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'bulan': bulan,
      'tahun': tahun,
    });

    try {
      // Ambil pemasukan dengan join ke penghuni dan kamar
      final response = await supabase
          .from(RepositoryConstants.pemasukanTable)
          .select('''
            id, 
            penghuni_id, 
            jumlah, 
            tanggal, 
            keterangan,
            pembayaran_id,
            created_at,
            penghuni:penghuni_id(
              kamar:kamar_id(
                kost_id
              )
            )
          ''')
          .order('tanggal', ascending: false);

      // Ensure we have a List<dynamic>
      final raw = List<dynamic>.from(response);

      // Filter by kost_id
      var kostFiltered = raw.where((item) {
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

      logDebug('Filtered pemasukan by kost', {
        'totalRaw': raw.length,
        'filteredCount': kostFiltered.length,
        'kostId': kostId,
      });

      // Apply date filters if provided
      if (startDate != null) {
        kostFiltered = kostFiltered.where((item) {
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
        kostFiltered = kostFiltered.where((item) {
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

      // Apply month filter if provided
      if (bulan != null && bulan >= 1 && bulan <= 12) {
        kostFiltered = kostFiltered.where((item) {
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

      // Apply year filter if provided
      if (tahun != null) {
        kostFiltered = kostFiltered.where((item) {
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

      // Untuk setiap pemasukan, ambil nama penghuni
      final enrichedData = <Map<String, dynamic>>[];

      for (final item in kostFiltered) {
        final map = Map<String, dynamic>.from(item);
        final pembayaranId = item['pembayaran_id']?.toString();

        // Default nama
        map['nama_penghuni'] = 'Penghuni';

        if (pembayaranId != null && pembayaranId.isNotEmpty) {
          try {
            // Ambil nama dari pembayaran
            final pembayaranData = await supabase
                .from(RepositoryConstants.pembayaranTable)
                .select('''
                  penghuni:penghuni_id(
                    users:user_id(
                      nama
                    )
                  )
                ''')
                .eq('id', pembayaranId)
                .maybeSingle();

            if (pembayaranData != null) {
              final penghuni = pembayaranData['penghuni'];
              if (penghuni is Map) {
                final users = penghuni['users'];
                if (users is Map && users['nama'] != null) {
                  map['nama_penghuni'] =
                      users['nama']?.toString() ?? 'Penghuni';
                }
              }
            }
          } catch (e) {
            logDebug('Error getting nama for pembayaran', {
              'pembayaranId': pembayaranId,
              'error': e.toString(),
            });
          }
        }

        enrichedData.add(map);
      }

      logInfo('Successfully retrieved pemasukan list', {
        'count': enrichedData.length,
        'kostId': kostId,
      });

      return enrichedData;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get pemasukan list', {
        'kostId': kostId,
        'error': errorMsg,
      });
      throw Exception('Gagal memuat data pemasukan: $errorMsg');
    } catch (e) {
      logError('Unexpected error getting pemasukan list', {
        'kostId': kostId,
        'error': e.toString(),
      });
      throw Exception('Gagal memuat data pemasukan: ${e.toString()}');
    }
  }

  /// Get pemasukan by ID
  ///
  /// Parameters:
  /// - [id]: Pemasukan ID
  ///
  /// Returns pemasukan map or null if not found
  ///
  /// Throws [Exception] on database error
  Future<Map<String, dynamic>?> getPemasukanById(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pemasukan tidak valid');
    }

    logDebug('Getting pemasukan by ID', {'id': id});

    try {
      final result = await supabase
          .from(RepositoryConstants.pemasukanTable)
          .select('*')
          .eq('id', id.trim())
          .maybeSingle();

      if (result == null) {
        logInfo('Pemasukan not found', {'id': id});
        return null;
      }

      logInfo('Successfully retrieved pemasukan', {'id': id});
      return Map<String, dynamic>.from(result);
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get pemasukan by ID', {'id': id, 'error': errorMsg});
      throw Exception('Gagal memuat pemasukan: $errorMsg');
    }
  }

  /// Create new pemasukan
  ///
  /// Parameters:
  /// - [penghuniId]: Penghuni ID (required)
  /// - [jumlah]: Amount (required)
  /// - [tanggal]: Date (required)
  /// - [keterangan]: Description (optional)
  /// - [pembayaranId]: Related pembayaran ID (optional)
  ///
  /// Returns the created pemasukan ID
  ///
  /// Throws [Exception] on validation error or database error
  Future<String> createPemasukan({
    required String penghuniId,
    required double jumlah,
    required DateTime tanggal,
    String? keterangan,
    String? pembayaranId,
  }) async {
    // Validation
    if (penghuniId.trim().isEmpty) {
      throw Exception('Penghuni wajib dipilih');
    }

    if (jumlah <= 0) {
      throw Exception('Jumlah harus lebih dari 0');
    }

    logDebug('Creating pemasukan', {
      'penghuniId': penghuniId,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
    });

    final payload = <String, dynamic>{
      'penghuni_id': penghuniId.trim(),
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'keterangan': (keterangan ?? '').trim().isEmpty
          ? null
          : keterangan!.trim(),
      'pembayaran_id': (pembayaranId ?? '').trim().isEmpty
          ? null
          : pembayaranId!.trim(),
    };

    try {
      final result = await supabase
          .from(RepositoryConstants.pemasukanTable)
          .insert(payload)
          .select('id')
          .single();

      final id = result['id'] as String;

      logInfo('Successfully created pemasukan', {'id': id, 'jumlah': jumlah});

      return id;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to create pemasukan', {
        'error': errorMsg,
        'payload': payload,
      });
      throw Exception('Gagal membuat pemasukan: $errorMsg');
    }
  }

  /// Update existing pemasukan
  ///
  /// Parameters:
  /// - [id]: Pemasukan ID (required)
  /// - [penghuniId]: Penghuni ID (required)
  /// - [jumlah]: Amount (required)
  /// - [tanggal]: Date (required)
  /// - [keterangan]: Description (optional)
  /// - [pembayaranId]: Related pembayaran ID (optional)
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> updatePemasukan({
    required String id,
    required String penghuniId,
    required double jumlah,
    required DateTime tanggal,
    String? keterangan,
    String? pembayaranId,
  }) async {
    // Validation
    if (id.trim().isEmpty) {
      throw Exception('ID pemasukan tidak valid');
    }

    if (penghuniId.trim().isEmpty) {
      throw Exception('Penghuni wajib dipilih');
    }

    if (jumlah <= 0) {
      throw Exception('Jumlah harus lebih dari 0');
    }

    logDebug('Updating pemasukan', {
      'id': id,
      'penghuniId': penghuniId,
      'jumlah': jumlah,
    });

    final payload = <String, dynamic>{
      'penghuni_id': penghuniId.trim(),
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'keterangan': (keterangan ?? '').trim().isEmpty
          ? null
          : keterangan!.trim(),
      'pembayaran_id': (pembayaranId ?? '').trim().isEmpty
          ? null
          : pembayaranId!.trim(),
    };

    try {
      await supabase
          .from(RepositoryConstants.pemasukanTable)
          .update(payload)
          .eq('id', id.trim());

      logInfo('Successfully updated pemasukan', {'id': id, 'jumlah': jumlah});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update pemasukan', {'id': id, 'error': errorMsg});
      throw Exception('Gagal mengupdate pemasukan: $errorMsg');
    }
  }

  /// Delete pemasukan
  ///
  /// Parameters:
  /// - [id]: Pemasukan ID
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> deletePemasukan(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pemasukan tidak valid');
    }

    logDebug('Deleting pemasukan', {'id': id});

    try {
      await supabase
          .from(RepositoryConstants.pemasukanTable)
          .delete()
          .eq('id', id.trim());

      logInfo('Successfully deleted pemasukan', {'id': id});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to delete pemasukan', {'id': id, 'error': errorMsg});
      throw Exception('Gagal menghapus pemasukan: $errorMsg');
    }
  }

  /// Get all pengeluaran (expenses) with optional filters
  ///
  /// Parameters:
  /// - [kostId]: Filter by kost ID (required)
  /// - [startDate]: Optional start date filter
  /// - [endDate]: Optional end date filter
  /// - [bulan]: Optional month filter (1-12)
  /// - [tahun]: Optional year filter
  ///
  /// Returns list of pengeluaran maps
  ///
  /// Throws [Exception] if kostId is empty or database error
  Future<List<Map<String, dynamic>>> getPengeluaranList({
    required String kostId,
    DateTime? startDate,
    DateTime? endDate,
    int? bulan,
    int? tahun,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('Kost ID wajib diisi');
    }

    logDebug('Getting pengeluaran list', {
      'kostId': kostId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'bulan': bulan,
      'tahun': tahun,
    });

    try {
      final response = await supabase
          .from(RepositoryConstants.pengeluaranTable)
          .select('id, nama, jumlah, tanggal, deskripsi, created_at')
          .eq('kost_id', kostId.trim())
          .order('tanggal', ascending: false);

      final raw = List<dynamic>.from(response);

      var result = raw.map((item) => Map<String, dynamic>.from(item)).toList();

      logDebug('Retrieved pengeluaran raw data', {
        'count': result.length,
        'kostId': kostId,
      });

      // Apply date filters if provided
      if (startDate != null) {
        result = result.where((item) {
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
        result = result.where((item) {
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

      // Apply month filter if provided
      if (bulan != null && bulan >= 1 && bulan <= 12) {
        result = result.where((item) {
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

      // Apply year filter if provided
      if (tahun != null) {
        result = result.where((item) {
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

      logInfo('Successfully retrieved pengeluaran list', {
        'count': result.length,
        'kostId': kostId,
      });

      return result;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get pengeluaran list', {
        'kostId': kostId,
        'error': errorMsg,
      });
      throw Exception('Gagal memuat data pengeluaran: $errorMsg');
    } catch (e) {
      logError('Unexpected error getting pengeluaran list', {
        'kostId': kostId,
        'error': e.toString(),
      });
      throw Exception('Gagal memuat data pengeluaran: ${e.toString()}');
    }
  }

  /// Get pengeluaran by ID
  ///
  /// Parameters:
  /// - [id]: Pengeluaran ID
  ///
  /// Returns pengeluaran map or null if not found
  ///
  /// Throws [Exception] on database error
  Future<Map<String, dynamic>?> getPengeluaranById(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengeluaran tidak valid');
    }

    logDebug('Getting pengeluaran by ID', {'id': id});

    try {
      final result = await supabase
          .from(RepositoryConstants.pengeluaranTable)
          .select('*')
          .eq('id', id.trim())
          .maybeSingle();

      if (result == null) {
        logInfo('Pengeluaran not found', {'id': id});
        return null;
      }

      logInfo('Successfully retrieved pengeluaran', {'id': id});
      return Map<String, dynamic>.from(result);
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to get pengeluaran by ID', {
        'id': id,
        'error': errorMsg,
      });
      throw Exception('Gagal memuat pengeluaran: $errorMsg');
    }
  }

  /// Create new pengeluaran
  ///
  /// Parameters:
  /// - [kostId]: Kost ID (required)
  /// - [nama]: Expense name/category (required)
  /// - [jumlah]: Amount (required)
  /// - [tanggal]: Date (required)
  /// - [deskripsi]: Description (optional)
  ///
  /// Returns the created pengeluaran ID
  ///
  /// Throws [Exception] on validation error or database error
  Future<String> createPengeluaran({
    required String kostId,
    required String nama,
    required double jumlah,
    required DateTime tanggal,
    String? deskripsi,
  }) async {
    // Validation
    if (kostId.trim().isEmpty) {
      throw Exception('Kost wajib dipilih');
    }

    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama pengeluaran wajib diisi');
    }

    if (jumlah <= 0) {
      throw Exception('Jumlah harus lebih dari 0');
    }

    logDebug('Creating pengeluaran', {
      'kostId': kostId,
      'nama': cleanNama,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
    });

    final payload = <String, dynamic>{
      'kost_id': kostId.trim(),
      'nama': cleanNama,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'deskripsi': (deskripsi ?? '').trim().isEmpty ? null : deskripsi!.trim(),
    };

    try {
      final result = await supabase
          .from(RepositoryConstants.pengeluaranTable)
          .insert(payload)
          .select('id')
          .single();

      final id = result['id'] as String;

      logInfo('Successfully created pengeluaran', {
        'id': id,
        'nama': cleanNama,
        'jumlah': jumlah,
      });

      return id;
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to create pengeluaran', {
        'error': errorMsg,
        'payload': payload,
      });
      throw Exception('Gagal membuat pengeluaran: $errorMsg');
    }
  }

  /// Update existing pengeluaran
  ///
  /// Parameters:
  /// - [id]: Pengeluaran ID (required)
  /// - [kostId]: Kost ID (required)
  /// - [nama]: Expense name/category (required)
  /// - [jumlah]: Amount (required)
  /// - [tanggal]: Date (required)
  /// - [deskripsi]: Description (optional)
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> updatePengeluaran({
    required String id,
    required String kostId,
    required String nama,
    required double jumlah,
    required DateTime tanggal,
    String? deskripsi,
  }) async {
    // Validation
    if (id.trim().isEmpty) {
      throw Exception('ID pengeluaran tidak valid');
    }

    if (kostId.trim().isEmpty) {
      throw Exception('Kost wajib dipilih');
    }

    final cleanNama = nama.trim();
    if (cleanNama.isEmpty) {
      throw Exception('Nama pengeluaran wajib diisi');
    }

    if (jumlah <= 0) {
      throw Exception('Jumlah harus lebih dari 0');
    }

    logDebug('Updating pengeluaran', {
      'id': id,
      'kostId': kostId,
      'nama': cleanNama,
      'jumlah': jumlah,
    });

    final payload = <String, dynamic>{
      'kost_id': kostId.trim(),
      'nama': cleanNama,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
      'deskripsi': (deskripsi ?? '').trim().isEmpty ? null : deskripsi!.trim(),
    };

    try {
      await supabase
          .from(RepositoryConstants.pengeluaranTable)
          .update(payload)
          .eq('id', id.trim());

      logInfo('Successfully updated pengeluaran', {
        'id': id,
        'nama': cleanNama,
        'jumlah': jumlah,
      });
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to update pengeluaran', {'id': id, 'error': errorMsg});
      throw Exception('Gagal mengupdate pengeluaran: $errorMsg');
    }
  }

  /// Delete pengeluaran
  ///
  /// Parameters:
  /// - [id]: Pengeluaran ID
  ///
  /// Throws [Exception] on validation error or database error
  Future<void> deletePengeluaran(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('ID pengeluaran tidak valid');
    }

    logDebug('Deleting pengeluaran', {'id': id});

    try {
      await supabase
          .from(RepositoryConstants.pengeluaranTable)
          .delete()
          .eq('id', id.trim());

      logInfo('Successfully deleted pengeluaran', {'id': id});
    } on PostgrestException catch (e) {
      final errorMsg = formatPostgrestError(e);
      logError('Failed to delete pengeluaran', {'id': id, 'error': errorMsg});
      throw Exception('Gagal menghapus pengeluaran: $errorMsg');
    }
  }

  /// Get financial summary for a kost
  ///
  /// Calculates total pemasukan, total pengeluaran, and net profit
  ///
  /// Parameters:
  /// - [kostId]: Kost ID (required)
  /// - [startDate]: Optional start date filter
  /// - [endDate]: Optional end date filter
  /// - [bulan]: Optional month filter (1-12)
  /// - [tahun]: Optional year filter
  ///
  /// Returns map with pemasukan, pengeluaran, and labaBersih
  ///
  /// Throws [Exception] if kostId is empty
  Future<Map<String, dynamic>> getFinancialSummary({
    required String kostId,
    DateTime? startDate,
    DateTime? endDate,
    int? bulan,
    int? tahun,
  }) async {
    if (kostId.trim().isEmpty) {
      throw Exception('Kost ID wajib diisi');
    }

    logDebug('Getting financial summary', {
      'kostId': kostId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'bulan': bulan,
      'tahun': tahun,
    });

    try {
      // Get pemasukan and pengeluaran with same filters
      final pemasukanList = await getPemasukanList(
        kostId: kostId,
        startDate: startDate,
        endDate: endDate,
        bulan: bulan,
        tahun: tahun,
      );

      final pengeluaranList = await getPengeluaranList(
        kostId: kostId,
        startDate: startDate,
        endDate: endDate,
        bulan: bulan,
        tahun: tahun,
      );

      // Calculate totals
      final totalPemasukan = pemasukanList.fold<double>(0.0, (sum, item) {
        return sum + (toDouble(item['jumlah']) ?? 0.0);
      });

      final totalPengeluaran = pengeluaranList.fold<double>(0.0, (sum, item) {
        return sum + (toDouble(item['jumlah']) ?? 0.0);
      });

      final labaBersih = totalPemasukan - totalPengeluaran;

      final summary = {
        'pemasukan': totalPemasukan,
        'pengeluaran': totalPengeluaran,
        'labaBersih': labaBersih,
      };

      logInfo('Successfully calculated financial summary', {
        'kostId': kostId,
        'pemasukan': totalPemasukan,
        'pengeluaran': totalPengeluaran,
        'labaBersih': labaBersih,
      });

      return summary;
    } catch (e) {
      logError('Failed to get financial summary', {
        'kostId': kostId,
        'error': e.toString(),
      });
      // Return zero values on error
      return {'pemasukan': 0.0, 'pengeluaran': 0.0, 'labaBersih': 0.0};
    }
  }
}
