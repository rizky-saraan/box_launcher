part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoaded extends SearchState {
  final List<AppInfo> results;
  final String query;
  const SearchLoaded(this.results, this.query);
  @override
  List<Object> get props => [results, query];
}
