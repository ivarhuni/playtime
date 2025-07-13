import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:ut_ad_leika/domain/locations/entities/geojson_location.dart';

@injectable
class GeoJsonParser {
  /// Parses a GeoJSON file from assets and returns a list of GeoJsonLocation entities
  Future<List<GeoJsonLocation>> parseGeoJsonFromAssets(String assetPath) async {
    try {
      // Ensure binding is initialized before attempting to load assets
      WidgetsFlutterBinding.ensureInitialized();

      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      if (jsonData['type'] != 'FeatureCollection') {
        throw const FormatException(
          'Invalid GeoJSON: expected FeatureCollection',
        );
      }

      final features = jsonData['features'] as List<dynamic>;
      final locations = <GeoJsonLocation>[];

      for (final feature in features) {
        final location = _parseFeature(feature as Map<String, dynamic>);
        if (location != null) {
          locations.add(location);
        }
      }

      return locations;
    } catch (e) {
      throw FormatException('Failed to parse GeoJSON file: $e');
    }
  }

  GeoJsonLocation? _parseFeature(Map<String, dynamic> feature) {
    try {
      final properties = feature['properties'] as Map<String, dynamic>?;
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      final id =
          feature['id'] as String? ?? properties?['@id'] as String? ?? '';

      if (properties == null || geometry == null || id.isEmpty) {
        return null;
      }

      // Extract address
      String address = '';
      if (properties['address'] is Map<String, dynamic>) {
        final addressData = properties['address'] as Map<String, dynamic>;
        address = addressData['google_formatted'] as String? ?? '';
      }

      // Extract coordinates
      final coordinates = _extractCoordinates(geometry);
      if (coordinates == null) {
        return null;
      }

      // Extract leisure type
      final leisureType = properties['leisure'] as String?;

      // Store additional properties for future use
      final additionalProperties = Map<String, dynamic>.from(properties);
      additionalProperties.remove('address');
      additionalProperties.remove('leisure');

      return GeoJsonLocation(
        id: id,
        address: address,
        latitude: coordinates['latitude']!,
        longitude: coordinates['longitude']!,
        leisureType: leisureType,
        additionalProperties: additionalProperties.isNotEmpty
            ? additionalProperties
            : null,
      );
    } catch (e) {
      // Skip features that can't be parsed
      return null;
    }
  }

  Map<String, double>? _extractCoordinates(Map<String, dynamic> geometry) {
    final type = geometry['type'] as String?;
    final coordinates = geometry['coordinates'] as List<dynamic>?;

    if (coordinates == null) return null;

    switch (type) {
      case 'Point':
        if (coordinates.length >= 2) {
          return {
            'longitude': (coordinates[0] as num).toDouble(),
            'latitude': (coordinates[1] as num).toDouble(),
          };
        }
        break;
      case 'Polygon':
        // For polygons, use the first point of the first ring as the representative coordinates
        if (coordinates.isNotEmpty && coordinates[0] is List) {
          final firstRing = coordinates[0] as List<dynamic>;
          if (firstRing.isNotEmpty) {
            final firstPoint = firstRing[0] as List<dynamic>;
            if (firstPoint.length >= 2) {
              return {
                'longitude': (firstPoint[0] as num).toDouble(),
                'latitude': (firstPoint[1] as num).toDouble(),
              };
            }
          }
        }
        break;
    }

    return null;
  }
}
