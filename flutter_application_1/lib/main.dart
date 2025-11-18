import 'package:flutter/material.dart';
import 'package:flutter_application_1/Settings/settings_screen.dart';
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

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');
  Locale get locale => _locale;
  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
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
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
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
      routerConfig: router,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selected = 'Dashboard';
  late UserController userController;

  Widget _getPage({required int id}) {
    switch (_selected) {
      // case 'Dashboard':
      //   return const dashboard.DashboardPage();
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
      // case 'Support centre':
      //   return const SupportCenterPage();
      case 'Settings':
        return const SettingsScreen();
      case 'Product':
        return const FamiliesPage();
         case 'Supplier':
        return const SupplierRegistrationPage();
      default:

        return  ProfilePageScreen(userId:id) ;
    }
  }

  @override
  void initState() {
    userController = Provider.of<UserController>(context, listen: false);

    //temporary fix to ensure user is logged in
    if(userController.currentUserId == null) {
      userController.login('admin', 'admin',context);
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (MediaQuery.of(context).size.width < 600)?AppBar(
        // title: Text(_selected),
      ):null,
      drawer: (MediaQuery.of(context).size.width < 600)?
          AppSidebar(
            selected: _selected,
            onItemSelected: (item) {
              setState(() {
                _selected = item;
              });
              Navigator.pop(context); // Close the drawer after selection
            },
          ):null,
      body: Row(
        children: [
          if(MediaQuery.of(context).size.width >= 600)
          AppSidebar(
            selected: _selected,
            onItemSelected: (item) {
              setState(() {
                _selected = item;
              });
            },
          ),
          Expanded(child: _getPage(id:userController.currentUserId!)),
        ],
      ),
    );
  }
}

