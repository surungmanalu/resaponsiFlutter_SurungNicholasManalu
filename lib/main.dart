import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/storage_service.dart';
import 'services/weather_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/landing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final weatherService = WeatherService();
  final storageService = StorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WeatherViewModel(
            weatherService: weatherService,
            storageService: storageService,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchViewModel(
            weatherService: weatherService,
            storageService: storageService,
          )..loadFavorites(),
        ),
      ],
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Cuaca Open-Meteo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LandingScreen(),
    );
  }
}
