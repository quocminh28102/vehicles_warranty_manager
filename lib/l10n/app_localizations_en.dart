// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vehicles Warranty Manager';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navWarranties => 'Warranty Requests';

  @override
  String get navReports => 'Reports';

  @override
  String get dashboardTitle => 'Overview';

  @override
  String get warrantiesTitle => 'Warranty Requests';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get attachFile => 'Attach file';

  @override
  String get summaryRequests => 'Warranty requests';

  @override
  String get summaryPending => 'Pending requests';

  @override
  String get summaryInProgress => 'In progress';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get registerTitle => 'Create account';

  @override
  String get displayName => 'Display name';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get noAccount => 'No account? Register';

  @override
  String get haveAccount => 'Already have an account? Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get vin => 'VIN';

  @override
  String get model => 'Model';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get issue => 'Issue';

  @override
  String get description => 'Description';

  @override
  String get upgradeCategory => 'Upgrade item';

  @override
  String get upgradeCategoryHint =>
      'e.g. Camera 360, Harman Kardon audio, Electric running board';

  @override
  String get upgradeDate => 'Upgrade date';

  @override
  String get requestWarranty => 'Request warranty';

  @override
  String get addRequest => 'New request';

  @override
  String get attachmentLinks => 'Attachment links (Google Drive)';

  @override
  String get requester => 'Requester';

  @override
  String get viewOnly => 'You don\'t have permission to update status.';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get inProgress => 'In progress';

  @override
  String get done => 'Done';

  @override
  String daysLeft(Object days) {
    return '$days days left';
  }

  @override
  String get daysLeftZero => 'Expires today';

  @override
  String daysExpired(Object days) {
    return 'Expired $days days';
  }

  @override
  String get change => 'Change';

  @override
  String get emptyState => 'No data yet. Start by creating a record.';

  @override
  String get comingSoon =>
      'This section is ready for integration with Firebase data.';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get catalogTitle => 'Catalog';

  @override
  String get addModel => 'Add model';

  @override
  String get noModels => 'No models yet.';

  @override
  String get vinPrefixes => 'VIN prefixes';

  @override
  String get vinPrefixesHint => 'Use commas or new lines to separate prefixes.';

  @override
  String get vinPrefixesEmpty => 'No VIN prefixes set.';

  @override
  String get addCategory => 'Add upgrade item';

  @override
  String get noCategories => 'No upgrade items yet.';

  @override
  String get warrantyMonths => 'Warranty (months)';

  @override
  String get modelAutoDetected => 'Auto-detected from VIN';

  @override
  String get modelNotFound => 'Model not found for this VIN';

  @override
  String get selectModelForCategory =>
      'Select a model to see its upgrade items';

  @override
  String get selectCategory => 'Select an upgrade item';

  @override
  String get dealer => 'Dealer';

  @override
  String get selectDealer => 'Select a dealer';

  @override
  String get addDealer => 'Add dealer';

  @override
  String get months => 'months';

  @override
  String get dealersTitle => 'Dealers';

  @override
  String get noDealers => 'No dealers yet.';

  @override
  String get editDealer => 'Edit dealer';

  @override
  String get deleteDealer => 'Delete dealer';

  @override
  String get deleteDealerConfirm => 'Delete this dealer?';

  @override
  String get dealerInUse =>
      'Dealer has warranty requests and cannot be deleted.';

  @override
  String get editModel => 'Edit model';

  @override
  String get deleteModel => 'Delete model';

  @override
  String get deleteModelConfirm => 'Delete this model and its upgrade items?';

  @override
  String get editCategory => 'Edit upgrade item';

  @override
  String get deleteCategory => 'Delete upgrade item';

  @override
  String get deleteCategoryConfirm => 'Delete this upgrade item?';

  @override
  String get modelInUse => 'Model has warranty requests and cannot be deleted.';

  @override
  String get categoryInUse =>
      'Upgrade item has warranty requests and cannot be deleted.';
}
