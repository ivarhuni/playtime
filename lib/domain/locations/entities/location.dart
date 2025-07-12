import 'package:equatable/equatable.dart';
import 'package:ut_ad_leika/domain/locations/entities/location_capability.dart';

class Location extends Equatable {
  final String id;
  final String imageUrl;
  final String address;
  final String description;
  final Set<LocationCapability> capabilities;
  final LocationSize size;
  final double starRating; // 1.0 to 5.0
  final double latitude;
  final double longitude;

  const Location({
    required this.id,
    required this.imageUrl,
    required this.address,
    required this.description,
    required this.capabilities,
    required this.size,
    required this.starRating,
    required this.latitude,
    required this.longitude,
  }) : assert(starRating >= 1.0 && starRating <= 5.0, 'Star rating must be between 1.0 and 5.0');

  bool hasCapability(LocationCapability capability) {
    return capabilities.contains(capability);
  }

  String get capabilitiesDisplayText {
    if (capabilities.isEmpty) return 'No facilities';
    return capabilities.map((c) => c.displayName).join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        imageUrl,
        address,
        description,
        capabilities,
        size,
        starRating,
        latitude,
        longitude,
      ];
} 
