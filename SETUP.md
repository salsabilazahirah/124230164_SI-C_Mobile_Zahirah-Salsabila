# Setup Instructions

## Prerequisites
- Flutter SDK (3.9.0 or higher)
- Android Studio / VS Code
- Android device or emulator (for testing)

## Installation Steps

### 1. Clone atau Download Project
```bash
cd c:\src\TokoKue\tokokue
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Konfigurasi Permissions

#### Android
File `android/app/src/main/AndroidManifest.xml` sudah dikonfigurasi dengan permissions:
- INTERNET - untuk API calls
- ACCESS_FINE_LOCATION - untuk GPS location
- ACCESS_COARSE_LOCATION - untuk approximate location
- POST_NOTIFICATIONS - untuk push notifications (Android 13+)

#### iOS (jika diperlukan)
Tambahkan ke `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show local time and timezone</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to show local time and timezone</string>
```

### 4. Run Aplikasi
```bash
flutter run
```

## Testing Features

### 1. Test Katalog Produk
- Aplikasi akan fetch data dari API
- Scroll untuk lihat semua produk
- Tap card untuk detail

### 2. Test Search
- Ketik di search bar
- Filter bekerja real-time

### 3. Test Currency Conversion
- Tap icon tune (⚙️) di kanan atas
- Pilih currency (USD, IDR, EUR, dll)
- Semua harga otomatis berubah

### 4. Test Location & Timezone
- Beri permission saat diminta
- Lokasi muncul di header
- Timezone auto-detect

### 5. Test Notifications
- Beri permission saat diminta
- Add produk ke cart
- Notifikasi muncul di notification tray

### 6. Test Shopping Cart
- Tap + untuk add to cart
- Tap cart icon (🛒)
- Ubah quantity dengan +/-
- Swipe left untuk delete
- Tap "Buy" untuk checkout

## Troubleshooting

### API Tidak Load
- Cek koneksi internet
- API mungkin down, tunggu beberapa saat

### Location Tidak Detect
- Pastikan GPS enabled di device
- Beri permission saat diminta
- Jika ditolak, buka Settings > Apps > Toko Kue > Permissions

### Notification Tidak Muncul
- Android 13+: Beri permission saat diminta
- Cek notification settings di device

### Currency Tidak Update
- Tap "Update Rates" di settings
- Jika API gagal, akan pakai static rates

## Build untuk Release

### Android APK
```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (untuk Play Store)
```bash
flutter build appbundle --release
```

### iOS (memerlukan Mac)
```bash
flutter build ios --release
```

## Development Tips

### Hot Reload
Saat development, gunakan `r` untuk hot reload setelah edit code.

### State Management
Aplikasi menggunakan Provider. Semua state ada di:
- `CartProvider` - untuk shopping cart
- `SettingsProvider` - untuk currency, location, timezone

### Mengubah Theme
Edit `lib/theme/app_theme.dart` untuk customize colors.

### Menambah Currency
Edit `lib/services/currency_service.dart`:
1. Tambah ke `staticRates` map
2. Tambah symbol di `getCurrencySymbol()`
3. Tambah ke list di `SettingsProvider`

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── cake_model.dart
│   └── cart_item.dart
├── providers/                   # State management
│   ├── cart_provider.dart
│   └── settings_provider.dart
├── screens/                     # UI Screens
│   ├── home_screen.dart
│   ├── detail_screen.dart
│   └── cart_screen.dart
├── services/                    # Business logic
│   ├── api_service.dart
│   ├── notification_service.dart
│   ├── location_service.dart
│   └── currency_service.dart
├── widgets/                     # Reusable widgets
│   ├── cake_card.dart
│   └── settings_drawer.dart
└── theme/                       # Styling
    └── app_theme.dart
```

## Dependencies Used

| Package | Purpose |
|---------|---------|
| provider | State management |
| http | REST API calls |
| shared_preferences | Local storage |
| geolocator | GPS location |
| geocoding | Address from coordinates |
| flutter_local_notifications | Push notifications |
| intl | Internationalization & formatting |
| timezone | Timezone calculations |
| google_fonts | Custom fonts |
| cached_network_image | Image caching |

## API Endpoints

### Cakes Data
```
GET https://gist.githubusercontent.com/prayagKhanal/8cdd00d762c48b84a911eca2e2eb3449/raw/5c5d62797752116799aacaeeef08ea2d613569e9/cakes.json
```

Response format:
```json
[
  {
    "id": 1,
    "title": "Cake Name",
    "description": "Description",
    "image": "URL",
    "price": 60.25,
    "rating": 4.5,
    "reviews": 1842,
    "sweetness": "low",
    "size": "13 x 5cm",
    "servings": 4
  }
]
```

### Currency Exchange Rates
```
GET https://api.exchangerate-api.com/v4/latest/USD
```

Response format:
```json
{
  "base": "USD",
  "rates": {
    "IDR": 15750,
    "EUR": 0.92,
    ...
  }
}
```

## Features Implementation

### ✅ Konversi Mata Uang & Waktu dalam Tema
- Integrated di Settings Drawer
- Tidak ada menu terpisah
- Real-time update

### ✅ Konversi Pakai API
- Currency: exchangerate-api.com
- Fallback ke static rates
- Auto-update semua harga

### ✅ Sensor Lokasi
- Geolocator untuk GPS
- Geocoding untuk nama lokasi
- Auto-detect timezone
- Update button available

### ✅ Notifikasi (BUKAN Snackbar)
- Flutter Local Notifications
- Muncul di notification tray
- Add to cart notification
- Order success notification

### ✅ Design sesuai Referensi
- Peach/Coral theme
- Card-based layout
- Grid view produk
- Modern & clean UI

---

**Happy Coding! 🚀**
