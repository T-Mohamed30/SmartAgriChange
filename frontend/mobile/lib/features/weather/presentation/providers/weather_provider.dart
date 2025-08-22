import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/weather_entity.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherData>> {
  final WeatherRepository _repository;
  
  WeatherNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchWeather('Dakar'); // Ville par défaut
  }

  Future<void> fetchWeather(String city) async {
    state = const AsyncValue.loading();
    try {
      final weather = await _repository.getWeather(city);
      state = AsyncValue.data(weather);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherData>>((ref) {
  return WeatherNotifier(ref.read(weatherRepositoryProvider));
});
