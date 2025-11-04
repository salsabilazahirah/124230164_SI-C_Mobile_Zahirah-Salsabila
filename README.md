# Toko Kue - Aplikasi Toko Kue Modern

Aplikasi mobile e-commerce untuk toko kue dengan fitur lengkap menggunakan Flutter.

## 🎯 Fitur Utama

### 1. **Authentication & User Management** 🔐 **NEW!**
- Login dengan username/email
- Register user baru dengan validasi lengkap
- Database lokal (SQLite) untuk menyimpan user
- Auto-login jika sudah pernah login
- Logout dengan confirmation
- Profile menu di home screen
- Demo users tersedia untuk testing

### 2. **Katalog Produk**
- Daftar kue dari API eksternal
- Grid view dengan gambar produk
- Rating dan review
- Search dan filter produk

### 2. **Detail Produk**
- Gambar produk full-screen
- Informasi lengkap (harga, rating, deskripsi)
- Info serving, sweetness, dan size
- Add to cart dan Buy now

### 3. **Shopping Cart**
- Manajemen keranjang belanja
- Ubah quantity produk
- Swipe to delete
- Perhitungan total otomatis
- Persistent cart (tersimpan di local storage)

### 4. **Konversi Mata Uang** 💱
- 7 mata uang: USD, IDR, EUR, GBP, JPY, SGD, MYR
- Real-time exchange rates dari API
- Fallback ke static rates jika API gagal
- Konversi otomatis semua harga
- Integrated dalam Settings (bukan menu terpisah)

### 5. **Waktu & Timezone** ⏰
- Deteksi timezone otomatis berdasarkan lokasi
- Mendukung WIB, WITA, WIT (Indonesia timezone)
- Tampilan waktu real-time
- Integrated dalam Settings

### 6. **Sensor Lokasi** 📍
- Deteksi lokasi pengguna menggunakan GPS
- Tampilkan nama kota/daerah
- Auto-update timezone berdasarkan koordinat
- Permission handling

### 7. **Notifikasi Push** 🔔
- Flutter Local Notifications (BUKAN Snackbar)
- Notifikasi saat add to cart
- Notifikasi saat order success
- Support Android & iOS
- Rich notification dengan detail

### 8. **Settings Drawer**
- Currency selector dengan 7 pilihan mata uang
- Lokasi dan timezone info
- Update exchange rates
- Refresh location
- Design modern dengan tema konsisten

## 📱 Screenshots Design Reference

Aplikasi mengikuti design modern dengan:
- Warna: Peach/Coral (#F4A58A) sebagai primary
- Card-based UI dengan rounded corners
- Clean dan minimalist
- Soft shadows dan spacing yang baik

## 🛠️ Teknologi

### Dependencies:
- **provider**: State management
- **http**: API calls
- **shared_preferences**: Local storage
- **sqflite**: Local database (SQLite)
- **path**: File path utilities
- **crypto**: Encryption & hashing
- **geolocator**: GPS location
- **geocoding**: Reverse geocoding
- **flutter_local_notifications**: Push notifications
- **intl**: Currency & date formatting
- **timezone**: Timezone handling
- **google_fonts**: Typography
- **cached_network_image**: Image caching

## 🚀 Cara Menjalankan

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Setup Android (untuk notifikasi)
Sudah dikonfigurasi di `android/app/src/main/AndroidManifest.xml`:
- INTERNET permission
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION  
- POST_NOTIFICATIONS

### 3. Jalankan Aplikasi
```bash
flutter run
```

### 4. Login dengan Demo User
Saat pertama buka, gunakan salah satu demo credentials:
- **Username**: `admin` / **Password**: `admin123`
- **Username**: `annie` / **Password**: `annie123`

Atau register user baru dengan tap "Register".

## 📡 API Integration

Data kue diambil dari:
```
https://gist.githubusercontent.com/prayagKhanal/8cdd00d762c48b84a911eca2e2eb3449/raw/5c5d62797752116799aacaeeef08ea2d613569e9/cakes.json
```

Currency rates dari:
```
https://api.exchangerate-api.com/v4/latest/USD
```

## 🎨 Struktur Project

```
lib/
├── main.dart                 # Entry point
├── models/
│   ├── cake_model.dart      # Model data kue
│   └── cart_item.dart       # Model item cart
├── providers/
│   ├── cart_provider.dart   # State management cart
│   └── settings_provider.dart # Settings (currency, location, time)
├── screens/
│   ├── home_screen.dart     # Halaman utama
│   ├── detail_screen.dart   # Detail produk
│   └── cart_screen.dart     # Keranjang belanja
├── services/
│   ├── api_service.dart     # API calls
│   ├── notification_service.dart # Push notifications
│   ├── location_service.dart # GPS & timezone
│   └── currency_service.dart # Currency conversion
├── widgets/
│   ├── cake_card.dart       # Card produk
│   └── settings_drawer.dart # Settings drawer
└── theme/
    └── app_theme.dart       # Theme & colors
```

## ✨ Fitur Unggulan

### Konversi Terintegrasi
Konversi mata uang dan waktu **TIDAK** dibuat sebagai menu terpisah, melainkan:
- Currency selector ada di Settings Drawer
- Semua harga otomatis ter-convert
- Waktu dan timezone ditampilkan di header dan settings
- Update real-time saat ganti currency

### Notifikasi Real
Menggunakan **Flutter Local Notifications**, bukan Snackbar:
- Notifikasi muncul di notification tray Android/iOS
- Persistent sampai di-dismiss
- Bisa diklik untuk action
- Icon dan styling custom

### Smart Location
- Otomatis detect timezone Indonesia (WIB/WITA/WIT)
- Geocoding untuk nama lokasi
- Permission handling yang baik
- Fallback jika location disabled

## 🎯 Cara Menggunakan

1. **Browse Produk**: Scroll grid view di home
2. **Search**: Gunakan search bar untuk cari kue
3. **Settings**: Tap icon tune (⚙️) untuk:
   - Ganti currency
   - Lihat lokasi & timezone
   - Update exchange rates
4. **Add to Cart**: Tap + di card atau "Add to cart" di detail
5. **Checkout**: Buka cart (🛒), review, lalu tap "Buy"
6. **Notifikasi**: Akan muncul setiap ada activity

## 📝 Notes

- Aplikasi membutuhkan koneksi internet untuk load produk dan exchange rates
- Location permission diperlukan untuk timezone auto-detection
- Notification permission diperlukan untuk push notifications (Android 13+)
- Cart data tersimpan lokal, tidak hilang saat app ditutup

## 🔮 Future Enhancements

- [ ] Payment integration
- [ ] User authentication
- [ ] Order history
- [ ] Favorites/Wishlist
- [ ] Multiple addresses
- [ ] Promo codes
- [ ] Dark mode

---

**Developed with ❤️ using Flutter**
