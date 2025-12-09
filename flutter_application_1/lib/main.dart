import 'package:flutter/material.dart';
import 'package:flutter_application_1/Settings/settings_screen.dart';
import 'package:flutter_application_1/controllers/locale_controller.dart';
import 'package:flutter_application_1/controllers/product_controller.dart';
import 'package:flutter_application_1/controllers/purchase_order_controller.dart';
import 'package:flutter_application_1/controllers/purchase_request_controller.dart';
import 'package:flutter_application_1/controllers/supplier_controller.dart';

import 'package:flutter_application_1/controllers/user_controller.dart';
import 'package:flutter_application_1/controllers/role_controller.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/screens/Dashboard/dashboard_screen.dart' as dashboard;
import 'package:flutter_application_1/screens/Product/family_screen.dart';
// import 'package:flutter_application_1/screens/Product/product_screen.dart';
import 'package:flutter_application_1/screens/Purchase%20Request/purchase_request_list_screen.dart' as requestor_order;
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Supplier_registration_screen.dart';
import 'package:flutter_application_1/screens/Support%20Center/Home_Center_screen.dart';
import 'package:flutter_application_1/screens/profile/profile_user.dart';
import 'package:flutter_application_1/screens/users/password_screen.dart';
import 'package:flutter_application_1/screens/Role/Role_screen.dart';
import 'package:flutter_application_1/screens/users/users_List_screen.dart' as users_list;
import 'package:flutter_application_1/utils/router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';
import 'widgets/sidebar.dart';


void main() {
  runApp(
    const MyApp(),
    // MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: (_) => ThemeProvider()), 
    //     ChangeNotifierProvider(create: (_) => UserController()),
    //     ChangeNotifierProvider(create: (_) => RoleController()),
    //     ChangeNotifierProvider(create: (_) => SupplierController()),
    //     ChangeNotifierProvider(create: (context) => PurchaseRequestController(context)),
    //     ChangeNotifierProvider(create: (context) => PurchaseOrderController()),
    //     ChangeNotifierProvider(create: (context) => ProductController()),
    //     // ChangeNotifierProvider(create: (_) => ProductController()),
    //     ChangeNotifierProvider(create: (_) => LocaleProvider()),
    //   ],
    //   child: const MyApp(),
    // ),
  );
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => RoleController()),
        ChangeNotifierProvider(create: (_) => SupplierController()),
        ChangeNotifierProvider(create: (context) => PurchaseRequestController(context)),
        ChangeNotifierProvider(create: (context) => PurchaseOrderController()),
        ChangeNotifierProvider(create: (context) => ProductController()),
        // ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
        child: HomeScreen(),
        // MaterialApp.router(
        //   title: 'Purchase Requestor',
        //   debugShowCheckedModeBanner: false,
        //   theme: Provider.of<ThemeProvider>(context).currentTheme,
        //   localizationsDelegates: [
        //     AppLocalizations.delegate,
        //     GlobalMaterialLocalizations.delegate,
        //     GlobalWidgetsLocalizations.delegate,
        //     GlobalCupertinoLocalizations.delegate,
        //   ],
        //   supportedLocales: const [
        //     Locale('en'),
        //     Locale('fr'),
        //     Locale('ar'),
        //   ],
        //   locale: localeProvider.locale,
        //   routerConfig: router,
        // ),
      
    );
  }
}

class HomeScreen extends StatefulWidget{
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LocaleProvider localeProvider;
  @override
  void initState() {
     localeProvider = Provider.of<LocaleProvider>(context,listen: false);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Purchase Requestor',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      locale: localeProvider.locale,
      routerConfig: router, // <-- Utilisation du ShellRoute
    );
  }
}

class MainScreen extends StatefulWidget {
  final Widget? child; // Ajout du paramètre child

  const MainScreen({super.key, this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selected = 'Dashboard';
  late UserController userController;

  Widget _getPage({required int id}) {
    switch (_selected) {
      case 'Profile':
        return ProfilePageScreen(userId: id);
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
      case 'Settings':
        return const SettingsScreen();
      case 'Product':
        return const FamiliesPage();
      case 'Supplier':
        return const SupplierRegistrationPage();
      default:
        return ProfilePageScreen(userId: id);
    }
  }

  @override
  void initState() {
    userController = Provider.of<UserController>(context, listen: false);
    if (userController.currentUserId == null) {
      userController.login('admin', 'admin', context, null);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (MediaQuery.of(context).size.width < 600) ? AppBar() : null,
      drawer: (MediaQuery.of(context).size.width < 600)
          ? AppSidebar(
              selected: _selected,
              onItemSelected: (item) {
                setState(() {
                  _selected = item;
                });
                Navigator.pop(context);
              },
            )
          : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 600)
            SizedBox(
              width: 220,
              child: AppSidebar(
                selected: _selected,
                onItemSelected: (item) {
                  setState(() {
                    _selected = item;
                  });
                },
              ),
            ),
          Expanded(
            child: widget.child ?? _getPage(id: userController.currentUserId ?? 0),
          ),
        ],
      ),
    );
  }
}

