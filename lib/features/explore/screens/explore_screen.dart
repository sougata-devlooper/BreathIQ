import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/route_data.dart';
import '../../../shared/widgets/pastel_card.dart';
import '../../../shared/widgets/demo_badge.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _originController =
      TextEditingController(text: "Connaught Place, New Delhi");
  final TextEditingController _destController =
      TextEditingController(text: "Cyber City, Gurugram");

  String _selectedMode = "petrol_car_medium";
  String _prioritize = "balanced";
  int _occupants = 1;
  bool _isComparing = false;
  String? _error;
  List<RouteItem> _routes = [];
  bool _isDemo = false;
  String _areaDisclaimer = "";

  final List<Map<String, String>> _modes = [
    {"id": "petrol_car_medium", "label": "🚗 Car"},
    {"id": "motorcycle_medium", "label": "🏍️ Motorcycle"},
    {"id": "bus_local", "label": "🚌 Bus"},
    {"id": "metro_light_rail", "label": "🚇 Metro"},
    {"id": "cycling", "label": "🚲 Cycle"},
    {"id": "walking", "label": "🚶 Walk"},
  ];

  @override
  void initState() {
    super.initState();
    _compareRoutes();
  }

  Future<void> _compareRoutes() async {
    setState(() {
      _isComparing = true;
      _error = null;
    });

    try {
      final res = await apiClient.compareRoutes(
        origin: _originController.text.trim(),
        destination: _destController.text.trim(),
        transportMode: _selectedMode,
        occupants: _occupants,
        prioritize: _prioritize,
      );

      final rawList = res['routes'] as List<dynamic>? ?? [];
      setState(() {
        _routes = rawList.map((e) => RouteItem.fromJson(e as Map<String, dynamic>)).toList();
        _isDemo = res['is_demo'] ?? false;
        final areaContext = res['area_exposure_context'] as Map<String, dynamic>? ?? {};
        _areaDisclaimer = areaContext['disclaimer'] ?? "";
        _isComparing = false;
      });
    } catch (e) {
      setState(() {
        _error = null;
        _isDemo = true;
        _routes = [
          RouteItem(
            routeId: "route_a",
            summary: "via Primary Expressway Corridor",
            distanceKm: 19.4,
            durationMinutes: 38,
            durationInTrafficMinutes: 44,
            co2eGrams: 3600.0,
            percentageSaved: 0,
            isLowestEmissions: false,
            isFastest: true,
            isShortest: true,
            transportMode: _selectedMode,
            googleMapsUrl: "https://www.google.com/maps/dir/?api=1",
          ),
          RouteItem(
            routeId: "route_b",
            summary: "via Ring Road Bypass Route",
            distanceKm: 22.1,
            durationMinutes: 43,
            durationInTrafficMinutes: 48,
            co2eGrams: 4100.0,
            percentageSaved: 0,
            isLowestEmissions: false,
            isFastest: false,
            isShortest: false,
            transportMode: _selectedMode,
            googleMapsUrl: "https://www.google.com/maps/dir/?api=1",
          ),
          RouteItem(
            routeId: "route_c",
            summary: "via Public Transit / Metro Rail Network",
            distanceKm: 20.2,
            durationMinutes: 46,
            durationInTrafficMinutes: 46,
            co2eGrams: 580.0,
            percentageSaved: 84,
            impactAnalogy: "equal to charging 120 smartphones",
            isLowestEmissions: true,
            isFastest: false,
            isShortest: false,
            transportMode: "metro_light_rail",
            googleMapsUrl: "https://www.google.com/maps/dir/?api=1",
          ),
        ];
        _isComparing = false;
      });
    }
  }

  Future<void> _openMapsUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Travel & Routes"),
        actions: [
          if (_isDemo)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: DemoBadge()),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journey Input Form
            PastelCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _originController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.my_location_rounded, size: 20, color: AppColors.success),
                      labelText: "From",
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _destController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on_rounded, size: 20, color: AppColors.critical),
                      labelText: "To Destination",
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mode Selector Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _modes.map((m) {
                        final isSelected = _selectedMode == m["id"];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(m["label"]!),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _selectedMode = m["id"]!);
                                _compareRoutes();
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Compare Routes CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isComparing ? null : _compareRoutes,
                      child: _isComparing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                            )
                          : const Text("Compare Routes & Emissions"),
                    ),
                  ),
                ],
              ),
            ),

            // Area Air Quality & Exposure Transparency Note
            if (_areaDisclaimer.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.butterYellow.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Area Air Quality: Moderate (AQI 142)\n$_areaDisclaimer",
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Priority Filter Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Route Options (${_routes.length})",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                DropdownButton<String>(
                  value: _prioritize,
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  items: const [
                    DropdownMenuItem(value: "balanced", child: Text("Prioritize: Balanced")),
                    DropdownMenuItem(value: "greenest", child: Text("Prioritize: Greenest")),
                    DropdownMenuItem(value: "fastest", child: Text("Prioritize: Fastest")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _prioritize = val);
                      _compareRoutes();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Route Comparison Cards
            ..._routes.map((route) {
              final isLowest = route.isLowestEmissions;
              final cardBg = isLowest ? AppColors.primarySage.withOpacity(0.4) : AppColors.cardWhite;

              return PastelCard(
                backgroundColor: cardBg,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          route.summary,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (route.isLowestEmissions)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.mintGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("✅ Lowest Emissions", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                          )
                        else if (route.isFastest)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.softSkyBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("⚡ Fastest", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.info)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Travel distance and duration
                    Row(
                      children: [
                        Text("${route.distanceKm} km", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const Text("  ·  "),
                        Text("${route.durationMinutes} min", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        if (route.durationInTrafficMinutes != null && route.durationInTrafficMinutes! > route.durationMinutes) ...[
                          Text(" (${route.durationInTrafficMinutes} min in traffic)", style: const TextStyle(fontSize: 12, color: AppColors.critical)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // DEFRA Emissions display
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Estimated Footprint:", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(
                                "${route.co2eGrams.round()} g CO₂e",
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          if (route.percentageSaved > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              "🌱 Saves ${route.percentageSaved}% vs highest route (${route.impactAnalogy})",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _openMapsUrl(route.googleMapsUrl),
                          icon: const Icon(Icons.map_outlined, size: 16),
                          label: const Text("Open in Google Maps", style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
