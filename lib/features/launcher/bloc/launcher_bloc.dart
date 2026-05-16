import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'launcher_event.dart';
part 'launcher_state.dart';

@injectable
class LauncherBloc extends Bloc<LauncherEvent, LauncherState> {
  LauncherBloc() : super(LauncherMainView()) {
    on<ShowSearchView>((event, emit) => emit(LauncherSearchView()));
    on<ShowMainView>((event, emit) => emit(LauncherMainView()));
  }
}
