import 'package:hive/hive.dart';
import '../../../products/data/models/product_model.dart';

abstract class WishlistLocalDataSource {
  Future<List<ProductModel>> getWishlist();
  Future<void> addToWishlist(ProductModel product);
  Future<void> removeFromWishlist(int productId);
  bool isWishlisted(int productId);
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  final Box wishlistBox;

  WishlistLocalDataSourceImpl(this.wishlistBox);

  @override
  Future<List<ProductModel>> getWishlist() async {
    try {
      final values = wishlistBox.values;
      return values
          .map((item) =>
              ProductModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addToWishlist(ProductModel product) async {
    await wishlistBox.put(product.id, product.toJson());
  }

  @override
  Future<void> removeFromWishlist(int productId) async {
    await wishlistBox.delete(productId);
  }

  @override
  bool isWishlisted(int productId) {
    return wishlistBox.containsKey(productId);
  }
}
