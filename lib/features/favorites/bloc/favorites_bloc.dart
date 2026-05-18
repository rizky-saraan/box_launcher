import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:box_launcher/domain/usecases/app_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final SaveFavoritesUseCase saveFavoritesUseCase;
  final GetAppsUseCase getAppsUseCase;

  FavoritesBloc(this.getFavoritesUseCase, this.saveFavoritesUseCase, this.getAppsUseCase) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddFavoriteEvent>(_onAddFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);
    on<SetFavoritesEvent>(_onSetFavorites);
  }

  Future<void> _onLoadFavorites(LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final favoritePackages = await getFavoritesUseCase();
      final allApps = await getAppsUseCase();
      
      final favoriteApps = favoritePackages.map((pkg) {
        return allApps.firstWhere((app) => app.packageName == pkg, orElse: () => AppInfo(packageName: pkg, label: 'Unknown'));
      }).where((app) => app.label != 'Unknown').toList();

      // Removed sorting to preserve the custom user-defined drag-and-drop order

      emit(FavoritesLoaded(favoriteApps));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onAddFavorite(AddFavoriteEvent event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      final currentApps = List<AppInfo>.from(currentState.favorites);
      if (!currentApps.any((app) => app.packageName == event.app.packageName)) {
        currentApps.add(event.app);
        final packages = currentApps.map((e) => e.packageName).toList();
        await saveFavoritesUseCase(packages);
        emit(FavoritesLoaded(currentApps));
      }
    }
  }

  Future<void> _onRemoveFavorite(RemoveFavoriteEvent event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      final currentApps = List<AppInfo>.from(currentState.favorites);
      currentApps.removeWhere((app) => app.packageName == event.app.packageName);
      final packages = currentApps.map((e) => e.packageName).toList();
      await saveFavoritesUseCase(packages);
      emit(FavoritesLoaded(currentApps));
    }
  }

  Future<void> _onSetFavorites(SetFavoritesEvent event, Emitter<FavoritesState> emit) async {
    try {
      final packages = event.favorites.map((e) => e.packageName).toList();
      await saveFavoritesUseCase(packages);
      emit(FavoritesLoaded(event.favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
