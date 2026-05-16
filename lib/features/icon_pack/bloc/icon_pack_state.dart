part of 'icon_pack_bloc.dart';

abstract class IconPackState extends Equatable {
  const IconPackState();
  
  @override
  List<Object?> get props => [];
}

class IconPackInitial extends IconPackState {}

class IconPackLoading extends IconPackState {}

class IconPackLoaded extends IconPackState {
  final List<Map<String, String>> availableIconPacks;
  final String? selectedIconPack;

  const IconPackLoaded({
    required this.availableIconPacks,
    this.selectedIconPack,
  });

  @override
  List<Object?> get props => [availableIconPacks, selectedIconPack];
}

class IconPackError extends IconPackState {
  final String message;

  const IconPackError(this.message);

  @override
  List<Object?> get props => [message];
}
