import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<(Failure?, List<Product>?)> getProducts({
    required int page,
    required int limit,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteProducts =
            await remoteDataSource.getProducts(page: page, limit: limit);
        await localDataSource.cacheProducts(remoteProducts);
        return (null, remoteProducts);
      } on DioException catch (dioError) {
        Failure failure;
        if (dioError.type == DioExceptionType.connectionTimeout ||
            dioError.type == DioExceptionType.receiveTimeout ||
            dioError.type == DioExceptionType.sendTimeout) {
          failure = const TimeoutFailure();
        } else if (dioError.type == DioExceptionType.connectionError) {
          failure = const NetworkFailure();
        } else {
          failure = ServerFailure(dioError.message ?? 'Server error occurred');
        }

        final cached = await localDataSource.getCachedProducts();
        if (cached.isEmpty) {
          return (failure, null);
        }
        return (failure, cached);
      } catch (e) {
        final failure = ServerFailure(e.toString());
        final cached = await localDataSource.getCachedProducts();
        if (cached.isEmpty) {
          return (failure, null);
        }
        return (failure, cached);
      }
    } else {
      final cached = await localDataSource.getCachedProducts();
      if (cached.isEmpty) {
        return (
          const NetworkFailure(
              'No Internet connection and no cached data found.'),
          null
        );
      }
      return (
        const NetworkFailure('You are viewing offline cached data.'),
        cached
      );
    }
  }
}
