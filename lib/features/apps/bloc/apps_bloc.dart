import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:box_launcher/domain/usecases/app_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'apps_event.dart';
part 'apps_state.dart';

@injectable
class AppsBloc extends Bloc<AppsEvent, AppsState> {
  final GetAppsUseCase getAppsUseCase;
  final OpenAppUseCase openAppUseCase;
  final GetAppIconUseCase getAppIconUseCase;

  AppsBloc(this.getAppsUseCase, this.openAppUseCase, this.getAppIconUseCase) : super(AppsInitial()) {
    on<LoadAppsEvent>(_onLoadApps);
    on<OpenAppEvent>(_onOpenApp);
    on<LoadAppIconEvent>(_onLoadAppIcon);
  }

  Future<void> _onLoadApps(LoadAppsEvent event, Emitter<AppsState> emit) async {
    emit(AppsLoading());
    try {
      final apps = await getAppsUseCase();
      emit(AppsLoaded(apps));
    } catch (e) {
      emit(AppsError(e.toString()));
    }
  }

  Future<void> _onOpenApp(OpenAppEvent event, Emitter<AppsState> emit) async {
    await openAppUseCase(event.packageName);
  }

  Future<void> _onLoadAppIcon(LoadAppIconEvent event, Emitter<AppsState> emit) async {
    if (state is AppsLoaded) {
      final currentState = state as AppsLoaded;
      try {
        final appWithIcon = await getAppIconUseCase(event.app);
        final updatedApps = currentState.apps.map((e) {
          if (e.packageName == appWithIcon.packageName) {
            return appWithIcon;
          }
          return e;
        }).toList();
        emit(AppsLoaded(updatedApps));
      } catch (e) {
        // ignore icon error
      }
    }
  }
}
