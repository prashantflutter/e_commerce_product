import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.rating,
    required super.reviewCount,
    required super.category,
    required super.imageUrl,
  });

  factory ProductModel.fromRemoteJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final title = json['title'] as String? ?? '';
    final description = json['description'] as String? ?? '';
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final rating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    final reviews = json['reviews'] as List?;
    final reviewCount = reviews?.length ?? 0;
    final category = json['category'] as String? ?? '';
    final images = json['images'] as List?;
    final imageUrl = json['thumbnail'] as String? ??
        (images != null && images.isNotEmpty ? images.first.toString() : '');

    return ProductModel(
      id: id,
      title: title,
      description: description,
      price: price,
      rating: rating,
      reviewCount: reviewCount,
      category: category,
      imageUrl: imageUrl,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'imageUrl': imageUrl,
    };
  }
}
