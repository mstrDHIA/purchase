import 'package:flutter_application_1/screens/Dashboard/dashboard_screen.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/Product/family_screen.dart';
// import 'package:flutter_application_1/screens/Product/product_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Add_supplier_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Edit_suplier_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Supplier_registration_screen.dart';
import 'package:flutter_application_1/screens/Supplier/View_supplier_screen.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/users/password_screen.dart';
import 'package:flutter_application_1/screens/Role/Role_screen.dart';
import 'package:flutter_application_1/screens/users/permission_screen.dart';
import 'package:flutter_application_1/screens/users/add_user_screen.dart';
import 'package:flutter_application_1/screens/Purchase Request/requestor_form_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',

  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardPage(),
    ),
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
    GoRoute(
      path: '/role',
      builder: (context, state) => RolePage(),
    ),
    GoRoute(
      path: '/permission',
      builder: (context, state) => PermissionPage(),
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
    // GoRoute(
    //   path: '/product',
    //   builder: (context, state) => FamiliesPage(),
    // ),
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