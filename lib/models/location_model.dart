/// Model data untuk merepresentasikan lokasi/kota dari Open-Meteo Geocoding API
/// maupun yang disimpan di Local Storage.
class LocationModel {
  final int? id;
  final String name;
  final String? country;
  final String? admin1;
  final double latitude;
  final double longitude;

  const LocationModel({
    this.id,
    required this.name,
    this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Tidak diketahui',
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Mengembalikan nama wilayah lengkap untuk ditampilkan di UI.
  String get subtitle {
    final parts = <String>[];
    if (admin1 != null && admin1!.isNotEmpty) parts.add(admin1!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LocationModel) return false;
    if (id != null && other.id != null) {
      return id == other.id;
    }
    return name == other.name &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode => id?.hashCode ?? Object.hash(name, latitude, longitude);
}
