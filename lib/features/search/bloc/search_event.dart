part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  final List<AppInfo> allApps;
  const SearchQueryChanged(this.query, this.allApps);
  @override
  List<Object> get props => [query, allApps];
}

class ClearSearch extends SearchEvent {}
