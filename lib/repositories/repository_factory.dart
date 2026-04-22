import 'auth_repository.dart';
import 'kost_repository.dart';
import 'kamar_repository.dart';
import 'penghuni_repository.dart';
import 'tagihan_repository.dart';
import 'pembayaran_repository.dart';
import 'storage_repository.dart';
import 'metode_pembayaran_repository.dart';
import 'pengumuman_repository.dart';
import 'peraturan_repository.dart';
import 'keuangan_repository.dart';
import 'dashboard_repository.dart';

/// Singleton factory for creating and managing repository instances
/// Provides lazy initialization and dependency injection
class RepositoryFactory {
  // Singleton instance
  static final RepositoryFactory _instance = RepositoryFactory._internal();

  /// Private constructor for singleton pattern
  RepositoryFactory._internal();

  /// Get singleton instance
  static RepositoryFactory get instance => _instance;

  // Private nullable fields for lazy initialization
  AuthRepository? _authRepository;
  KostRepository? _kostRepository;
  KamarRepository? _kamarRepository;
  PenghuniRepository? _penghuniRepository;
  TagihanRepository? _tagihanRepository;
  PembayaranRepository? _pembayaranRepository;
  StorageRepository? _storageRepository;
  MetodePembayaranRepository? _metodePembayaranRepository;
  PengumumanRepository? _pengumumanRepository;
  PeraturanRepository? _peraturanRepository;
  KeuanganRepository? _keuanganRepository;
  DashboardRepository? _dashboardRepository;

  /// Get AuthRepository instance (lazy initialized)
  AuthRepository get authRepository {
    _authRepository ??= AuthRepository();
    return _authRepository!;
  }

  /// Get KostRepository instance (lazy initialized)
  KostRepository get kostRepository {
    _kostRepository ??= KostRepository();
    return _kostRepository!;
  }

  /// Get KamarRepository instance (lazy initialized)
  KamarRepository get kamarRepository {
    _kamarRepository ??= KamarRepository();
    return _kamarRepository!;
  }

  /// Get PenghuniRepository instance (lazy initialized with dependencies)
  PenghuniRepository get penghuniRepository {
    _penghuniRepository ??= PenghuniRepository(
      kostRepository: kostRepository,
      kamarRepository: kamarRepository,
    );
    return _penghuniRepository!;
  }

  /// Get TagihanRepository instance (lazy initialized)
  TagihanRepository get tagihanRepository {
    _tagihanRepository ??= TagihanRepository();
    return _tagihanRepository!;
  }

  /// Get PembayaranRepository instance (lazy initialized with dependencies)
  PembayaranRepository get pembayaranRepository {
    _pembayaranRepository ??= PembayaranRepository(
      tagihanRepository: tagihanRepository,
    );
    return _pembayaranRepository!;
  }

  /// Get StorageRepository instance (lazy initialized)
  StorageRepository get storageRepository {
    _storageRepository ??= StorageRepository();
    return _storageRepository!;
  }

  /// Get MetodePembayaranRepository instance (lazy initialized with dependencies)
  MetodePembayaranRepository get metodePembayaranRepository {
    _metodePembayaranRepository ??= MetodePembayaranRepository(
      storageRepository: storageRepository,
    );
    return _metodePembayaranRepository!;
  }

  /// Get PengumumanRepository instance (lazy initialized)
  PengumumanRepository get pengumumanRepository {
    _pengumumanRepository ??= PengumumanRepository();
    return _pengumumanRepository!;
  }

  /// Get PeraturanRepository instance (lazy initialized)
  PeraturanRepository get peraturanRepository {
    _peraturanRepository ??= PeraturanRepository();
    return _peraturanRepository!;
  }

  /// Get KeuanganRepository instance (lazy initialized)
  KeuanganRepository get keuanganRepository {
    _keuanganRepository ??= KeuanganRepository();
    return _keuanganRepository!;
  }

  /// Get DashboardRepository instance (lazy initialized with dependencies)
  DashboardRepository get dashboardRepository {
    _dashboardRepository ??= DashboardRepository(
      kostRepository: kostRepository,
      kamarRepository: kamarRepository,
      penghuniRepository: penghuniRepository,
      tagihanRepository: tagihanRepository,
      pembayaranRepository: pembayaranRepository,
    );
    return _dashboardRepository!;
  }

  /// Reset all repository instances (useful for testing)
  void reset() {
    _authRepository = null;
    _kostRepository = null;
    _kamarRepository = null;
    _penghuniRepository = null;
    _tagihanRepository = null;
    _pembayaranRepository = null;
    _storageRepository = null;
    _metodePembayaranRepository = null;
    _pengumumanRepository = null;
    _peraturanRepository = null;
    _keuanganRepository = null;
    _dashboardRepository = null;
  }

  /// Inject custom repository instances (useful for testing with mocks)
  void inject({
    AuthRepository? authRepository,
    KostRepository? kostRepository,
    KamarRepository? kamarRepository,
    PenghuniRepository? penghuniRepository,
    TagihanRepository? tagihanRepository,
    PembayaranRepository? pembayaranRepository,
    StorageRepository? storageRepository,
    MetodePembayaranRepository? metodePembayaranRepository,
    PengumumanRepository? pengumumanRepository,
    PeraturanRepository? peraturanRepository,
    KeuanganRepository? keuanganRepository,
    DashboardRepository? dashboardRepository,
  }) {
    if (authRepository != null) _authRepository = authRepository;
    if (kostRepository != null) _kostRepository = kostRepository;
    if (kamarRepository != null) _kamarRepository = kamarRepository;
    if (penghuniRepository != null) _penghuniRepository = penghuniRepository;
    if (tagihanRepository != null) _tagihanRepository = tagihanRepository;
    if (pembayaranRepository != null) {
      _pembayaranRepository = pembayaranRepository;
    }
    if (storageRepository != null) _storageRepository = storageRepository;
    if (metodePembayaranRepository != null) {
      _metodePembayaranRepository = metodePembayaranRepository;
    }
    if (pengumumanRepository != null) {
      _pengumumanRepository = pengumumanRepository;
    }
    if (peraturanRepository != null) {
      _peraturanRepository = peraturanRepository;
    }
    if (keuanganRepository != null) _keuanganRepository = keuanganRepository;
    if (dashboardRepository != null) {
      _dashboardRepository = dashboardRepository;
    }
  }
}
