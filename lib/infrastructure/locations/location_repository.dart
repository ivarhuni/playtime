import 'package:injectable/injectable.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_repository.dart';
import 'package:ut_ad_leika/infrastructure/locations/geojson_parser.dart';
import 'package:ut_ad_leika/infrastructure/locations/location_mapper.dart';

@LazySingleton(as: ILocationRepository)
class LocationRepository implements ILocationRepository {
  final GeoJsonParser _geoJsonParser;
  final LocationMapper _locationMapper;

  static const String _geoJsonAssetPath =
      'assets/offline/geo/hafnarfjordur_playgrounds_geocoded.geojson';

  List<Location>? _cachedLocations;

  LocationRepository(this._geoJsonParser, this._locationMapper);

  @override
  Future<List<Location>> getLocations() async {
    if (_cachedLocations != null) {
      return _cachedLocations!;
    }

    try {
      // Parse GeoJSON data from assets
      final geoJsonLocations = await _geoJsonParser.parseGeoJsonFromAssets(
        _geoJsonAssetPath,
      );

      // Map to Location entities with defaults
      final locations = _locationMapper.mapToLocations(geoJsonLocations);

      // Cache the results
      _cachedLocations = locations;

      return locations;
    } catch (e) {
      // Log the error and rethrow so the cubit can handle it
      throw Exception('Failed to load locations from GeoJSON: $e');
    }
  }

  @override
  Future<Location?> getLocationById(String id) async {
    final locations = await getLocations();
    try {
      return locations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Location>> searchLocations(String query) async {
    final locations = await getLocations();

    if (query.isEmpty) {
      return locations;
    }

    final lowerQuery = query.toLowerCase();
    return locations
        .where(
          (location) =>
              location.address.toLowerCase().contains(lowerQuery) ||
              location.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  @override
  Future<List<Location>> filterLocationsByCapabilities(
    Set<LocationCapability> capabilities,
  ) async {
    final locations = await getLocations();

    if (capabilities.isEmpty) {
      return locations;
    }

    return locations
        .where(
          (location) => capabilities.every(
            (capability) => location.capabilities.contains(capability),
          ),
        )
        .toList();
  }

  @override
  Future<List<Location>> filterLocationsBySize(LocationSize size) async {
    final locations = await getLocations();
    return locations.where((location) => location.size == size).toList();
  }

  @override
  Future<List<Location>> getLocationsNearby(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    final locations = await getLocations();

    // Simple distance calculation (not accurate for large distances)
    return locations.where((location) {
      final latDiff = location.latitude - latitude;
      final lngDiff = location.longitude - longitude;
      final distance =
          (latDiff * latDiff + lngDiff * lngDiff) *
          111.32; // Rough km conversion
      return distance <= radiusKm * radiusKm;
    }).toList();
  }

  /// Clears the cached locations (useful for testing or force refresh)
  void clearCache() {
    _cachedLocations = null;
  }
}
