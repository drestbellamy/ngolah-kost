/// Centralized constants for repositories
class RepositoryConstants {
  // Storage Buckets
  static const String metodePembayaranQrisBucket = 'metode-pembayaran-qris';
  static const String buktiPembayaranBucket = 'bukti-pembayaran';
  static const String fotoProfilBucket = 'foto-profil';

  // Table Names
  static const String usersTable = 'users';
  static const String kostTable = 'kost';
  static const String kamarTable = 'kamar';
  static const String penghuniTable = 'penghuni';
  static const String tagihanTable = 'tagihan';
  static const String pembayaranTable = 'pembayaran';
  static const String metodePembayaranTable = 'metode_pembayaran';
  static const String pengumumanTable = 'pengumuman';
  static const String peraturanTable = 'peraturan';
  static const String pemasukanTable = 'pemasukan';
  static const String pengeluaranTable = 'pengeluaran';

  // RPC Function Names
  static const String loginUserSecureRpc = 'login_user_secure';
  static const String createUserSecureRpc = 'create_user_secure';
  static const String getUserByIdRpc = 'get_user_by_id';
  static const String deleteUserByIdRpc = 'delete_user_by_id';
  static const String verifyUserPasswordRpc = 'verify_user_password';
  static const String updateUserUsernameRpc = 'update_user_username';
  static const String updateUserPasswordRpc = 'update_user_password';
  static const String updateUserFotoProfilRpc = 'update_user_foto_profil';
  static const String getPenghuniByKamarSecureRpc =
      'get_penghuni_by_kamar_secure';
  static const String getUserProfileDataRpc = 'get_user_profile_data';

  // Status Values
  static const String statusAktif = 'aktif';
  static const String statusNonAktif = 'non_aktif';
  static const String statusKosong = 'kosong';
  static const String statusTerisi = 'terisi';
  static const String statusPenuh = 'penuh';
  static const String statusBelumDibayar = 'belum_dibayar';
  static const String statusMenungguVerifikasi = 'menunggu_verifikasi';
  static const String statusLunas = 'lunas';
  static const String statusPending = 'pending';
  static const String statusVerified = 'verified';
  static const String statusRejected = 'rejected';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Payment Types
  static const String paymentTypeTransferBank = 'transfer_bank';
  static const String paymentTypeQris = 'qris';
  static const String paymentTypeTunai = 'tunai';

  // Month Names (Indonesian)
  static const List<String> monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
}
