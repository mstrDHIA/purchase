import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/Dashboard/Dashboard.dart' as dashboard;
import 'package:flutter_application_1/screens/Home.dart' as home;
import 'package:flutter_application_1/screens/Product/Product.dart';
import 'package:flutter_application_1/screens/Purchase%20Requestor/Requestor_Form.dart';
import 'package:flutter_application_1/screens/Purchase%20Requestor/Requestor_order.dart' as requestor_order;
import 'package:flutter_application_1/screens/Purchase%20Requestor/request_view.dart' as request_view;
import 'package:flutter_application_1/screens/Purchase%20order/Purchase_form.dart';
import 'package:flutter_application_1/screens/Purchase%20order/Refuse_Purchase.dart';
import 'package:flutter_application_1/screens/Purchase%20order/View_purchase.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order.dart';
import 'package:flutter_application_1/screens/Supplier/Add_supplier.dart';
import 'package:flutter_application_1/screens/Supplier/Edit_suplier.dart';
import 'package:flutter_application_1/screens/Supplier/Supplier_registration.dart';
import 'package:flutter_application_1/screens/Supplier/View_supplier.dart';
import 'package:flutter_application_1/screens/Support%20Center/Home_Center.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/users/Password.dart';
import 'package:flutter_application_1/screens/users/Role.dart';
import 'package:flutter_application_1/screens/users/Users_List.dart' as users_list;
// import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:flutter_application_1/screens/users/Add_user.dart';
import 'package:flutter_application_1/screens/users/Modify_user.dart';
import 'package:flutter_application_1/screens/users/permission.dart';
import 'package:flutter_application_1/screens/users/profile.dart';
import 'package:flutter_application_1/screens/users/profile_user.dart';
import 'package:flutter_application_1/screens/users/users.dart';
import 'package:flutter_application_1/utils/router.dart';
import 'widgets/sidebar.dart';

void main() {
  runApp(const MaterialApp(
     // Replace with a valid User object
    home: MainScreen(),


    // home: SignInPage(),
    
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Purchase Requestor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF8F8FB),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEDEDED),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // initialRoute: '/requestor_order',
      // routes: {
      //   '/login': (context) => const SignInPage(),
      //   '/password': (context) => const PasswordPage(),
      //   '/users': (context) => const users_list.UserListPage(),
      //   '/role': (context) => const RolePage(),
      //   '/permission': (context) => const PermissionPage(),
      //   '/profile': (context) => ProfilePage(user: {}),
      //   '/requestor_order': (context) => requestor_order.PurchaseRequestPage(),
      //   '/purchase_order': (context) => const PurchaseOrderPage(),
      //   '/supplier_registration': (context) => const SupplierRegistrationPage(),
      //   '/edit_supplier': (context) => const EditSupplierPage(),
      //   '/view_supplier': (context) => const ViewSupplierPage(),
      //   '/add_supplier': (context) => const AddSupplierPage(),
      //   '/dashboard': (context) => const dashboard.DashboardPage(),
      //   '/product': (context) => const ProductPage(),
      //   '/requestor_form': (context) => PurchaseRequestorForm(
      //     onSave: (order) {
      //       // TODO: Implement save logic
      //     },
      //     initialOrder: <String, dynamic>{},
      //   ),
      //   // Add any additional routes here
      // },

    );
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selected = 'Home';

  Widget _getPage() {
    switch (_selected) {
      case 'Home':
        return const home.HomePage();
      case 'Dashboard':
        return const dashboard.DashboardPage();
      case 'Profile':
        return ProfilePage(user: {});
      case 'Users':
        return const users_list.UserListPage();
      case 'Password':
        return const PasswordPage();
      case 'PurchaseRequest':
        return const requestor_order.PurchaseRequestPage();
      case 'Purchase Order':
        return const PurchaseOrderPage();
      case 'Roles and access':
        return const RolePage();
      case 'Support centre':
        return const SupportCenterPage();
      default:
        return const Center(child: Text('Home Page'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selected: _selected,
            onItemSelected: (item) {
              setState(() {
                _selected = item;
              });
            },
          ),
          Expanded(child: _getPage()),
        ],
      ),
    );
  }
}

