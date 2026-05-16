import 'package:box_launcher/domain/usecases/theme_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'icon_pack_event.dart';
part 'icon_pack_state.dart';

@injectable
class IconPackBloc extends Bloc<IconPackEvent, IconPackState> {
  final GetInstalledIconPacksUseCase getInstalledIconPacksUseCase;
  final GetIconPackUseCase getIconPackUseCase;
  final SetIconPackUseCase setIconPackUseCase;

  IconPackBloc(
    this.getInstalledIconPacksUseCase,
    this.getIconPackUseCase,
    this.setIconPackUseCase,
  ) : super(IconPackInitial()) {
    on<LoadIconPackEvent>(_onLoadIconPack);
    on<SetIconPackSelectionEvent>(_onSetIconPack);
  }

  Future<void> _onLoadIconPack(LoadIconPackEvent event, Emitter<IconPackState> emit) async {
    emit(IconPackLoading());
    try {
      final packs = await getInstalledIconPacksUseCase();
      final selectedPack = await getIconPackUseCase();
      
      // Initialize the native side with the selected pack
      await setIconPackUseCase(selectedPack);

      emit(IconPackLoaded(
        availableIconPacks: packs,
        selectedIconPack: selectedPack,
      ));
    } catch (e) {
      emit(IconPackError(e.toString()));
    }
  }

  Future<void> _onSetIconPack(SetIconPackSelectionEvent event, Emitter<IconPackState> emit) async {
    if (state is IconPackLoaded) {
      final currentState = state as IconPackLoaded;
      try {
        await setIconPackUseCase(event.packageName);
        emit(IconPackLoaded(
          availableIconPacks: currentState.availableIconPacks,
          selectedIconPack: event.packageName,
        ));
      } catch (e) {
        emit(IconPackError(e.toString()));
      }
    }
  }
}
