import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

/// Service untuk menyimpan dan membaca lokasi favorit serta lokasi terakhir
/// menggunakan SharedPreferences (Local Storage).
class StorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _lastLocationKey = 'last_selected_location';

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favoritesKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString(_favoritesKey, encoded);
  }

  Future<LocationModel?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null || raw.isEmpty) return null;

    return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }
}
