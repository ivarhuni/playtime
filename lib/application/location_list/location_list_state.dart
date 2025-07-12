part of 'location_list_cubit.dart';

enum LocationListStatus {
  initial,
  loading,
  loaded,
  error,
}

class LocationListState extends Equatable {
  final LocationListStatus status;
  final List<Location> locations;
  final String? errorMessage;

  const LocationListState._({
    required this.status,
    this.locations = const [],
    this.errorMessage,
  });

  const LocationListState.initial() : this._(status: LocationListStatus.initial);

  const LocationListState.loading() : this._(status: LocationListStatus.loading);

  const LocationListState.loaded(List<Location> locations) : this._(
    status: LocationListStatus.loaded,
    locations: locations,
  );

  const LocationListState.error(String message) : this._(
    status: LocationListStatus.error,
    errorMessage: message,
  );

  @override
  List<Object?> get props => [status, locations, errorMessage];
} 
