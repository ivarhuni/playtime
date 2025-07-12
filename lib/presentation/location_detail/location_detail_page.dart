import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ut_ad_leika/application/location_detail/location_detail_cubit.dart';
import 'package:ut_ad_leika/presentation/location_detail/widgets/location_map_view.dart';
import 'package:ut_ad_leika/presentation/location_detail/widgets/location_detail_drawer.dart';

class LocationDetailPage extends StatelessWidget {
  final String locationId;

  const LocationDetailPage({
    super.key,
    required this.locationId,
  });

  @override
  Widget build(BuildContext context) {
    print('🏗️ LocationDetailPage: Building with locationId: $locationId');
    return BlocProvider(
      create: (context) => GetIt.instance<LocationDetailCubit>()..loadLocation(locationId),
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
        print('🔄 LocationDetailPageView: Location: ${state.location?.address}');
        print('🔄 LocationDetailPageView: User Location: ${state.userLocation}');
        print('🔄 LocationDetailPageView: Permission: ${state.permissionStatus}');
        print('🔄 LocationDetailPageView: Distance: ${state.distanceToLocation}');
        print('🔄 LocationDetailPageView: Loading User Location: ${state.isLoadingUserLocation}');
        
        if (state.status == LocationDetailStatus.loading) {
          print('⏳ LocationDetailPageView: Building loading state');
          return _buildLoadingState();
        } else if (state.status == LocationDetailStatus.error) {
          print('❌ LocationDetailPageView: Building error state: ${state.errorMessage}');
          return _buildErrorState(context, state.errorMessage ?? 'Unknown error');
        } else if (state.status == LocationDetailStatus.loaded && state.location != null) {
          print('✅ LocationDetailPageView: Building loaded state');
          return _buildLocationView(context, state);
        } else {
          print('⚠️ LocationDetailPageView: Building initial state');
          return _buildInitialState();
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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

  Widget _buildInitialState() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLocationView(BuildContext context, LocationDetailState state) {
    return Scaffold(
      body: Stack(
        children: [
          // Map view at the top
          LocationMapView(
            location: state.location!,
            userLocation: state.userLocation,
            permissionStatus: state.permissionStatus,
            isLoadingUserLocation: state.isLoadingUserLocation,
          ),
          
          // Back button overlay
          Positioned(
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
          ),
          
          // Draggable detail drawer
          LocationDetailDrawer(
            location: state.location!,
            distance: state.distanceToLocation,
            permissionStatus: state.permissionStatus,
            onOpenInMaps: () => context.read<LocationDetailCubit>().openInMaps(),
            onRetryLocation: () => context.read<LocationDetailCubit>().retryLocationPermission(),
          ),
        ],
      ),
    );
  }
} 
