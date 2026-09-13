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

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Captures single-point GPS coordinates at payment time.
  /// Returns null if permission is denied, services disabled, or acquisition fails.
  /// Strictly adheres to rule: Do not invent coordinates.
  Future<PaymentLocation?> getCurrentPaymentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return PaymentLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );
    } catch (e) {
      // Never synthesize or guess coordinates upon failure or timeout
      return null;
    }
  }
}
