import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';

/// Screen 1: Home / Weather Screen
/// Menampilkan cuaca terkini, informasi tambahan, dan prakiraan harian kota terpilih.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSearchScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeatherViewModel, SearchViewModel>(
      builder: (context, weatherVm, searchVm, _) {
        final location = weatherVm.selectedLocation;
        final isFav = location != null && searchVm.isFavorite(location);

        return Scaffold(
          appBar: AppBar(
            title: Text(location?.name ?? 'Cuaca'),
            actions: [
              if (location != null)
                IconButton(
                  tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : null,
                  ),
                  onPressed: () => searchVm.toggleFavorite(location),
                ),
              if (location != null)
                IconButton(
                  tooltip: 'Muat ulang cuaca',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed:
                      weatherVm.isLoading ? null : weatherVm.refreshWeather,
                ),
              IconButton(
                tooltip: 'Cari Kota',
                icon: const Icon(Icons.search_rounded),
                onPressed: () => _openSearchScreen(context),
              ),
            ],
          ),
          body: _buildBody(context, weatherVm),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel weatherVm) {
    if (weatherVm.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat informasi cuaca...'),
          ],
        ),
      );
    }

    if (weatherVm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                weatherVm.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: weatherVm.refreshWeather,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final weather = weatherVm.weather;
    final location = weatherVm.selectedLocation;

    if (weather == null || location == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_searching_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Lokasi Dipilih',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Cari nama kota untuk melihat kondisi cuaca terkini dan prakiraan beberapa hari ke depan.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _openSearchScreen(context),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Cari Kota'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: weatherVm.refreshWeather,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CurrentWeatherCard(
                      location: location,
                      weather: weather,
                    ),
                    const SizedBox(height: 16),
                    _AdditionalInfoGrid(
                      weather: weather,
                      crossAxisCount: isWide ? 4 : 2,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Prakiraan Beberapa Hari ke Depan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...weather.daily.map(
                      (day) => _DailyForecastTile(forecast: day),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final LocationModel location;
  final WeatherModel weather;

  const _CurrentWeatherCard({
    required this.location,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final current = weather.current;
    final codeInfo = WeatherCodeInfo.fromCode(current.weatherCode);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: colorScheme.onPrimary, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location.subtitle.isEmpty
                      ? location.name
                      : '${location.name}, ${location.subtitle}',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperature.toStringAsFixed(1)}°C',
                    style: textTheme.displayLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    codeInfo.description,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terasa seperti ${current.apparentTemperature.toStringAsFixed(1)}°C',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
              Icon(
                codeInfo.icon,
                size: 76,
                color: colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdditionalInfoGrid extends StatelessWidget {
  final WeatherModel weather;
  final int crossAxisCount;

  const _AdditionalInfoGrid({
    required this.weather,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    final rainChanceToday = weather.daily.isNotEmpty
        ? weather.daily.first.precipitationProbabilityMax
        : 0;

    final metrics = [
      _MetricData(
        icon: Icons.water_drop_outlined,
        label: 'Kelembapan',
        value: '${current.relativeHumidity}%',
      ),
      _MetricData(
        icon: Icons.air_rounded,
        label: 'Kecepatan Angin',
        value: '${current.windSpeed.toStringAsFixed(1)} km/j',
      ),
      _MetricData(
        icon: Icons.umbrella_outlined,
        label: 'Peluang Hujan',
        value: '$rainChanceToday%',
      ),
      _MetricData(
        icon: Icons.grain_rounded,
        label: 'Curah Hujan',
        value: '${current.precipitation.toStringAsFixed(1)} mm',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        final item = metrics[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;

  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _DailyForecastTile extends StatelessWidget {
  final DailyForecast forecast;

  const _DailyForecastTile({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final codeInfo = WeatherCodeInfo.fromCode(forecast.weatherCode);
    final dateText = DateFormat('EEE, d MMM').format(forecast.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 92,
              child: Text(
                dateText,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(
              codeInfo.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    codeInfo.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Hujan: ${forecast.precipitationProbabilityMax}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '${forecast.tempMin.toStringAsFixed(0)}° / ${forecast.tempMax.toStringAsFixed(0)}°C',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
