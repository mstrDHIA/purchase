import 'package:flutter/material.dart';

import '../network/product_network.dart';
import '../models/category.dart';
import '../models/product.dart';

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

	// PRODUCT MANAGEMENT METHODS
	Future<List<Product>> getProducts({int? subcategoryId}) async {
		try {
			return await network.fetchProducts(subcategoryId: subcategoryId);
		} catch (e) {
			rethrow;
		}
	}

	Future<Product> getProductById(int id) async {
		try {
			return await network.getProductById(id);
		} catch (e) {
			rethrow;
		}
	}

	Future<Product> createProduct(Product product) async {
		try {
			final result = await network.createProduct(product);
			notifyListeners();
			return result;
		} catch (e) {
			rethrow;
		}
	}

	Future<Product> updateProduct(int id, Product product) async {
		try {
			final result = await network.updateProduct(id, product);
			notifyListeners();
			return result;
		} catch (e) {
			rethrow;
		}
	}

	Future<void> deleteProduct(int id) async {
		try {
			await network.deleteProduct(id);
			notifyListeners();
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
