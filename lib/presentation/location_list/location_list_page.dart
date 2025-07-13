import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ut_ad_leika/application/location_list/location_list_cubit.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/domain/locations/repositories/i_location_service.dart';
import 'package:ut_ad_leika/domain/core/value_objects/distance_value_object.dart';
import 'package:ut_ad_leika/presentation/core/theme/play_theme.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/organisms/import.dart';
import 'package:ut_ad_leika/presentation/core/widgets/templates/import.dart';
import 'package:ut_ad_leika/presentation/location_list/widgets/location_card.dart';
import 'package:ut_ad_leika/setup.dart';

class LocationListPage extends StatelessWidget {
  const LocationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationListCubit>(
      create: (BuildContext context) {
        return getIt<LocationListCubit>()..init();
      },
      child: BlocBuilder<LocationListCubit, LocationListState>(
        builder: (BuildContext context, LocationListState state) {
          return PlayScaffold(
            appBar: const PlayAppBar(title: 'Locations', showBack: false),
            child: _LocationListBody(state: state),
          );
        },
      ),
    );
  }
}

class _LocationListBody extends StatelessWidget {
  final LocationListState state;

  const _LocationListBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case LocationListStatus.initial:
      case LocationListStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case LocationListStatus.loaded:
        if (state.locations.isEmpty) {
          return const _EmptyLocationsView();
        }

        return Column(
          children: [
            // Location permission banner
            if (state.permissionStatus != LocationPermissionStatus.granted &&
                !state.isLoadingUserLocation)
              _LocationPermissionBanner(
                permissionStatus: state.permissionStatus,
                onRetry: () {
                  context.read<LocationListCubit>().retryLocationPermission();
                },
              ),

            // Locations list
            Expanded(
              child: _LocationsListView(
                locations: state.locations,
                locationDistances: state.locationDistances,
              ),
            ),
          ],
        );

      case LocationListStatus.error:
        return _LocationListErrorView(errorMessage: state.errorMessage);
    }
  }
}

class _LocationPermissionBanner extends StatelessWidget {
  final LocationPermissionStatus permissionStatus;
  final VoidCallback onRetry;

  const _LocationPermissionBanner({
    super.key,
    required this.permissionStatus,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    Color backgroundColor;
    IconData icon;

    switch (permissionStatus) {
      case LocationPermissionStatus.denied:
        message = 'Location permission denied. Enable to see distances.';
        backgroundColor = Colors.orange[50]!;
        icon = Icons.location_off;
        break;
      case LocationPermissionStatus.deniedForever:
        message = 'Location permission permanently denied. Check settings.';
        backgroundColor = Colors.red[50]!;
        icon = Icons.location_disabled;
        break;
      case LocationPermissionStatus.unasked:
        message = 'Allow location access to see distances to playgrounds.';
        backgroundColor = Colors.blue[50]!;
        icon = Icons.location_on;
        break;
      case LocationPermissionStatus.granted:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PlayPaddings.medium),
      margin: const EdgeInsets.all(PlayPaddings.medium),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(PlayCornerRadius.medium),
        border: Border.all(
          color: (permissionStatus == LocationPermissionStatus.deniedForever
              ? Colors.red[200]
              : permissionStatus == LocationPermissionStatus.denied
              ? Colors.orange[200]
              : Colors.blue[200])!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: permissionStatus == LocationPermissionStatus.deniedForever
                ? Colors.red[600]
                : permissionStatus == LocationPermissionStatus.denied
                ? Colors.orange[600]
                : Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: PlayPaddings.small),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color:
                    permissionStatus == LocationPermissionStatus.deniedForever
                    ? Colors.red[700]
                    : permissionStatus == LocationPermissionStatus.denied
                    ? Colors.orange[700]
                    : Colors.blue[700],
              ),
            ),
          ),
          if (permissionStatus != LocationPermissionStatus.deniedForever) ...[
            const SizedBox(width: PlayPaddings.small),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: const Size(60, 32),
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Allow',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyLocationsView extends StatelessWidget {
  const _EmptyLocationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(PlayPaddings.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: PlayPaddings.medium),
            Text(
              'No locations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationsListView extends StatelessWidget {
  final List<Location> locations;
  final Map<String, DistanceValueObject> locationDistances;

  const _LocationsListView({
    super.key,
    required this.locations,
    required this.locationDistances,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(PlayPaddings.medium),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        final distance = locationDistances[location.id];

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == locations.length - 1 ? 0 : PlayPaddings.extraSmall,
          ),
          child: LocationCard(location: location, distance: distance),
        );
      },
    );
  }
}

class _LocationListErrorView extends StatelessWidget {
  final String? errorMessage;

  const _LocationListErrorView({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PlayPaddings.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: PlayPaddings.medium),
            const Text(
              'Error loading locations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: PlayPaddings.small),
              Text(
                errorMessage ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: PlayPaddings.medium),
            PlayButton(
              text: 'Retry',
              onTap: () {
                context.read<LocationListCubit>().init();
              },
            ),
          ],
        ),
      ),
    );
  }
}
