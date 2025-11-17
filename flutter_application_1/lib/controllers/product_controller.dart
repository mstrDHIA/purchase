import 'package:flutter/material.dart';

import '../network/product_network.dart';
import '../models/category.dart';

class ProductController extends ChangeNotifier {
	final ProductNetwork network=ProductNetwork();


	 getCategories(int? parent_category) async {
		try {
			return await network.fetchCategories(parent_category);
		} catch (e) {
			
			rethrow;
		}
	}

	 getCategoriesWithoutQuery() async {
    try {

      return await network.fetchCategoriesWithoutQuery();
    } catch (e) {
      rethrow;
    }
  }

	Future<void> createCategories(Category category) async {
		try {
			await network.createCategory(category);
		} catch (e) {
			rethrow;
		}
	}

	Future<void> editCategory(Category category) async {
		try {
			await network.editCategory(category);
		} catch (e) {
			rethrow;
		}
	}

	Future<void> deleteCategory(String categoryId) async {
      try {
          await network.deleteCategory(categoryId);
      } catch (e) {
          rethrow;
      }
  }

	// Future<void> createSubfamily(Map<String, dynamic> subfamilyData) async {
  //   try {
  //     await network.createSubfamily(subfamilyData);
  //   } catch (e) {
  //     throw Exception('Failed to create subfamily: $e');
  //   }
  // }
}
