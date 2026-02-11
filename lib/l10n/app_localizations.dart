import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Vehicles Warranty Manager'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navWarranties.
  ///
  /// In en, this message translates to:
  /// **'Warranty Requests'**
  String get navWarranties;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardTitle;

  /// No description provided for @warrantiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Warranty Requests'**
  String get warrantiesTitle;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFile;

  /// No description provided for @summaryRequests.
  ///
  /// In en, this message translates to:
  /// **'Warranty requests'**
  String get summaryRequests;

  /// No description provided for @summaryPending.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get summaryPending;

  /// No description provided for @summaryInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get summaryInProgress;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @vin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get vin;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @issue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get issue;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @upgradeCategory.
  ///
  /// In en, this message translates to:
  /// **'Upgrade item'**
  String get upgradeCategory;

  /// No description provided for @upgradeCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Camera 360, Harman Kardon audio, Electric running board'**
  String get upgradeCategoryHint;

  /// No description provided for @upgradeDate.
  ///
  /// In en, this message translates to:
  /// **'Upgrade date'**
  String get upgradeDate;

  /// No description provided for @requestWarranty.
  ///
  /// In en, this message translates to:
  /// **'Request warranty'**
  String get requestWarranty;

  /// No description provided for @addRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get addRequest;

  /// No description provided for @attachmentLinks.
  ///
  /// In en, this message translates to:
  /// **'Attachment links (Google Drive)'**
  String get attachmentLinks;

  /// No description provided for @requester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get requester;

  /// No description provided for @viewOnly.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to update status.'**
  String get viewOnly;

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

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Remaining days before warranty expires
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(Object days);

  /// No description provided for @daysLeftZero.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get daysLeftZero;

  /// Days after warranty expiration
  ///
  /// In en, this message translates to:
  /// **'Expired {days} days'**
  String daysExpired(Object days);

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @emptyState.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Start by creating a record.'**
  String get emptyState;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This section is ready for integration with Firebase data.'**
  String get comingSoon;

  /// No description provided for @navCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navCatalog;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalogTitle;

  /// No description provided for @addModel.
  ///
  /// In en, this message translates to:
  /// **'Add model'**
  String get addModel;

  /// No description provided for @noModels.
  ///
  /// In en, this message translates to:
  /// **'No models yet.'**
  String get noModels;

  /// No description provided for @vinPrefixes.
  ///
  /// In en, this message translates to:
  /// **'VIN prefixes'**
  String get vinPrefixes;

  /// No description provided for @vinPrefixesHint.
  ///
  /// In en, this message translates to:
  /// **'Use commas or new lines to separate prefixes.'**
  String get vinPrefixesHint;

  /// No description provided for @vinPrefixesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No VIN prefixes set.'**
  String get vinPrefixesEmpty;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add upgrade item'**
  String get addCategory;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No upgrade items yet.'**
  String get noCategories;

  /// No description provided for @warrantyMonths.
  ///
  /// In en, this message translates to:
  /// **'Warranty (months)'**
  String get warrantyMonths;

  /// No description provided for @modelAutoDetected.
  ///
  /// In en, this message translates to:
  /// **'Auto-detected from VIN'**
  String get modelAutoDetected;

  /// No description provided for @modelNotFound.
  ///
  /// In en, this message translates to:
  /// **'Model not found for this VIN'**
  String get modelNotFound;

  /// No description provided for @selectModelForCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a model to see its upgrade items'**
  String get selectModelForCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select an upgrade item'**
  String get selectCategory;

  /// No description provided for @dealer.
  ///
  /// In en, this message translates to:
  /// **'Dealer'**
  String get dealer;

  /// No description provided for @selectDealer.
  ///
  /// In en, this message translates to:
  /// **'Select a dealer'**
  String get selectDealer;

  /// No description provided for @addDealer.
  ///
  /// In en, this message translates to:
  /// **'Add dealer'**
  String get addDealer;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @dealersTitle.
  ///
  /// In en, this message translates to:
  /// **'Dealers'**
  String get dealersTitle;

  /// No description provided for @noDealers.
  ///
  /// In en, this message translates to:
  /// **'No dealers yet.'**
  String get noDealers;

  /// No description provided for @editDealer.
  ///
  /// In en, this message translates to:
  /// **'Edit dealer'**
  String get editDealer;

  /// No description provided for @deleteDealer.
  ///
  /// In en, this message translates to:
  /// **'Delete dealer'**
  String get deleteDealer;

  /// No description provided for @deleteDealerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this dealer?'**
  String get deleteDealerConfirm;

  /// No description provided for @dealerInUse.
  ///
  /// In en, this message translates to:
  /// **'Dealer has warranty requests and cannot be deleted.'**
  String get dealerInUse;

  /// No description provided for @editModel.
  ///
  /// In en, this message translates to:
  /// **'Edit model'**
  String get editModel;

  /// No description provided for @deleteModel.
  ///
  /// In en, this message translates to:
  /// **'Delete model'**
  String get deleteModel;

  /// No description provided for @deleteModelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this model and its upgrade items?'**
  String get deleteModelConfirm;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit upgrade item'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete upgrade item'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this upgrade item?'**
  String get deleteCategoryConfirm;

  /// No description provided for @modelInUse.
  ///
  /// In en, this message translates to:
  /// **'Model has warranty requests and cannot be deleted.'**
  String get modelInUse;

  /// No description provided for @categoryInUse.
  ///
  /// In en, this message translates to:
  /// **'Upgrade item has warranty requests and cannot be deleted.'**
  String get categoryInUse;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
