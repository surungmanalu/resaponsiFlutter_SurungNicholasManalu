import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// ViewModel untuk Home / Weather Screen (mengelola state cuaca & lokasi aktif).
class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  WeatherViewModel({
    required this._weatherService,
    required this._storageService,
  });

  LocationModel? _selectedLocation;
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  LocationModel? get selectedLocation => _selectedLocation;
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Memuat lokasi terakhir atau favorit pertama saat aplikasi dibuka.
  Future<void> initialize() async {
    final lastLocation = await _storageService.getLastLocation();
    if (lastLocation != null) {
      await selectLocationAndLoad(lastLocation);
      return;
    }

    final favorites = await _storageService.getFavorites();
    if (favorites.isNotEmpty) {
      await selectLocationAndLoad(favorites.first);
    }
  }

  /// Memilih kota baru, menyimpannya sebagai lokasi terakhir, dan mengambil data cuaca.
  Future<void> selectLocationAndLoad(LocationModel location) async {
    _selectedLocation = location;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _storageService.saveLastLocation(location);

    try {
      _weather = await _weatherService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (e) {
      _errorMessage =
          'Tidak dapat memuat data cuaca. Periksa koneksi internet Anda.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memuat ulang data cuaca untuk lokasi yang sedang aktif.
  Future<void> refreshWeather() async {
    if (_selectedLocation == null) return;
    await selectLocationAndLoad(_selectedLocation!);
  }
}
