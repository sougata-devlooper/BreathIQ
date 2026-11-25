import 'dart:async';
import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio dio;
  String? _accessToken;
  String? _refreshToken;
  String _deviceId = "breathiq-guest-device-default";

  ApiClient({String? baseUrl, String? deviceId}) {
    if (deviceId != null && deviceId.isNotEmpty) {
      _deviceId = deviceId;
    }

    dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Device-Id': _deviceId,
      },
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Device-Id'] = _deviceId;
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 && _refreshToken != null) {
            final refreshed = await _attemptTokenRefresh();
            if (refreshed) {
              final opts = Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers..['Authorization'] = 'Bearer $_accessToken',
              );
              try {
                final cloneReq = await dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: opts,
                );
                return handler.resolve(cloneReq);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setTokens({required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void setDeviceId(String deviceId) {
    _deviceId = deviceId;
    dio.options.headers['X-Device-Id'] = deviceId;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  Future<bool> _attemptTokenRefresh() async {
    if (_refreshToken == null) return false;
    try {
      final res = await dio.post(ApiEndpoints.authRefresh, data: {
        'refresh_token': _refreshToken,
      });
      if (res.statusCode == 200 && res.data != null) {
        _accessToken = res.data['access_token'];
        _refreshToken = res.data['refresh_token'];
        return true;
      }
    } catch (_) {
      clearTokens();
    }
    return false;
  }

  // --- API Methods ---
  Future<Map<String, dynamic>> guestLogin(String deviceId) async {
    setDeviceId(deviceId);
    final res = await dio.post(ApiEndpoints.authGuest, data: {'device_id': deviceId});
    final data = res.data as Map<String, dynamic>;
    setTokens(accessToken: data['access_token'], refreshToken: data['refresh_token']);
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? displayName,
    String? city,
  }) async {
    final res = await dio.post(ApiEndpoints.authRegister, data: {
      'email': email,
      'password': password,
      'display_name': displayName,
      'device_id': _deviceId,
      'city': city,
    });
    final data = res.data as Map<String, dynamic>;
    setTokens(accessToken: data['access_token'], refreshToken: data['refresh_token']);
    return data;
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final res = await dio.post(ApiEndpoints.authLogin, data: {'email': email, 'password': password});
    final data = res.data as Map<String, dynamic>;
    setTokens(accessToken: data['access_token'], refreshToken: data['refresh_token']);
    return data;
  }

  Future<Map<String, dynamic>> getAirQuality({double? lat, double? lng, String? city}) async {
    final res = await dio.get(ApiEndpoints.airQuality, queryParameters: {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (city != null) 'city': city,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWeather({double? lat, double? lng, String? city}) async {
    final res = await dio.get(ApiEndpoints.weather, queryParameters: {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (city != null) 'city': city,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> compareRoutes({
    required String origin,
    required String destination,
    String transportMode = "petrol_car_medium",
    int occupants = 1,
    String prioritize = "balanced",
  }) async {
    final res = await dio.post(ApiEndpoints.routesCompare, data: {
      'origin': origin,
      'destination': destination,
      'transport_mode': transportMode,
      'occupants': occupants,
      'prioritize': prioritize,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPlacesAutocomplete(String query) async {
    final res = await dio.get(ApiEndpoints.routesPlaces, queryParameters: {'q': query});
    return (res.data['suggestions'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> calculateEmissions({
    required String transportMode,
    required double distanceKm,
    int occupants = 1,
  }) async {
    final res = await dio.post(ApiEndpoints.emissionsCalculate, data: {
      'transport_mode': transportMode,
      'distance_km': distanceKm,
      'occupants': occupants,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> chatWithAssistant(
    List<Map<String, String>> messages, {
    Map<String, dynamic>? contextOverride,
  }) async {
    final res = await dio.post(ApiEndpoints.assistantChat, data: {
      'messages': messages,
      if (contextOverride != null) 'context_override': contextOverride,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDailyRecommendations() async {
    final res = await dio.get(ApiEndpoints.recommendationsDaily);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getIndoorAdvice() async {
    final res = await dio.get(ApiEndpoints.indoorAdvice);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> logJourney({
    required String transportMode,
    required double distanceKm,
    int occupants = 1,
    String? notes,
  }) async {
    final res = await dio.post(ApiEndpoints.journeys, data: {
      'transport_mode': transportMode,
      'distance_km': distanceKm,
      'occupants': occupants,
      if (notes != null) 'notes': notes,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getJourneys({int limit = 20}) async {
    final res = await dio.get(ApiEndpoints.journeys, queryParameters: {'limit': limit});
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getImpactSummary({String period = "week"}) async {
    final res = await dio.get(ApiEndpoints.impactSummary, queryParameters: {'period': period});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final res = await dio.get(ApiEndpoints.userProfile);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> updateData) async {
    final res = await dio.put(ApiEndpoints.userProfile, data: updateData);
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteUserData() async {
    await dio.delete('${ApiEndpoints.userProfile}/data');
    clearTokens();
  }
}

final apiClient = ApiClient();
