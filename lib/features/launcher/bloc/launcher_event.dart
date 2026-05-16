part of 'launcher_bloc.dart';

abstract class LauncherEvent extends Equatable {
  const LauncherEvent();

  @override
  List<Object> get props => [];
}

class ShowSearchView extends LauncherEvent {}

class ShowMainView extends LauncherEvent {}
