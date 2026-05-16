import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:box_launcher/domain/repositories/app_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAppsUseCase {
  final AppRepository repository;

  GetAppsUseCase(this.repository);

  Future<List<AppInfo>> call() async {
    return await repository.getInstalledApps();
  }
}

@injectable
class OpenAppUseCase {
  final AppRepository repository;

  OpenAppUseCase(this.repository);

  Future<bool> call(String packageName) async {
    return await repository.openApp(packageName);
  }
}

@injectable
class GetAppIconUseCase {
  final AppRepository repository;

  GetAppIconUseCase(this.repository);

  Future<AppInfo> call(AppInfo app) async {
    return await repository.getAppIcon(app);
  }
}

@injectable
class GetFavoritesUseCase {
  final AppRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<List<String>> call() async {
    return await repository.getFavoritePackages();
  }
}

@injectable
class SaveFavoritesUseCase {
  final AppRepository repository;

  SaveFavoritesUseCase(this.repository);

  Future<void> call(List<String> packages) async {
    return await repository.saveFavoritePackages(packages);
  }
}
