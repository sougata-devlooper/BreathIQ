class HourlyWeather {
  final String timestamp;
  final double temperatureC;
  final int humidityPercent;
  final double windSpeedKmh;
  final int weatherCode;
  final String condition;

  HourlyWeather({
    required this.timestamp,
    required this.temperatureC,
    required this.humidityPercent,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.condition,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      timestamp: json['timestamp'] ?? '',
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 25.0,
      humidityPercent: json['humidity_percent'] ?? 50,
      windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 10.0,
      weatherCode: json['weather_code'] ?? 0,
      condition: json['condition'] ?? 'Clear',
    );
  }
}

class WeatherData {
  final String city;
  final double latitude;
  final double longitude;
  final double temperatureC;
  final double feelsLikeC;
  final int humidityPercent;
  final double windSpeedKmh;
  final String windDirection;
  final String condition;
  final double highTempC;
  final double lowTempC;
  final double uvIndex;
  final String updatedAt;
  final bool isDemo;
  final String? demoBadge;
  final List<HourlyWeather> hourlyForecast;
  final bool isStale;
  final int ageMinutes;

  WeatherData({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.humidityPercent,
    required this.windSpeedKmh,
    required this.windDirection,
    required this.condition,
    required this.highTempC,
    required this.lowTempC,
    required this.uvIndex,
    required this.updatedAt,
    this.isDemo = false,
    this.demoBadge,
    this.hourlyForecast = const [],
    this.isStale = false,
    this.ageMinutes = 0,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final list = (json['hourly_forecast'] as List<dynamic>?)
            ?.map((e) => HourlyWeather.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return WeatherData(
      city: json['city'] ?? 'New Delhi',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 28.6139,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.2090,
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 26.0,
      feelsLikeC: (json['feels_like_c'] as num?)?.toDouble() ?? 26.0,
      humidityPercent: json['humidity_percent'] ?? 55,
      windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 12.0,
      windDirection: json['wind_direction'] ?? 'NW',
      condition: json['condition'] ?? 'Partly Cloudy',
      highTempC: (json['high_temp_c'] as num?)?.toDouble() ?? 29.0,
      lowTempC: (json['low_temp_c'] as num?)?.toDouble() ?? 18.0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 5.0,
      updatedAt: json['updated_at'] ?? '',
      isDemo: json['is_demo'] ?? false,
      demoBadge: json['demo_badge'],
      hourlyForecast: list,
      isStale: json['_is_stale'] ?? false,
      ageMinutes: json['_age_minutes'] ?? 0,
    );
  }
}
