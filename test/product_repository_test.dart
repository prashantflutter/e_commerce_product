import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:e_commerce_product/core/error/failures.dart';
import 'package:e_commerce_product/core/network/network_info.dart';
import 'package:e_commerce_product/features/products/data/datasources/product_local_data_source.dart';
import 'package:e_commerce_product/features/products/data/datasources/product_remote_data_source.dart';
import 'package:e_commerce_product/features/products/data/models/product_model.dart';
import 'package:e_commerce_product/features/products/data/repositories/product_repository_impl.dart';

// Manual mock implementation for RemoteDataSource
class MockProductRemoteDataSource implements ProductRemoteDataSource {
  List<ProductModel> productsToReturn = [];
  bool shouldThrowDioError = false;
  DioExceptionType dioErrorType = DioExceptionType.unknown;

  @override
  Future<List<ProductModel>> getProducts(
      {required int page, required int limit}) async {
    if (shouldThrowDioError) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: dioErrorType,
        message: 'Mock Dio Exception',
      );
    }
    return productsToReturn;
  }
}

// Manual mock implementation for LocalDataSource
class MockProductLocalDataSource implements ProductLocalDataSource {
  List<ProductModel> cachedProducts = [];
  bool cacheCalled = false;

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    return cachedProducts;
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    cacheCalled = true;
    cachedProducts = products;
  }

  @override
  Future<void> clearCache() async {
    cachedProducts.clear();
  }
}

// Manual mock implementation for NetworkInfo
class MockNetworkInfo implements NetworkInfo {
  bool isConnectedValue = true;

  @override
  Future<bool> get isConnected async => isConnectedValue;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(isConnectedValue);
}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemoteDataSource;
  late MockProductLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    mockLocalDataSource = MockProductLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  final tProductList = [
    const ProductModel(
      id: 1,
      title: 'Test Product 1',
      description: 'Description 1',
      price: 99.99,
      rating: 4.5,
      reviewCount: 120,
      category: 'Electronics',
      imageUrl: 'https://example.com/image1.jpg',
    ),
  ];

  group('getProducts', () {
    test('should return remote data and cache it when network is connected',
        () async {
      // Arrange
      mockNetworkInfo.isConnectedValue = true;
      mockRemoteDataSource.productsToReturn = tProductList;

      // Act
      final (failure, result) =
          await repository.getProducts(page: 1, limit: 10);

      // Assert
      expect(failure, isNull);
      expect(result, equals(tProductList));
      expect(mockLocalDataSource.cacheCalled, isTrue);
      expect(mockLocalDataSource.cachedProducts, equals(tProductList));
    });

    test(
        'should return cached data and NetworkFailure when network is disconnected and cache exists',
        () async {
      // Arrange
      mockNetworkInfo.isConnectedValue = false;
      mockLocalDataSource.cachedProducts = tProductList;

      // Act
      final (failure, result) =
          await repository.getProducts(page: 1, limit: 10);

      // Assert
      expect(failure, isA<NetworkFailure>());
      expect(result, equals(tProductList));
    });

    test(
        'should return NetworkFailure error when network is disconnected and no cache exists',
        () async {
      // Arrange
      mockNetworkInfo.isConnectedValue = false;
      mockLocalDataSource.cachedProducts = [];

      // Act
      final (failure, result) =
          await repository.getProducts(page: 1, limit: 10);

      // Assert
      expect(failure, isA<NetworkFailure>());
      expect(result, isNull);
    });

    test(
        'should return ServerFailure and fallback to cache when remote API call throws Dio Timeout error',
        () async {
      // Arrange
      mockNetworkInfo.isConnectedValue = true;
      mockRemoteDataSource.shouldThrowDioError = true;
      mockRemoteDataSource.dioErrorType = DioExceptionType.connectionTimeout;
      mockLocalDataSource.cachedProducts = tProductList;

      // Act
      final (failure, result) =
          await repository.getProducts(page: 1, limit: 10);

      // Assert
      expect(failure, isA<TimeoutFailure>());
      expect(result, equals(tProductList));
    });
  });
}
