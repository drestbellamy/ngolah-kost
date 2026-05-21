# User History Pembayaran - Payment Proof Feature

## Overview
Fitur ini memungkinkan user untuk melihat bukti transfer pembayaran dengan cara mengklik card pembayaran di halaman riwayat pembayaran.

## Features
- ✅ Tampilan list riwayat pembayaran
- ✅ Filter pembayaran (Semua, Lunas, Pending)
- ✅ Klik card untuk melihat detail & bukti transfer
- ✅ Modal bottom sheet dengan bukti pembayaran
- ✅ Loading state saat fetch data
- ✅ Error handling
- ✅ Cached network image untuk performa optimal
- ✅ Responsive design

## File Structure
```
lib/
├── models/
│   └── payment_detail_model.dart          # Model untuk detail pembayaran
├── services/
│   ├── payment_service.dart               # Service untuk API calls
│   └── API_DOCUMENTATION.md               # Dokumentasi API
└── app/modules/user_history_pembayaran/
    ├── controllers/
    │   └── user_history_pembayaran_controller.dart
    ├── views/
    │   ├── user_history_pembayaran_view.dart
    │   └── widgets/
    │       ├── payment_card.dart          # Card pembayaran (dengan onTap)
    │       ├── payment_proof_modal.dart   # Modal bukti pembayaran
    │       ├── payment_history_list.dart
    │       ├── filter_tabs.dart
    │       └── total_payment_card.dart
    └── README.md
```

## How It Works

### 1. User Flow
1. User membuka halaman "Riwayat Pembayaran"
2. User melihat list pembayaran yang sudah dilakukan
3. User **klik salah satu card pembayaran** (misal: Juli 2026)
4. Loading indicator muncul
5. System fetch detail pembayaran dari API
6. Modal bottom sheet muncul menampilkan:
   - Info pembayaran (periode, metode, jumlah, tanggal, status)
   - Bukti transfer (gambar)
   - Alasan penolakan (jika ditolak)

### 2. Technical Flow
```
PaymentCard (onTap)
    ↓
_showPaymentProof()
    ↓
controller.fetchPaymentDetail(paymentId)
    ↓
PaymentService.getPaymentDetail()
    ↓
API Call: GET /payments/{id}
    ↓
PaymentDetail Model
    ↓
PaymentProofModal (Bottom Sheet)
```

## Setup Instructions

### 1. Update Base URL
Edit file `lib/services/payment_service.dart`:
```dart
PaymentService({
  Dio? dio,
  this.baseUrl = 'https://your-actual-api-url.com/api', // ← Ganti ini
})
```

### 2. Add Authentication Token (Optional)
Jika API memerlukan token, tambahkan di `payment_service.dart`:
```dart
final response = await _dio.get(
  '$baseUrl/payments/$paymentId',
  options: Options(
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${yourToken}', // ← Tambahkan token
    },
  ),
);
```

### 3. Backend Requirements
Backend harus menyediakan endpoint:
- `GET /api/payments/{payment_id}` - Detail pembayaran
- Response format sesuai dokumentasi di `lib/services/API_DOCUMENTATION.md`

## API Response Example
```json
{
  "status": "success",
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

## Testing Without Backend

Untuk testing tanpa backend, Anda bisa:

### Option 1: Mock Data
Edit `payment_service.dart` dan return mock data:
```dart
Future<PaymentDetail> getPaymentDetail(String paymentId) async {
  // Mock data untuk testing
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  
  return PaymentDetail(
    id: paymentId,
    userId: 'user_123',
    month: 'Juli 2026',
    paymentMethod: 'BCA',
    amount: 2000000,
    status: 'verified',
    proofImageUrl: 'https://picsum.photos/400/600', // Random image
    paymentDate: DateTime.now(),
    createdAt: DateTime.now(),
  );
}
```

### Option 2: Use Mock API
Gunakan service seperti:
- [Mockapi.io](https://mockapi.io/)
- [JSONPlaceholder](https://jsonplaceholder.typicode.com/)
- [Mocky.io](https://designer.mocky.io/)

## Dependencies Used
```yaml
dependencies:
  dio: ^5.4.0                      # HTTP client
  cached_network_image: ^3.3.1     # Image caching
  get: ^4.6.6                      # State management
  intl: ^0.19.0                    # Date formatting
```

## UI Components

### PaymentCard
- Menampilkan info pembayaran dalam card
- **Clickable** - membuka modal saat diklik
- Status indicator (icon & badge)
- Responsive design

### PaymentProofModal
- Bottom sheet modal (85% screen height)
- Scrollable content
- Info pembayaran lengkap
- Bukti transfer image dengan:
  - Loading placeholder
  - Error handling
  - Cached image
- Rejection reason (jika ada)

## Error Handling
- Network error → Snackbar error message
- Invalid payment ID → Snackbar error
- Image load error → Placeholder dengan icon
- No proof image → "Bukti tidak tersedia" message

## Performance Optimization
- ✅ Cached network images
- ✅ Lazy loading list
- ✅ Efficient state management dengan GetX
- ✅ Minimal rebuilds

## Next Steps
1. ✅ Implementasi frontend (DONE)
2. ⏳ Backend API development
3. ⏳ Integration testing
4. ⏳ Upload bukti pembayaran feature
5. ⏳ Admin verification feature

## Notes
- Pastikan backend sudah siap sebelum testing di production
- Gunakan mock data untuk development
- Image URL harus accessible (public atau signed URL)
- Pertimbangkan image compression untuk performa
