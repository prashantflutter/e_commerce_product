import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductListState {
  final List<Product> products;
  final int page;
  final bool isLoading;
  final bool isLoadMore;
  final bool hasReachedMax;
  final Failure? failure;
  final String searchQuery;
  final String selectedCategory;

  const ProductListState({
    required this.products,
    required this.page,
    required this.isLoading,
    required this.isLoadMore,
    required this.hasReachedMax,
    this.failure,
    required this.searchQuery,
    required this.selectedCategory,
  });

  factory ProductListState.initial() => const ProductListState(
        products: [],
        page: 1,
        isLoading: false,
        isLoadMore: false,
        hasReachedMax: false,
        failure: null,
        searchQuery: '',
        selectedCategory: 'All',
      );

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesSearch = searchQuery.isEmpty ||
          product.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.description
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final matchesCategory = selectedCategory == 'All' ||
          product.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  ProductListState copyWith({
    List<Product>? products,
    int? page,
    bool? isLoading,
    bool? isLoadMore,
    bool? hasReachedMax,
    Failure? failure,
    bool clearFailure = false,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ProductListState(
      products: products ?? this.products,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadMore: isLoadMore ?? this.isLoadMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      failure: clearFailure ? null : (failure ?? this.failure),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class ProductListCubit extends Cubit<ProductListState> {
  final ProductRepository _repository;
  static const int _limit = 10;

  static const List<String> categories = [
    'All',
    'Electronics',
    'Fashion & Apparel',
    'Home & Kitchen',
    'Sports & Outdoors'
  ];

  ProductListCubit(this._repository) : super(ProductListState.initial()) {
    fetchProducts();
  }

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      emit(state.copyWith(
        page: 1,
        hasReachedMax: false,
        isLoading: true,
        clearFailure: true,
      ));
    } else {
      if (state.isLoading || state.isLoadMore || state.hasReachedMax) return;
      if (state.page == 1) {
        emit(state.copyWith(isLoading: true, clearFailure: true));
      } else {
        emit(state.copyWith(isLoadMore: true, clearFailure: true));
      }
    }

    final (failure, fetchedList) = await _repository.getProducts(
      page: state.page,
      limit: _limit,
    );

    if (failure != null) {
      if (fetchedList != null) {
        emit(state.copyWith(
          products: fetchedList,
          isLoading: false,
          isLoadMore: false,
          hasReachedMax: true,
          failure: failure,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          isLoadMore: false,
          failure: failure,
        ));
      }
      return;
    }

    if (fetchedList != null) {
      final List<Product> updatedProducts;
      if (isRefresh || state.page == 1) {
        updatedProducts = fetchedList;
      } else {
        final existingIds = state.products.map((p) => p.id).toSet();
        final newUnique =
            fetchedList.where((p) => !existingIds.contains(p.id)).toList();
        updatedProducts = [...state.products, ...newUnique];
      }

      emit(state.copyWith(
        products: updatedProducts,
        page: state.page + 1,
        isLoading: false,
        isLoadMore: false,
        hasReachedMax: fetchedList.length < _limit,
        clearFailure: true,
      ));
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }
}
