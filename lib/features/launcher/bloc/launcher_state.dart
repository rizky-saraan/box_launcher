part of 'launcher_bloc.dart';

abstract class LauncherState extends Equatable {
  const LauncherState();
  
  @override
  List<Object> get props => [];
}

class LauncherMainView extends LauncherState {}

class LauncherSearchView extends LauncherState {}
