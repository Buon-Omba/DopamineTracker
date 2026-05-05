import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
    Locale('it')
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @n_a.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get n_a;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @aboutScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'About {trigger} Tracker'**
  String aboutScreenTitle(String trigger);

  /// No description provided for @aboutDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'{trigger} Tracker'**
  String aboutDescriptionTitle(String trigger);

  /// No description provided for @aboutDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'{trigger} Tracker is an open-source app designed to help you track the time since your last {trigger} and see the progress you\'ve made. It calculates the {trigger}s avoided and the potential health benefits based on your habits. Is a fork of https://codeberg.org/retiolus/ExHale who add a calendar feature.'**
  String aboutDescriptionText(String trigger);

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Open Source'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyText.
  ///
  /// In en, this message translates to:
  /// **'{trigger} Tracker respects your privacy. It does not track your data, and all your information is stored locally on your device. The source code is available for review, ensuring complete transparency.'**
  String aboutPrivacyText(String trigger);

  /// No description provided for @aboutLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get aboutLinksTitle;

  /// No description provided for @aboutLinksViewSourceCode.
  ///
  /// In en, this message translates to:
  /// **'View Source Code'**
  String get aboutLinksViewSourceCode;

  /// No description provided for @aboutLinksReportAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get aboutLinksReportAnIssue;

  /// No description provided for @aboutCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get aboutCreditsTitle;

  /// No description provided for @aboutCreditsText.
  ///
  /// In en, this message translates to:
  /// **'The app icon is provided by OpenMoji - an open-source emoji project. Thanks to OpenMoji for their amazing work!'**
  String get aboutCreditsText;

  /// No description provided for @aboutCreditsOpenMoji.
  ///
  /// In en, this message translates to:
  /// **' '**
  String get aboutCreditsOpenMoji;

  /// No description provided for @aboutCreditsMyWebsite.
  ///
  /// In en, this message translates to:
  /// **'Retiolus web site. Thanks they for the base of this app'**
  String get aboutCreditsMyWebsite;

  /// No description provided for @aboutCreditsLiberapay.
  ///
  /// In en, this message translates to:
  /// **' '**
  String get aboutCreditsLiberapay;

  /// No description provided for @configSnackBarValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid numbers before saving.'**
  String get configSnackBarValidNumber;

  /// No description provided for @configDialogEnableFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Friends'**
  String get configDialogEnableFriendsTitle;

  /// No description provided for @configDialogEnableFriendsDataText.
  ///
  /// In en, this message translates to:
  /// **'Enabling the Friends requires an internet connection and will share your device\'s random UID and stats with the server: dopamine-tracker.retiolus.net.'**
  String get configDialogEnableFriendsDataText;

  /// No description provided for @configDialogEnableFriendsSourceCodeText.
  ///
  /// In en, this message translates to:
  /// **'The source code of the API is available at:'**
  String get configDialogEnableFriendsSourceCodeText;

  /// No description provided for @configScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get configScreenTitle;

  /// No description provided for @configOptionEnableFriendsText.
  ///
  /// In en, this message translates to:
  /// **'Enable Friends'**
  String get configOptionEnableFriendsText;

  /// No description provided for @configOptionPacketsPerWeekText.
  ///
  /// In en, this message translates to:
  /// **'{trigger} per portion'**
  String configOptionPacketsPerWeekText(String trigger);

  /// No description provided for @configOptionCigarettesPerPacketText.
  ///
  /// In en, this message translates to:
  /// **'Average daily {trigger}'**
  String configOptionCigarettesPerPacketText(String trigger);

  /// No description provided for @configOptionCounterStartDateText.
  ///
  /// In en, this message translates to:
  /// **'Counter Start Date'**
  String get configOptionCounterStartDateText;

  /// No description provided for @configOptionCounterStartDateSelectText.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get configOptionCounterStartDateSelectText;

  /// No description provided for @configOptionPriceHistoryText.
  ///
  /// In en, this message translates to:
  /// **'Improvement History'**
  String get configOptionPriceHistoryText;

  /// No description provided for @configOptionPriceHistoryPriceText.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get configOptionPriceHistoryPriceText;

  /// No description provided for @configButtonAddPriceText.
  ///
  /// In en, this message translates to:
  /// **'Add Price'**
  String get configButtonAddPriceText;

  /// No description provided for @configOptionThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get configOptionThemeTitle;

  /// No description provided for @configOptionThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get configOptionThemeLight;

  /// No description provided for @configOptionThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get configOptionThemeDark;

  /// No description provided for @configOptionThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get configOptionThemeSystem;

  /// No description provided for @configDataBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Data backup'**
  String get configDataBackupTitle;

  /// No description provided for @configExportDataButton.
  ///
  /// In en, this message translates to:
  /// **'Export data (JSON)'**
  String get configExportDataButton;

  /// No description provided for @configImportDataButton.
  ///
  /// In en, this message translates to:
  /// **'Import data (JSON)'**
  String get configImportDataButton;

  /// No description provided for @configExportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Export ready. Use the share menu to save the file.'**
  String get configExportSuccessMessage;

  /// No description provided for @configExportErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Export failed. Try again.'**
  String get configExportErrorMessage;

  /// No description provided for @configImportSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully. Restart the app if needed.'**
  String get configImportSuccessMessage;

  /// No description provided for @configImportErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Invalid or corrupted file. Use a valid {trigger} Tracker backup JSON.'**
  String configImportErrorMessage(String trigger);

  /// No description provided for @configImportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Import cancelled.'**
  String get configImportCancelled;

  /// No description provided for @configDeleteAddictionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete addiction'**
  String get configDeleteAddictionTitle;

  /// No description provided for @configDeleteAddictionButton.
  ///
  /// In en, this message translates to:
  /// **'Delete all data for {trigger}'**
  String configDeleteAddictionButton(String trigger);

  /// No description provided for @configDeleteAddictionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all data for {trigger}? This action cannot be undone.'**
  String configDeleteAddictionConfirmation(String trigger);

  /// No description provided for @configDeleteAddictionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Addiction deleted successfully'**
  String get configDeleteAddictionSuccess;

  /// No description provided for @friendsDialogUIDYourQRText.
  ///
  /// In en, this message translates to:
  /// **'Your QR Code'**
  String get friendsDialogUIDYourQRText;

  /// No description provided for @friendsDialogUIDNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No User UID available'**
  String get friendsDialogUIDNotAvailable;

  /// No description provided for @friendsDialogUIDNoUserUID.
  ///
  /// In en, this message translates to:
  /// **'No User UID'**
  String get friendsDialogUIDNoUserUID;

  /// No description provided for @friendsDialogUIDCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get friendsDialogUIDCopiedToClipboard;

  /// No description provided for @friendsDialogUIDCopyUID.
  ///
  /// In en, this message translates to:
  /// **'Copy UID'**
  String get friendsDialogUIDCopyUID;

  /// No description provided for @friendsDialogAddFriendTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get friendsDialogAddFriendTitle;

  /// No description provided for @friendsDialogAddFriendNameText.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get friendsDialogAddFriendNameText;

  /// No description provided for @friendsDialogAddFriendUIDText.
  ///
  /// In en, this message translates to:
  /// **'UID'**
  String get friendsDialogAddFriendUIDText;

  /// No description provided for @friendsSnackBarSyncSuccessfull.
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully!'**
  String get friendsSnackBarSyncSuccessfull;

  /// No description provided for @friendsSnackBarSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync data.'**
  String get friendsSnackBarSyncFailed;

  /// No description provided for @friendsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsScreenTitle;

  /// No description provided for @friendsNoFriendsText.
  ///
  /// In en, this message translates to:
  /// **'No friends yet, Add some to see their progress!'**
  String get friendsNoFriendsText;

  /// No description provided for @friendsLastSmokedText.
  ///
  /// In en, this message translates to:
  /// **'Last {trigger}: {lastSmoked}'**
  String friendsLastSmokedText(String lastSmoked, String trigger);

  /// No description provided for @friendsCigarettesAvoidedText.
  ///
  /// In en, this message translates to:
  /// **'{trigger}s avoided: {cigAvoided}'**
  String friendsCigarettesAvoidedText(String cigAvoided, String trigger);

  /// No description provided for @friendsMoneySavedText.
  ///
  /// In en, this message translates to:
  /// **'Money Saved: €{moneySaved}'**
  String friendsMoneySavedText(String moneySaved);

  /// No description provided for @friendsLastAnnouncedText.
  ///
  /// In en, this message translates to:
  /// **'Last Announced: {lastAnnounced}'**
  String friendsLastAnnouncedText(String lastAnnounced);

  /// No description provided for @friendsButtonShowUID.
  ///
  /// In en, this message translates to:
  /// **'Show my UID'**
  String get friendsButtonShowUID;

  /// No description provided for @friendsButtonShowUIDEnterUIDText.
  ///
  /// In en, this message translates to:
  /// **'Enter UID Manually'**
  String get friendsButtonShowUIDEnterUIDText;

  /// No description provided for @friendsButtonAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get friendsButtonAddFriend;

  /// No description provided for @friendsDialogEditFriendsNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Friend\'s Name'**
  String get friendsDialogEditFriendsNameTitle;

  /// No description provided for @health2DaysTitle.
  ///
  /// In en, this message translates to:
  /// **'2 days without using your {trigger}s'**
  String health2DaysTitle(String trigger);

  /// No description provided for @health2DaysText.
  ///
  /// In en, this message translates to:
  /// **'{trigger} receptors begin to re-sensitize.'**
  String health2DaysText(String trigger);

  /// No description provided for @health3DaysTitle.
  ///
  /// In en, this message translates to:
  /// **'3 days without using your {trigger}s'**
  String health3DaysTitle(String trigger);

  /// No description provided for @health3DaysText.
  ///
  /// In en, this message translates to:
  /// **'Mental clarity begins to improve and focus increases.'**
  String get health3DaysText;

  /// No description provided for @health7DaysTitle.
  ///
  /// In en, this message translates to:
  /// **'7 days without using your {trigger}s'**
  String health7DaysTitle(String trigger);

  /// No description provided for @health7DaysText.
  ///
  /// In en, this message translates to:
  /// **'Mood stability gradually returns.'**
  String get health7DaysText;

  /// No description provided for @health2WeeksTitle.
  ///
  /// In en, this message translates to:
  /// **'2 weeks without using your {trigger}s'**
  String health2WeeksTitle(String trigger);

  /// No description provided for @health2WeeksText.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality improves.'**
  String get health2WeeksText;

  /// No description provided for @health1MonthTitle.
  ///
  /// In en, this message translates to:
  /// **'1 month without using your {trigger}s'**
  String health1MonthTitle(String trigger);

  /// No description provided for @health1MonthText.
  ///
  /// In en, this message translates to:
  /// **'Willpower becomes stronger.'**
  String get health1MonthText;

  /// No description provided for @health2MonthsTitle.
  ///
  /// In en, this message translates to:
  /// **'2.5 months without using your {trigger}s'**
  String health2MonthsTitle(String trigger);

  /// No description provided for @health2MonthsText.
  ///
  /// In en, this message translates to:
  /// **'Natural joy in simple activities returns.'**
  String get health2MonthsText;

  /// No description provided for @health3MonthsTitle.
  ///
  /// In en, this message translates to:
  /// **'3 months without using your {trigger}s'**
  String health3MonthsTitle(String trigger);

  /// No description provided for @health3MonthsText.
  ///
  /// In en, this message translates to:
  /// **'{trigger} levels are mostly restored to baseline.'**
  String health3MonthsText(String trigger);

  /// No description provided for @health1YearTitle.
  ///
  /// In en, this message translates to:
  /// **'1 year without using your {trigger}s'**
  String health1YearTitle(String trigger);

  /// No description provided for @health1YearText.
  ///
  /// In en, this message translates to:
  /// **'Brain pathways have significantly rewired.'**
  String get health1YearText;

  /// No description provided for @health5YearsTitle.
  ///
  /// In en, this message translates to:
  /// **'5 years without using your {trigger}s'**
  String health5YearsTitle(String trigger);

  /// No description provided for @health5YearsText.
  ///
  /// In en, this message translates to:
  /// **'Sustained long-term cognitive health benefits.'**
  String get health5YearsText;

  /// No description provided for @health15YearsTitle.
  ///
  /// In en, this message translates to:
  /// **'10-15 without using your {trigger}s'**
  String health15YearsTitle(String trigger);

  /// No description provided for @health15YearsText.
  ///
  /// In en, this message translates to:
  /// **'Maximum mental resilience achieved.'**
  String get health15YearsText;

  /// No description provided for @homeMenuConfig.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeMenuConfig;

  /// No description provided for @homeMenuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get homeMenuAbout;

  /// No description provided for @homeSnackBarFriendsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Friends screen is disabled in settings.'**
  String get homeSnackBarFriendsDisabled;

  /// No description provided for @homeCigarettesAvoidedText.
  ///
  /// In en, this message translates to:
  /// **'{trigger}s avoided: \n {cigarettesAvoided}'**
  String homeCigarettesAvoidedText(String cigarettesAvoided, String trigger);

  /// No description provided for @homeMoneySavedText.
  ///
  /// In en, this message translates to:
  /// **'Money saved: \n {moneySaved}'**
  String homeMoneySavedText(String moneySaved);

  /// No description provided for @homeRestartProgressText.
  ///
  /// In en, this message translates to:
  /// **'Restart Progress'**
  String get homeRestartProgressText;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Track, log, and stay accountable.'**
  String get homeTagline;

  /// No description provided for @homeSinceLastTitle.
  ///
  /// In en, this message translates to:
  /// **'Time since last used {trigger}'**
  String homeSinceLastTitle(String trigger);

  /// No description provided for @homeLastSmokedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last logged: {date}'**
  String homeLastSmokedLabel(String date);

  /// No description provided for @homeNotStartedYet.
  ///
  /// In en, this message translates to:
  /// **'Not started yet'**
  String get homeNotStartedYet;

  /// No description provided for @homeQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActionsTitle;

  /// No description provided for @homeSmokedTodayText.
  ///
  /// In en, this message translates to:
  /// **'{trigger}s used today: \n {cigarettesSmoked}'**
  String homeSmokedTodayText(String cigarettesSmoked, String trigger);

  /// No description provided for @homeHoursWithoutSmokingText.
  ///
  /// In en, this message translates to:
  /// **'Hours without using {trigger}: \n {hours}'**
  String homeHoursWithoutSmokingText(String hours, String trigger);

  /// No description provided for @homeLogCigaretteButton.
  ///
  /// In en, this message translates to:
  /// **'Log a {trigger}'**
  String homeLogCigaretteButton(String trigger);

  /// No description provided for @homeViewCalendarLogButton.
  ///
  /// In en, this message translates to:
  /// **'View calendar log'**
  String get homeViewCalendarLogButton;

  /// No description provided for @homeSnackBarCigaretteLogged.
  ///
  /// In en, this message translates to:
  /// **'{trigger} logged for today.'**
  String homeSnackBarCigaretteLogged(String trigger);

  /// No description provided for @logScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'{trigger} log'**
  String logScreenTitle(String trigger);

  /// No description provided for @logScreenToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get logScreenToday;

  /// No description provided for @logScreenCigaretteSingular.
  ///
  /// In en, this message translates to:
  /// **'{trigger}'**
  String logScreenCigaretteSingular(String trigger);

  /// No description provided for @logScreenCigarettePlural.
  ///
  /// In en, this message translates to:
  /// **'{trigger}s'**
  String logScreenCigarettePlural(String trigger);

  /// No description provided for @logScreenSelectedDayHeader.
  ///
  /// In en, this message translates to:
  /// **'Selected Day'**
  String get logScreenSelectedDayHeader;

  /// No description provided for @logScreenSelectedDayText.
  ///
  /// In en, this message translates to:
  /// **'{count} {trigger}s {date}'**
  String logScreenSelectedDayText(String count, String date, String trigger);

  /// No description provided for @logScreenEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No entries yet. Log each {trigger} to build your calendar.'**
  String logScreenEmptyHint(String trigger);

  /// No description provided for @logScreenChartTitle.
  ///
  /// In en, this message translates to:
  /// **'{trigger}s logged'**
  String logScreenChartTitle(String trigger);

  /// No description provided for @logScreenRange7d.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get logScreenRange7d;

  /// No description provided for @logScreenRange14d.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get logScreenRange14d;

  /// No description provided for @logScreenRange30d.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get logScreenRange30d;

  /// No description provided for @logScreenRange180d.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get logScreenRange180d;

  /// No description provided for @logScreenRange365d.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get logScreenRange365d;

  /// No description provided for @logScreenChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data in this range yet.'**
  String get logScreenChartEmpty;

  /// No description provided for @logEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get logEditTitle;

  /// No description provided for @logEditCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{trigger}s {date}'**
  String logEditCountLabel(String date, String trigger);

  /// No description provided for @navigationFriendsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Friends feature is disabled. Enable it in settings.'**
  String get navigationFriendsDisabled;

  /// No description provided for @navigationBarHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationBarHome;

  /// No description provided for @navigationBarHealthGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navigationBarHealthGoals;

  /// No description provided for @navigationBarCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navigationBarCalendar;

  /// No description provided for @healthScreenNoCigarettesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals - Log your first {trigger}'**
  String healthScreenNoCigarettesYetTitle(String trigger);

  /// No description provided for @statsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Stats'**
  String get statsScreenTitle;

  /// No description provided for @statsHeartRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate (7d average)'**
  String get statsHeartRateTitle;

  /// No description provided for @statsStressTitle.
  ///
  /// In en, this message translates to:
  /// **'Stress Level / HRV (7d average)'**
  String get statsStressTitle;

  /// No description provided for @statsAuthorizeButton.
  ///
  /// In en, this message translates to:
  /// **'Authorize Health Access'**
  String get statsAuthorizeButton;

  /// No description provided for @statsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get statsNoData;

  /// No description provided for @statsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading health data...'**
  String get statsLoading;

  /// No description provided for @navigationBarDailyLog.
  ///
  /// In en, this message translates to:
  /// **'Daily Log'**
  String get navigationBarDailyLog;

  /// No description provided for @dailyLogCategoryMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get dailyLogCategoryMood;

  /// No description provided for @dailyLogCategorySymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get dailyLogCategorySymptoms;

  /// No description provided for @dailyLogCategoryActivity.
  ///
  /// In en, this message translates to:
  /// **'Physical Activity'**
  String get dailyLogCategoryActivity;

  /// No description provided for @dailyLogCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dailyLogCategoryOther;

  /// No description provided for @dailyLogCategoryContraceptives.
  ///
  /// In en, this message translates to:
  /// **'Oral contraceptives'**
  String get dailyLogCategoryContraceptives;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodEnergetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get moodEnergetic;

  /// No description provided for @moodLively.
  ///
  /// In en, this message translates to:
  /// **'Lively'**
  String get moodLively;

  /// No description provided for @moodMoodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get moodMoodSwings;

  /// No description provided for @moodIrritated.
  ///
  /// In en, this message translates to:
  /// **'Irritated'**
  String get moodIrritated;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodDepressed.
  ///
  /// In en, this message translates to:
  /// **'Depressed'**
  String get moodDepressed;

  /// No description provided for @moodGuilt.
  ///
  /// In en, this message translates to:
  /// **'Guilt'**
  String get moodGuilt;

  /// No description provided for @moodObsessiveThoughts.
  ///
  /// In en, this message translates to:
  /// **'Obsessive thoughts'**
  String get moodObsessiveThoughts;

  /// No description provided for @moodLowEnergy.
  ///
  /// In en, this message translates to:
  /// **'Low energy'**
  String get moodLowEnergy;

  /// No description provided for @moodApathetic.
  ///
  /// In en, this message translates to:
  /// **'Apathetic'**
  String get moodApathetic;

  /// No description provided for @moodConfused.
  ///
  /// In en, this message translates to:
  /// **'Confused'**
  String get moodConfused;

  /// No description provided for @moodSelfCritical.
  ///
  /// In en, this message translates to:
  /// **'Self-critical'**
  String get moodSelfCritical;

  /// No description provided for @symptomFine.
  ///
  /// In en, this message translates to:
  /// **'All fine'**
  String get symptomFine;

  /// No description provided for @symptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// No description provided for @symptomBreastTension.
  ///
  /// In en, this message translates to:
  /// **'Breast tension'**
  String get symptomBreastTension;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomAcne;

  /// No description provided for @symptomBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get symptomBackPain;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get symptomCravings;

  /// No description provided for @symptomInsomnia.
  ///
  /// In en, this message translates to:
  /// **'Insomnia'**
  String get symptomInsomnia;

  /// No description provided for @activityNone.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get activityNone;

  /// No description provided for @activityYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get activityYoga;

  /// No description provided for @activityGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get activityGym;

  /// No description provided for @activityAerobics.
  ///
  /// In en, this message translates to:
  /// **'Aerobics and dance'**
  String get activityAerobics;

  /// No description provided for @activitySwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get activitySwimming;

  /// No description provided for @activityTeamSports.
  ///
  /// In en, this message translates to:
  /// **'Team sports'**
  String get activityTeamSports;

  /// No description provided for @activityRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get activityRunning;

  /// No description provided for @activityCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get activityCycling;

  /// No description provided for @activityWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get activityWalking;

  /// No description provided for @otherTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get otherTravel;

  /// No description provided for @otherStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get otherStress;

  /// No description provided for @otherMeditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get otherMeditation;

  /// No description provided for @otherJournaling.
  ///
  /// In en, this message translates to:
  /// **'Journaling'**
  String get otherJournaling;

  /// No description provided for @otherKegel.
  ///
  /// In en, this message translates to:
  /// **'Kegel exercises'**
  String get otherKegel;

  /// No description provided for @otherBreathing.
  ///
  /// In en, this message translates to:
  /// **'Breathing exercises'**
  String get otherBreathing;

  /// No description provided for @otherIllness.
  ///
  /// In en, this message translates to:
  /// **'Illness or trauma'**
  String get otherIllness;

  /// No description provided for @otherAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get otherAlcohol;

  /// No description provided for @contraceptiveTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get contraceptiveTaken;

  /// No description provided for @contraceptiveMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get contraceptiveMissed;

  /// No description provided for @logDailyScore.
  ///
  /// In en, this message translates to:
  /// **'Daily Wellness Score: {score}'**
  String logDailyScore(String score);

  /// No description provided for @logTodayHR.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate: {hr} BPM'**
  String logTodayHR(Object hr);

  /// No description provided for @logTodayStress.
  ///
  /// In en, this message translates to:
  /// **'Stress (HRV): {stress} ms'**
  String logTodayStress(Object stress);

  /// No description provided for @addCustomItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add custom item'**
  String get addCustomItemTitle;

  /// No description provided for @addCustomItemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addCustomItemNameLabel;

  /// No description provided for @addCustomItemCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addCustomItemCategoryLabel;

  /// No description provided for @categoryMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get categoryMood;

  /// No description provided for @categoryActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get categoryActivity;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
