part of 'apps_bloc.dart';

abstract class AppsState extends Equatable {
  const AppsState();
  
  @override
  List<Object> get props => [];
}

class AppsInitial extends AppsState {}

class AppsLoading extends AppsState {}

class AppsLoaded extends AppsState {
  final List<AppInfo> apps;
  const AppsLoaded(this.apps);
  @override
  List<Object> get props => [apps];
}

class AppsError extends AppsState {
  final String message;
  const AppsError(this.message);
  @override
  List<Object> get props => [message];
}
