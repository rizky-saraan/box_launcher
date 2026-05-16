import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(isDarkMode: true)) {
    on<ToggleThemeEvent>((event, emit) => emit(ThemeState(isDarkMode: !state.isDarkMode)));
  }
}
