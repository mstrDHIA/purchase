// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get userName => 'Jasser Boubaker';

  @override
  String get userEmail => 'jasser.boubaker@email.com';

  @override
  String get french => 'Français';

  @override
  String get english => 'Anglais';

  @override
  String get arabic => 'Arabe';

  @override
  String get purchaseRequests => 'Demandes d\'achat';

  @override
  String get addPR => 'Ajouter une demande';

  @override
  String get search => 'Rechercher...';

  @override
  String get purchaseRequestsTable => 'Table des demandes d\'achat';

  @override
  String get id => 'ID';

  @override
  String get dateSubmitted => 'Date de soumission';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get priority => 'Priorité';

  @override
  String get status => 'Statut';

  @override
  String get actions => 'Actions';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get appPreferences => 'Préférences de l\'application';

  @override
  String get appearance => 'Apparence';

  @override
  String get aboutSecurity => 'À propos & Sécurité';

  @override
  String get chooseTheme => 'Choisir le thème';

  @override
  String get logout => 'Déconnexion';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Langue';

  @override
  String get about => 'À propos';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get doYouReallyWantToLogout => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get profileUpdated => 'Profil mis à jour !';

  @override
  String themeChanged(Object themeName) {
    return 'Thème changé en $themeName';
  }

  @override
  String languageChanged(Object language) {
    return 'Langue changée en $language';
  }

  @override
  String get notificationsEnabled => 'Notifications activées';

  @override
  String get notificationsDisabled => 'Notifications désactivées';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get refreshStats => 'Rafraîchir les statistiques';

  @override
  String get dashboardRefreshed => 'Tableau de bord actualisé !';

  @override
  String get periodDay => 'Jour';

  @override
  String get periodWeek => 'Semaine';

  @override
  String get periodMonth => 'Mois';

  @override
  String get periodYear => 'Année';
}
