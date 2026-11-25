import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/pastel_card.dart';

class IndoorGuideScreen extends StatefulWidget {
  const IndoorGuideScreen({super.key});

  @override
  State<IndoorGuideScreen> createState() => _IndoorGuideScreenState();
}

class _IndoorGuideScreenState extends State<IndoorGuideScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _loadAdvice();
  }

  Future<void> _loadAdvice() async {
    setState(() => _isLoading = true);
    try {
      final res = await apiClient.getIndoorAdvice();
      setState(() {
        _data = res;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.textPrimary)),
      );
    }

    final recommendations = (_data['recommendations'] as List<dynamic>?) ?? [];
    final mythBuster = _data['myth_buster'] as Map<String, dynamic>? ?? {};
    final disclaimer = _data['disclaimer'] ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Indoor Air Quality Guide")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.butterYellow.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      disclaimer,
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text("Rule-Based Action Plan", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            ...recommendations.map((item) {
              final imp = item['importance'] ?? 'advisory';
              Color iconBg = AppColors.softSkyBlue;
              if (imp == 'critical') iconBg = AppColors.critical.withOpacity(0.2);
              if (imp == 'recommended') iconBg = AppColors.mintGreen;

              return PastelCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                      child: Text(item['icon'] ?? '🪟', style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? '',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['action'] ?? '',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['explanation'] ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Honest Science Myth-Buster Note
            if (mythBuster.isNotEmpty) ...[
              const SizedBox(height: 8),
              PastelCard(
                backgroundColor: AppColors.pastelLavender.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("🔬", style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          mythBuster['title'] ?? "Science Note",
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mythBuster['text'] ?? "",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
