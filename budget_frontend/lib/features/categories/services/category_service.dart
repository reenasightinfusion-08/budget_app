import 'package:budget_frontend/core/network/api_client.dart';
import 'package:budget_frontend/features/categories/models/category_model.dart';

class CategoryService {
  CategoryService(this.client);

  final ApiClient client;

  /// Fetches shared categories from GET /api/categories.
  Future<List<CategoryModel>> getCategories() async {
    final data = await client.get('/categories');
    final list = data['categories'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }
}
