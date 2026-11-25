class ApiEndpoints {
  // Configurable base URL. Default is 127.0.0.1 (use 10.0.2.2 for Android emulator)
  static String baseUrl = "http://127.0.0.1:8000";

  static const String authGuest = "/auth/guest";
  static const String authRegister = "/auth/register";
  static const String authLogin = "/auth/login";
  static const String authRefresh = "/auth/refresh";

  static const String airQuality = "/api/air-quality";
  static const String weather = "/api/weather";

  static const String routesCompare = "/api/routes/compare";
  static const String routesPlaces = "/api/routes/places";

  static const String emissionsCalculate = "/api/emissions/calculate";
  static const String emissionsModes = "/api/emissions/modes";

  static const String assistantChat = "/api/assistant/chat";
  static const String recommendationsDaily = "/api/recommendations/daily";
  static const String indoorAdvice = "/api/indoor-aq/advice";

  static const String journeys = "/api/journeys";
  static const String impactSummary = "/api/impact/summary";
  static const String userProfile = "/api/user/profile";
}
