import 'dart:convert';
// import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';

import 'api.dart';
import '../models/category.dart';

class ProductNetwork {
		
    APIS api = APIS();

		// ProductNetwork({required this.baseUrl});

		 fetchCategories(int? parent_category) async {
      print('Fetching categories with parent_category: $parent_category');
			print('Fetching categories from API: ${APIS.baseUrl}${APIS.fetchCategories}');
      Map<String, dynamic> queryParameters = {};
      if (parent_category != null) {
        queryParameters['parent_category'] = parent_category;
      }
			// final url = Uri.parse('${APIS.baseUrl}${APIS.fetchCategories}',
          
      // );

      // final url=Uri.http(APIS.httpbaseUrl, APIS.fetchCategories, queryParameters);
			// final response = await http.get(
			// 	url,
        
			// 	headers: {
			// 		'Authorization': 'Bearer ${APIS.token}',
			// 		'Content-Type': 'application/json',
			// 	},

			// );
      Response response=await api.dio.get(
        APIS.baseUrl+APIS.fetchCategories,
        // url.toString(),
        options: Options(

          headers: {
            'Authorization': 'Bearer ${APIS.token}',
            'Content-Type': 'application/json',
          },
        ),
        queryParameters: queryParameters
      );
			print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
			if (response.statusCode == 200) {
				print('Categories fetched successfully');
				return response.data;
			} else {
				print('Failed to fetch categories: ${response.data}');
				throw Exception('Failed to load products');
			}
		}

		 fetchCategoriesWithoutQuery() async {
    print('Fetching categories without query parameters from API: ${APIS.baseUrl}${APIS.fetchCategories}');
    Response response = await api.dio.get(
      APIS.baseUrl + APIS.fetchCategories,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${APIS.token}',
          'Content-Type': 'application/json',
        },
      ),
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Categories fetched successfully');
      return response.data;
    } else {
      print('Failed to fetch categories: ${response.data}');
      throw Exception('Failed to load categories');
    }
  }


  //   Future<Map<String, dynamic>> createCategories(Map<String, dynamic> categoriesData) async {
	// 	print('Creating categories with data: $categoriesData');
	// 	final url = Uri.parse('${APIS.baseUrl}${APIS.createCategories}');
	// 	final response = await http.post(
	// 		url,
	// 		headers: {
	// 			'Authorization': 'Bearer ${APIS.token}',
	// 			'Content-Type': 'application/json',
	// 		},
	// 		body: jsonEncode(categoriesData),
	// 	);
	// 	print('Response status: ${response.statusCode}');
	// 	if (response.statusCode == 201 || response.statusCode == 200) {
	// 		print('Categories created successfully');
	// 		return jsonDecode(response.body);
	// 	} else {
	// 		print('Failed to create categories: ${response.body}');
	// 		throw Exception('Failed to create categories: ${response.body}');
	// 	}
	// }

	Future<void> createCategory(Category category) async {
		print('Creating category with data: ${category.toJson()}');
		final url = Uri.parse('${APIS.baseUrl}${APIS.createCategories}');
		Response response = await api.dio.post(
      APIS.baseUrl + APIS.createCategories,
      data: jsonEncode(category.toJson()),
      options: Options(
        headers: {
          'Authorization': 'Bearer ${APIS.token}',
          'Content-Type': 'application/json',
        },
        
      ),
    );
		print('Response status: ${response.statusCode}');
		if (response.statusCode != 201 && response.statusCode != 200) {
			print('Failed to create category: ${response.data}');
			throw Exception('Failed to create category');
		}
		print('Category created successfully');
	}

	Future<void> editCategory(Category category) async {
    print('Editing category with ID: ${category.id} and data: ${category.toJson()}');
    Response response = await api.dio.put(
      APIS.baseUrl + APIS.editCategory + category.id.toString() + '/',
      data: jsonEncode(category.toJson()),
      options: Options(
        headers: {
          'Authorization': 'Bearer ${APIS.token}',
          'Content-Type': 'application/json',
        },
      ),
    );
    print('Response status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Failed to edit category: ${response.data}');
      throw Exception('Failed to edit category: ${response.data}');
    }
    print('Category edited successfully');
  }

  Future<void> deleteCategory(String categoryId) async {
        print('Deleting category with ID: $categoryId');
        Response response = await api.dio.delete(
          APIS.baseUrl + APIS.deleteCategory + categoryId + '/',
          options: Options(
            headers: {
              'Authorization': 'Bearer ${APIS.token}',
              'Content-Type': 'application/json',
            },
          ),
        );
        print('Response status: ${response.statusCode}');
        if (response.statusCode != 200 && response.statusCode != 204) {
            print('Failed to delete category: ${response.data}');
            throw Exception('Failed to delete category: ${response.data}');
        }
        print('Category deleted successfully');
    }

    
}
