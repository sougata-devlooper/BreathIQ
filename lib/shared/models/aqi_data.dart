class Pollutants {
  final double pm25;
  final double pm10;
  final double no2;
  final double o3;
  final double so2;
  final double co;

  Pollutants({
    required this.pm25,
    required this.pm10,
    this.no2 = 0.0,
    this.o3 = 0.0,
    this.so2 = 0.0,
    this.co = 0.0,
  });

  factory Pollutants.fromJson(Map<String, dynamic> json) {
    return Pollutants(
      pm25: (json['pm25'] as num?)?.toDouble() ?? 0.0,
      pm10: (json['pm10'] as num?)?.toDouble() ?? 0.0,
      no2: (json['no2'] as num?)?.toDouble() ?? 0.0,
      o3: (json['o3'] as num?)?.toDouble() ?? 0.0,
      so2: (json['so2'] as num?)?.toDouble() ?? 0.0,
      co: (json['co'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ForecastPoint {
  final String timestamp;
  final int aqi;
  final String category;
  final double pm25;
  final double pm10;

  ForecastPoint({
    required this.timestamp,
    required this.aqi,
    required this.category,
    required this.pm25,
    required this.pm10,
  });

  factory ForecastPoint.fromJson(Map<String, dynamic> json) {
    return ForecastPoint(
      timestamp: json['timestamp'] ?? '',
      aqi: json['aqi'] ?? 0,
      category: json['category'] ?? 'Moderate',
      pm25: (json['pm25'] as num?)?.toDouble() ?? 0.0,
      pm10: (json['pm10'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AqiData {
  final String city;
  final double latitude;
  final double longitude;
  final int aqi;
  final String category;
  final String primaryPollutant;
  final String scale;
  final String explanation;
  final Pollutants pollutants;
  final String updatedAt;
  final bool isDemo;
  final String? demoBadge;
  final List<ForecastPoint> forecast;
  final bool isStale;
  final int ageMinutes;

  AqiData({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.aqi,
    required this.category,
    required this.primaryPollutant,
    required this.scale,
    required this.explanation,
    required this.pollutants,
    required this.updatedAt,
    this.isDemo = false,
    this.demoBadge,
    this.forecast = const [],
    this.isStale = false,
    this.ageMinutes = 0,
  });

  factory AqiData.fromJson(Map<String, dynamic> json) {
    final polsJson = json['pollutants'] as Map<String, dynamic>? ?? {};
    final fcList = (json['forecast'] as List<dynamic>?)
            ?.map((e) => ForecastPoint.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return AqiData(
      city: json['city'] ?? 'New Delhi',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 28.6139,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.2090,
      aqi: json['aqi'] ?? 142,
      category: json['category'] ?? 'Moderate',
      primaryPollutant: json['primary_pollutant'] ?? 'PM2.5',
      scale: json['scale'] ?? 'US EPA (0-500)',
      explanation: json['explanation'] ?? '',
      pollutants: Pollutants.fromJson(polsJson),
      updatedAt: json['updated_at'] ?? '',
      isDemo: json['is_demo'] ?? false,
      demoBadge: json['demo_badge'],
      forecast: fcList,
      isStale: json['_is_stale'] ?? false,
      ageMinutes: json['_age_minutes'] ?? 0,
    );
  }
}
