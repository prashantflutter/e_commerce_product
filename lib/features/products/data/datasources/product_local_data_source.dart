import 'package:hive/hive.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> clearCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box productsBox;

  ProductLocalDataSourceImpl(this.productsBox);

  static const String _cachedProductsKey = 'cached_products_list';

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final List<dynamic>? rawList =
          productsBox.get(_cachedProductsKey) as List<dynamic>?;
      if (rawList == null) return [];

      return rawList
          .map((item) =>
              ProductModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final currentCached = await getCachedProducts();
      final Map<int, ProductModel> mergedMap = {
        for (var p in currentCached) p.id: p,
      };

      for (var p in products) {
        mergedMap[p.id] = p; // Overwrite or add
      }

      final serializedList = mergedMap.values.map((p) => p.toJson()).toList();
      await productsBox.put(_cachedProductsKey, serializedList);
    } catch (_) {
      // Fail silently or handle local storage error
    }
  }

  @override
  Future<void> clearCache() async {
    await productsBox.delete(_cachedProductsKey);
  }
}
