part of 'location_detail_cubit.dart';

enum LocationDetailStatus { initial, loading, loaded, error }

class LocationDetailState extends Equatable {
  final LocationDetailStatus status;
  final Location? location;
  final String? errorMessage;
  final CoordinatesValueObject? userLocation;
  final LocationPermissionStatus permissionStatus;
  final bool isLoadingUserLocation;
  final DistanceValueObject? distance;

  const LocationDetailState._({
    required this.status,
    this.location,
    this.errorMessage,
    this.userLocation,
    this.permissionStatus = LocationPermissionStatus.unasked,
    this.isLoadingUserLocation = false,
    this.distance,
  });

  const LocationDetailState.initial()
    : this._(status: LocationDetailStatus.initial);

  const LocationDetailState.loading()
    : this._(status: LocationDetailStatus.loading);

  const LocationDetailState.loaded(Location location)
    : this._(status: LocationDetailStatus.loaded, location: location);

  const LocationDetailState.error(String message)
    : this._(status: LocationDetailStatus.error, errorMessage: message);

  LocationDetailState copyWith({
    LocationDetailStatus? status,
    Location? location,
    String? errorMessage,
    CoordinatesValueObject? userLocation,
    LocationPermissionStatus? permissionStatus,
    bool? isLoadingUserLocation,
    DistanceValueObject? distance,
  }) {
    return LocationDetailState._(
      status: status ?? this.status,
      location: location ?? this.location,
      errorMessage: errorMessage ?? this.errorMessage,
      userLocation: userLocation ?? this.userLocation,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isLoadingUserLocation:
          isLoadingUserLocation ?? this.isLoadingUserLocation,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [
    status,
    location,
    errorMessage,
    userLocation,
    permissionStatus,
    isLoadingUserLocation,
    distance,
  ];
}
