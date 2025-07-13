import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ut_ad_leika/application/location_detail/location_detail_cubit.dart';
import 'package:ut_ad_leika/domain/locations/entities/location.dart';
import 'package:ut_ad_leika/presentation/location_detail/widgets/location_map_view.dart';
import 'package:ut_ad_leika/presentation/location_detail/widgets/location_detail_drawer.dart';

class LocationDetailPage extends StatelessWidget {
  final String locationId;

  const LocationDetailPage({super.key, required this.locationId});

  @override
  Widget build(BuildContext context) {
    print('🏗️ LocationDetailPage: Building with locationId: $locationId');
    return BlocProvider(
      create: (context) =>
          GetIt.instance<LocationDetailCubit>()..loadLocation(locationId),
      child: const _LocationDetailPageView(),
    );
  }
}

class _LocationDetailPageView extends StatelessWidget {
  const _LocationDetailPageView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationDetailCubit, LocationDetailState>(
      builder: (context, state) {
        print('🔄 LocationDetailPageView: State changed - ${state.status}');
        print(
          '🔄 LocationDetailPageView: Location: ${state.location?.address}',
        );
        print(
          '🔄 LocationDetailPageView: User Location: ${state.userLocation}',
        );
        print(
          '🔄 LocationDetailPageView: Permission: ${state.permissionStatus}',
        );
        print(
          '🔄 LocationDetailPageView: Distance: ${state.distanceToLocation}',
        );
        print(
          '🔄 LocationDetailPageView: Loading User Location: ${state.isLoadingUserLocation}',
        );

        switch (state.status) {
          case LocationDetailStatus.loading:
            print('⏳ LocationDetailPageView: Building loading state');
            return const _LoadingStateView();
          case LocationDetailStatus.error:
            print(
              '❌ LocationDetailPageView: Building error state: ${state.errorMessage}',
            );
            return _ErrorStateView(
              error: state.errorMessage ?? 'Unknown error',
            );
          case LocationDetailStatus.loaded:
            final location = state.location;
            if (location != null) {
              print('✅ LocationDetailPageView: Building loaded state');
              return _LocationView(state: state, location: location);
            }
            print(
              '⚠️ LocationDetailPageView: Building initial state - location is null',
            );
            return const _InitialStateView();
          case LocationDetailStatus.initial:
            print('⚠️ LocationDetailPageView: Building initial state');
            return const _InitialStateView();
        }
      },
    );
  }
}

class _LoadingStateView extends StatelessWidget {
  const _LoadingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorStateView extends StatelessWidget {
  final String error;

  const _ErrorStateView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialStateView extends StatelessWidget {
  const _InitialStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _LocationView extends StatelessWidget {
  final LocationDetailState state;
  final Location location;

  const _LocationView({super.key, required this.state, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map view at the top
          LocationMapView(
            location: location,
            userLocation: state.userLocation,
            permissionStatus: state.permissionStatus,
            isLoadingUserLocation: state.isLoadingUserLocation,
          ),

          // Back button overlay
          const Positioned(top: 16, left: 8, child: _BackButtonOverlay()),

          // Draggable detail drawer
          LocationDetailDrawer(
            location: location,
            distance: state.distanceToLocation,
            permissionStatus: state.permissionStatus,
            onOpenInMaps: () =>
                context.read<LocationDetailCubit>().openInMaps(),
            onRetryLocation: () =>
                context.read<LocationDetailCubit>().retryLocationPermission(),
          ),
        ],
      ),
    );
  }
}

class _BackButtonOverlay extends StatelessWidget {
  const _BackButtonOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          color: Colors.black87,
        ),
      ),
    );
  }
}
