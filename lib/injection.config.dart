// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'application.dart' as _i3;
import 'application/config_service.dart' as _i5;
import 'application/cryptography_service.dart' as _i16;
import 'application/firebase_service.dart' as _i4;
import 'application/http_service.dart' as _i7;
import 'application/user_service.dart' as _i9;
import 'src/applets/applet.dart' as _i14;
import 'src/applets/connections/connection_interface.dart' as _i12;
import 'src/applets/connections/flutternfc.dart' as _i13;
import 'src/applets/gids/gids_applet.dart' as _i15;
import 'src/features/auth/application/discovery_service.dart' as _i6;
import 'src/features/auth/application/registration_service.dart' as _i19;
import 'src/features/auth/presentation/auth_viewmodel.dart' as _i21;
import 'src/features/home/application/fetch_service.dart' as _i17;
import 'src/features/home/presentation/home_viewmodel.dart' as _i22;
import 'src/features/notification/application/notification_service.dart'
    as _i18;
import 'src/features/notification/presentation/notification_viewmodel.dart'
    as _i20;
import 'src/features/onboarding/application/onboarding_service.dart' as _i8;
import 'src/features/onboarding/presentation/onboarding_viewmodel.dart' as _i10;
import 'src/features/settings/presentation/settings_viewmodel.dart'
    as _i11; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(
  _i1.GetIt get, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    get,
    environment,
    environmentFilter,
  );
  gh.factory<_i3.ApplicationViewModel>(() => _i3.ApplicationViewModel());
  gh.singleton<_i4.FirebaseService>(_i4.FirebaseService());
  gh.factory<_i5.IConfigService>(() => _i5.ConfigService());
  gh.factory<_i6.IDiscoveryService>(() => _i6.DiscoveryService());
  gh.factory<_i7.IHttpService>(
      () => _i7.HttpService(get<_i5.IConfigService>()));
  gh.factory<_i8.IOnboardingService>(
      () => _i8.OnboardingService(get<_i4.FirebaseService>()));
  gh.factory<_i9.IUserService>(() => _i9.UserService());
  gh.factory<_i10.OnboardingViewModel>(
      () => _i10.OnboardingViewModel(get<_i8.IOnboardingService>()));
  gh.factory<_i11.SettingsViewModel>(
      () => _i11.SettingsViewModel(get<_i5.IConfigService>()));
  gh.factory<_i12.SmartCardConnection>(() => _i13.NfcConnection());
  gh.factory<_i14.Applet>(
      () => _i15.GidsApplet(get<_i12.SmartCardConnection>()));
  gh.factory<_i16.ICryptographyService>(
      () => _i16.CryptographyService(get<_i14.Applet>()));
  gh.factory<_i17.IFetchService>(
      () => _i17.FetchService(get<_i7.IHttpService>()));
  gh.factory<_i18.INotificationService>(() => _i18.NotificationService(
        get<_i7.IHttpService>(),
        get<_i16.ICryptographyService>(),
      ));
  gh.factory<_i19.IRegistrationService>(() => _i19.RegistrationService(
        get<_i7.IHttpService>(),
        get<_i5.IConfigService>(),
        get<_i6.IDiscoveryService>(),
        get<_i4.FirebaseService>(),
        get<_i16.ICryptographyService>(),
      ));
  gh.factory<_i20.NotificationViewModel>(
      () => _i20.NotificationViewModel(get<_i18.INotificationService>()));
  gh.factory<_i21.AuthViewModel>(
      () => _i21.AuthViewModel(get<_i19.IRegistrationService>()));
  gh.factory<_i22.HomeViewModel>(() => _i22.HomeViewModel(
        get<_i9.IUserService>(),
        get<_i17.IFetchService>(),
        get<_i5.IConfigService>(),
        get<_i4.FirebaseService>(),
      ));
  return get;
}
