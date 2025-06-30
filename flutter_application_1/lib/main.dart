import 'package:flutter/material.dart';


import 'package:flutter_application_1/utils/router.dart';

void main() {
  runApp(MyApp());
  // runApp(const MaterialApp(
  //   home: MainScreen(),
  // ));
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

