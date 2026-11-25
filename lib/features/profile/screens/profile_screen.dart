import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/chat_message.dart';
import '../../../shared/widgets/pastel_card.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onOpenIndoorGuide;

  const ProfileScreen({
    super.key,
    required this.onOpenIndoorGuide,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _profile = {};
  Map<String, dynamic> _impactSummary = {};
  List<JourneyItem> _journeys = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final profileRes = await apiClient.getUserProfile();
      final summaryRes = await apiClient.getImpactSummary(period: "week");
      final journeysRes = await apiClient.getJourneys(limit: 15);

      setState(() {
        _profile = profileRes;
        _impactSummary = summaryRes;
        _journeys = journeysRes
            .map((e) => JourneyItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showLogActivityDialog() {
    String selectedMode = "metro_light_rail";
    double distanceKm = 10.0;
    int occupants = 1;
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                      Text(
                        "Log Travel Activity",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("Transport Mode", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedMode,
                    decoration: const InputDecoration(isDense: true),
                    items: const [
                      DropdownMenuItem(value: "metro_light_rail", child: Text("🚇 Metro / Light Rail")),
                      DropdownMenuItem(value: "bus_local", child: Text("🚌 Local Bus")),
                      DropdownMenuItem(value: "petrol_car_medium", child: Text("🚗 Petrol Car")),
                      DropdownMenuItem(value: "electric_car", child: Text("⚡ Electric Car")),
                      DropdownMenuItem(value: "motorcycle_medium", child: Text("🏍️ Motorcycle")),
                      DropdownMenuItem(value: "auto_rickshaw_cng", child: Text("🛺 Auto-rickshaw (CNG)")),
                      DropdownMenuItem(value: "cycling", child: Text("🚲 Cycling (0g)")),
                      DropdownMenuItem(value: "walking", child: Text("🚶 Walking (0g)")),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedMode = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Text("Distance: ${distanceKm.toStringAsFixed(1)} km", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  Slider(
                    value: distanceKm,
                    min: 1.0,
                    max: 100.0,
                    divisions: 99,
                    activeColor: AppColors.textPrimary,
                    onChanged: (val) => setModalState(() => distanceKm = val),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: "Notes (Optional)", isDense: true),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await apiClient.logJourney(
                          transportMode: selectedMode,
                          distanceKm: distanceKm,
                          occupants: occupants,
                          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                        );
                        _loadAllData();
                      },
                      child: const Text("Save Activity"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Personal Data?"),
        content: const Text("This will permanently remove your logged journeys and lifestyle survey responses from the local device and backend."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await apiClient.deleteUserData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All personal data has been erased.")),
                );
              }
              _loadAllData();
            },
            child: const Text("Delete", style: TextStyle(color: AppColors.critical)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _profile['display_name'] ?? "Friend");
    final cityCtrl = TextEditingController(text: _profile['city'] ?? "New Delhi");
    String selectedVehicle = (_profile['lifestyle_data'] as Map<String, dynamic>?)?['primary_transport'] ?? "metro_light_rail";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                      Text(
                        "Edit Profile & Location",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("Your Name", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(isDense: true)),
                  const SizedBox(height: 14),
                  const Text("Primary City / Location", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(controller: cityCtrl, decoration: const InputDecoration(isDense: true)),
                  const SizedBox(height: 14),
                  const Text("Primary Vehicle / Mode", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedVehicle,
                    decoration: const InputDecoration(isDense: true),
                    items: const [
                      DropdownMenuItem(value: "metro_light_rail", child: Text("🚇 Metro / Rail")),
                      DropdownMenuItem(value: "petrol_car_medium", child: Text("🚗 Petrol Car")),
                      DropdownMenuItem(value: "motorcycle_medium", child: Text("🏍️ Motorcycle")),
                      DropdownMenuItem(value: "bus_local", child: Text("🚌 City Bus")),
                      DropdownMenuItem(value: "cycling", child: Text("🚲 Bicycle")),
                      DropdownMenuItem(value: "walking", child: Text("🚶 Walking")),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedVehicle = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await apiClient.updateUserProfile({
                          "display_name": nameCtrl.text.trim(),
                          "city": cityCtrl.text.trim(),
                          "lifestyle_data": {
                            ...?(_profile['lifestyle_data'] as Map<String, dynamic>?),
                            "primary_transport": selectedVehicle,
                          },
                        });
                        _loadAllData();
                      },
                      child: const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSyncAccountDialog() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

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
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                  Text(
                    "Sync Impact Across Devices",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Link an email to backup your logged trips and access BreathIQ from any device.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email Address", isDense: true),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: "Password", isDense: true),
                obscureText: true,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                        Navigator.pop(ctx);
                        try {
                          await apiClient.login(email: emailCtrl.text.trim(), password: passCtrl.text.trim());
                          _loadAllData();
                        } catch (_) {}
                      },
                      child: const Text("Log In"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
                        Navigator.pop(ctx);
                        try {
                          await apiClient.register(
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text.trim(),
                            displayName: _profile['display_name'] ?? "Friend",
                          );
                          _loadAllData();
                        } catch (_) {}
                      },
                      child: const Text("Sign Up"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.textPrimary)),
      );
    }

    final isGuest = _profile['is_guest'] ?? true;
    final totalCo2e = (_impactSummary['total_co2e_grams'] as num?)?.toDouble() ?? 0.0;
    final totalKm = (_impactSummary['total_distance_km'] as num?)?.toDouble() ?? 0.0;
    final analogy = _impactSummary['primary_analogy'] ?? "No emissions logged yet";
    final weeklyChartData = (_impactSummary['weekly_chart'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Impact"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showLogActivityDialog,
            tooltip: "Log Travel Activity",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: AppColors.textPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Profile Header Card with Edit Action
              PastelCard(
                backgroundColor: AppColors.primarySage.withOpacity(0.4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primarySage,
                      child: const Text("👤", style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _profile['display_name'] ?? "Friend",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isGuest ? AppColors.cardWhite : AppColors.mintGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isGuest ? "Guest" : "Synced",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isGuest ? AppColors.textSecondary : AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "📍 ${_profile['city'] ?? 'New Delhi'}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textPrimary),
                      onPressed: _showEditProfileDialog,
                      tooltip: "Edit Profile & Location",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Optional Sync Across Devices Card
              PastelCard(
                backgroundColor: AppColors.pastelLavender.withOpacity(0.4),
                onTap: _showSyncAccountDialog,
                child: Row(
                  children: [
                    const Text("☁️", style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sync Across Devices",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          Text(
                            isGuest ? "Link email to backup your footprint history" : "Account synced with ${_profile['email'] ?? ''}",
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),

              // 2. Personal Environmental Impact Section
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("My Environmental Impact", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: _showLogActivityDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Log Trip", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              PastelCard(
                backgroundColor: AppColors.primarySage.withOpacity(0.5),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "THIS WEEK'S ESTIMATED EMISSIONS",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "${totalCo2e.round()}",
                          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        const Text("g CO₂e", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Across $totalKm km logged  ·  $analogy",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "ℹ️ Sourced from UK DEFRA 2024 factors based on your logged trips.",
                      style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),

              // 3. Weekly Activity Chart (7 Days)
              if (weeklyChartData.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text("Weekly Footprint Trend", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                PastelCard(
                  padding: const EdgeInsets.only(top: 24, right: 16, bottom: 12, left: 8),
                  child: SizedBox(
                    height: 150,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx >= 0 && idx < weeklyChartData.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      weeklyChartData[idx]['day_label'] ?? '',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: weeklyChartData.asMap().entries.map((e) {
                          final grams = (e.value['co2e_grams'] as num?)?.toDouble() ?? 0.0;
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: grams > 0 ? grams : 40.0,
                                color: grams > 0 ? AppColors.textPrimary : AppColors.borderSoft,
                                width: 14,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],

              // 4. Recent Activity Logs
              if (_journeys.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text("Recent Trips (${_journeys.length})", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ..._journeys.map((j) {
                  return PastelCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              j.transportMode.replaceAll("_", " ").toUpperCase(),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text("${j.distanceKm} km  ·  ${j.notes ?? 'Daily commute'}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${j.perPersonCo2eGrams.round()} g", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const Text("CO₂e", style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // 5. Indoor Air Quality Guide Link
              const SizedBox(height: 10),
              PastelCard(
                backgroundColor: AppColors.pastelLavender.withOpacity(0.5),
                onTap: widget.onOpenIndoorGuide,
                child: Row(
                  children: [
                    const Text("🪟", style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Indoor Air Quality Guide", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          Text("Ventilation rules, cooking exhaust & science insights", style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textPrimary),
                  ],
                ),
              ),

              // 6. Privacy & Storage
              const SizedBox(height: 10),
              Text("Privacy & Storage", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              PastelCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.critical),
                  title: const Text("Delete My Data", style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text("Permanently erase logged journeys and profile settings", style: TextStyle(fontSize: 12)),
                  onTap: _showDeleteConfirm,
                ),
              ),

              // App Version Footer
              const SizedBox(height: 16),
              const Center(
                child: Text("BreathIQ Version 2.0 (Upgraded)", style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
