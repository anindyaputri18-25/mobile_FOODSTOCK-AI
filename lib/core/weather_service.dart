import 'api_client.dart';

/// Memanggil endpoint cuaca di Next.js (Docker).
class WeatherService {
  WeatherService({ApiClient? api}) : _api = api ?? ApiClient();

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final data = await _api.get(
      '/api/external/weather',
      query: {'lat': '$lat', 'lon': '$lon'},
    );
    if (data is Map<String, dynamic>) return data;
    return {'data': data};
  }
}