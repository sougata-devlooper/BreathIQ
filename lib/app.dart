import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/network/cache_manager.dart';

class BreathIQApp extends ConsumerWidget {
  const BreathIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createRouter(
      isOnboardingComplete: cacheManager.isOnboardingComplete,
    );

    return MaterialApp.router(
      title: 'BreathIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
