import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';

abstract class ILocationRepository {
  Future<List<Location>> getLocations();
  Future<Location?> getLocationById(String id);
  Future<List<Location>> searchLocations(String query);
  Future<List<Location>> filterLocationsByCapabilities(
    Set<LocationCapability> capabilities,
  );
  Future<List<Location>> filterLocationsBySize(LocationSize size);
  Future<List<Location>> getLocationsNearby(
    double latitude,
    double longitude,
    double radiusKm,
  );
}
