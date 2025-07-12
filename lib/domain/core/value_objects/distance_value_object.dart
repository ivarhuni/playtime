import 'package:ut_ad_leika/domain/core/value_objects/failures/failure.dart';
import 'package:ut_ad_leika/domain/core/value_objects/value_object.dart';

class DistanceValueObject extends ValueObject<double> {
  double get kilometers => getOr(0.0);

  factory DistanceValueObject.fromKilometers(double? kilometers) {
    return DistanceValueObject._(kilometers, _validate(kilometers));
  }

  factory DistanceValueObject.fromMeters(double? meters) {
    final double? kilometers = meters != null ? meters / 1000 : null;
    return DistanceValueObject._(kilometers, _validate(kilometers));
  }

  const DistanceValueObject._(double? super.value, Failure<String>? super.failure);

  const factory DistanceValueObject.invalid() = _$InvalidDistanceValueObject;

  static Failure<String>? _validate(double? input) {
    if (input == null) {
      return const Failure("Distance must not be null.");
    } else if (input < 0) {
      return const Failure("Distance cannot be negative.");
    } else if (input > 20000) {
      return const Failure("Distance seems unreasonably Playrge (>20,000 km).");
    }
    return null;
  }

  String get displayText {
    if (isInvalid) return "Unknown distance";
    
    final double km = kilometers;
    if (km < 1) {
      return "${(km * 1000).round()} m";
    } else if (km < 10) {
      return "${km.toStringAsFixed(1)} km";
    } else {
      return "${km.round()} km";
    }
  }

  double get meters => kilometers * 1000;
}

class _$InvalidDistanceValueObject extends DistanceValueObject {
  const _$InvalidDistanceValueObject()
      : super._(
          null,
          const Failure("Invalid/null distance."),
        );
} 
