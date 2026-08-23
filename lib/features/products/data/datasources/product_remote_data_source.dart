import 'package:dio/dio.dart';
import '../../../../core/constants/constants.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  /// Fetches a list of augmented products using pagination parameters [_start] and [_limit].
  Future<List<ProductModel>> getProducts(
      {required int page, required int limit});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio) {
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = AppConstants.connectTimeout;
    dio.options.receiveTimeout = AppConstants.receiveTimeout;
  }

  @override
  Future<List<ProductModel>> getProducts(
      {required int page, required int limit}) async {
    final skip = (page - 1) * limit;

    try {
      final response = await dio.get(
        AppConstants.postsEndpoint,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
        final List<dynamic> dataList = responseData['products'] as List<dynamic>;
        return dataList
            .map((item) =>
                ProductModel.fromRemoteJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      // Re-throw or map exceptions to core custom exceptions
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected network error occurred: $e');
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DioException(
          requestOptions: error.requestOptions,
          message:
              'Connection timed out. Please check your network and try again.',
          type: DioExceptionType.connectionTimeout,
        );
      case DioExceptionType.connectionError:
        return DioException(
          requestOptions: error.requestOptions,
          message:
              'No internet connection. Please verify your connection status.',
          type: DioExceptionType.connectionError,
        );
      default:
        return DioException(
          requestOptions: error.requestOptions,
          message:
              error.message ?? 'Server error occurred. Please try again later.',
          type: DioExceptionType.unknown,
        );
    }
  }
}
