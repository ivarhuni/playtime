// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:event_bus/event_bus.dart' as _i1017;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:ut_ad_leika/application/core/language/language_cubit.dart'
    as _i762;
import 'package:ut_ad_leika/application/location_detail/location_detail_cubit.dart'
    as _i816;
import 'package:ut_ad_leika/application/location_list/location_list_cubit.dart'
    as _i1001;
import 'package:ut_ad_leika/domain/locations/repositories/i_location_service.dart'
    as _i840;
import 'package:ut_ad_leika/infrastructure/core/auth/device_id_provider.dart'
    as _i84;
import 'package:ut_ad_leika/infrastructure/core/event/event_bus_module.dart'
    as _i1057;
import 'package:ut_ad_leika/infrastructure/core/initialization/initialization_service.dart'
    as _i37;
import 'package:ut_ad_leika/infrastructure/core/platform/platform_detector.dart'
    as _i160;
import 'package:ut_ad_leika/infrastructure/core/time/i_poll_and_debounce.dart'
    as _i760;
import 'package:ut_ad_leika/infrastructure/core/time/poll_and_debounce.dart'
    as _i849;
import 'package:ut_ad_leika/infrastructure/locations/location_service.dart'
    as _i130;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final eventBusModule = _$EventBusModule();
    gh.factory<_i762.LanguageCubit>(() => _i762.LanguageCubit());
    gh.factory<_i1001.LocationListCubit>(() => _i1001.LocationListCubit());
    gh.singleton<_i1017.EventBus>(() => eventBusModule.eventBus);
    gh.singleton<_i37.InitializationService>(
      () => _i37.InitializationService(),
    );
    gh.lazySingleton<_i84.DeviceIdProvider>(() => _i84.DeviceIdProvider());
    gh.lazySingleton<_i160.PlatformDetector>(() => _i160.PlatformDetector());
    gh.factory<_i760.IPollAndDebounce>(() => _i849.PollAndDebounce());
    gh.lazySingleton<_i840.ILocationService>(() => _i130.LocationService());
    gh.factory<_i816.LocationDetailCubit>(
      () => _i816.LocationDetailCubit(gh<_i840.ILocationService>()),
    );
    return this;
  }
}

class _$EventBusModule extends _i1057.EventBusModule {}
