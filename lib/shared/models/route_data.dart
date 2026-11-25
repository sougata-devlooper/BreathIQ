class Equivalency {
  final String id;
  final String label;
  final String icon;
  final double value;
  final String formattedValue;
  final String unit;
  final String source;

  Equivalency({
    required this.id,
    required this.label,
    required this.icon,
    required this.value,
    required this.formattedValue,
    required this.unit,
    required this.source,
  });

  factory Equivalency.fromJson(Map<String, dynamic> json) {
    return Equivalency(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] ?? '🌱',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      formattedValue: json['formatted_value'] ?? '0',
      unit: json['unit'] ?? '',
      source: json['source'] ?? '',
    );
  }
}

class RouteItem {
  final String routeId;
  final String summary;
  final double distanceKm;
  final int durationMinutes;
  final int? durationInTrafficMinutes;
  final String polyline;
  final String transportMode;
  final double co2eGrams;
  final double score;
  final bool isLowestEmissions;
  final bool isFastest;
  final bool isShortest;
  final double emissionsSavedGrams;
  final int percentageSaved;
  final String impactAnalogy;
  final List<Equivalency> equivalencies;
  final String googleMapsUrl;

  RouteItem({
    required this.routeId,
    required this.summary,
    required this.distanceKm,
    required this.durationMinutes,
    this.durationInTrafficMinutes,
    required this.polyline,
    required this.transportMode,
    required this.co2eGrams,
    required this.score,
    required this.isLowestEmissions,
    required this.isFastest,
    required this.isShortest,
    required this.emissionsSavedGrams,
    required this.percentageSaved,
    required this.impactAnalogy,
    required this.equivalencies,
    required this.googleMapsUrl,
  });

  factory RouteItem.fromJson(Map<String, dynamic> json) {
    final eqList = (json['equivalencies'] as List<dynamic>?)
            ?.map((e) => Equivalency.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return RouteItem(
      routeId: json['route_id'] ?? '',
      summary: json['summary'] ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['duration_minutes'] ?? 0,
      durationInTrafficMinutes: json['duration_in_traffic_minutes'],
      polyline: json['polyline'] ?? '',
      transportMode: json['transport_mode'] ?? 'petrol_car_medium',
      co2eGrams: (json['co2e_grams'] as num?)?.toDouble() ?? 0.0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      isLowestEmissions: json['is_lowest_emissions'] ?? false,
      isFastest: json['is_fastest'] ?? false,
      isShortest: json['is_shortest'] ?? false,
      emissionsSavedGrams: (json['emissions_saved_grams'] as num?)?.toDouble() ?? 0.0,
      percentageSaved: json['percentage_saved'] ?? 0,
      impactAnalogy: json['impact_analogy'] ?? '',
      equivalencies: eqList,
      googleMapsUrl: json['google_maps_url'] ?? '',
    );
  }
}
