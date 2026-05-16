part of 'apps_bloc.dart';

abstract class AppsEvent extends Equatable {
  const AppsEvent();

  @override
  List<Object> get props => [];
}

class LoadAppsEvent extends AppsEvent {}

class OpenAppEvent extends AppsEvent {
  final String packageName;
  const OpenAppEvent(this.packageName);
  @override
  List<Object> get props => [packageName];
}

class LoadAppIconEvent extends AppsEvent {
  final AppInfo app;
  const LoadAppIconEvent(this.app);
  @override
  List<Object> get props => [app];
}
