# Quick Start Guide - Toko Kue

## 🚀 Memulai dalam 3 Langkah

### 1️⃣ Install Dependencies
```bash
flutter pub get
```

### 2️⃣ Jalankan Aplikasi
```bash
flutter run
```

### 3️⃣ Explore Fitur!

---

## 🎮 Tour Fitur Aplikasi

### Saat Pertama Buka
1. **Permission Dialogs** akan muncul:
   - Location Permission → **Tap "Allow"** untuk timezone auto-detect
   - Notification Permission → **Tap "Allow"** untuk push notifications

2. **Loading** → App akan fetch data kue dari API

3. **Home Screen** muncul dengan:
   - Lokasi Anda di kanan atas
   - Waktu lokal dengan timezone (WIB/WITA/WIT)
   - Grid produk kue

---

## 📱 Panduan Menggunakan Setiap Fitur

### 🔍 Feature 1: Browse & Search Produk
**Cara pakai:**
1. Scroll untuk lihat katalog kue
2. Ketik di search bar untuk cari kue spesifik
3. Filter bekerja real-time

**What to expect:**
- Gambar kue dari internet
- Harga dalam USD (default)
- Rating dan jumlah review
- Quick add button (+)

---

### 💱 Feature 2: Konversi Mata Uang (Terintegrasi)
**Cara pakai:**
1. Tap icon **⚙️ (tune)** di kanan atas home screen
2. Settings drawer terbuka dari kanan
3. Scroll ke section "Currency"
4. Tap currency yang diinginkan (USD, IDR, EUR, dll)
5. Semua harga otomatis berubah!

**What to expect:**
- 7 pilihan currency
- Harga auto-convert di semua screen
- Symbol mata uang berubah (Rp, $, €, dll)
- Bisa tap "Update Rates" untuk refresh exchange rate

**Testing Tips:**
- Coba IDR → harga jadi Rp 950,000+
- Coba JPY → harga jadi ¥9,000+
- Bandingkan dengan calculator manual

---

### 📍 Feature 3: Sensor Lokasi & Timezone
**Cara pakai:**
1. Otomatis detect saat app start
2. Lihat di **header home screen** (kanan atas)
   - Nama kota/daerah
   - Waktu lokal dengan timezone
3. Atau buka Settings (⚙️) → lihat detail lengkap
4. Tap **refresh icon** untuk update lokasi

**What to expect:**
- Nama kota muncul (Jakarta, Surabaya, dll)
- Timezone otomatis (WIB untuk Jawa, WITA untuk Bali, WIT untuk Papua)
- Waktu sesuai timezone lokal

**Testing Tips:**
- Jika di Jakarta → harus WIB (UTC+7)
- Jika di Bali → harus WITA (UTC+8)
- Jika di Papua → harus WIT (UTC+9)
- Coba refresh untuk update

---

### 🔔 Feature 4: Notifikasi Push (BUKAN Snackbar!)
**Cara pakai:**
1. Pastikan permission granted
2. Tap **+ button** di product card → Notifikasi "Added to Cart"
3. Lakukan checkout → Notifikasi "Order Success"

**What to expect:**
- Notifikasi muncul di **notification tray** (pull down dari top)
- BUKAN Snackbar di bawah screen
- Ada icon, title, dan detail
- Bisa di-dismiss seperti notif biasa

**Testing Tips:**
- Add 3 produk berbeda → 3 notifikasi terpisah
- Checkout → notifikasi dengan total harga
- Cek notification tray Android/iOS
- Notifikasi tetap ada sampai di-clear

---

### 🛒 Feature 5: Shopping Cart
**Cara pakai:**
1. **Add to Cart:** Tap + button di card atau di detail
2. **View Cart:** Tap cart icon (🛒) di kanan atas
3. **Update Quantity:** Tap +/- di cart
4. **Delete Item:** Swipe card ke kiri
5. **Checkout:** Tap tombol "Buy"

**What to expect:**
- Cart badge menunjukkan jumlah item
- Total harga auto-calculate
- Cart tersimpan (tidak hilang saat app ditutup)
- Notifikasi saat checkout

---

### 🎂 Feature 6: Detail Produk
**Cara pakai:**
1. Tap pada card produk
2. Lihat detail lengkap
3. Scroll untuk info lebih
4. Tap "Add to cart" atau "Buy now"

**What to expect:**
- Full-screen image
- Rating dengan bintang
- Info serving, sweetness, size
- Description lengkap
- Storage instructions

---

## ⚙️ Settings Drawer Lengkap

### Cara Buka Settings
Tap icon **⚙️** di kanan atas home screen

### Isi Settings:

#### 1️⃣ Location Section
- **Current Location:** Nama kota Anda
  - Tap refresh untuk update
- **Timezone:** WIB/WITA/WIT dengan offset UTC

#### 2️⃣ Currency Section
- **Select Currency:** 7 chips untuk pilih mata uang
  - USD, IDR, EUR, GBP, JPY, SGD, MYR
  - Chip active highlighted dengan warna coral
- **Update Rates Button:** Refresh exchange rates dari API

---

## 🧪 Skenario Testing

### Test 1: Complete Shopping Flow
```
1. Browse produk
2. Ganti currency ke IDR
3. Pilih produk → Detail
4. Add to cart → Cek notifikasi
5. Tap cart icon
6. Update quantity beberapa item
7. Checkout → Cek notifikasi
8. Cart jadi kosong
```

### Test 2: Location & Timezone
```
1. Buka app → Cek header (lokasi muncul?)
2. Buka Settings → Cek timezone (WIB/WITA/WIT?)
3. Tap refresh location
4. Tunggu update
5. Cek apakah nama kota berubah
```

### Test 3: Currency Conversion
```
1. Catat harga produk di USD
2. Ganti ke IDR via Settings
3. Cek harga berubah? (kalikan ~15,750)
4. Ganti ke JPY
5. Cek harga berubah? (kalikan ~149)
6. Buka Detail produk → harga juga berubah?
7. Checkout → total di notifikasi sesuai?
```

### Test 4: Cart Persistence
```
1. Add 3 produk ke cart
2. Close app completely (swipe dari recent apps)
3. Buka app lagi
4. Tap cart → apakah 3 produk masih ada?
```

### Test 5: Notifications
```
1. Clear semua notifications di tray
2. Add produk → Swipe down → Notifikasi ada?
3. Add 2 produk lagi → 2 notifikasi tambahan?
4. Checkout → Notifikasi success ada?
5. Tap notifikasi → apa yang terjadi?
```

---

## 🐛 Troubleshooting

### ❌ "No cakes found"
**Solusi:**
- Cek koneksi internet
- Coba pull to refresh (upcoming feature)
- Restart app

### ❌ Location = "Unknown"
**Solusi:**
- Pastikan GPS enabled
- Beri location permission
- Tap refresh di Settings
- Jika masih gagal → fallback ke WIB

### ❌ Notifikasi tidak muncul
**Solusi:**
- Cek permission di Settings > Apps > Toko Kue > Notifications
- Android 13+: Pastikan permission granted saat diminta
- Restart app dan grant permission

### ❌ Harga tidak berubah saat ganti currency
**Solusi:**
- Tap "Update Rates" di Settings
- Tutup dan buka Settings lagi
- Restart app

### ❌ Gambar produk tidak load
**Solusi:**
- Cek koneksi internet
- Tunggu beberapa detik
- Icon cake akan muncul sebagai placeholder

---

## 💡 Tips & Tricks

### 1. Quick Add to Cart
Dari home screen, langsung tap + tanpa buka detail

### 2. Swipe to Delete
Di cart, swipe card ke kiri untuk hapus cepat

### 3. Currency Shortcut
Settings drawer bisa dibuka dari mana saja dengan gesture (upcoming)

### 4. Cart Badge
Badge merah di cart icon menunjukkan total item (bukan unique products)

### 5. Real-time Time
Waktu di header update setiap menit

---

## 📊 Expected Data

### Currencies dengan Symbol
- USD → $
- IDR → Rp
- EUR → €
- GBP → £
- JPY → ¥
- SGD → S$
- MYR → RM

### Indonesia Timezones
- **WIB (UTC+7):** Sumatra, Jawa, Kalimantan Barat & Tengah
- **WITA (UTC+8):** Bali, NTT, NTB, Kalimantan Selatan & Timur, Sulawesi
- **WIT (UTC+9):** Maluku, Papua

### Approximate Exchange Rates (USD base)
- IDR: ~15,750
- EUR: ~0.92
- GBP: ~0.79
- JPY: ~149.50
- SGD: ~1.35
- MYR: ~4.72

---

## 🎉 Selamat Mencoba!

Jika ada masalah atau pertanyaan:
1. Cek SETUP.md untuk instalasi
2. Cek FEATURES.md untuk detail teknis
3. Cek code comments di source

**Enjoy shopping! 🛍️**
