// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get purchaseRequests => 'طلبات الشراء';

  @override
  String get addPR => 'إضافة طلب';

  @override
  String get search => 'بحث...';

  @override
  String get purchaseRequestsTable => 'جدول طلبات الشراء';

  @override
  String get id => 'المعرف';

  @override
  String get dateSubmitted => 'تاريخ التقديم';

  @override
  String get dueDate => 'تاريخ الاستحقاق';

  @override
  String get priority => 'الأولوية';

  @override
  String get status => 'الحالة';

  @override
  String get actions => 'إجراءات';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get appPreferences => 'تفضيلات التطبيق';

  @override
  String get appearance => 'المظهر';

  @override
  String get aboutSecurity => 'حول & الأمان';

  @override
  String get chooseTheme => 'اختر السمة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get about => 'حول';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get doYouReallyWantToLogout => 'هل تريد حقًا تسجيل الخروج؟';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي!';

  @override
  String themeChanged(Object themeName) {
    return 'تم تغيير السمة إلى $themeName';
  }

  @override
  String languageChanged(Object language) {
    return 'تم تغيير اللغة إلى $language';
  }

  @override
  String get notificationsEnabled => 'تم تفعيل الإشعارات';

  @override
  String get notificationsDisabled => 'تم تعطيل الإشعارات';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get refreshStats => 'تحديث الإحصائيات';

  @override
  String get dashboardRefreshed => 'تم تحديث لوحة التحكم!';

  @override
  String get periodDay => 'يوم';

  @override
  String get periodWeek => 'أسبوع';

  @override
  String get periodMonth => 'شهر';

  @override
  String get periodYear => 'سنة';
}
