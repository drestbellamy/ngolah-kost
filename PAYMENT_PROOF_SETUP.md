# Setup Payment Proof Feature

## 🎯 Fitur yang Sudah Dibuat

Fitur untuk menampilkan bukti pembayaran saat user klik card pembayaran di halaman riwayat pembayaran.

### ✅ Yang Sudah Selesai:
1. **Model** - `PaymentDetail` model untuk data pembayaran
2. **Service** - API service dengan Dio untuk fetching data
3. **Controller** - Method `fetchPaymentDetail()` di controller
4. **UI Components**:
   - `PaymentCard` dengan onTap handler
   - `PaymentProofModal` - Modal bottom sheet untuk menampilkan bukti
5. **Mock Service** - Untuk testing tanpa backend
6. **Error Handling** - Loading state, error messages
7. **Image Caching** - Menggunakan `cached_network_image`

---

## 🚀 Cara Menggunakan

### Option 1: Testing dengan Mock Data (Tanpa Backend)

Jika backend belum siap, gunakan mock service:

**1. Edit Controller**
File: `lib/app/modules/user_history_pembayaran/controllers/user_history_pembayaran_controller.dart`

Ganti import:
```dart
// Ganti ini:
import '../../../../services/payment_service.dart';

// Dengan ini:
import '../../../../services/payment_service_mock.dart';
```

Ganti service initialization:
```dart
// Ganti ini:
final PaymentService _paymentService = PaymentService();

// Dengan ini:
final PaymentServiceMock _paymentService = PaymentServiceMock();
```

**2. Test di App**
- Jalankan app
- Buka halaman Riwayat Pembayaran
- Klik salah satu card pembayaran
- Modal akan muncul dengan mock data dan gambar random dari picsum.photos

---

### Option 2: Menggunakan Real API (Production)

Jika backend sudah siap:

**1. Update Base URL**
File: `lib/services/payment_service.dart`

```dart
PaymentService({
  Dio? dio,
  this.baseUrl = 'https://your-actual-api-url.com/api', // ← Ganti dengan URL backend Anda
})
```

**2. Tambahkan Authentication (Jika Perlu)**
```dart
Future<PaymentDetail> getPaymentDetail(String paymentId) async {
  try {
    final response = await _dio.get(
      '$baseUrl/payments/$paymentId',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${yourAuthToken}', // ← Tambahkan token
        },
      ),
    );
    // ...
  }
}
```

**3. Pastikan Controller Menggunakan Real Service**
File: `lib/app/modules/user_history_pembayaran/controllers/user_history_pembayaran_controller.dart`

```dart
import '../../../../services/payment_service.dart'; // ← Real service

final PaymentService _paymentService = PaymentService(); // ← Real service
```

---

## 📋 Backend Requirements

Backend harus menyediakan endpoint berikut:

### Endpoint: Get Payment Detail
```
GET /api/payments/{payment_id}
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Response Format:**
```json
{
  "status": "success",
  "message": "Payment detail retrieved successfully",
  "data": {
    "id": "payment_123",
    "user_id": "user_456",
    "month": "Juli 2026",
    "payment_method": "BCA",
    "amount": 2000000,
    "status": "verified",
    "proof_image_url": "https://storage.example.com/proofs/payment_123.jpg",
    "payment_date": "2026-07-15T10:30:00Z",
    "created_at": "2026-07-15T10:30:00Z",
    "verified_at": "2026-07-16T14:20:00Z",
    "verified_by": "admin_789",
    "rejection_reason": null
  }
}
```

**Status Values:**
- `verified` atau `lunas` - Terverifikasi
- `pending` - Menunggu verifikasi
- `rejected` atau `ditolak` - Ditolak

**Dokumentasi lengkap:** Lihat `lib/services/API_DOCUMENTATION.md`

---

## 🧪 Testing Checklist

### Mock Data Testing:
- [ ] Card pembayaran bisa diklik
- [ ] Loading indicator muncul saat fetch
- [ ] Modal bottom sheet muncul
- [ ] Info pembayaran tampil dengan benar
- [ ] Gambar bukti transfer tampil
- [ ] Status badge tampil dengan warna yang benar
- [ ] Alasan penolakan tampil (untuk status rejected)
- [ ] Modal bisa di-close dengan tombol X atau swipe down

### Real API Testing:
- [ ] API endpoint accessible
- [ ] Authentication token valid
- [ ] Response format sesuai dokumentasi
- [ ] Image URL accessible
- [ ] Error handling bekerja (network error, 404, dll)
- [ ] Loading state smooth
- [ ] Image caching bekerja

---

## 📁 File Structure

```
lib/
├── models/
│   └── payment_detail_model.dart          # Model data
├── services/
│   ├── payment_service.dart               # Real API service
│   ├── payment_service_mock.dart          # Mock service untuk testing
│   └── API_DOCUMENTATION.md               # Dokumentasi API
└── app/modules/user_history_pembayaran/
    ├── controllers/
    │   └── user_history_pembayaran_controller.dart  # Logic & fetching
    ├── views/
    │   └── widgets/
    │       ├── payment_card.dart          # Card dengan onTap
    │       └── payment_proof_modal.dart   # Modal bukti pembayaran
    └── README.md                          # Dokumentasi module
```

---

## 🔧 Troubleshooting

### Problem: Modal tidak muncul
**Solution:**
- Cek console untuk error messages
- Pastikan payment ID tidak kosong
- Cek network connection (jika pakai real API)

### Problem: Gambar tidak muncul
**Solution:**
- Cek URL gambar valid dan accessible
- Pastikan ada internet connection
- Cek console untuk error dari CachedNetworkImage

### Problem: Error "Failed to load payment detail"
**Solution:**
- Cek base URL sudah benar
- Cek endpoint API sudah sesuai
- Cek response format dari backend
- Gunakan mock service untuk isolate masalah

### Problem: Loading terus-menerus
**Solution:**
- Cek network timeout
- Cek backend response time
- Pastikan `isLoadingDetail.value = false` dipanggil di finally block

---

## 📝 Notes untuk Developer

1. **Mock vs Real Service**: 
   - Development: Gunakan mock service
   - Production: Gunakan real service
   - Jangan lupa switch sebelum deploy!

2. **Image Storage**:
   - Backend harus menyimpan gambar di cloud storage
   - URL harus accessible (public atau signed URL)
   - Pertimbangkan image compression

3. **Performance**:
   - Image di-cache otomatis dengan `cached_network_image`
   - Loading state untuk UX yang baik
   - Error handling untuk semua edge cases

4. **Security**:
   - Validasi user hanya bisa akses pembayaran miliknya
   - Gunakan authentication token
   - Jangan expose sensitive data di error messages

---

## 🎨 UI Preview

### Payment Card (Clickable)
```
┌─────────────────────────────────────┐
│  ✓   Juli 2026      [Terverifikasi] │
│      BCA                             │
│      Rp 2.000.000    📅 19 Mei 2026 │
└─────────────────────────────────────┘
```

### Payment Proof Modal
```
┌─────────────────────────────────────┐
│  Bukti Pembayaran              ✕    │
├─────────────────────────────────────┤
│  Periode: Juli 2026                 │
│  Metode: BCA                        │
│  Jumlah: Rp 2.000.000              │
│  Tanggal: 15 Juli 2026             │
│  Status: [Terverifikasi]           │
│                                     │
│  Bukti Transfer                     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │     [Transfer Receipt]      │   │
│  │                             │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## 📞 Support

Jika ada pertanyaan atau masalah:
1. Cek dokumentasi di `lib/services/API_DOCUMENTATION.md`
2. Cek README di `lib/app/modules/user_history_pembayaran/README.md`
3. Test dengan mock service terlebih dahulu
4. Hubungi backend developer untuk masalah API

---

**Happy Coding! 🚀**
