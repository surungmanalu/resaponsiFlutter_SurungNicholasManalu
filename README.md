# Aplikasi Cuaca Open-Meteo (Responsi Flutter)

Aplikasi informasi cuaca berbasis Flutter menggunakan REST API **Open-Meteo** dengan arsitektur **MVVM (Model-View-ViewModel)**, state management **Provider**, dan penyimpanan lokal **SharedPreferences**.

## Struktur Aplikasi (MVVM)

```text
lib/
├── models/
│   ├── location_model.dart      # Model data lokasi (Geocoding & Favorit)
│   └── weather_model.dart       # Model data cuaca terkini & harian + mapping kode WMO
├── services/
│   ├── weather_service.dart     # HTTP GET ke Open-Meteo Geocoding & Forecast API
│   └── storage_service.dart     # Local Storage (SharedPreferences) untuk favorit & lokasi terakhir
├── viewmodels/
│   ├── weather_viewmodel.dart   # Pengelola state cuaca aktif, loading, dan error
│   └── search_viewmodel.dart    # Pengelola state pencarian kota dan daftar favorit
├── views/
│   ├── landing_screen.dart      # Landing Page / Welcome Screen
│   ├── home_screen.dart         # Home / Weather Screen
│   └── search_screen.dart       # Search / Location Screen
├── theme/
│   └── app_theme.dart           # Material Design Theme & Typography
└── main.dart                    # Inisialisasi MultiProvider & MaterialApp
```

## Penerapan MVVM
- **Model (`models/`):** Merepresentasikan struktur data JSON dari API (`WeatherModel`, `CurrentWeather`, `DailyForecast`, `LocationModel`).
- **View (`views/`):** Bertanggung jawab hanya untuk menampilkan UI (`HomeScreen`, `SearchScreen`) dan mendengarkan perubahan state dari ViewModel melalui `Consumer`.
- **ViewModel (`viewmodels/`):** Menggunakan `ChangeNotifier` (`WeatherViewModel`, `SearchViewModel`) untuk memproses logika bisnis, memanggil `WeatherService` / `StorageService`, serta mengelola kondisi *loading*, *data kosong*, dan *error*.

## Implementasi API Open-Meteo
1. **Geocoding API:** `GET https://geocoding-api.open-meteo.com/v1/search` untuk mencari koordinat (`latitude`, `longitude`) berdasarkan nama kota.
2. **Weather Forecast API:** `GET https://api.open-meteo.com/v1/forecast` dengan parameter `latitude`, `longitude`, `current`, `daily`, dan `timezone=auto` untuk mengambil:
   - `current.temperature_2m`, `current.relative_humidity_2m`, `current.apparent_temperature`, `current.precipitation`, `current.weather_code`, `current.wind_speed_10m`
   - `daily.weather_code`, `daily.temperature_2m_max`, `daily.temperature_2m_min`, `daily.precipitation_probability_max`

## Screenshot Aplikasi
*(Tambahkan screenshot setiap screen di sini sebelum dikumpulkan)*

- **Landing Screen:** `<!-- ![Landing Screen](screenshots/landing.png) -->`
- **Home / Weather Screen:** `<!-- ![Home Screen](screenshots/home.png) -->`
- **Search / Location Screen:** `<!-- ![Search Screen](screenshots/search.png) -->`
