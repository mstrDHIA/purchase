// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get purchaseRequests => 'Purchase Requests';

  @override
  String get addPR => 'Add Request';

  @override
  String get search => 'Search...';

  @override
  String get purchaseRequestsTable => 'Purchase Requests Table';

  @override
  String get id => 'ID';

  @override
  String get dateSubmitted => 'Date submitted';

  @override
  String get dueDate => 'Due date';

  @override
  String get priority => 'Priority';

  @override
  String get status => 'Status';

  @override
  String get actions => 'Actions';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get appearance => 'Appearance';

  @override
  String get aboutSecurity => 'About & Security';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get logout => 'Logout';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get doYouReallyWantToLogout => 'Do you really want to logout?';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String themeChanged(Object themeName) {
    return 'Theme changed to $themeName';
  }

  @override
  String languageChanged(Object language) {
    return 'Language changed to $language';
  }

  @override
  String get notificationsEnabled => 'Notifications enabled';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get refreshStats => 'Refresh stats';

  @override
  String get dashboardRefreshed => 'Dashboard refreshed!';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';
}
