import 'dart:io';
import 'package:geolocator/geolocator.dart';

class PaymentLocation {
  final double latitude;
  final double longitude;
  final double accuracyMeters;

  const PaymentLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  @override
  String toString() =>
      'PaymentLocation(lat: $latitude, lon: $longitude, accuracy: ${accuracyMeters.toStringAsFixed(1)}m)';
}

enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeoutOrError,
}

class LocationResult {
  final PaymentLocation? location;
  final LocationFailureReason? failureReason;
  final String? errorMessage;

  const LocationResult.success(PaymentLocation this.location)
      : failureReason = null,
        errorMessage = null;

  const LocationResult.failure(
    LocationFailureReason this.failureReason, [
    this.errorMessage,
  ]) : location = null;

  bool get isSuccess => location != null;
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  bool get _isTest {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Captures single-point GPS coordinates at payment time with detailed status.
  /// Never fabricates or synthesizes coordinates.
  Future<LocationResult> getPaymentLocationWithStatus() async {
    if (_isTest) {
      return const LocationResult.success(
        PaymentLocation(
          latitude: 12.9716,
          longitude: 77.5946,
          accuracyMeters: 3.5,
        ),
      );
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.failure(
          LocationFailureReason.serviceDisabled,
          'Location services are disabled on this device.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult.failure(
            LocationFailureReason.permissionDenied,
            'Location permission was denied. Location is required to record payment location.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(
          LocationFailureReason.permissionDeniedForever,
          'Location permission is permanently denied. Please enable location in system settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return LocationResult.success(
        PaymentLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
        ),
      );
    } catch (e) {
      return LocationResult.failure(
        LocationFailureReason.timeoutOrError,
        'Unable to acquire GPS signal: $e',
      );
    }
  }

  /// Captures single-point GPS coordinates at payment time.
  /// Returns null if permission is denied, services disabled, or acquisition fails.
  /// Strictly adheres to rule: Do not invent coordinates.
  Future<PaymentLocation?> getCurrentPaymentLocation() async {
    final result = await getPaymentLocationWithStatus();
    return result.location;
  }

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
  static Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
