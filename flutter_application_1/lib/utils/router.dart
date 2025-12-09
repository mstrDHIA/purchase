import 'package:flutter_application_1/Settings/settings_screen.dart';
import 'package:flutter_application_1/screens/Dashboard/dashboard_screen.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/Product/family_screen.dart';
import 'package:flutter_application_1/screens/Purchase Request/purchase_request_list_screen.dart';
import 'package:flutter_application_1/screens/Purchase order/pushase_order_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Supplier_registration_screen.dart';
import 'package:flutter_application_1/screens/Supplier/Add_supplier_screen.dart';
import 'package:flutter_application_1/screens/Supplier/View_supplier_screen.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/profile/profile_user.dart';
import 'package:flutter_application_1/screens/users/password_screen.dart';
import 'package:flutter_application_1/screens/Role/Role_screen.dart';
import 'package:flutter_application_1/screens/users/permission_screen.dart';
import 'package:flutter_application_1/screens/users/add_user_screen.dart';
import 'package:flutter_application_1/screens/users/users_List_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/user_controller.dart';


final GoRouter router = GoRouter(
  initialLocation: '/login',

  routes: [
    
    GoRoute(
      path: '/login',
      builder: (context, state) => SignInPage(),
    ),

    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);  
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => DashboardPage(),
        ),
         GoRoute(
          path: '/Profile',
          builder: (context, state) {
            final extra = state.extra;
            final userId = extra is int
                ? extra
                : Provider.of<UserController>(context, listen: false).currentUserId ?? 0;
            return ProfilePageScreen(userId: userId);
          },
        ),
         GoRoute(
          path: '/users_list',
          builder: (context, state) => UserListPage(),
        ),
        GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),

        GoRoute(
          path: '/purchase_requests',
          builder: (context, state) => PurchaseRequestPage(),
        ),

        GoRoute(
          path: '/purchase_orders', // <- nouvelle route (pluriel)
          builder: (context, state) => const PurchaseOrderPage(),
        ),

        GoRoute(
          path: '/supplier_registration',
          builder: (context, state) => SupplierRegistrationPage(),
        ),

        GoRoute(
          path: '/add_supplier',
          builder: (context, state) => AddSupplierPage(),
        ),

        GoRoute(
          path: '/view_supplier',
          builder: (context, state) => ViewSupplierPage(),
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
          path: '/families',
          builder: (context, state) => FamiliesPage(),
        ),

        GoRoute(
          path: '/add_user',
          builder: (context, state) => AddUserPage(),
        ),
      ],
    ),
  ],
);
