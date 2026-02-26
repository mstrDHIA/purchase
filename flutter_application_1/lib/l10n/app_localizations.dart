import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Jasser Boubaker'**
  String get userName;

  /// No description provided for @userEmail.
  ///
  /// In en, this message translates to:
  /// **'jasser.boubaker@email.com'**
  String get userEmail;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @purchaseRequests.
  ///
  /// In en, this message translates to:
  /// **'Purchase Requests'**
  String get purchaseRequests;

  /// No description provided for @addPR.
  ///
  /// In en, this message translates to:
  /// **'Add Request'**
  String get addPR;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @purchaseRequestsTable.
  ///
  /// In en, this message translates to:
  /// **'Purchase Requests Table'**
  String get purchaseRequestsTable;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @dateSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Date submitted'**
  String get dateSubmitted;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get dueDate;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @aboutSecurity.
  ///
  /// In en, this message translates to:
  /// **'About & Security'**
  String get aboutSecurity;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @doYouReallyWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to logout?'**
  String get doYouReallyWantToLogout;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// No description provided for @themeChanged.
  ///
  /// In en, this message translates to:
  /// **'Theme changed to {themeName}'**
  String themeChanged(Object themeName);

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(Object language);

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get notificationsEnabled;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @refreshStats.
  ///
  /// In en, this message translates to:
  /// **'Refresh stats'**
  String get refreshStats;

  /// No description provided for @dashboardRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Dashboard refreshed!'**
  String get dashboardRefreshed;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodYear;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @purchaseRequest.
  ///
  /// In en, this message translates to:
  /// **'Purchase Request'**
  String get purchaseRequest;

  /// No description provided for @editPurchaseRequest.
  ///
  /// In en, this message translates to:
  /// **'Edit Purchase Request'**
  String get editPurchaseRequest;

  /// No description provided for @confirmCancelUnsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel? Unsaved changes will be lost.'**
  String get confirmCancelUnsavedChanges;

  /// No description provided for @purchaseOrder.
  ///
  /// In en, this message translates to:
  /// **'Purchase Order'**
  String get purchaseOrder;

  /// No description provided for @rolesAccess.
  ///
  /// In en, this message translates to:
  /// **'Roles and access'**
  String get rolesAccess;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @supplierRegistration.
  ///
  /// In en, this message translates to:
  /// **'Supplier Registration'**
  String get supplierRegistration;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @usersList.
  ///
  /// In en, this message translates to:
  /// **'User\'s List'**
  String get usersList;

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// No description provided for @userAdded.
  ///
  /// In en, this message translates to:
  /// **'User added successfully.'**
  String get userAdded;

  /// No description provided for @searchUser.
  ///
  /// In en, this message translates to:
  /// **'Search user name, email ...'**
  String get searchUser;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @userPermission.
  ///
  /// In en, this message translates to:
  /// **'User Permission'**
  String get userPermission;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @loadProfileError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load user profile.'**
  String get loadProfileError;

  /// No description provided for @userUpdated.
  ///
  /// In en, this message translates to:
  /// **'User updated successfully.'**
  String get userUpdated;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get filterStatus;

  /// No description provided for @filterPermission.
  ///
  /// In en, this message translates to:
  /// **'Filter by User Permission'**
  String get filterPermission;

  /// No description provided for @operational.
  ///
  /// In en, this message translates to:
  /// **'Operational'**
  String get operational;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get confirmDeleteUser;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget password?'**
  String get forgetPassword;

  /// No description provided for @loginBtn.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginBtn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @supplierDetails.
  ///
  /// In en, this message translates to:
  /// **'Supplier Details'**
  String get supplierDetails;

  /// No description provided for @productFamilies.
  ///
  /// In en, this message translates to:
  /// **'Product Families'**
  String get productFamilies;

  /// No description provided for @subfamilies.
  ///
  /// In en, this message translates to:
  /// **'Subfamilies'**
  String get subfamilies;

  /// No description provided for @addNewBrand.
  ///
  /// In en, this message translates to:
  /// **'Add New Brand'**
  String get addNewBrand;

  /// No description provided for @createNewRole.
  ///
  /// In en, this message translates to:
  /// **'Create new role'**
  String get createNewRole;

  /// No description provided for @addBtn.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addBtn;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @submitBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitBtn;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @nextBtn.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextBtn;

  /// No description provided for @prevBtn.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get prevBtn;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'Zip code'**
  String get zipCode;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Role'**
  String get selectRole;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// No description provided for @roleField.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleField;

  /// No description provided for @descriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionField;

  /// No description provided for @reenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPasswordField.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordField;

  /// No description provided for @confirmPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordField;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get enterValidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long.'**
  String get passwordMinLength;

  /// No description provided for @includeUppercase.
  ///
  /// In en, this message translates to:
  /// **'Include at least one uppercase letter.'**
  String get includeUppercase;

  /// No description provided for @includeLowercase.
  ///
  /// In en, this message translates to:
  /// **'Include at least one lowercase letter.'**
  String get includeLowercase;

  /// No description provided for @includeNumber.
  ///
  /// In en, this message translates to:
  /// **'Include at least one number.'**
  String get includeNumber;

  /// No description provided for @includeSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'Include at least one special character.'**
  String get includeSpecialChar;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters, include upper, lower, and a number.'**
  String get passwordRequirements;

  /// No description provided for @fieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldsRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @allFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get allFieldsRequired;

  /// No description provided for @branchName.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get branchName;

  /// No description provided for @categoryField.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryField;

  /// No description provided for @phoneField.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneField;

  /// No description provided for @matriculeFiscale.
  ///
  /// In en, this message translates to:
  /// **'Matricule fiscale'**
  String get matriculeFiscale;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @searchProduct.
  ///
  /// In en, this message translates to:
  /// **'Search Product name...'**
  String get searchProduct;

  /// No description provided for @filterByPriority.
  ///
  /// In en, this message translates to:
  /// **'Filter by Priority'**
  String get filterByPriority;

  /// No description provided for @filterBySubmissionDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Submission Date'**
  String get filterBySubmissionDate;

  /// No description provided for @filterByDueDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Due Date'**
  String get filterByDueDate;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show Archived'**
  String get showArchived;

  /// No description provided for @hideArchived.
  ///
  /// In en, this message translates to:
  /// **'Hide Archived'**
  String get hideArchived;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @supplierCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Supplier created successfully!'**
  String get supplierCreatedSuccessfully;

  /// No description provided for @supplierUpdated.
  ///
  /// In en, this message translates to:
  /// **'Supplier updated'**
  String get supplierUpdated;

  /// No description provided for @supplierDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Supplier deleted successfully'**
  String get supplierDeletedSuccessfully;

  /// No description provided for @familyUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Family updated successfully!'**
  String get familyUpdatedSuccessfully;

  /// No description provided for @familyCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Family created successfully!'**
  String get familyCreatedSuccessfully;

  /// No description provided for @familyDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Family deleted successfully'**
  String get familyDeletedSuccessfully;

  /// No description provided for @subfamilyCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subfamily created successfully!'**
  String get subfamilyCreatedSuccessfully;

  /// No description provided for @subfamilyDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Subfamily deleted successfully'**
  String get subfamilyDeletedSuccessfully;

  /// No description provided for @permissionsSaved.
  ///
  /// In en, this message translates to:
  /// **'Permissions saved'**
  String get permissionsSaved;

  /// No description provided for @purchaseOrderCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Purchase Order created successfully!'**
  String get purchaseOrderCreatedSuccessfully;

  /// No description provided for @deleteSupplier.
  ///
  /// In en, this message translates to:
  /// **'Delete Supplier'**
  String get deleteSupplier;

  /// No description provided for @deleteFamily.
  ///
  /// In en, this message translates to:
  /// **'Delete Family'**
  String get deleteFamily;

  /// No description provided for @deleteSubfamily.
  ///
  /// In en, this message translates to:
  /// **'Delete Subfamily'**
  String get deleteSubfamily;

  /// No description provided for @addNewSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add New Supplier'**
  String get addNewSupplier;

  /// No description provided for @addFamily.
  ///
  /// In en, this message translates to:
  /// **'Add Family'**
  String get addFamily;

  /// No description provided for @editFamily.
  ///
  /// In en, this message translates to:
  /// **'Edit Family'**
  String get editFamily;

  /// No description provided for @addSubfamily.
  ///
  /// In en, this message translates to:
  /// **'Add Subfamily'**
  String get addSubfamily;

  /// No description provided for @editSubfamily.
  ///
  /// In en, this message translates to:
  /// **'Edit Subfamily'**
  String get editSubfamily;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @createAccountToStart.
  ///
  /// In en, this message translates to:
  /// **'Create YOUR ACCOUNT TO START'**
  String get createAccountToStart;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and services'**
  String get agreeToTerms;

  /// No description provided for @copyrightInfo.
  ///
  /// In en, this message translates to:
  /// **'© 2025 MyApp Dashboard'**
  String get copyrightInfo;

  /// No description provided for @mainPage.
  ///
  /// In en, this message translates to:
  /// **'Main Page'**
  String get mainPage;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @welcomeToMainPage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Main Page!'**
  String get welcomeToMainPage;

  /// No description provided for @userInformationForm.
  ///
  /// In en, this message translates to:
  /// **'User Information Form'**
  String get userInformationForm;

  /// No description provided for @openFileToSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Open File to Select Image'**
  String get openFileToSelectImage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @rejectReasons.
  ///
  /// In en, this message translates to:
  /// **'Reject Reasons'**
  String get rejectReasons;

  /// No description provided for @searchRejectReasons.
  ///
  /// In en, this message translates to:
  /// **'Search reject reasons...'**
  String get searchRejectReasons;

  /// No description provided for @addRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Add Reject Reason'**
  String get addRejectReason;

  /// No description provided for @editRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Edit Reject Reason'**
  String get editRejectReason;

  /// No description provided for @rejectReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get rejectReasonLabel;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @rejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter description...'**
  String get rejectReasonHint;

  /// No description provided for @deleteRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Delete Reason'**
  String get deleteRejectReason;

  /// No description provided for @deleteRejectReasonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reason?'**
  String get deleteRejectReasonConfirm;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @noRejectReasons.
  ///
  /// In en, this message translates to:
  /// **'No reject reasons'**
  String get noRejectReasons;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get updateProfile;

  /// No description provided for @addNewRole.
  ///
  /// In en, this message translates to:
  /// **'Add New Role'**
  String get addNewRole;

  /// No description provided for @editRole.
  ///
  /// In en, this message translates to:
  /// **'Edit Role'**
  String get editRole;

  /// No description provided for @roleName.
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get roleName;

  /// No description provided for @roleDescription.
  ///
  /// In en, this message translates to:
  /// **'Role Description'**
  String get roleDescription;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'(No name)'**
  String get noName;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'(No description)'**
  String get noDescription;

  /// No description provided for @invalidRoleId.
  ///
  /// In en, this message translates to:
  /// **'Invalid role ID'**
  String get invalidRoleId;

  /// No description provided for @errorLoadingRole.
  ///
  /// In en, this message translates to:
  /// **'Error loading role'**
  String get errorLoadingRole;

  /// No description provided for @roleCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Role created successfully!'**
  String get roleCreatedSuccessfully;

  /// No description provided for @failedToCreateRole.
  ///
  /// In en, this message translates to:
  /// **'Failed to create role!'**
  String get failedToCreateRole;

  /// No description provided for @deleteRole.
  ///
  /// In en, this message translates to:
  /// **'Delete Role'**
  String get deleteRole;

  /// No description provided for @confirmDeleteRole.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this role?'**
  String get confirmDeleteRole;

  /// No description provided for @editSupplier.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get editSupplier;

  /// No description provided for @supplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier name'**
  String get supplierName;

  /// No description provided for @supplierEmail.
  ///
  /// In en, this message translates to:
  /// **'Supplier Email'**
  String get supplierEmail;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @matricule.
  ///
  /// In en, this message translates to:
  /// **'Matricule'**
  String get matricule;

  /// No description provided for @cin.
  ///
  /// In en, this message translates to:
  /// **'CIN'**
  String get cin;

  /// No description provided for @supplierUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Supplier updated successfully!'**
  String get supplierUpdatedSuccessfully;

  /// No description provided for @confirmDeleteSupplier.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this supplier?'**
  String get confirmDeleteSupplier;

  /// No description provided for @addNewProduct.
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get addNewProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @productCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully!'**
  String get productCreatedSuccessfully;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully!'**
  String get productUpdatedSuccessfully;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @confirmDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get confirmDeleteProduct;

  /// No description provided for @addTicket.
  ///
  /// In en, this message translates to:
  /// **'Add Ticket'**
  String get addTicket;

  /// No description provided for @editTicket.
  ///
  /// In en, this message translates to:
  /// **'Edit Ticket'**
  String get editTicket;

  /// No description provided for @ticketTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket Title'**
  String get ticketTitle;

  /// No description provided for @ticketDescription.
  ///
  /// In en, this message translates to:
  /// **'Ticket Description'**
  String get ticketDescription;

  /// No description provided for @ticketStatus.
  ///
  /// In en, this message translates to:
  /// **'Ticket Status'**
  String get ticketStatus;

  /// No description provided for @ticketPriority.
  ///
  /// In en, this message translates to:
  /// **'Ticket Priority'**
  String get ticketPriority;

  /// No description provided for @ticketCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket created successfully!'**
  String get ticketCreatedSuccessfully;

  /// No description provided for @ticketUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket updated successfully!'**
  String get ticketUpdatedSuccessfully;

  /// No description provided for @ticketDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket deleted successfully'**
  String get ticketDeletedSuccessfully;

  /// No description provided for @deleteTicket.
  ///
  /// In en, this message translates to:
  /// **'Delete Ticket'**
  String get deleteTicket;

  /// No description provided for @confirmDeleteTicket.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ticket?'**
  String get confirmDeleteTicket;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get updatedAt;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByName;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @pleaseSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a file'**
  String get pleaseSelectFile;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmail;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to logout?'**
  String get confirmLogout;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update your password'**
  String get updatePassword;

  /// No description provided for @forYourSecurity.
  ///
  /// In en, this message translates to:
  /// **'For your security, please use a strong password that you do not use elsewhere.'**
  String get forYourSecurity;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @updatePasswordBtn.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePasswordBtn;

  /// No description provided for @failedToLoadFamilies.
  ///
  /// In en, this message translates to:
  /// **'Failed to load families: {error}'**
  String failedToLoadFamilies(Object error);

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDate;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @failedToCreateFamily.
  ///
  /// In en, this message translates to:
  /// **'Failed to create family: {error}'**
  String failedToCreateFamily(Object error);

  /// No description provided for @failedToUpdateFamily.
  ///
  /// In en, this message translates to:
  /// **'Failed to update family: {error}'**
  String failedToUpdateFamily(Object error);

  /// No description provided for @confirmDeleteFamily.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} and all its subfamilies?'**
  String confirmDeleteFamily(Object name);

  /// No description provided for @failedToDeleteFamily.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete family: {error}'**
  String failedToDeleteFamily(Object error);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @familyLabel.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familyLabel;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(Object current, Object total);

  /// No description provided for @allFamilies.
  ///
  /// In en, this message translates to:
  /// **'All Families'**
  String get allFamilies;

  /// No description provided for @allSubfamilies.
  ///
  /// In en, this message translates to:
  /// **'All Subfamilies'**
  String get allSubfamilies;

  /// No description provided for @selectFamilyFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a family first'**
  String get selectFamilyFirst;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(Object count);

  /// No description provided for @failedWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedWithError(Object error);

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @confirmDeleteSelectedRequests.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} requests? This cannot be undone.'**
  String confirmDeleteSelectedRequests(Object count);

  /// No description provided for @deletedRequests.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} requests'**
  String deletedRequests(Object count);

  /// No description provided for @failedToDeleteRequests.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDeleteRequests(Object error);

  /// No description provided for @accessDeniedAdmin.
  ///
  /// In en, this message translates to:
  /// **'Access denied — admins only'**
  String get accessDeniedAdmin;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersionLabel(Object version);

  /// No description provided for @purchaseOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase Order'**
  String get purchaseOrderTitle;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String idLabel(Object id);

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdLabel(Object date);

  /// No description provided for @updatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String updatedLabel(Object date);

  /// No description provided for @supplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplierLabel;

  /// No description provided for @supplierDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Supplier Delivery Date'**
  String get supplierDeliveryDate;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority: {priority}'**
  String priorityLabel(Object priority);

  /// No description provided for @archivedRequests.
  ///
  /// In en, this message translates to:
  /// **'Archived {count} requests'**
  String archivedRequests(Object count);

  /// No description provided for @unarchivedRequests.
  ///
  /// In en, this message translates to:
  /// **'Unarchived {count} requests'**
  String unarchivedRequests(Object count);

  /// No description provided for @archiveSelected.
  ///
  /// In en, this message translates to:
  /// **'Archive Selected'**
  String get archiveSelected;

  /// No description provided for @unarchiveSelected.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Selected'**
  String get unarchiveSelected;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get createdBy;

  /// No description provided for @validatedBy.
  ///
  /// In en, this message translates to:
  /// **'Validated by'**
  String get validatedBy;

  /// No description provided for @filterByFamily.
  ///
  /// In en, this message translates to:
  /// **'Filter by Family'**
  String get filterByFamily;

  /// No description provided for @filterBySubfamily.
  ///
  /// In en, this message translates to:
  /// **'Filter by Subfamily'**
  String get filterBySubfamily;

  /// No description provided for @purchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Purchase Orders'**
  String get purchaseOrders;

  /// No description provided for @archivePurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Archive Purchase Orders'**
  String get archivePurchaseOrders;

  /// No description provided for @unarchivePurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Purchase Orders'**
  String get unarchivePurchaseOrders;

  /// No description provided for @confirmArchivePurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to {action} {count} selected purchase orders?'**
  String confirmArchivePurchaseOrders(Object action, Object count);

  /// No description provided for @archivedPurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'{count} purchase orders archived'**
  String archivedPurchaseOrders(Object count);

  /// No description provided for @unarchivedPurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'{count} purchase orders unarchived'**
  String unarchivedPurchaseOrders(Object count);

  /// No description provided for @deletePurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Delete Purchase Orders'**
  String get deletePurchaseOrders;

  /// No description provided for @confirmDeletePurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} selected purchase orders? This cannot be undone.'**
  String confirmDeletePurchaseOrders(Object count);

  /// No description provided for @deletedPurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'{count} purchase orders deleted'**
  String deletedPurchaseOrders(Object count);

  /// No description provided for @failedToDeletePurchaseOrders.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDeletePurchaseOrders(Object error);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @deletePurchaseOrder.
  ///
  /// In en, this message translates to:
  /// **'Delete Purchase Order'**
  String get deletePurchaseOrder;

  /// No description provided for @purchaseOrderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Purchase order {id} deleted'**
  String purchaseOrderDeleted(Object id);

  /// No description provided for @failedToDeletePurchaseOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete purchase order: {error}'**
  String failedToDeletePurchaseOrder(Object error);

  /// No description provided for @archivedPurchaseOrder.
  ///
  /// In en, this message translates to:
  /// **'Purchase order {id} archived'**
  String archivedPurchaseOrder(Object id);

  /// No description provided for @unarchivedPurchaseOrder.
  ///
  /// In en, this message translates to:
  /// **'Purchase order {id} unarchived'**
  String unarchivedPurchaseOrder(Object id);

  /// No description provided for @failedToArchivePurchaseOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive purchase order: {error}'**
  String failedToArchivePurchaseOrder(Object error);

  /// No description provided for @viewPurchaseOrder.
  ///
  /// In en, this message translates to:
  /// **'View Purchase Order {id}'**
  String viewPurchaseOrder(Object id);

  /// No description provided for @purchaseOrdersTable.
  ///
  /// In en, this message translates to:
  /// **'Purchase Orders Table'**
  String get purchaseOrdersTable;

  /// No description provided for @idShort.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idShort;

  /// No description provided for @priorityShort.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityShort;

  /// No description provided for @invalidSupplierDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid supplier delivery date.'**
  String get invalidSupplierDeliveryDate;

  /// No description provided for @refuseReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Refuse Reason'**
  String get refuseReasonLabel;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @subfamilyLabel.
  ///
  /// In en, this message translates to:
  /// **'Subfamily'**
  String get subfamilyLabel;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total price of approved PO'**
  String get totalPrice;

  /// No description provided for @purchaseOrderApproved.
  ///
  /// In en, this message translates to:
  /// **'Order approved!'**
  String get purchaseOrderApproved;

  /// No description provided for @purchaseOrderRejected.
  ///
  /// In en, this message translates to:
  /// **'Order rejected!'**
  String get purchaseOrderRejected;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @invalidDueDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid due date.'**
  String get invalidDueDate;

  /// No description provided for @removeProductLine.
  ///
  /// In en, this message translates to:
  /// **'Remove product line'**
  String get removeProductLine;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount}'**
  String totalLabel(Object amount);

  /// No description provided for @pleaseFillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields.'**
  String get pleaseFillAllRequiredFields;

  /// No description provided for @editPurchaseOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit Purchase Order'**
  String get editPurchaseOrder;

  /// No description provided for @purchaseOrderSaved.
  ///
  /// In en, this message translates to:
  /// **'Purchase order saved!'**
  String get purchaseOrderSaved;

  /// No description provided for @purchaseRequestUpdated.
  ///
  /// In en, this message translates to:
  /// **'Purchase request updated successfully!'**
  String get purchaseRequestUpdated;

  /// No description provided for @poDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'PO Dashboard'**
  String get poDashboardTitle;

  /// No description provided for @selectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get selectSupplier;

  /// No description provided for @allSuppliers.
  ///
  /// In en, this message translates to:
  /// **'All Suppliers'**
  String get allSuppliers;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @requester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get requester;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From Date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To Date'**
  String get toDate;

  /// No description provided for @fromPrefix.
  ///
  /// In en, this message translates to:
  /// **'From: '**
  String get fromPrefix;

  /// No description provided for @toPrefix.
  ///
  /// In en, this message translates to:
  /// **'To: '**
  String get toPrefix;

  /// No description provided for @selectFromDate.
  ///
  /// In en, this message translates to:
  /// **'Select From Date'**
  String get selectFromDate;

  /// No description provided for @selectToDate.
  ///
  /// In en, this message translates to:
  /// **'Select To Date'**
  String get selectToDate;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @exportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Export {count} orders?'**
  String exportConfirmTitle(Object count);

  /// No description provided for @exportConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'This will export the {count} purchase orders currently shown on the dashboard.'**
  String exportConfirmContent(Object count);

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @noOrdersToExportForCurrentFilters.
  ///
  /// In en, this message translates to:
  /// **'No orders to export for current filters'**
  String get noOrdersToExportForCurrentFilters;

  /// No description provided for @noOrdersToExportForSelectedRange.
  ///
  /// In en, this message translates to:
  /// **'No orders to export for the selected range'**
  String get noOrdersToExportForSelectedRange;

  /// No description provided for @downloadedFile.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {fileName}'**
  String downloadedFile(Object fileName);

  /// No description provided for @exportedToPath.
  ///
  /// In en, this message translates to:
  /// **'Exported to {path}'**
  String exportedToPath(Object path);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(Object error);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @createPurchaseOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Purchase Order?'**
  String get createPurchaseOrderTitle;

  /// No description provided for @createPurchaseOrderContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to create a new purchase order from this purchase request?'**
  String get createPurchaseOrderContent;

  /// No description provided for @createPO.
  ///
  /// In en, this message translates to:
  /// **'Create PO'**
  String get createPO;

  /// No description provided for @purchaseRequestMarkedConverted.
  ///
  /// In en, this message translates to:
  /// **'Purchase Request marked as converted!'**
  String get purchaseRequestMarkedConverted;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get noProducts;

  /// No description provided for @supplierDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Supplier'**
  String get supplierDeleteTitle;

  /// No description provided for @supplierDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" ?'**
  String supplierDeleteConfirm(Object name);

  /// No description provided for @supplierCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get supplierCancel;

  /// No description provided for @supplierDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get supplierDelete;

  /// No description provided for @errorDeletingSupplier.
  ///
  /// In en, this message translates to:
  /// **'Error deleting supplier: {error}'**
  String errorDeletingSupplier(Object error);

  /// No description provided for @supplierAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Supplier'**
  String get supplierAddNew;

  /// No description provided for @supplierRequired.
  ///
  /// In en, this message translates to:
  /// **'is required'**
  String get supplierRequired;

  /// No description provided for @supplierContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact Email'**
  String get supplierContactEmail;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @supplierPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get supplierPhoneNumber;

  /// No description provided for @supplierPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number (min 6 digits)'**
  String get supplierPhoneHint;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneRequired;

  /// No description provided for @phoneMinDigits.
  ///
  /// In en, this message translates to:
  /// **'Phone must be at least 6 digits'**
  String get phoneMinDigits;

  /// No description provided for @phoneDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Phone must contain only digits'**
  String get phoneDigitsOnly;

  /// No description provided for @supplierMatricule.
  ///
  /// In en, this message translates to:
  /// **'Matricule'**
  String get supplierMatricule;

  /// No description provided for @supplierCIN.
  ///
  /// In en, this message translates to:
  /// **'CIN'**
  String get supplierCIN;

  /// No description provided for @supplierAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get supplierAddress;

  /// No description provided for @supplierCodeFournisseur.
  ///
  /// In en, this message translates to:
  /// **'Code fournisseur'**
  String get supplierCodeFournisseur;

  /// No description provided for @supplierGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get supplierGroupName;

  /// No description provided for @supplierContactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get supplierContactName;

  /// No description provided for @supplierAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Supplier already exists'**
  String get supplierAlreadyExists;

  /// No description provided for @supplierError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String supplierError(Object error);

  /// No description provided for @supplierSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get supplierSave;

  /// No description provided for @supplierAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get supplierAdd;

  /// No description provided for @supplierEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get supplierEdit;

  /// No description provided for @supplierWithNameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Supplier with this name already exists'**
  String get supplierWithNameAlreadyExists;

  /// No description provided for @supplierEitherMatriculeOrCINRequired.
  ///
  /// In en, this message translates to:
  /// **'Either Matricule or CIN is required'**
  String get supplierEitherMatriculeOrCINRequired;

  /// No description provided for @supplierDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Supplier Details'**
  String get supplierDetailsTitle;

  /// No description provided for @supplierApprovalStatus.
  ///
  /// In en, this message translates to:
  /// **'Approval Status'**
  String get supplierApprovalStatus;

  /// No description provided for @supplierID.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get supplierID;

  /// No description provided for @supplierBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get supplierBack;

  /// No description provided for @supplierReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get supplierReject;

  /// No description provided for @supplierApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get supplierApprove;

  /// No description provided for @supplierStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Supplier status updated to {status}'**
  String supplierStatusUpdated(Object status);

  /// No description provided for @selectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Select Department'**
  String get selectDepartment;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @copyName.
  ///
  /// In en, this message translates to:
  /// **'Copy name'**
  String get copyName;

  /// No description provided for @nameCopied.
  ///
  /// In en, this message translates to:
  /// **'Name copied'**
  String get nameCopied;

  /// No description provided for @copyDescription.
  ///
  /// In en, this message translates to:
  /// **'Copy description'**
  String get copyDescription;

  /// No description provided for @descriptionCopied.
  ///
  /// In en, this message translates to:
  /// **'Description copied'**
  String get descriptionCopied;

  /// No description provided for @addDepartment.
  ///
  /// In en, this message translates to:
  /// **'Add Department'**
  String get addDepartment;

  /// No description provided for @editDepartment.
  ///
  /// In en, this message translates to:
  /// **'Edit Department'**
  String get editDepartment;

  /// No description provided for @departmentName.
  ///
  /// In en, this message translates to:
  /// **'Department name'**
  String get departmentName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @departmentAdded.
  ///
  /// In en, this message translates to:
  /// **'Department added'**
  String get departmentAdded;

  /// No description provided for @departmentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Department updated'**
  String get departmentUpdated;

  /// No description provided for @deleteDepartment.
  ///
  /// In en, this message translates to:
  /// **'Delete Department'**
  String get deleteDepartment;

  /// No description provided for @confirmDeleteDepartment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteDepartment(Object name);

  /// No description provided for @deletedDepartment.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\"'**
  String deletedDepartment(Object name);

  /// No description provided for @noDepartmentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No departments available'**
  String get noDepartmentsAvailable;

  /// No description provided for @noDepartmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No departments found'**
  String get noDepartmentsFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @searchDepartments.
  ///
  /// In en, this message translates to:
  /// **'Search departments...'**
  String get searchDepartments;

  /// No description provided for @resultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} result(s) found'**
  String resultsFound(Object count);

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String selected(Object name);

  /// No description provided for @supplierRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Supplier Registration'**
  String get supplierRegistrationTitle;

  /// No description provided for @supplierSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search supplier name, email, phone, matricule, cin ...'**
  String get supplierSearchHint;

  /// No description provided for @supplierReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get supplierReset;

  /// No description provided for @supplierRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get supplierRetry;

  /// No description provided for @supplierMatriculeFiscale.
  ///
  /// In en, this message translates to:
  /// **'Matricule fiscale'**
  String get supplierMatriculeFiscale;

  /// No description provided for @supplierCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code fournisseur'**
  String get supplierCodeLabel;

  /// No description provided for @supplierStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get supplierStatusLabel;

  /// No description provided for @supplierView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get supplierView;

  /// No description provided for @supplierPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String supplierPageOf(Object current, Object total);

  /// No description provided for @transformed.
  ///
  /// In en, this message translates to:
  /// **'Transformed'**
  String get transformed;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get edited;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @poStatistics.
  ///
  /// In en, this message translates to:
  /// **'PO Statistics'**
  String get poStatistics;

  /// No description provided for @rejectionStatistics.
  ///
  /// In en, this message translates to:
  /// **'Rejection Statistics'**
  String get rejectionStatistics;

  /// No description provided for @poTotalsByDept.
  ///
  /// In en, this message translates to:
  /// **'PO Totals by Department'**
  String get poTotalsByDept;

  /// No description provided for @poTotalsByRequester.
  ///
  /// In en, this message translates to:
  /// **'PO Totals by Requester'**
  String get poTotalsByRequester;

  /// No description provided for @poTotalsByCategory.
  ///
  /// In en, this message translates to:
  /// **'PO Totals by Category'**
  String get poTotalsByCategory;

  /// No description provided for @poTotalsBySubcategory.
  ///
  /// In en, this message translates to:
  /// **'PO Totals by Subcategory'**
  String get poTotalsBySubcategory;

  /// No description provided for @poTotalsBySupplier.
  ///
  /// In en, this message translates to:
  /// **'PO Totals by Supplier'**
  String get poTotalsBySupplier;

  /// No description provided for @rejectionRateByRequester.
  ///
  /// In en, this message translates to:
  /// **'Rejection Rate by Requester'**
  String get rejectionRateByRequester;

  /// No description provided for @rejectionRate.
  ///
  /// In en, this message translates to:
  /// **'Rejection Rate (%)'**
  String get rejectionRate;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @exportCSV.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCSV;

  /// No description provided for @filtersApplied.
  ///
  /// In en, this message translates to:
  /// **'Filters applied'**
  String get filtersApplied;

  /// No description provided for @generatingCSV.
  ///
  /// In en, this message translates to:
  /// **'Generating CSV...'**
  String get generatingCSV;

  /// No description provided for @exportedTo.
  ///
  /// In en, this message translates to:
  /// **'Exported to'**
  String get exportedTo;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategory;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @userNotLoggedInError.
  ///
  /// In en, this message translates to:
  /// **'User is not logged in'**
  String get userNotLoggedInError;

  /// No description provided for @pleaseAddAtLeastOneProduct.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one product'**
  String get pleaseAddAtLeastOneProduct;

  /// No description provided for @eachProductMustHaveNameAndQuantity.
  ///
  /// In en, this message translates to:
  /// **'Each product must have a name and quantity'**
  String get eachProductMustHaveNameAndQuantity;

  /// No description provided for @requestSavedAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Request saved. Add another?'**
  String get requestSavedAddAnother;

  /// No description provided for @excludePoWithoutDepartment.
  ///
  /// In en, this message translates to:
  /// **'Exclude PO without Department'**
  String get excludePoWithoutDepartment;

  /// No description provided for @includePoWithoutDepartment.
  ///
  /// In en, this message translates to:
  /// **'Include PO without Department'**
  String get includePoWithoutDepartment;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
