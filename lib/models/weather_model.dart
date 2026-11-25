import 'package:flutter/material.dart';

/// Informasi deskripsi dan ikon untuk kode cuaca WMO Open-Meteo.
class WeatherCodeInfo {
  final String description;
  final IconData icon;

  const WeatherCodeInfo(this.description, this.icon);

  static const Map<int, WeatherCodeInfo> _wmoMap = {
    0: WeatherCodeInfo('Cerah', Icons.wb_sunny_rounded),
    1: WeatherCodeInfo('Cerah Berawan', Icons.wb_sunny_outlined),
    2: WeatherCodeInfo('Berawan Sebagian', Icons.cloud_queue_rounded),
    3: WeatherCodeInfo('Mendung', Icons.cloud_rounded),
    45: WeatherCodeInfo('Berkabut', Icons.foggy),
    48: WeatherCodeInfo('Kabut Beku', Icons.foggy),
    51: WeatherCodeInfo('Gerimis Ringan', Icons.grain_rounded),
    53: WeatherCodeInfo('Gerimis Sedang', Icons.grain_rounded),
    55: WeatherCodeInfo('Gerimis Lebat', Icons.grain_rounded),
    56: WeatherCodeInfo('Gerimis Beku Ringan', Icons.ac_unit_rounded),
    57: WeatherCodeInfo('Gerimis Beku Lebat', Icons.ac_unit_rounded),
    61: WeatherCodeInfo('Hujan Ringan', Icons.water_drop_outlined),
    63: WeatherCodeInfo('Hujan Sedang', Icons.water_drop_rounded),
    65: WeatherCodeInfo('Hujan Lebat', Icons.thunderstorm_outlined),
    66: WeatherCodeInfo('Hujan Beku Ringan', Icons.ac_unit_rounded),
    67: WeatherCodeInfo('Hujan Beku Lebat', Icons.ac_unit_rounded),
    71: WeatherCodeInfo('Salju Ringan', Icons.ac_unit_rounded),
    73: WeatherCodeInfo('Salju Sedang', Icons.ac_unit_rounded),
    75: WeatherCodeInfo('Salju Lebat', Icons.ac_unit_rounded),
    77: WeatherCodeInfo('Butiran Salju', Icons.ac_unit_rounded),
    80: WeatherCodeInfo('Hujan Lokal Ringan', Icons.umbrella_rounded),
    81: WeatherCodeInfo('Hujan Lokal Sedang', Icons.umbrella_rounded),
    82: WeatherCodeInfo('Hujan Lokal Deras', Icons.umbrella_rounded),
    85: WeatherCodeInfo('Hujan Salju Ringan', Icons.ac_unit_rounded),
    86: WeatherCodeInfo('Hujan Salju Lebat', Icons.ac_unit_rounded),
    95: WeatherCodeInfo('Badai Petir', Icons.thunderstorm_rounded),
    96: WeatherCodeInfo('Badai Petir & Hujan Es', Icons.thunderstorm_rounded),
    99: WeatherCodeInfo('Badai Petir Hebat', Icons.thunderstorm_rounded),
  };

  static WeatherCodeInfo fromCode(int code) {
    return _wmoMap[code] ??
        const WeatherCodeInfo('Kondisi Tidak Diketahui', Icons.help_outline_rounded);
  }
}

/// Model data cuaca saat ini (`current` dari Open-Meteo).
class CurrentWeather {
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  const CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

/// Model data prakiraan cuaca harian (`daily` dari Open-Meteo).
class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final int precipitationProbabilityMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbabilityMax,
  });
}

/// Model utama respons Weather Forecast API Open-Meteo.
class WeatherModel {
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherModel({
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    final times = List<String>.from(dailyJson['time'] as List);
    final codes = List<num>.from(dailyJson['weather_code'] as List);
    final maxTemps = List<num>.from(dailyJson['temperature_2m_max'] as List);
    final minTemps = List<num>.from(dailyJson['temperature_2m_min'] as List);
    final precipProbs =
        List<num?>.from(dailyJson['precipitation_probability_max'] as List);

    final dailyList = List.generate(times.length, (index) {
      return DailyForecast(
        date: DateTime.parse(times[index]),
        weatherCode: codes[index].toInt(),
        tempMax: maxTemps[index].toDouble(),
        tempMin: minTemps[index].toDouble(),
        precipitationProbabilityMax: (precipProbs[index] ?? 0).toInt(),
      );
    });

    return WeatherModel(
      timezone: json['timezone'] as String? ?? 'auto',
      current: CurrentWeather.fromJson(currentJson),
      daily: dailyList,
    );
  }
}
