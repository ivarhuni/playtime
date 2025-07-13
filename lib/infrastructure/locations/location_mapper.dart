import 'package:injectable/injectable.dart';
import 'package:ut_ad_leika/domain/locations/entities/geojson_location.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';

@injectable
class LocationMapper {
  /// Maps a GeoJsonLocation to a Location entity with default values for missing fields
  Location mapToLocation(GeoJsonLocation geoJsonLocation) {
    return Location(
      id: geoJsonLocation.id,
      imageUrl: 'assets/images/default_playground.png',
      address: geoJsonLocation.address,
      description: _generateDescription(geoJsonLocation.address),
      capabilities: const {LocationCapability.unknown},
      size: LocationSize.unknown,
      starRating: 3.0, // Default rating for unknown locations
      latitude: geoJsonLocation.latitude,
      longitude: geoJsonLocation.longitude,
    );
  }

  /// Maps a list of GeoJsonLocation entities to Location entities
  List<Location> mapToLocations(List<GeoJsonLocation> geoJsonLocations) {
    return geoJsonLocations.map(mapToLocation).toList();
  }

  /// Generates a description from the address
  String _generateDescription(String address) {
    if (address.isEmpty) {
      return 'Playground in Hafnarfjörður';
    }
    return 'Playground at $address';
  }
}
