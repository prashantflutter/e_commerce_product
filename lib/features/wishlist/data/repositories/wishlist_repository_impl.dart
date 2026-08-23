import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_data_source.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistLocalDataSource localDataSource;

  WishlistRepositoryImpl(this.localDataSource);

  @override
  Future<List<Product>> getWishlist() async {
    return await localDataSource.getWishlist();
  }

  @override
  Future<void> addToWishlist(Product product) async {
    final model = ProductModel(
      id: product.id,
      title: product.title,
      description: product.description,
      price: product.price,
      rating: product.rating,
      reviewCount: product.reviewCount,
      category: product.category,
      imageUrl: product.imageUrl,
    );
    await localDataSource.addToWishlist(model);
  }

  @override
  Future<void> removeFromWishlist(int productId) async {
    await localDataSource.removeFromWishlist(productId);
  }

  @override
  bool isWishlisted(int productId) {
    return localDataSource.isWishlisted(productId);
  }
}
