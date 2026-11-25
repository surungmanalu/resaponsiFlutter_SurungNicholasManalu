import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// ViewModel untuk Search / Location Screen (pencarian kota & daftar favorit).
class SearchViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  SearchViewModel({
    required this._weatherService,
    required this._storageService,
  });

  List<LocationModel> _searchResults = [];
  List<LocationModel> _favorites = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;

  /// Memuat daftar lokasi favorit dari Local Storage saat aplikasi dibuka.
  Future<void> loadFavorites() async {
    _favorites = await _storageService.getFavorites();
    notifyListeners();
  }

  /// Mencari kota melalui Open-Meteo Geocoding API.
  Future<void> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    _isLoading = true;
    _hasSearched = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _weatherService.searchLocations(trimmed);
    } catch (e) {
      _searchResults = [];
      _errorMessage =
          'Gagal mencari kota. Periksa koneksi internet Anda lalu coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _hasSearched = false;
    _errorMessage = null;
    notifyListeners();
  }

  bool isFavorite(LocationModel location) {
    return _favorites.contains(location);
  }

  /// Menambah atau menghapus lokasi dari daftar favorit dan menyimpannya ke Local Storage.
  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      _favorites.remove(location);
    } else {
      _favorites.insert(0, location);
    }
    notifyListeners();
    await _storageService.saveFavorites(_favorites);
  }
}
