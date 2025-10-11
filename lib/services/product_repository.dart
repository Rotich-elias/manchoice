import '../config/api_config.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();

  // Get all products
  Future<List<Product>> getAllProducts({
    int page = 1,
    String? category,
    String? search,
    bool? available,
    bool? inStock,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;
      if (available != null) queryParams['available'] = available.toString();
      if (inStock != null) queryParams['in_stock'] = inStock.toString();

      final response = await _apiService.get(
        ApiConfig.products,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['data'] as List;
        return data.map((e) => Product.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Get product by ID
  Future<Product?> getProductById(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.products}/$id');

      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  // Create product
  Future<Product?> createProduct({
    required String name,
    String? description,
    String? category,
    required double price,
    String? imageUrl,
    int? stockQuantity,
    bool? isAvailable,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.products,
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (category != null) 'category': category,
          'price': price,
          if (imageUrl != null) 'image_url': imageUrl,
          if (stockQuantity != null) 'stock_quantity': stockQuantity,
          if (isAvailable != null) 'is_available': isAvailable,
        },
      );

      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  // Update product
  Future<Product?> updateProduct({
    required int id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    int? stockQuantity,
    bool? isAvailable,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.products}/$id',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (category != null) 'category': category,
          if (price != null) 'price': price,
          if (imageUrl != null) 'image_url': imageUrl,
          if (stockQuantity != null) 'stock_quantity': stockQuantity,
          if (isAvailable != null) 'is_available': isAvailable,
        },
      );

      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _apiService.delete('${ApiConfig.products}/$id');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Update stock quantity
  Future<Product?> updateStock({
    required int id,
    required int quantity,
    required String action, // add, reduce, or set
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.products}/$id/update-stock',
        data: {
          'quantity': quantity,
          'action': action,
        },
      );

      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  // Toggle product availability
  Future<Product?> toggleAvailability(int id) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.products}/$id/toggle-availability',
      );

      if (response.data['success'] == true) {
        return Product.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to toggle availability: $e');
    }
  }

  // Get products by category
  Future<List<Product>> getByCategory(String category) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.products}/category/$category',
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['data'] as List;
        return data.map((e) => Product.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }
}
