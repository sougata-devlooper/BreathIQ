import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/network/cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local Hive cache
  try {
    await cacheManager.init();
  } catch (_) {
    // Graceful fallback for non-persistent testing environments
  }

  runApp(
    const ProviderScope(
      child: BreathIQApp(),
    ),
  );
}
