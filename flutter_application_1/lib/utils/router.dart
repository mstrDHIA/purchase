import 'package:flutter_application_1/screens/Product/Product.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order.dart';
import 'package:flutter_application_1/screens/Supplier/Add_supplier.dart';
import 'package:flutter_application_1/screens/Supplier/Edit_suplier.dart';
import 'package:flutter_application_1/screens/Supplier/Supplier_registration.dart';
import 'package:flutter_application_1/screens/Supplier/View_supplier.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/home/home_screen.dart';
import 'package:flutter_application_1/screens/users/Password.dart';
import 'package:flutter_application_1/screens/users/Role.dart';
import 'package:flutter_application_1/screens/users/permission.dart';
import 'package:flutter_application_1/screens/users/profile_user.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) => HomePage(),
    // ),
    GoRoute(
      path: '/login',
      builder: (context, state) => SignInPage(),
    ),
    GoRoute(
      path: '/password',
      builder: (context, state) => PasswordPage(),
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
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfilePage(user: {},),
    ),
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
    GoRoute(
      path: '/home_screen',
      builder: (context, state) => HomeScreen(),
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