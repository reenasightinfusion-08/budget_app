import 'package:flutter/foundation.dart';

@immutable
abstract class CategoryEvent {
  const CategoryEvent();
}

/// Dispatched to load and cache categories from GET /api/categories.
class LoadCategories extends CategoryEvent {
  const LoadCategories();
}
