class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, String> toApiMap() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class JourneyItem {
  final String id;
  final String transportMode;
  final double distanceKm;
  final int occupants;
  final double co2eGrams;
  final double perPersonCo2eGrams;
  final String? notes;
  final String factorSource;
  final String createdAt;

  JourneyItem({
    required this.id,
    required this.transportMode,
    required this.distanceKm,
    required this.occupants,
    required this.co2eGrams,
    required this.perPersonCo2eGrams,
    this.notes,
    required this.factorSource,
    required this.createdAt,
  });

  factory JourneyItem.fromJson(Map<String, dynamic> json) {
    return JourneyItem(
      id: json['id'] ?? '',
      transportMode: json['transport_mode'] ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      occupants: json['occupants'] ?? 1,
      co2eGrams: (json['co2e_grams'] as num?)?.toDouble() ?? 0.0,
      perPersonCo2eGrams: (json['per_person_co2e_grams'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      factorSource: json['factor_source'] ?? 'UK DEFRA 2024',
      createdAt: json['created_at'] ?? '',
    );
  }
}
