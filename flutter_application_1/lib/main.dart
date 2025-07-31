import 'package:flutter/material.dart';

import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/role_controller.dart';

import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/Dashboard/Dashboard.dart' as dashboard;
import 'package:flutter_application_1/screens/Home.dart' as home;
import 'package:flutter_application_1/screens/Product/Product.dart';
import 'package:flutter_application_1/screens/Purchase%20Requestor/requestor_form_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20Requestor/requestor_order_screen.dart' as requestor_order;
import 'package:flutter_application_1/screens/Purchase%20Requestor/request_view_screen.dart' as request_view;
import 'package:flutter_application_1/screens/Purchase%20order/purchase_form_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/refuse_purchase_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/view_purchase_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Add_supplier.dart';
import 'package:flutter_application_1/screens/Supplier/Edit_suplier.dart';
import 'package:flutter_application_1/screens/Supplier/Supplier_registration.dart';
import 'package:flutter_application_1/screens/Supplier/View_supplier.dart';
import 'package:flutter_application_1/screens/Support%20Center/Home_Center.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/users/password_screen.dart';
import 'package:flutter_application_1/screens/Role/Role_screen.dart';
import 'package:flutter_application_1/screens/users/users_List_screen.dart' as users_list;
// import 'package:flutter_application_1/screens/auth/login.dart';
import 'package:flutter_application_1/screens/users/add_user_screen.dart';
import 'package:flutter_application_1/screens/users/modify_user_screen.dart';
import 'package:flutter_application_1/screens/users/permission_screen.dart';

import 'package:flutter_application_1/screens/profile/profile_user_screen.dart';

import 'package:flutter_application_1/utils/router.dart';
import 'package:provider/provider.dart';
import 'widgets/sidebar.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => RoleController()),
      ],
      child: MaterialApp(
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
        home: const MainScreen(), // <-- Ajoute cette ligne
        // routerConfig: router,   // <-- Commente ou supprime cette ligne
      ),
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
        return const PasswordScreen();
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

