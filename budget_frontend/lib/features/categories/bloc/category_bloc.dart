import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:budget_frontend/features/categories/bloc/category_event.dart';
import 'package:budget_frontend/features/categories/bloc/category_state.dart';
import 'package:budget_frontend/features/categories/models/category_registry.dart';
import 'package:budget_frontend/features/categories/services/category_service.dart';

export 'package:budget_frontend/features/categories/bloc/category_event.dart';
export 'package:budget_frontend/features/categories/bloc/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({required this.categoryService}) : super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
  }

  final CategoryService categoryService;

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    // If already loaded, do background refresh without flashing loading indicator
    if (!state.isLoaded) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }
    try {
      final list = await categoryService.getCategories();
      CategoryRegistry.setCategories(list);
      emit(state.copyWith(categories: list, isLoading: false, isLoaded: true));
    } catch (e) {
      debugPrint('CategoryBloc LoadCategories error: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load categories',
        ),
      );
    }
  }
}
