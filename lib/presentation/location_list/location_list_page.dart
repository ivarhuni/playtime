import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ut_ad_leika/application/location_list/location_list_cubit.dart';
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
            appBar: const PlayAppBar(
              title: 'Locations',
              showBack: false,
            ),
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, LocationListState state) {
    switch (state.status) {
      case LocationListStatus.initial:
      case LocationListStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case LocationListStatus.loaded:
        if (state.locations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(PlayPaddings.large),
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

        return ListView.builder(
          padding: const EdgeInsets.all(PlayPaddings.medium),
          itemCount: state.locations.length,
          itemBuilder: (context, index) {
            final location = state.locations[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == state.locations.length - 1 
                    ? 0 
                    : PlayPaddings.extraSmall,
              ),
              child: LocationCard(
                location: location,
              ),
            );
          },
        );

      case LocationListStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(PlayPaddings.large),
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
                  'Error loading locations',
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
                    context.read<LocationListCubit>().init();
                  },
                ),
              ],
            ),
          ),
        );
    }
  }
} 
