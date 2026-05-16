import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'search_event.dart';
part 'search_state.dart';

@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ClearSearch>(_onClearSearch);
  }

  void _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    final filtered = event.allApps.where((app) {
      return app.label.toLowerCase().contains(event.query.toLowerCase());
    }).toList();
    emit(SearchLoaded(filtered, event.query));
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
