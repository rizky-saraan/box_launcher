part of 'icon_pack_bloc.dart';

abstract class IconPackEvent extends Equatable {
  const IconPackEvent();

  @override
  List<Object?> get props => [];
}

class LoadIconPackEvent extends IconPackEvent {}

class SetIconPackSelectionEvent extends IconPackEvent {
  final String? packageName;

  const SetIconPackSelectionEvent(this.packageName);

  @override
  List<Object?> get props => [packageName];
}
