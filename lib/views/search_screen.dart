import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

/// Screen 2: Search / Location Screen
/// Menyediakan input pencarian kota via API, daftar hasil pencarian,
/// serta daftar lokasi favorit yang tersimpan di Local Storage.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(SearchViewModel searchVm) {
    FocusScope.of(context).unfocus();
    searchVm.searchCities(_controller.text);
  }

  void _selectLocation(LocationModel location) {
    context.read<WeatherViewModel>().selectLocationAndLoad(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, searchVm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cari Lokasi'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _onSearchSubmitted(searchVm),
                            decoration: InputDecoration(
                              hintText: 'Masukkan nama kota (mis. Yogyakarta)',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _controller.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _controller.clear();
                                        searchVm.clearSearch();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: searchVm.isLoading
                              ? null
                              : () => _onSearchSubmitted(searchVm),
                          child: const Text('Cari'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildContent(context, searchVm),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SearchViewModel searchVm) {
    if (searchVm.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Mencari lokasi...'),
          ],
        ),
      );
    }

    if (searchVm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              searchVm.errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _onSearchSubmitted(searchVm),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (searchVm.hasSearched) {
      if (searchVm.searchResults.isEmpty) {
        return const Center(
          child: Text('Kota tidak ditemukan. Coba kata kunci lain.'),
        );
      }

      return ListView(
        children: [
          Text(
            'Hasil Pencarian',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...searchVm.searchResults.map(
            (loc) => _LocationTile(
              location: loc,
              isFavorite: searchVm.isFavorite(loc),
              onTap: () => _selectLocation(loc),
              onToggleFavorite: () => searchVm.toggleFavorite(loc),
            ),
          ),
        ],
      );
    }

    // Jika belum mencari, tampilkan daftar Lokasi Favorit yang tersimpan lokal.
    if (searchVm.favorites.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada lokasi favorit.\nCari nama kota di atas untuk memulai.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView(
      children: [
        Text(
          'Lokasi Favorit',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...searchVm.favorites.map(
          (loc) => _LocationTile(
            location: loc,
            isFavorite: true,
            onTap: () => _selectLocation(loc),
            onToggleFavorite: () => searchVm.toggleFavorite(loc),
          ),
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _LocationTile({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.location_city_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(location.name),
        subtitle: location.subtitle.isNotEmpty ? Text(location.subtitle) : null,
        trailing: IconButton(
          tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? Colors.redAccent : null,
          ),
          onPressed: onToggleFavorite,
        ),
        onTap: onTap,
      ),
    );
  }
}
