import '../../../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  /// Fetches products from remote or falls back to local cache if offline/errors occur.
  /// Returns a tuple containing an optional [Failure] and optional [List<Product>].
  Future<(Failure?, List<Product>?)> getProducts(
      {required int page, required int limit});
}
