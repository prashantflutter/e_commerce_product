import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/error_retry_widget.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../domain/entities/product.dart';
import '../../../wishlist/presentation/cubits/wishlist_cubit.dart';
import '../cubits/product_list_cubit.dart';
import 'product_details_screen.dart';
import '../../../../core/theme/theme_cubit.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() =>
      _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductListCubit>().fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = context.watch<ProductListCubit>().state;
    final filteredProducts = listState.filteredProducts;
    final categories = ProductListCubit.categories;
    final themeMode = context.watch<ThemeCubit>().state;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SwiftShop'),
        actions: [
          // Grid/List toggle
          IconButton(
            icon: Icon(_isGridView
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          // Theme toggle
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Connection check / Offline banner
          if (listState.failure != null && listState.products.isNotEmpty)
            OfflineBanner(message: listState.failure!.message),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context.read<ProductListCubit>().updateSearchQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductListCubit>().updateSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Category Selector Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = listState.selectedCategory == category;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      context.read<ProductListCubit>().updateCategory(category);
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Content body
          Expanded(
            child: listState.isLoading && listState.products.isEmpty
                ? const ProductGridShimmer()
                : listState.products.isEmpty && listState.failure != null
                    ? ErrorRetryWidget(
                        errorMessage: listState.failure!.message,
                        onRetry: () => context
                            .read<ProductListCubit>()
                            .fetchProducts(isRefresh: true),
                      )
                    : filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => context
                                .read<ProductListCubit>()
                                .fetchProducts(isRefresh: true),
                            child: ListView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                if (_isGridView)
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.62,
                                    ),
                                    itemCount: filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      return ProductCard(
                                          product: filteredProducts[index]);
                                    },
                                  )
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemCount: filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = filteredProducts[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: SizedBox(
                                          height: 120,
                                          child:
                                              ProductRowItem(product: product),
                                        ),
                                      );
                                    },
                                  ),

                                // Pagination loader / End message
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: listState.isLoadMore
                                        ? const CircularProgressIndicator()
                                        : listState.hasReachedMax &&
                                                filteredProducts.isNotEmpty
                                            ? Text(
                                                'You have viewed all products',
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 13,
                                                ),
                                              )
                                            : const SizedBox(),
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// Sub-widget for List Layout
class ProductRowItem extends StatelessWidget {
  final Product product;

  const ProductRowItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isWishlisted = context.watch<WishlistCubit>().isWishlisted(product.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                product: product,
                heroTag: 'shop_list_product_image_${product.id}',
              ),
            ),
          );
        },
        child: Row(
          children: [
            // Product Image
            Hero(
              tag: 'shop_list_product_image_${product.id}',
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  color: isDark ? const Color(0xFF1F293D) : Colors.grey.shade50,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2));
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),
            // Text details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Wishlist Toggle
            IconButton(
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                context.read<WishlistCubit>().toggleWishlist(product);
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
