// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../../data/datasources/local_datasource_hive.dart' as _i6;
import '../../data/datasources/native_channel.dart' as _i7;
import '../../data/repositories/app_repository_impl.dart' as _i9;
import '../../domain/repositories/app_repository.dart' as _i8;
import '../../domain/usecases/app_usecases.dart' as _i10;
import '../../features/apps/bloc/apps_bloc.dart' as _i11;
import '../../features/favorites/bloc/favorites_bloc.dart' as _i12;
import '../../features/launcher/bloc/launcher_bloc.dart' as _i4;
import '../../features/search/bloc/search_bloc.dart' as _i5;
import '../theme/bloc/theme_bloc.dart' as _i3;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.ThemeBloc>(() => _i3.ThemeBloc());
    gh.factory<_i4.LauncherBloc>(() => _i4.LauncherBloc());
    gh.factory<_i5.SearchBloc>(() => _i5.SearchBloc());
    gh.singleton<_i6.LocalDataSourceHive>(() => _i6.LocalDataSourceHive());
    gh.singleton<_i7.NativeChannel>(() => _i7.NativeChannel());
    gh.singleton<_i8.AppRepository>(() => _i9.AppRepositoryImpl(
          nativeChannel: gh<_i7.NativeChannel>(),
          localDataSource: gh<_i6.LocalDataSourceHive>(),
        ));
    gh.factory<_i10.GetAppsUseCase>(
        () => _i10.GetAppsUseCase(gh<_i8.AppRepository>()));
    gh.factory<_i10.OpenAppUseCase>(
        () => _i10.OpenAppUseCase(gh<_i8.AppRepository>()));
    gh.factory<_i10.GetAppIconUseCase>(
        () => _i10.GetAppIconUseCase(gh<_i8.AppRepository>()));
    gh.factory<_i10.GetFavoritesUseCase>(
        () => _i10.GetFavoritesUseCase(gh<_i8.AppRepository>()));
    gh.factory<_i10.SaveFavoritesUseCase>(
        () => _i10.SaveFavoritesUseCase(gh<_i8.AppRepository>()));
    gh.factory<_i11.AppsBloc>(() => _i11.AppsBloc(
          gh<_i10.GetAppsUseCase>(),
          gh<_i10.OpenAppUseCase>(),
          gh<_i10.GetAppIconUseCase>(),
        ));
    gh.factory<_i12.FavoritesBloc>(() => _i12.FavoritesBloc(
          gh<_i10.GetFavoritesUseCase>(),
          gh<_i10.SaveFavoritesUseCase>(),
          gh<_i10.GetAppsUseCase>(),
        ));
    return this;
  }
}
