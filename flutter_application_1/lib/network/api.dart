import 'package:dio/dio.dart';

class APIS {

  // Product endpoints
  static const String productList = "product/products/";
  static const String addProduct = "product/products/";
  static const String updateProduct = "product/products/";
  static const String deleteProduct = "product/products/";

 
  static const String purchaseOrderList = "purchase_order/purchaseOrders/";
  
  
  final dio = Dio();
  static String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzYzNjM0MjgzLCJpYXQiOjE3NjMwMjk0ODMsImp0aSI6IjVhNjYyZTAwYThmZTRjZTBiZDdjMWM1NmExMDc4MmRkIiwidXNlcl9pZCI6MX0.5OE58vMoA6sA0HLKQc5lt-6FFw49VAKn3_5H3LWKC6U';

  // APIS() {
  //   dio.interceptors.add(LogInterceptor(
  //     request: true,
  //     requestBody: true,
  //     responseBody: true,
  //     responseHeader: false,
  //     error: true,
  //   ));
  // }

  static const String baseUrl = "http://72.60.90.60:8000/";
    // static const String httpbaseUrl = "72.60.90.60:8000/";


  static const String login = "/user/login/";

  static const String register = "user/register/";
  static const String userList = "user/users/";
  static const String updateUser = "user/users-with-details/";
  static const String deleteUser = "user/users/";
  static const String addProfile = "profile/add-profile/";
  static const String viewProfile = 'profile/profiles/';
  static const String addRole = "role/roles/";
  static const String deleteRole = "role/roles/";
  static const String updateRole = "role/roles/";
  static const String viewProfileByUserId = "user/users-with-details/";
  static const String userListDetailed = "user/users-with-details-list/";
  static const String updateProfile = "profile/profiles/";
  static const String changePassword = "user/change-password/";
  static const String viewProfileById = "purchase_request/purchaseRequests/";
  static const String updateAllUsers = "user/users/update-all/";
  static const String deletePurchaseRequest = "purchase_request/purchaseRequests/";
  static const String updatePurchaseRequest = "purchase_request/purchaseRequests/";

  static const String viewPurchaseOrder = "purchase_order/purchaseOrders/";
  static const String createPurchaseOrder = "purchase_order/purchaseOrders/";
  static const String updatePurchaseOrder = "purchase_order/purchaseOrders/";
  static const String deletePurchaseOrder = "purchase_order/purchaseOrders/";

   // adapte selon ton endpoint réel

  static const String viewPurchaseOrderById = "purchase_order/purchaseOrders/";
  static const String updatePurchaseOrderById = "purchase_order/purchaseOrders/";
  static const String deletePurchaseOrderById = "purchase_order/purchaseOrders/";
  static const String fetchCategories = "category/category/";
  static const String createCategories = "category/category/";
  static const String editCategory = "category/category/";
  static const String deleteCategory = "category/category/";
  static const String createSubfamily = "category/category/?parent_category="; // Added endpoint for subfamily creation



  // Add more API endpoints as needed
}