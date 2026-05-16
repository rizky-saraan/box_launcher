import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/data/datasources/native_channel.dart';
import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:box_launcher/domain/repositories/app_repository.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: AppRepository)
class AppRepositoryImpl implements AppRepository {
  final NativeChannel nativeChannel;
  final LocalDataSourceHive localDataSource;

  AppRepositoryImpl({
    required this.nativeChannel,
    required this.localDataSource,
  });

  @override
  Future<List<AppInfo>> getInstalledApps() async {
    final rawApps = await nativeChannel.getInstalledApps();
    return rawApps.map((map) {
      return AppInfo(
        packageName: map['packageName'] as String,
        label: map['label'] as String,
      );
    }).toList();
  }

  @override
  Future<bool> openApp(String packageName) {
    return nativeChannel.openApp(packageName);
  }

  @override
  Future<AppInfo> getAppIcon(AppInfo app) async {
    if (app.icon != null) return app;
    final icon = await nativeChannel.getAppIcon(app.packageName);
    return app.copyWith(icon: icon);
  }

  @override
  Future<List<String>> getFavoritePackages() {
    return localDataSource.getFavoritePackages();
  }

  @override
  Future<void> saveFavoritePackages(List<String> packages) {
    return localDataSource.saveFavoritePackages(packages);
  }

  @override
  Future<List<Map<String, String>>> getInstalledIconPacks() {
    return nativeChannel.getInstalledIconPacks();
  }

  @override
  Future<String?> getIconPack() {
    return localDataSource.getIconPack();
  }

  @override
  Future<bool> setIconPack(String? packageName) async {
    await localDataSource.saveIconPack(packageName);
    return nativeChannel.setIconPack(packageName);
  }
}
