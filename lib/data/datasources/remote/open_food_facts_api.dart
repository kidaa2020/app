import 'package:dio/dio.dart';
import 'package:healthbuddy/core/constants/app_constants.dart';
import 'package:healthbuddy/data/models/product.dart';

class OpenFoodFactsApi {
  final Dio _dio;

  OpenFoodFactsApi({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.openFoodFactsBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'User-Agent': 'HealthBuddy/1.0 (Flutter App)',
              },
            ));

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get('/$barcode.json');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final status = data['status'] as int?;

        if (status == 1) {
          return Product.fromOpenFoodFacts(data);
        }
      }
      return null;
    } on DioException {
      return null;
    }
  }
}
