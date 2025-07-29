import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Purchase%20Requestor/request_view.dart';
import 'package:flutter_application_1/screens/Purchase%20order/pushase_order.dart';
import 'package:flutter_application_1/screens/Support%20Center/Home_Center.dart';
import 'package:flutter_application_1/screens/users/Password.dart';
import 'package:flutter_application_1/screens/users/permission.dart';
import 'package:flutter_application_1/screens/users/profile_user.dart';
import 'package:flutter_application_1/screens/Dashboard/Dashboard.dart' as dashboard;
import 'package:flutter_application_1/screens/Home.dart' as home;
import 'package:flutter_application_1/screens/Purchase%20Requestor/Requestor_order.dart' as requestor_order;
import 'package:flutter_application_1/screens/Purchase%20Requestor/request_view.dart' as request_view;
import 'package:flutter_application_1/screens/users/Users_List.dart' as users_list;
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        return const PermissionPage();
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