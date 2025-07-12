part of 'location_detail_cubit.dart';

enum LocationDetailStatus {
  initial,
  loading,
  loaded,
  error,
}

class LocationDetailState extends Equatable {
  final LocationDetailStatus status;
  final Location? location;
  final String? errorMessage;
  final CoordinatesValueObject? userLocation;
  final LocationPermissionStatus permissionStatus;
  final DistanceValueObject? distanceToLocation;
  final bool isLoadingUserLocation;

  const LocationDetailState._({
    required this.status,
    this.location,
    this.errorMessage,
    this.userLocation,
    this.permissionStatus = LocationPermissionStatus.unasked,
    this.distanceToLocation,
    this.isLoadingUserLocation = false,
  });

  const LocationDetailState.initial() : this._(
    status: LocationDetailStatus.initial,
  );

  const LocationDetailState.loading() : this._(
    status: LocationDetailStatus.loading,
  );

  const LocationDetailState.loaded(Location location) : this._(
    status: LocationDetailStatus.loaded,
    location: location,
  );

  const LocationDetailState.error(String message) : this._(
    status: LocationDetailStatus.error,
    errorMessage: message,
  );

  LocationDetailState copyWith({
    LocationDetailStatus? status,
    Location? location,
    String? errorMessage,
    CoordinatesValueObject? userLocation,
    LocationPermissionStatus? permissionStatus,
    DistanceValueObject? distanceToLocation,
    bool? isLoadingUserLocation,
  }) {
    return LocationDetailState._(
      status: status ?? this.status,
      location: location ?? this.location,
      errorMessage: errorMessage ?? this.errorMessage,
      userLocation: userLocation ?? this.userLocation,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      distanceToLocation: distanceToLocation ?? this.distanceToLocation,
      isLoadingUserLocation: isLoadingUserLocation ?? this.isLoadingUserLocation,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    location, 
    errorMessage, 
    userLocation, 
    permissionStatus, 
    distanceToLocation, 
    isLoadingUserLocation,
  ];
}
