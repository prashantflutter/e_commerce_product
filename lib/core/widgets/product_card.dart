import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/products/presentation/screens/product_details_screen.dart';
import '../../features/wishlist/presentation/cubits/wishlist_cubit.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String heroTagPrefix;

  const ProductCard({
    super.key,
    required this.product,
    this.heroTagPrefix = 'shop',
  });

  @override
  Widget build(BuildContext context) {
    final isWishlisted = context.watch<WishlistCubit>().isWishlisted(product.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine category pill colors
    Color categoryBgColor;
    Color categoryTextColor;
    switch (product.category) {
      case 'Electronics':
        categoryBgColor =
            isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
        categoryTextColor =
            isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
        break;
      case 'Fashion & Apparel':
        categoryBgColor =
            isDark ? const Color(0xFF881337) : const Color(0xFFFFF1F2);
        categoryTextColor =
            isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C);
        break;
      case 'Home & Kitchen':
        categoryBgColor =
            isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        categoryTextColor =
            isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309);
        break;
      case 'Sports & Outdoors':
        categoryBgColor =
            isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5);
        categoryTextColor =
            isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857);
        break;
      default:
        categoryBgColor =
            isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
        categoryTextColor =
            isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(
                product: product,
                heroTag: '${heroTagPrefix}_product_image_${product.id}',
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack image and heart/wishlist button
            Stack(
              children: [
                // Product Image
                Hero(
                  tag: '${heroTagPrefix}_product_image_${product.id}',
                  child: AspectRatio(
                    aspectRatio: 1.25,
                    child: Container(
                      color: isDark
                          ? const Color(0xFF1F293D)
                          : Colors.grey.shade50,
                      child: Image.network(
                        product.imageUrl,
                        fit: product.id % 2 == 0
                            ? BoxFit.cover
                            : BoxFit.fitHeight,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey.shade400,
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: IconButton(
                      iconSize: 18,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.grey.shade600,
                      ),
                      onPressed: () {
                        context
                            .read<WishlistCubit>()
                            .toggleWishlist(product);
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Text Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: categoryBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: categoryTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Title
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ratings
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.reviewCount})',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Price
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
