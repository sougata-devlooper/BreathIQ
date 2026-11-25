import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/aqi_data.dart';
import '../../../shared/models/weather_data.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../shared/widgets/demo_badge.dart';
import '../../../shared/widgets/error_state.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenChat;
  final VoidCallback onOpenExplore;

  const HomeScreen({
    super.key,
    required this.onOpenChat,
    required this.onOpenExplore,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _error;
  AqiData? _aqiData;
  WeatherData? _weatherData;
  List<Map<String, dynamic>> _recommendations = [];

  String _activeCity = "New Delhi";
  double _activeLat = 28.6139;
  double _activeLng = 77.2090;
  String _userName = "Friend";

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData({String? city, double? lat, double? lng}) async {
    if (city != null) _activeCity = city;
    if (lat != null) _activeLat = lat;
    if (lng != null) _activeLng = lng;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final aqiRes = await apiClient.getAirQuality(lat: _activeLat, lng: _activeLng, city: _activeCity);
      final weatherRes = await apiClient.getWeather(lat: _activeLat, lng: _activeLng, city: _activeCity);
      final recRes = await apiClient.getDailyRecommendations();
      try {
        final profRes = await apiClient.getUserProfile();
        if (profRes['display_name'] != null && (profRes['display_name'] as String).isNotEmpty) {
          _userName = profRes['display_name'];
        }
      } catch (_) {}

      setState(() {
        _aqiData = AqiData.fromJson(aqiRes);
        _weatherData = WeatherData.fromJson(weatherRes);
        final top3 = recRes['top_3'] as List<dynamic>? ?? [];
        _recommendations = top3.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Could not load environmental telemetry.";
        _isLoading = false;
      });
    }
  }

  void _showCitySearchDialog() {
    final searchCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Change City / Location", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  hintText: "Search any city worldwide...",
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      final q = searchCtrl.text.trim();
                      if (q.isNotEmpty) {
                        Navigator.pop(ctx);
                        _loadDashboardData(city: q);
                      }
                    },
                  ),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    Navigator.pop(ctx);
                    _loadDashboardData(city: val.trim());
                  }
                },
              ),
              const SizedBox(height: 14),
              const Text("Popular Cities", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(label: const Text("📍 New Delhi"), onPressed: () { Navigator.pop(ctx); _loadDashboardData(city: "New Delhi", lat: 28.6139, lng: 77.2090); }),
                  ActionChip(label: const Text("📍 Mumbai"), onPressed: () { Navigator.pop(ctx); _loadDashboardData(city: "Mumbai", lat: 19.0760, lng: 72.8777); }),
                  ActionChip(label: const Text("📍 Bengaluru"), onPressed: () { Navigator.pop(ctx); _loadDashboardData(city: "Bengaluru", lat: 12.9716, lng: 77.5946); }),
                  ActionChip(label: const Text("📍 London"), onPressed: () { Navigator.pop(ctx); _loadDashboardData(city: "London", lat: 51.5074, lng: -0.1278); }),
                  ActionChip(label: const Text("📍 New York"), onPressed: () { Navigator.pop(ctx); _loadDashboardData(city: "New York", lat: 40.7128, lng: -74.0060); }),
                  ActionChip(label: const Text("📍 Tokyo"), onPressed: () { Navigator.pop(ctx); _loadDashboardData(city: "Tokyo", lat: 35.6762, lng: 139.6503); }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.textPrimary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: ErrorStateWidget(
          title: "Connection issue",
          message: _error!,
          onRetry: _loadDashboardData,
        ),
      );
    }

    final aqi = _aqiData?.aqi ?? 142;
    final aqiTint = AppColors.getAqiTint(aqi);
    final aqiAccent = AppColors.getAqiAccent(aqi);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppColors.textPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Location & Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_getGreeting()}, $_userName 👋",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 3),
                        InkWell(
                          onTap: _showCitySearchDialog,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                "${_aqiData?.city ?? _activeCity}  ·  Updated just now",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySage,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text("Change", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_aqiData?.isDemo == true) const DemoBadge(),
                  ],
                ),
                const SizedBox(height: 20),

                // AQI Overview Card
                PastelCard(
                  backgroundColor: aqiTint,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "AIR QUALITY INDEX",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: aqiAccent,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _aqiData?.category ?? "Moderate",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: aqiAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "$aqi",
                            style: TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w800,
                              color: aqiAccent,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "US EPA AQI",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: aqiAccent.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _aqiData?.explanation ?? "Air quality is acceptable.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.35,
                            ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.black12, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPollutantMetric("PM2.5", "${_aqiData?.pollutants.pm25 ?? 55.2}", "μg/m³"),
                          _buildPollutantMetric("PM10", "${_aqiData?.pollutants.pm10 ?? 88.1}", "μg/m³"),
                          _buildPollutantMetric("NO2", "${_aqiData?.pollutants.no2 ?? 32.4}", "μg/m³"),
                        ],
                      ),
                    ],
                  ),
                ),

                // Weather Card
                PastelCard(
                  backgroundColor: AppColors.softSkyBlue.withOpacity(0.5),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.wb_sunny_rounded, size: 32, color: AppColors.warning),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${_weatherData?.temperatureC.round()}°C",
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  _weatherData?.condition ?? "Partly Cloudy",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Humidity: ${_weatherData?.humidityPercent}%  ·  Wind: ${_weatherData?.windSpeedKmh} km/h ${_weatherData?.windDirection}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 24-Hour Forecast Chart
                if (_aqiData?.forecast.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    "Air Quality Forecast (24 Hours)",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  PastelCard(
                    padding: const EdgeInsets.only(top: 20, right: 20, bottom: 12, left: 10),
                    child: SizedBox(
                      height: 150,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 4,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _aqiData!.forecast.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value.aqi.toDouble());
                              }).toList(),
                              isCurved: true,
                              color: AppColors.textPrimary,
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: aqiTint.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Today's Top Recommendations
                const SizedBox(height: 12),
                Text(
                  "Today's Recommendations",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ..._recommendations.map((rec) {
                  return PastelCard(
                    backgroundColor: AppColors.cardWhite,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rec['icon'] ?? '🌱', style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec['title'] ?? '',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rec['explanation'] ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                rec['trigger'] ?? '',
                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // CTA Card: Assistant
                const SizedBox(height: 8),
                PastelCard(
                  backgroundColor: AppColors.mintGreen.withOpacity(0.6),
                  onTap: widget.onOpenChat,
                  child: Row(
                    children: [
                      const Text("💬", style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Chat with BreathIQ",
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              "Ask about workout safety, transit options, or air tips.",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollutantMetric(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(unit, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
      ],
    );
  }
}
