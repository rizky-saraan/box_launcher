import 'package:box_launcher/domain/entities/app_info.dart';

abstract class AppRepository {
  Future<List<AppInfo>> getInstalledApps();
  Future<bool> openApp(String packageName);
  Future<AppInfo> getAppIcon(AppInfo app);
  Future<List<String>> getFavoritePackages();
  Future<void> saveFavoritePackages(List<String> packages);
}
