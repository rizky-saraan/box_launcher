import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@singleton
class LocalDataSourceHive {
  static const String _boxName = 'launcher_box';
  static const String _favoritesKey = 'favorites';

  Future<List<String>> getFavoritePackages() async {
    final box = await Hive.openBox(_boxName);
    final List<dynamic>? list = box.get(_favoritesKey);
    if (list == null) return [];
    return list.cast<String>();
  }

  Future<void> saveFavoritePackages(List<String> packages) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_favoritesKey, packages);
  }
}
