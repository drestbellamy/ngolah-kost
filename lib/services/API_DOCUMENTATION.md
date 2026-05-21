# API Documentation - Payment Service

## Base URL
```
https://your-api-url.com/api
```

## Authentication
Semua endpoint memerlukan authentication token di header:
```
Authorization: Bearer {your_token}
```

---

## Endpoints

### 1. Get Payment Detail
Mendapatkan detail pembayaran beserta bukti transfer

**Endpoint:** `GET /payments/{payment_id}`

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}"
}
```

**Response Success (200):**
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

**Response Error (404):**
```json
{
  "status": "error",
  "message": "Payment not found",
  "data": null
}
```

**Response Error (401):**
```json
{
  "status": "error",
  "message": "Unauthorized",
  "data": null
}
```

---

### 2. Get Payment History
Mendapatkan semua riwayat pembayaran user

**Endpoint:** `GET /payments/user/{user_id}`

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}"
}
```

**Response Success (200):**
```json
{
  "status": "success",
  "message": "Payment history retrieved successfully",
  "data": [
    {
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
    },
    {
      "id": "payment_124",
      "user_id": "user_456",
      "month": "Juni 2026",
      "payment_method": "BCA",
      "amount": 2000000,
      "status": "pending",
      "proof_image_url": "https://storage.example.com/proofs/payment_124.jpg",
      "payment_date": "2026-06-15T10:30:00Z",
      "created_at": "2026-06-15T10:30:00Z",
      "verified_at": null,
      "verified_by": null,
      "rejection_reason": null
    },
    {
      "id": "payment_125",
      "user_id": "user_456",
      "month": "Mei 2026",
      "payment_method": "BCA",
      "amount": 2000000,
      "status": "rejected",
      "proof_image_url": "https://storage.example.com/proofs/payment_125.jpg",
      "payment_date": "2026-05-15T10:30:00Z",
      "created_at": "2026-05-15T10:30:00Z",
      "verified_at": null,
      "verified_by": "admin_789",
      "rejection_reason": "Bukti transfer tidak jelas, mohon upload ulang dengan kualitas lebih baik"
    }
  ]
}
```

---

## Status Values

| Status | Description |
|--------|-------------|
| `pending` | Menunggu verifikasi admin |
| `verified` atau `lunas` | Pembayaran telah diverifikasi |
| `rejected` atau `ditolak` | Pembayaran ditolak |

---

## Notes untuk Backend Developer

1. **Image Storage**: Gunakan cloud storage (AWS S3, Google Cloud Storage, atau sejenisnya) untuk menyimpan bukti transfer
2. **Image URL**: Pastikan URL gambar dapat diakses secara public atau dengan signed URL
3. **Image Format**: Support format JPG, PNG, PDF
4. **Image Size**: Maksimal 5MB per file
5. **Security**: 
   - Validasi user hanya bisa akses pembayaran miliknya sendiri
   - Admin bisa akses semua pembayaran
   - Gunakan JWT token untuk authentication
6. **Pagination**: Untuk endpoint history, pertimbangkan menambahkan pagination jika data banyak

---

## Example cURL Request

### Get Payment Detail
```bash
curl -X GET \
  'https://your-api-url.com/api/payments/payment_123' \
  -H 'Authorization: Bearer your_token_here' \
  -H 'Content-Type: application/json'
```

### Get Payment History
```bash
curl -X GET \
  'https://your-api-url.com/api/payments/user/user_456' \
  -H 'Authorization: Bearer your_token_here' \
  -H 'Content-Type: application/json'
```
