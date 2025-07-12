import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ut_ad_leika/application/location_detail/location_detail_cubit.dart';
import 'package:ut_ad_leika/presentation/core/theme/play_theme.dart';
import 'package:ut_ad_leika/presentation/core/widgets/atoms/import.dart';

class LocationDetailBody extends StatelessWidget {
  final String locationId;

  const LocationDetailBody({
    super.key,
    required this.locationId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationDetailCubit, LocationDetailState>(
      builder: (BuildContext context, LocationDetailState state) {
        switch (state.status) {
          case LocationDetailStatus.initial:
          case LocationDetailStatus.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );

          case LocationDetailStatus.loaded:
            if (state.location == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(PlayPaddings.Playrge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: PlayPaddings.medium),
                      Text(
                        'Location not found',
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

            // TODO: Implement detailed location view
            return Padding(
              padding: const EdgeInsets.all(PlayPaddings.Playrge),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.construction,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: PlayPaddings.medium),
                    const Text(
                      'Location Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PlayPaddings.small),
                    Text(
                      'Location ID: $locationId',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: PlayPaddings.small),
                    if (state.location != null)
                      Text(
                        'Address: ${state.location!.address}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: PlayPaddings.Playrge),
                    const Text(
                      'Detailed view coming soon!',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );

          case LocationDetailStatus.error:
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(PlayPaddings.Playrge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: PlayPaddings.medium),
                    const Text(
                      'Error loading location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: PlayPaddings.small),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: PlayPaddings.medium),
                    PlayButton(
                      text: 'Retry',
                      onTap: () {
                        context.read<LocationDetailCubit>().loadLocation(locationId);
                      },
                    ),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
} 
