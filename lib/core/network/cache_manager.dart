import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class CacheManager {
  static const String boxName = "breathiq_cache";
  Box? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(boxName);
  }

  Future<void> putData(String key, Map<String, dynamic> data) async {
    if (_box == null) return;
    final entry = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'payload': jsonEncode(data),
    };
    await _box!.put(key, entry);
  }

  Map<String, dynamic>? getData(String key, {Duration maxAge = const Duration(minutes: 30)}) {
    final raw = _box?.get(key);
    if (raw == null) return null;

    final entry = Map<String, dynamic>.from(raw as Map);
    final timestamp = entry['timestamp'] as int? ?? 0;
    final payloadStr = entry['payload'] as String? ?? '{}';

    try {
      final data = jsonDecode(payloadStr) as Map<String, dynamic>;
      final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
      data['_is_stale'] = age > maxAge;
      data['_cached_at'] = DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String();
      data['_age_minutes'] = age.inMinutes;
      return data;
    } catch (_) {
      return null;
    }
  }

  bool isKeyStale(String key, Duration maxAge) {
    final raw = _box?.get(key);
    if (raw == null) return true;
    final entry = Map<String, dynamic>.from(raw as Map);
    final timestamp = entry['timestamp'] as int? ?? 0;
    final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
    return age > maxAge;
  }

  String? getStoredDeviceId() {
    return _box?.get('device_id') as String?;
  }

  Future<void> setStoredDeviceId(String id) async {
    if (_box != null) await _box!.put('device_id', id);
  }

  bool get isOnboardingComplete => (_box?.get('onboarded') as bool?) ?? false;

  Future<void> setOnboardingComplete(bool value) async {
    if (_box != null) await _box!.put('onboarded', value);
  }
}

final cacheManager = CacheManager();
