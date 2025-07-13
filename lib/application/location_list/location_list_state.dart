part of 'location_list_cubit.dart';

enum LocationListStatus { initial, loading, loaded, error }

class LocationListState extends Equatable {
  final LocationListStatus status;
  final List<Location> locations;
  final String? errorMessage;
  final CoordinatesValueObject? userLocation;
  final LocationPermissionStatus permissionStatus;
  final bool isLoadingUserLocation;
  final Map<String, DistanceValueObject> locationDistances;

  const LocationListState._({
    required this.status,
    this.locations = const [],
    this.errorMessage,
    this.userLocation,
    this.permissionStatus = LocationPermissionStatus.unasked,
    this.isLoadingUserLocation = false,
    this.locationDistances = const {},
  });

  const LocationListState.initial()
    : this._(status: LocationListStatus.initial);

  const LocationListState.loading()
    : this._(status: LocationListStatus.loading);

  const LocationListState.loaded(List<Location> locations)
    : this._(status: LocationListStatus.loaded, locations: locations);

  const LocationListState.error(String message)
    : this._(status: LocationListStatus.error, errorMessage: message);

  LocationListState copyWith({
    LocationListStatus? status,
    List<Location>? locations,
    String? errorMessage,
    CoordinatesValueObject? userLocation,
    LocationPermissionStatus? permissionStatus,
    bool? isLoadingUserLocation,
    Map<String, DistanceValueObject>? locationDistances,
  }) {
    return LocationListState._(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      errorMessage: errorMessage ?? this.errorMessage,
      userLocation: userLocation ?? this.userLocation,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isLoadingUserLocation:
          isLoadingUserLocation ?? this.isLoadingUserLocation,
      locationDistances: locationDistances ?? this.locationDistances,
    );
  }

  @override
  List<Object?> get props => [
    status,
    locations,
    errorMessage,
    userLocation,
    permissionStatus,
    isLoadingUserLocation,
    locationDistances,
  ];
}
