part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {}

class AddFavoriteEvent extends FavoritesEvent {
  final AppInfo app;
  const AddFavoriteEvent(this.app);
  @override
  List<Object> get props => [app];
}

class RemoveFavoriteEvent extends FavoritesEvent {
  final AppInfo app;
  const RemoveFavoriteEvent(this.app);
  @override
  List<Object> get props => [app];
}

class SetFavoritesEvent extends FavoritesEvent {
  final List<AppInfo> favorites;
  const SetFavoritesEvent(this.favorites);
  @override
  List<Object> get props => [favorites];
}
