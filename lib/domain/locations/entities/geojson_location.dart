import 'package:equatable/equatable.dart';

class GeoJsonLocation extends Equatable {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  final String? leisureType;
  final Map<String, dynamic>? additionalProperties;

  const GeoJsonLocation({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.leisureType,
    this.additionalProperties,
  });

  @override
  List<Object?> get props => [
    id,
    address,
    latitude,
    longitude,
    leisureType,
    additionalProperties,
  ];
}
