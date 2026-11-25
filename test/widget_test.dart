import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weather_app/main.dart';
import 'package:weather_app/services/storage_service.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/viewmodels/search_viewmodel.dart';
import 'package:weather_app/viewmodels/weather_viewmodel.dart';

void main() {
  testWidgets('LandingScreen tampil dan navigasi ke HomeScreen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final weatherService = WeatherService();
    final storageService = StorageService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => WeatherViewModel(
              weatherService: weatherService,
              storageService: storageService,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => SearchViewModel(
              weatherService: weatherService,
              storageService: storageService,
            ),
          ),
        ],
        child: const WeatherApp(),
      ),
    );

    expect(find.text('CuacaKu'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);

    await tester.ensureVisible(find.text('Mulai Sekarang'));
    await tester.tap(find.text('Mulai Sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Lokasi Dipilih'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsWidgets);
  });
}
