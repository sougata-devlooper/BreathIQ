import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/cache_manager.dart';
import '../../../shared/widgets/pastel_card.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WelcomeScreen({super.key, required this.onComplete});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: "New Delhi");
  String _selectedVehicle = "metro_light_rail";

  final List<Map<String, String>> _vehicles = [
    {"id": "metro_light_rail", "label": "🚇 Metro / Rail"},
    {"id": "petrol_car_medium", "label": "🚗 Petrol Car"},
    {"id": "motorcycle_medium", "label": "🏍️ Motorcycle"},
    {"id": "bus_local", "label": "🚌 City Bus"},
    {"id": "cycling", "label": "🚲 Bicycle"},
    {"id": "walking", "label": "🚶 Walking"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primarySage,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text("🌿", style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to BreathIQ",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Text(
                        "Your personal environmental companion",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Conversational Greeting Card
              PastelCard(
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Paragraph 1: Welcome & Name
                      const Text(
                        "Hello there! I am BreathIQ, your personal environmental companion. I am delighted to welcome",
                        style: TextStyle(fontSize: 15, height: 1.6, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "your name",
                          filled: true,
                          fillColor: AppColors.primarySage.withOpacity(0.4),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "to a cleaner, greener journey!",
                        style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
                      ),
                      const Divider(height: 28),

                      // Paragraph 2: Location
                      const Text(
                        "To protect your lungs and deliver real-time air quality forecasts, where are you based? I'll be monitoring conditions for you in",
                        style: TextStyle(fontSize: 15, height: 1.6, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _cityController,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "city, e.g. New Delhi, London",
                          filled: true,
                          fillColor: AppColors.primarySage.withOpacity(0.4),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.location_city_rounded, size: 20, color: AppColors.textSecondary),
                        ),
                      ),
                      const Divider(height: 28),

                      // Paragraph 3: Mode of Travel / Vehicle
                      const Text(
                        "Whenever you head out, what is your primary vehicle or mode of travel? I will help optimize trips for",
                        style: TextStyle(fontSize: 15, height: 1.6, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primarySage.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedVehicle,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
                            items: _vehicles.map((v) {
                              return DropdownMenuItem<String>(
                                value: v["id"],
                                child: Text(
                                  v["label"]!,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedVehicle = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Micro badge
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySage.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Text("🌱", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Together, let's make every breath count and travel smarter!",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final enteredName = _nameController.text.trim();
                    final enteredCity = _cityController.text.trim();
                    try {
                      await cacheManager.setOnboardingComplete(true);
                    } catch (_) {}
                    try {
                      await apiClient.updateUserProfile({
                        if (enteredName.isNotEmpty) "display_name": enteredName,
                        if (enteredCity.isNotEmpty) "city": enteredCity,
                        "lifestyle_data": {
                          "primary_transport": _selectedVehicle,
                        }
                      });
                    } catch (_) {}
                    widget.onComplete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Step Inside BreathIQ 🌿 →",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Zero forced sign-up · You can edit this anytime in Profile",
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
