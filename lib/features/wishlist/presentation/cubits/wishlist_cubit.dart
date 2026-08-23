import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/wishlist_repository.dart';

class WishlistCubit extends Cubit<List<Product>> {
  final WishlistRepository _repository;

  WishlistCubit(this._repository) : super([]) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    final list = await _repository.getWishlist();
    emit(list);
  }

  Future<void> toggleWishlist(Product product) async {
    final exists = state.any((p) => p.id == product.id);
    if (exists) {
      await _repository.removeFromWishlist(product.id);
      emit(state.where((p) => p.id != product.id).toList());
    } else {
      await _repository.addToWishlist(product);
      emit([...state, product]);
    }
  }

  bool isWishlisted(int productId) {
    return state.any((p) => p.id == productId);
  }
}
