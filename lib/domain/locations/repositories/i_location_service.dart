import 'package:ut_ad_leika/domain/core/value_objects/coordinates_value_object.dart';
import 'package:ut_ad_leika/domain/core/value_objects/distance_value_object.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  unasked,
}

abstract class ILocationService {
  /// Request location permission from the user
  Future<LocationPermissionStatus> requestLocationPermission();
  
  /// Get current location permission status
  Future<LocationPermissionStatus> getLocationPermissionStatus();
  
  /// Get user's current location
  /// Returns null if permission is denied or location can't be determined
  Future<CoordinatesValueObject?> getCurrentLocation();
  
  /// Calculate distance between two coordinates in kilometers
  DistanceValueObject calculateDistance(
    CoordinatesValueObject from,
    CoordinatesValueObject to,
  );
  
  /// Open device's native maps app with the given coordinates
  Future<bool> openInMaps(CoordinatesValueObject coordinates, {String? label});
} 
