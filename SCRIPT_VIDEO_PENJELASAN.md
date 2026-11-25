# Naskah / Skrip Video Penjelasan Responsi Flutter
**Aplikasi Cuaca Open-Meteo (CuacaKu)**  
**Nama Mahasiswa:** Surung Nicholas Manalu  
**Estimasi Durasi Video:** 3 – 5 Menit  

---

## 📌 Tips Rekaman
1. Buka dua jendela di layar: **Emulator/HP** (tampilan aplikasi) dan **VS Code** (struktur kode).
2. Bicara dengan tempo santai, jelas, dan percaya diri.

---

## 🎬 Bagian 1: Pembukaan & Demonstrasi Aplikasi (00:00 – 01:30)

### [Tampilkan Layar HP / Emulator di Layar Penuh]

> *"Halo, selamat pagi/siang kepada Bapak/Ibu dosen dan rekan-rekan asisten praktikum.  
> Perkenalkan, nama saya **Surung Nicholas Manalu**.  
> Pada kesempatan kali ini, saya akan mendemonstrasikan dan menjelaskan arsitektur kode dari proyek **Responsi Pemrograman Mobile**, yaitu aplikasi pemantau cuaca berbasis Flutter dengan memanfaatkan REST API dari **Open-Meteo**."*

---

### [Layar Aplikasi: Landing Screen]
> *"Pertama, ketika aplikasi dibuka, pengguna akan disambut oleh **Landing Screen** bertajuk **CuacaKu**. Di halaman ini terdapat ringkasan fitur utama seperti cuaca terkini, prakiraan harian, dan penyimpanan kota favorit. Untuk mulai menggunakan aplikasi, kita tekan tombol **'Mulai Sekarang'**."*

---

### [Layar Aplikasi: Home / Weather Screen]
*(Tekan tombol 'Mulai Sekarang', masuk ke Home Screen)*

> *"Sekarang kita berada di **Home Screen**.  
> Di layar ini, seluruh parameter cuaca yang diwajibkan dalam soal berhasil ditampilkan secara real-time dari API Open-Meteo:
> 1. **Nama dan Wilayah Kota:** di bagian atas, misalnya Kota Bekasi, Jawa Barat.
> 2. **Suhu Terkini & Kondisi Cuaca:** misalnya 26.3°C dengan kondisi gerimis sedang beserta ikon cuaca dinamis berdasarkan kode WMO.
> 3. **Suhu yang Dirasakan (Apparent Temperature):** misalnya terasa seperti 32.0°C.
> 4. **Empat Grid Informasi Tambahan:** yaitu Kelembapan Udara (93%), Kecepatan Angin (7.2 km/j), Peluang Hujan (97%), dan Curah Hujan (0.2 mm).
> 5. **Prakiraan Cuaca Beberapa Hari ke Depan (Daily Forecast):** menampilkan tanggal, kondisi cuaca, peluang hujan, serta rentang suhu minimum dan maksimum harian."*

---

### [Layar Aplikasi: Search Screen & Fitur Favorit]
*(Klik ikon Cari di pojok kanan atas)*

> *"Selanjutnya adalah **Search Screen**.  
> Fitur pencarian ini benar-benar melakukan HTTP GET request ke Open-Meteo Geocoding API.  
> Mari kita coba ketik nama kota, misalnya **'Siborongborong'**, lalu tekan tombol **Cari**.  
> Hasil pencarian langsung muncul lengkap dengan nama kecamatan/kabupaten dan provinsinya.  
> 
> Pengguna juga bisa menyimpan kota ini ke **Favorit** dengan menekan ikon hati. Data favorit ini langsung disimpan ke **Local Storage** menggunakan **SharedPreferences**, sehingga saat aplikasi ditutup dan dibuka kembali, daftar kota favorit dan lokasi terakhir tetap tersimpan secara persisten.  
> Ketika kita klik salah satu hasil pencarian, aplikasi otomatis kembali ke Home Screen dan memuat data cuaca untuk kota tersebut."*

---

## 💻 Bagian 2: Penjelasan Arsitektur MVVM & Struktur Kode (01:30 – 03:30)

### [Pindahkan Tampilan Layar ke VS Code]

> *"Sekarang mari kita bedah struktur kode aplikasinya.  
> Sesuai ketentuan teknis soal, aplikasi ini mengimplementasikan pola arsitektur **MVVM (Model-View-ViewModel)** dengan state management **Provider**."*

---

### 1. Model (`lib/models/`)
*(Buka folder `lib/models/` di VS Code explorer)*

> *"Di folder `models`, terdapat dua file utama:
> - `location_model.dart`: memodelkan data lokasi hasil geocoding dan data favorit (nama, provinsi, koordinat latitude & longitude) beserta fungsi `fromJson` dan `toJson`.
> - `weather_model.dart`: memetakan respons JSON dari Open-Meteo menjadi objek Dart yang terstruktur, mencakup `CurrentWeather` untuk cuaca terkini, list `DailyForecast` untuk prakiraan harian, serta kelas `WeatherCodeInfo` yang memetakan kode cuaca WMO menjadi teks bahasa Indonesia dan ikon cuaca yang sesuai."*

---

### 2. Service (`lib/services/`)
*(Buka folder `lib/services/`)*

> *"Di folder `services`, terdapat pemisahan akses data:
> - `weather_service.dart`: menangani komunikasi jaringan HTTP Request menggunakan metode **GET** ke dua endpoint REST API Open-Meteo, yaitu endpoint Geocoding untuk pencarian kota dan endpoint Forecast untuk mengambil data cuaca berdasarkan koordinat latitude dan longitude.
> - `storage_service.dart`: menangani penyimpanan lokal berbasis **SharedPreferences** untuk menyimpan dan membaca data riwayat/favorit serta lokasi terakhir yang dipilih pengguna dalam bentuk JSON string."*

---

### 3. ViewModel (`lib/viewmodels/`)
*(Buka folder `lib/viewmodels/`)*

> *"Di folder `viewmodels`, logika bisnis dipisahkan sepenuhnya dari tampilan antarmuka:
> - `weather_viewmodel.dart`: mewarisi `ChangeNotifier` untuk mengelola state data cuaca aktif, lokasi terpilih, indikator `isLoading`, dan `errorMessage`. Di sini terdapat method `selectLocationAndLoad()` dan `refreshWeather()` yang memanggil service lalu memicu pembaruan UI melalui `notifyListeners()`.
> - `search_viewmodel.dart`: mengelola state pencarian kota, daftar hasil pencarian, serta daftar favorit dengan fungsi `toggleFavorite()` dan `loadFavorites()`."*

---

### 4. View & Theme (`lib/views/` dan `lib/theme/`)
*(Buka folder `lib/views/`)*

> *"Di bagian View:
> - `home_screen.dart` dan `search_screen.dart` bertindak sebagai UI murni yang mendengarkan state melalui widget `Consumer`.
> - Penanganan kondisi antarmuka dibuat lengkap:
>   - Saat memuat data, tampil `CircularProgressIndicator`.
>   - Jika terjadi gangguan jaringan, tampil pesan error informatif beserta tombol **'Coba Lagi'**.
>   - Jika belum ada data/pencarian kosong, tampil pesan ilustrasi yang ramah pengguna.
> - Desain antarmuka menerapkan **Material 3 Theme** yang konsisten dan tipografi yang mudah dibaca pada `app_theme.dart`."*

---

## 🎯 Bagian 3: Penutup (03:30 – 04:00)

> *"Seluruh kode proyek ini telah diverifikasi dengan unit test dan di-push ke repositori GitHub publik saya. Dokumentasi struktur aplikasi serta tangkapan layar setiap screen juga telah tercantum pada berkas README.md.  
> 
> Demikian presentasi dan penjelasan kode proyek Responsi Pemrograman Mobile ini. Terima kasih atas perhatian Bapak/Ibu dosen dan rekan-rekan asisten. Wassalamu'alaikum warahmatullahi wabarakatuh / Salam sejahtera."*
