class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final String category;
  final String imageUrl;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          price == other.price &&
          rating == other.rating &&
          reviewCount == other.reviewCount &&
          category == other.category &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      price.hashCode ^
      rating.hashCode ^
      reviewCount.hashCode ^
      category.hashCode ^
      imageUrl.hashCode;
}
