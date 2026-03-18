// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get name => 'Name';

  @override
  String get n_a => 'N/A';

  @override
  String get save => 'Save';

  @override
  String get aboutScreenTitle => 'About Dopamine Tracker';

  @override
  String get aboutDescriptionTitle => 'Dopamine Tracker';

  @override
  String get aboutDescriptionText =>
      'Dopamine Tracker is an open-source app designed to help you track the time since your last dopamine trigger and see the progress you\'ve made. It calculates the dopamine triggers avoided and the potential health benefits based on your habits. Is a fork of https://codeberg.org/retiolus/ExHale who add a calendar feature.';

  @override
  String get aboutPrivacyTitle => 'Privacy and Open Source';

  @override
  String get aboutPrivacyText =>
      'Dopamine Tracker respects your privacy. It does not track your data, and all your information is stored locally on your device. The source code is available for review, ensuring complete transparency.';

  @override
  String get aboutLinksTitle => 'Links';

  @override
  String get aboutLinksViewSourceCode => 'View Source Code';

  @override
  String get aboutLinksReportAnIssue => 'Report an Issue';

  @override
  String get aboutCreditsTitle => 'Credits';

  @override
  String get aboutCreditsText =>
      'The app icon is provided by OpenMoji - an open-source emoji project. Thanks to OpenMoji for their amazing work!';

  @override
  String get aboutCreditsOpenMoji => ' ';

  @override
  String get aboutCreditsMyWebsite =>
      'Retiolus web site. Thanks they for the base of this app';

  @override
  String get aboutCreditsLiberapay => ' ';

  @override
  String get configSnackBarValidNumber =>
      'Please enter valid numbers before saving.';

  @override
  String get configDialogEnableFriendsTitle => 'Enable Friends';

  @override
  String get configDialogEnableFriendsDataText =>
      'Enabling the Friends requires an internet connection and will share your device\'s random UID and stats with the server: dopamine-tracker.retiolus.net.';

  @override
  String get configDialogEnableFriendsSourceCodeText =>
      'The source code of the API is available at:';

  @override
  String get configScreenTitle => 'Settings';

  @override
  String get configOptionEnableFriendsText => 'Enable Friends';

  @override
  String get configOptionPacketsPerWeekText => 'Average dopamine trigger used';

  @override
  String get configOptionCigarettesPerPacketText =>
      'Average daily dopamine trigger used';

  @override
  String get configOptionCounterStartDateText => 'Counter Start Date';

  @override
  String get configOptionCounterStartDateSelectText => 'Select a date';

  @override
  String get configOptionPriceHistoryText => 'Improvement History';

  @override
  String get configOptionPriceHistoryPriceText => 'Price';

  @override
  String get configButtonAddPriceText => 'Add Price';

  @override
  String get configOptionThemeTitle => 'Theme';

  @override
  String get configOptionThemeLight => 'Light';

  @override
  String get configOptionThemeDark => 'Dark';

  @override
  String get configOptionThemeSystem => 'System';

  @override
  String get configDataBackupTitle => 'Data backup';

  @override
  String get configExportDataButton => 'Export data (JSON)';

  @override
  String get configImportDataButton => 'Import data (JSON)';

  @override
  String get configExportSuccessMessage =>
      'Export ready. Use the share menu to save the file.';

  @override
  String get configExportErrorMessage => 'Export failed. Try again.';

  @override
  String get configImportSuccessMessage =>
      'Data imported successfully. Restart the app if needed.';

  @override
  String get configImportErrorMessage =>
      'Invalid or corrupted file. Use a valid Dopamine Tracker backup JSON.';

  @override
  String get configImportCancelled => 'Import cancelled.';

  @override
  String get friendsDialogUIDYourQRText => 'Your QR Code';

  @override
  String get friendsDialogUIDNotAvailable => 'No User UID available';

  @override
  String get friendsDialogUIDNoUserUID => 'No User UID';

  @override
  String get friendsDialogUIDCopiedToClipboard => 'Copied to clipboard!';

  @override
  String get friendsDialogUIDCopyUID => 'Copy UID';

  @override
  String get friendsDialogAddFriendTitle => 'Add Friend';

  @override
  String get friendsDialogAddFriendNameText => 'Name';

  @override
  String get friendsDialogAddFriendUIDText => 'UID';

  @override
  String get friendsSnackBarSyncSuccessfull => 'Data synced successfully!';

  @override
  String get friendsSnackBarSyncFailed => 'Failed to sync data.';

  @override
  String get friendsScreenTitle => 'Friends';

  @override
  String get friendsNoFriendsText =>
      'No friends yet, Add some to see their progress!';

  @override
  String friendsLastSmokedText(String lastSmoked) {
    return 'Last Trigger: $lastSmoked';
  }

  @override
  String friendsCigarettesAvoidedText(String cigAvoided) {
    return 'Triggers avoided: $cigAvoided';
  }

  @override
  String friendsMoneySavedText(String moneySaved) {
    return 'Money Saved: €$moneySaved';
  }

  @override
  String friendsLastAnnouncedText(String lastAnnounced) {
    return 'Last Announced: $lastAnnounced';
  }

  @override
  String get friendsButtonShowUID => 'Show my UID';

  @override
  String get friendsButtonShowUIDEnterUIDText => 'Enter UID Manually';

  @override
  String get friendsButtonAddFriend => 'Add Friend';

  @override
  String get friendsDialogEditFriendsNameTitle => 'Edit Friend\'s Name';

  @override
  String get health2DaysTitle => '2 days without using your dopamine triggers';

  @override
  String get health2DaysText => 'Dopamine receptors begin to re-sensitize.';

  @override
  String get health3DaysTitle => '3 days without using your dopamine triggers';

  @override
  String get health3DaysText =>
      'Mental clarity begins to improve and focus increases.';

  @override
  String get health7DaysTitle => '7 days without using your dopamine triggers';

  @override
  String get health7DaysText => 'Mood stability gradually returns.';

  @override
  String get health2WeeksTitle =>
      '2 weeks without using your dopamine triggers';

  @override
  String get health2WeeksText => 'Sleep quality improves.';

  @override
  String get health1MonthTitle =>
      '1 month without using your dopamine triggers';

  @override
  String get health1MonthText => 'Willpower becomes stronger.';

  @override
  String get health2MonthsTitle =>
      '2.5 months without using your dopamine triggers';

  @override
  String get health2MonthsText => 'Natural joy in simple activities returns.';

  @override
  String get health3MonthsTitle =>
      '3 months without using your dopamine triggers';

  @override
  String get health3MonthsText =>
      'Dopamine levels are mostly restored to baseline.';

  @override
  String get health1YearTitle => '1 year without using your dopamine triggers';

  @override
  String get health1YearText => 'Brain pathways have significantly rewired.';

  @override
  String get health5YearsTitle =>
      '5 years without using your dopamine triggers';

  @override
  String get health5YearsText =>
      'Sustained long-term cognitive health benefits.';

  @override
  String get health15YearsTitle => '10-15 without using your dopamine triggers';

  @override
  String get health15YearsText => 'Maximum mental resilience achieved.';

  @override
  String get homeMenuConfig => 'Settings';

  @override
  String get homeMenuAbout => 'About';

  @override
  String get homeSnackBarFriendsDisabled =>
      'Friends screen is disabled in settings.';

  @override
  String homeCigarettesAvoidedText(String cigarettesAvoided) {
    return 'Triggers avoided: \n $cigarettesAvoided';
  }

  @override
  String homeMoneySavedText(String moneySaved) {
    return 'Money saved: \n $moneySaved';
  }

  @override
  String get homeRestartProgressText => 'Restart Progress';

  @override
  String get homeTagline => 'Track, log, and stay accountable.';

  @override
  String get homeSinceLastTitle => 'Time since last used trigger';

  @override
  String homeLastSmokedLabel(String date) {
    return 'Last logged: $date';
  }

  @override
  String get homeNotStartedYet => 'Not started yet';

  @override
  String get homeQuickActionsTitle => 'Quick actions';

  @override
  String homeSmokedTodayText(String cigarettesSmoked) {
    return 'Dopamine Triggers used today: \n $cigarettesSmoked';
  }

  @override
  String homeHoursWithoutSmokingText(String hours) {
    return 'Hours without using dopamine trigger: \n $hours';
  }

  @override
  String get homeLogCigaretteButton => 'Log a dopamine trigger';

  @override
  String get homeViewCalendarLogButton => 'View calendar log';

  @override
  String get homeSnackBarCigaretteLogged =>
      'Dopamine Trigger logged for today.';

  @override
  String get logScreenTitle => 'Dopamine log';

  @override
  String get logScreenToday => 'Today';

  @override
  String get logScreenCigaretteSingular => 'trigger';

  @override
  String get logScreenCigarettePlural => 'triggers';

  @override
  String get logScreenSelectedDayHeader => 'Selected Day';

  @override
  String logScreenSelectedDayText(String count, String date) {
    return '$count triggers on $date';
  }

  @override
  String get logScreenEmptyHint =>
      'No entries yet. Log each dopamine trigger to build your calendar.';

  @override
  String get logScreenChartTitle => 'Dopamine riggers logged';

  @override
  String get logScreenRange7d => '7 days';

  @override
  String get logScreenRange14d => '14 days';

  @override
  String get logScreenRange30d => '1 month';

  @override
  String get logScreenRange180d => '6 months';

  @override
  String get logScreenRange365d => '1 year';

  @override
  String get logScreenChartEmpty => 'No data in this range yet.';

  @override
  String get logEditTitle => 'Edit entry';

  @override
  String logEditCountLabel(String date) {
    return 'Dopamine Triggers on $date';
  }

  @override
  String get navigationFriendsDisabled =>
      'Friends feature is disabled. Enable it in settings.';

  @override
  String get navigationBarHome => 'Home';

  @override
  String get navigationBarHealthGoals => 'Goals';

  @override
  String get navigationBarCalendar => 'Calendar';

  @override
  String get healthScreenNoCigarettesYetTitle =>
      'Goals - Log your first dopamine trigger';

  @override
  String get statsScreenTitle => 'Health Stats';

  @override
  String get statsHeartRateTitle => 'Heart Rate (7d average)';

  @override
  String get statsStressTitle => 'Stress Level / HRV (7d average)';

  @override
  String get statsAuthorizeButton => 'Authorize Health Access';

  @override
  String get statsNoData => 'No data available';

  @override
  String get statsLoading => 'Loading health data...';

  @override
  String get navigationBarDailyLog => 'Daily Log';

  @override
  String get dailyLogCategoryMood => 'Mood';

  @override
  String get dailyLogCategorySymptoms => 'Symptoms';

  @override
  String get dailyLogCategoryActivity => 'Physical Activity';

  @override
  String get dailyLogCategoryOther => 'Other';

  @override
  String get dailyLogCategoryContraceptives => 'Oral contraceptives';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodEnergetic => 'Energetic';

  @override
  String get moodLively => 'Lively';

  @override
  String get moodMoodSwings => 'Mood swings';

  @override
  String get moodIrritated => 'Irritated';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodDepressed => 'Depressed';

  @override
  String get moodGuilt => 'Guilt';

  @override
  String get moodObsessiveThoughts => 'Obsessive thoughts';

  @override
  String get moodLowEnergy => 'Low energy';

  @override
  String get moodApathetic => 'Apathetic';

  @override
  String get moodConfused => 'Confused';

  @override
  String get moodSelfCritical => 'Self-critical';

  @override
  String get symptomFine => 'All fine';

  @override
  String get symptomCramps => 'Cramps';

  @override
  String get symptomBreastTension => 'Breast tension';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomBackPain => 'Back pain';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomCravings => 'Cravings';

  @override
  String get symptomInsomnia => 'Insomnia';

  @override
  String get activityNone => 'No activity';

  @override
  String get activityYoga => 'Yoga';

  @override
  String get activityGym => 'Gym';

  @override
  String get activityAerobics => 'Aerobics and dance';

  @override
  String get activitySwimming => 'Swimming';

  @override
  String get activityTeamSports => 'Team sports';

  @override
  String get activityRunning => 'Running';

  @override
  String get activityCycling => 'Cycling';

  @override
  String get activityWalking => 'Walking';

  @override
  String get otherTravel => 'Travel';

  @override
  String get otherStress => 'Stress';

  @override
  String get otherMeditation => 'Meditation';

  @override
  String get otherJournaling => 'Journaling';

  @override
  String get otherKegel => 'Kegel exercises';

  @override
  String get otherBreathing => 'Breathing exercises';

  @override
  String get otherIllness => 'Illness or trauma';

  @override
  String get otherAlcohol => 'Alcohol';

  @override
  String get contraceptiveTaken => 'Taken';

  @override
  String get contraceptiveMissed => 'Missed';

  @override
  String logDailyScore(String score) {
    return 'Daily Wellness Score: $score';
  }
}
