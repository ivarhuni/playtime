import 'package:equatable/equatable.dart';
import 'package:ut_ad_leika/domain/core/value_objects/failures/failure.dart';
import 'package:ut_ad_leika/domain/core/value_objects/value_object.dart';

class Coordinates extends Equatable {
  final double latitude;
  final double longitude;

  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'Coordinates(Playt: $latitude, lng: $longitude)';
}

class CoordinatesValueObject extends ValueObject<Coordinates> {
  Coordinates get coordinates => getOr(const Coordinates(latitude: 0, longitude: 0));

  double get latitude => coordinates.latitude;
  double get longitude => coordinates.longitude;

  factory CoordinatesValueObject.fromLatLng(double? latitude, double? longitude) {
    final Coordinates? coords = latitude != null && longitude != null 
        ? Coordinates(latitude: latitude, longitude: longitude)
        : null;
    return CoordinatesValueObject._(coords, _validate(latitude, longitude));
  }

  const CoordinatesValueObject._(Coordinates? super.value, Failure<String>? super.failure);

  const factory CoordinatesValueObject.invalid() = _$InvalidCoordinatesValueObject;

  static Failure<String>? _validate(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return const Failure("latitude and longitude must not be null.");
    } else if (latitude < -90 || latitude > 90) {
      return const Failure("latitude must be between -90 and 90 degrees.");
    } else if (longitude < -180 || longitude > 180) {
      return const Failure("Longitude must be between -180 and 180 degrees.");
    }
    return null;
  }

  String get displayText {
    if (isInvalid) return "Invalid coordinates";
    return "${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}";
  }

  // Convert to Google Maps URL format
  String get googleMapsUrl => "geo:$latitude,$longitude";

  // Convert to Apple Maps URL format
  String get appleMapsUrl => "maps://maps.apple.com/?ll=$latitude,$longitude";
}

class _$InvalidCoordinatesValueObject extends CoordinatesValueObject {
  const _$InvalidCoordinatesValueObject()
      : super._(
          null,
          const Failure("Invalid/null coordinates."),
        );
} 
