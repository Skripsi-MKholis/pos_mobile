# Implementation Plan — Milestone 2 & 3 (Updated)
### POS Mobile — Mesin Kasir, Transaksi, Laporan & Dashboard

---

## Klarifikasi Konfirmasi

| Poin | Keputusan |
|------|-----------|
| **Offline Mode** | ✅ **Hybrid Mode** — Wajib. App berjalan penuh offline, sync otomatis saat online |
| **Struk** | ✅ **Keduanya** — Bluetooth Thermal Printer **DAN** WhatsApp/PDF |

---

## Background & Kondisi Kode Saat Ini

| File | Status | Pekerjaan yang Dibutuhkan |
|------|--------|--------------------------|
| `kasir_page.dart` | UI Lengkap ✅ | Ganti dummy products → Supabase/lokal |
| `checkout_page.dart` | UI Lengkap ✅ | Tambah metode bayar, simpan transaksi, offline handler |
| `laporan_page.dart` | UI Dummy ⚠️ | Hubungkan ke data real + tambah filter |
| `dashboard_page.dart` | Placeholder ⚠️ | Implementasi chart & KPI real |
| `riwayat_transaksi_page.dart` | Skeleton ⚠️ | Load dari DB + pagination |
| Models/Services | **Tidak ada** ❌ | Buat dari nol |

---

## Arsitektur Hybrid (Online + Offline)

```
┌─────────────────────────────────────────────┐
│                  Flutter App                │
│                                             │
│  ┌──────────┐    ┌───────────┐              │
│  │  UI Layer│───▶│ Providers │              │
│  └──────────┘    └─────┬─────┘              │
│                        │                   │
│               ┌────────▼────────┐          │
│               │  Repository     │          │
│               │  (Satu entry    │          │
│               │   point untuk   │          │
│               │   semua data)   │          │
│               └────────┬────────┘          │
│                   ┌────┴─────┐             │
│              ┌────▼──┐  ┌────▼────┐        │
│              │SQLite │  │Supabase │        │
│              │(Lokal)│  │(Remote) │        │
│              └───────┘  └─────────┘        │
│                   ▲           ▲            │
│                   └─SyncSvc───┘            │
└─────────────────────────────────────────────┘
```

**Prinsip Hybrid:**
- **Write**: Selalu tulis ke SQLite lokal dulu, tandai sebagai `pending_sync`
- **Read**: Baca dari SQLite lokal (instant, no latency)
- **Sync**: Background job upload pending records ke Supabase saat online
- **Conflict Resolution**: Server wins — jika konflik, data server menang

---

## Proposed Changes

### 🗃️ Fase 0: Database Schema & Dependencies

#### Supabase — Tabel Baru

```sql
CREATE TABLE transactions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  local_id      TEXT NULL,           -- SQLite ID untuk tracking offline
  store_id      UUID REFERENCES stores(id),
  cashier_id    UUID REFERENCES users(id),
  table_id      UUID REFERENCES tables(id) NULL,
  total_amount  NUMERIC(12,2) NOT NULL,
  payment_method TEXT CHECK (payment_method IN ('Tunai','QRIS','Transfer','Kartu')),
  cash_paid     NUMERIC(12,2) NULL,
  change_amount NUMERIC(12,2) NULL,
  status        TEXT CHECK (status IN ('Berhasil','Batal','Pending')) DEFAULT 'Berhasil',
  notes         TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE transaction_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id  UUID REFERENCES transactions(id) ON DELETE CASCADE,
  product_id      UUID REFERENCES products(id) NULL,     -- nullable karena produk bisa dihapus
  product_name    TEXT NOT NULL,      -- snapshot nama saat transaksi
  product_sku     TEXT NULL,
  unit_price      NUMERIC(12,2) NOT NULL,
  quantity        INT NOT NULL,
  subtotal        NUMERIC(12,2) NOT NULL,
  selected_variants JSONB NULL,
  discount_applied  JSONB NULL,
  notes           TEXT NULL
);
```

#### Dependencies Baru — `pubspec.yaml`

```yaml
# Backend & Storage
supabase_flutter: ^2.x.x
sqflite: ^2.x.x
path_provider: ^2.x.x

# Connectivity
connectivity_plus: ^6.x.x

# Struk & Print
pdf: ^3.x.x
printing: ^5.x.x        # Bluetooth thermal + preview
share_plus: ^10.x.x     # Share via WhatsApp

# State Management
provider: ^6.x.x        # atau flutter_riverpod jika mau

# Utilities
uuid: ^4.x.x            # Generate local UUID
image_picker: ^1.x.x    # Upload foto produk (jika belum ada)
```

---

### 📦 Fase 1: Core Data Layer

#### [NEW] `lib/models/product_model.dart`
```dart
class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final double price;
  final double modalPrice;    // HPP — dipakai juga di M5
  final String? imageUrl;
  final String category;
  final int stock;
  final bool isInfiniteStock;
  final String? barcode;
  final List<VariantModel> variants;
  final DiscountModel? appliedDiscount;
}
```

#### [NEW] `lib/models/transaction_model.dart`
```dart
class TransactionModel {
  final String localId;       // UUID lokal (SQLite)
  final String? remoteId;     // UUID Supabase (null jika belum sync)
  final String storeId;
  final String cashierId;
  final String? tableId;
  final List<TransactionItemModel> items;
  final double totalAmount;
  final String paymentMethod;
  final double? cashPaid;
  final double? changeAmount;
  final String status;        // Berhasil | Batal
  final String? notes;
  final DateTime createdAt;
  final bool isSynced;
}
```

#### [NEW] `lib/services/local_db_service.dart`
- Inisialisasi SQLite dengan tabel `products`, `transactions`, `transaction_items`
- Setiap record punya kolom `is_synced INTEGER DEFAULT 0`
- Method: `insertTransaction()`, `getTransactions()`, `getPendingTransactions()`
- Method: `cacheProducts()`, `getCachedProducts()`

#### [NEW] `lib/services/supabase_service.dart`
- `fetchProducts(storeId)` → simpan ke cache SQLite
- `uploadTransaction(transaction)` → push ke Supabase
- `fetchTransactions({filters})` → untuk laporan
- `getDailySummary()`, `getMonthlySummary()`

#### [NEW] `lib/services/sync_service.dart`
- Listen ke `connectivity_plus`
- Saat online: ambil semua `pending_transactions` dari SQLite → upload ke Supabase
- Update flag `is_synced = 1` setelah berhasil
- Tampilkan badge di UI jika ada transaksi pending

#### [NEW] `lib/repositories/transaction_repository.dart`
- Single entry point untuk semua aksi transaksi
- `saveTransaction()`:  tulis ke SQLite → jika online, langsung sync ke Supabase
- `getTransactions()`: baca dari SQLite lokal

---

### 🛒 Fase 2: Kasir & Checkout

#### [MODIFY] `lib/pages/karyawan/kasir_page.dart`
- Load produk dari `ProductRepository` (SQLite cache/Supabase)
- Shimmer loading saat fetch
- Integrasi barcode scanner (`mobile_scanner`) → search produk by SKU
- Filter kategori dinamis dari data produk nyata

#### [MODIFY] `lib/pages/karyawan/checkout_page.dart`

**Tambahan UI:**
```
[ ] Pilih Metode Pembayaran (Tunai | QRIS | Transfer | Kartu)
    └── Jika Tunai: Input "Uang Diterima" → Kalkulasi Kembalian
    └── Jika QRIS: Tampilkan QR Code statis toko
[ ] Tombol "Proses Pembayaran"
    └── Online: Simpan ke SQLite + sync ke Supabase
    └── Offline: Simpan ke SQLite, tandai pending, tampilkan banner
```

#### [NEW] `lib/pages/karyawan/struk_page.dart`

**Struktur Struk Digital:**
```
┌─────────────────────────┐
│     [LOGO TOKO]        │
│   Nama Toko             │
│   Alamat Toko           │
├─────────────────────────┤
│ No: TRX-20260419-001   │
│ Waktu: 19 Apr 2026...  │
│ Kasir: Budi             │
│ Meja: Meja 03           │
├─────────────────────────┤
│ Kopi Susu    x2  36.000│
│  + Topping Boba   6.000│
│ Americano    x1  15.000│
├─────────────────────────┤
│ Subtotal         57.000│
│ Diskon            5.700│
│ TOTAL            51.300│
│ Tunai            60.000│
│ Kembalian         8.700│
├─────────────────────────┤
│    Terima Kasih! 🙏    │
└─────────────────────────┘

[ 🖨 Cetak Thermal ] [ 📤 Bagikan via WhatsApp ]
```

**Implementasi Cetak:**
- `printing` package → `Printing.layoutPdf()` untuk Bluetooth thermal (58mm/80mm)
- `pdf` package → generate dokumen PDF dari widget tree
- `share_plus` → share file PDF ke WhatsApp, Email, dll

---

### 📊 Fase 3: Dashboard & Laporan

#### [MODIFY] `lib/pages/shared/dashboard_page.dart`
- **KPI Cards**: Pendapatan hari ini, Jumlah transaksi, Rata-rata nilai transaksi, Produk terlaku
- **LineChart** (fl_chart): Tren penjualan 7 hari terakhir — data nyata
- **PieChart** (fl_chart): Breakdown metode pembayaran Tunai/QRIS/Transfer
- **BarChart** (fl_chart): Top 5 produk terlaris hari ini

#### [MODIFY] `lib/pages/owner/laporan_page.dart`

**Tab Transaksi:**
- Load dari DB dengan pagination (infinite scroll)
- Search by ID transaksi / nama kasir
- Tap item → Detail transaksi + daftar item

**Tab Laporan — Filter Panel:**
```
[ Periode: Hari Ini ▼ ]  [ Custom Range 📅 ]
[ Kategori: Semua  ▼ ]  [ Kasir: Semua  ▼ ]
[ Metode: Semua    ▼ ]
```

**Tab Laporan — Output:**
- Summary cards (Total, Transaksi, Avg, Profit)
- Grafik perbandingan (BarChart mingguan/bulanan)
- Tabel produk terlaris per periode
- Tombol Export → generate PDF laporan → share

---

## Sprint Plan

### Sprint 1 — Fondasi Data (3–4 hari)
- [ ] Buat Supabase schema `transactions` & `transaction_items`
- [ ] Tambah semua dependencies ke `pubspec.yaml`
- [ ] Buat `ProductModel`, `TransactionModel`, `TransactionItemModel`
- [ ] Implementasi `LocalDbService` (SQLite init + CRUD)
- [ ] Implementasi `SupabaseService` (fetch products, upload transaction)
- [ ] Implementasi `SyncService` (connectivity listener + batch upload)
- [ ] Ganti dummy products di `KasirPage` → load dari repository

### Sprint 2 — Alur Transaksi (3–4 hari)
- [ ] Update `CheckoutPage`: pilih metode bayar + hitung kembalian
- [ ] Simpan transaksi via `TransactionRepository` (hybrid write)
- [ ] Buat `StrukPage` (UI struk digital lengkap)
- [ ] Implementasi PDF generation (`pdf` package)
- [ ] Implementasi Bluetooth thermal print (`printing` package)
- [ ] Implementasi share via WhatsApp (`share_plus`)
- [ ] Update `RiwayatTransaksiPage`: load dari SQLite + pagination

### Sprint 3 — Dashboard & Laporan (3–4 hari)
- [ ] Update `DashboardPage`: KPI cards + 3 jenis chart real data
- [ ] Update `LaporanPage` Tab Transaksi: load real + search + detail
- [ ] Update `LaporanPage` Tab Laporan: semua filter aktif
- [ ] Implementasi query aggregasi di `SupabaseService`
- [ ] Export laporan PDF

### Sprint 4 — Offline Polish & Testing (2–3 hari)
- [ ] Tambah banner/indicator saat offline
- [ ] Tambah badge jumlah transaksi pending sync
- [ ] Test skenario: offline total → buat banyak transaksi → online → verify sync
- [ ] Uji Bluetooth thermal dengan printer fisik
- [ ] `flutter analyze` + perbaikan issues

---

## Verification Plan

| Skenario | Langkah | Expected |
|----------|---------|----------|
| Load Produk | Buka KasirPage | Produk dari Supabase/cache tampil, bukan hardcoded |
| Scan Barcode | Scan QR produk | Produk langsung masuk keranjang |
| Checkout Tunai | Input Rp 100.000 untuk transaksi Rp 87.000 | Kembalian Rp 13.000 tampil |
| Simpan Online | Proses bayar saat ada koneksi | Record muncul di Supabase `transactions` |
| Simpan Offline | Matikan WiFi → proses bayar | Record masuk SQLite, badge pending muncul |
| Auto Sync | Nyalakan WiFi kembali | SyncService upload secara otomatis |
| Struk Thermal | Tap "Cetak Thermal" | Bluetooth printer cetak struk 58mm |
| Struk WhatsApp | Tap "Bagikan" | PDF ter-generate, dialog share terbuka |
| Dashboard Chart | Buka Dashboard setelah transaksi | Chart menampilkan data transaksi nyata |
| Filter Laporan | Filter by tanggal + kasir | Hanya transaksi yang cocok filter tampil |
