import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class HiveStorage {
  static const String productsBoxName = 'products_cache_box';
  static const String wishlistBoxName = 'wishlist_cache_box';
  static const String appSettingsBoxName = 'app_settings_box';

  static Future<void> init() async {
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    await Hive.openBox(productsBoxName);
    await Hive.openBox(wishlistBoxName);
    await Hive.openBox(appSettingsBoxName);
  }

  static Box getBox(String boxName) => Hive.box(boxName);

  static Future<void> clearAll() async {
    await getBox(productsBoxName).clear();
    await getBox(wishlistBoxName).clear();
    await getBox(appSettingsBoxName).clear();
  }
}
