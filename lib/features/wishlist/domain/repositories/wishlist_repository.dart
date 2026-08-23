import '../../../products/domain/entities/product.dart';

abstract class WishlistRepository {
  Future<List<Product>> getWishlist();
  Future<void> addToWishlist(Product product);
  Future<void> removeFromWishlist(int productId);
  bool isWishlisted(int productId);
}
