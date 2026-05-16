import 'package:box_launcher/domain/repositories/app_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetInstalledIconPacksUseCase {
  final AppRepository repository;
  GetInstalledIconPacksUseCase(this.repository);

  Future<List<Map<String, String>>> call() {
    return repository.getInstalledIconPacks();
  }
}

@injectable
class GetIconPackUseCase {
  final AppRepository repository;
  GetIconPackUseCase(this.repository);

  Future<String?> call() {
    return repository.getIconPack();
  }
}

@injectable
class SetIconPackUseCase {
  final AppRepository repository;
  SetIconPackUseCase(this.repository);

  Future<bool> call(String? packageName) {
    return repository.setIconPack(packageName);
  }
}
