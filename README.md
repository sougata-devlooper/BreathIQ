# BreathIQ Mobile App (Flutter)

> **"Breathe better. Travel smarter. Live greener."**

Cross-platform Flutter mobile client for **BreathIQ** — a personal environmental intelligence and sustainable lifestyle companion.

## Features

- **Conversational Onboarding** (`lib/features/onboarding/`): Single-screen welcome greeting to personalize name, primary city, and travel mode, persisted locally via Hive (`cache_manager.dart`).
- **Home Dashboard** (`lib/features/home/`): Real-time US EPA AQI overview with pollutant metrics (`PM2.5`, `PM10`, `NO2`), weather summary, 24-hour forecast chart (`fl_chart`), and daily environmental recommendations.
- **Smart Travel & Routes** (`lib/features/explore/`): Multi-route carbon comparison across 6 travel modes (`Car`, `Motorcycle`, `Bus`, `Metro`, `Cycling`, `Walking`) with priority sorting (`Balanced`, `Greenest`, `Fastest`) and Google Maps launch support.
- **AI Environmental Assistant** (`lib/features/chat/`): Conversational assistant chat with quick-action prompt chips and user context forwarding.
- **Profile, Footprint & Indoor Guide** (`lib/features/profile/`, `lib/features/indoor/`): Weekly emissions tracking (`fl_chart`), manual trip logging, recent journey history, optional account sync, Indoor Air Quality Guide, and user data deletion.

## Tech Stack

- **Framework:** Flutter (Dart `>=3.3.0 <4.0.0`)
- **State & Navigation:** `flutter_riverpod`, `go_router`
- **Networking & Storage:** `dio`, `hive_flutter`, `flutter_dotenv`
- **UI & Visualization:** `fl_chart`, `google_fonts`, `flutter_animate`, `shimmer`, `url_launcher`

## Setup & Running Locally

> Platform wrapper folders (`android/`, `ios/`) are generated on your machine with the Flutter CLI so repository size stays lean.

1. **Generate platform runners** (inside `mobile/`):
   ```bash
   flutter create .
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure Backend URL:**
   Update `ApiEndpoints.baseUrl` in `lib/core/network/api_endpoints.dart`:
   - iOS Simulator / Desktop: `http://127.0.0.1:8000`
   - Android Emulator: `http://10.0.2.2:8000`
   - Physical Device: `http://<YOUR_LAN_IP>:8000`
4. **Run the app:**
   ```bash
   flutter run
   ```
