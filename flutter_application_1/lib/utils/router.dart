import 'package:flutter_application_1/screens/Dashboard/dashboard_screen.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/Product/product_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Add_supplier_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Edit_suplier_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Supplier_registration_screen.dart';
import 'package:flutter_application_1/screens/Supplier/View_supplier_screen.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
// import 'package:flutter_application_1/screens/profile/profile_user.dart';
import 'package:flutter_application_1/screens/users/password_screen.dart';
import 'package:flutter_application_1/screens/Role/Role_screen.dart';
import 'package:flutter_application_1/screens/users/permission_screen.dart';


import 'package:flutter_application_1/screens/users/add_user_screen.dart';

import 'package:flutter_application_1/screens/Purchase Request/requestor_form_screen.dart';

import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  // redirect: (context, state) => state. == '/login' || state.subloc == '/signup'
  //     ? null
  //     : '/main_screen',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardPage(),
    ),
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) => HomePage(),
    // ),
    GoRoute(
      path: '/purchase_requestor_form',
      builder: (context, state) => PurchaseRequestorForm(
        onSave: (order) {},
        initialOrder: const {},
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => SignInPage(),
    ),
    GoRoute(
      path: '/main_screen',
      builder: (context, state) => MainScreen(),
    ),
    GoRoute(
      path: '/password',
      builder: (context, state) => PasswordScreen(),
    ),
    // GoRoute(
    //   path: '/users',
    //   builder: (context, state) => UsersL(),
    // ),
    GoRoute(
      path: '/role',
      builder: (context, state) => RolePage(),
    ),
    GoRoute(
      path: '/permission',
      builder: (context, state) => PermissionPage(),
    ),
    // GoRoute(
    //   path: '/profile',
    //   builder: (context, state) => ProfilePageScreen(),
      
    // ),
    GoRoute(
      path: '/purchase_order',
      builder: (context, state) => PurchaseOrderPage(),
    ),
    GoRoute(
      path: '/supplier_registration',
      builder: (context, state) => SupplierRegistrationPage(),
    ),
    GoRoute(
      path: '/edit_supplier',
      builder: (context, state) => EditSupplierPage(),
    ),
    GoRoute(
      path: '/view_supplier',
      builder: (context, state) => ViewSupplierPage(),
    ),
    GoRoute(
      path: '/add_supplier',
      builder: (context, state) => AddSupplierPage(),
    ),
    GoRoute(
      path: '/product',
      builder: (context, state) => ProductPage(),
    ),
    // GoRoute(
    //   path: '/home_screen',
    //   // builder: (context, state) => HomeScreen(),
    // ),
    GoRoute(
      path: '/add_user',
      builder: (context, state) => AddUserPage(),
    ),
    
    
  ],
);


// initialRoute: '/requestor_order',
      // routes: {
      //   '/users': (context) => const users_list.UserListPage(),


      //   '/requestor_order': (context) => requestor_order.PurchaseRequestPage(),


      //   '/dashboard': (context) => const dashboard.DashboardPage(),

      //   '/requestor_form': (context) => PurchaseRequestorForm(
      //     onSave: (order) {
      //       // TODO: Implement save logic
      //     },
      //     initialOrder: <String, dynamic>{},
      //   ),
      //   // Add any additional routes here
      // },