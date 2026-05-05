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
  String aboutScreenTitle(String trigger) {
    return 'About $trigger Tracker';
  }

  @override
  String aboutDescriptionTitle(String trigger) {
    return '$trigger Tracker';
  }

  @override
  String aboutDescriptionText(String trigger) {
    return '$trigger Tracker is an open-source app designed to help you track the time since your last $trigger and see the progress you\'ve made. It calculates the ${trigger}s avoided and the potential health benefits based on your habits. Is a fork of https://codeberg.org/retiolus/ExHale who add a calendar feature.';
  }

  @override
  String get aboutPrivacyTitle => 'Privacy and Open Source';

  @override
  String aboutPrivacyText(String trigger) {
    return '$trigger Tracker respects your privacy. It does not track your data, and all your information is stored locally on your device. The source code is available for review, ensuring complete transparency.';
  }

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
  String configOptionPacketsPerWeekText(String trigger) {
    return '$trigger per portion';
  }

  @override
  String configOptionCigarettesPerPacketText(String trigger) {
    return 'Average daily $trigger';
  }

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
  String configImportErrorMessage(String trigger) {
    return 'Invalid or corrupted file. Use a valid $trigger Tracker backup JSON.';
  }

  @override
  String get configImportCancelled => 'Import cancelled.';

  @override
  String get configDeleteAddictionTitle => 'Delete addiction';

  @override
  String configDeleteAddictionButton(String trigger) {
    return 'Delete all data for $trigger';
  }

  @override
  String configDeleteAddictionConfirmation(String trigger) {
    return 'Are you sure you want to delete all data for $trigger? This action cannot be undone.';
  }

  @override
  String get configDeleteAddictionSuccess => 'Addiction deleted successfully';

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
  String friendsLastSmokedText(String lastSmoked, String trigger) {
    return 'Last $trigger: $lastSmoked';
  }

  @override
  String friendsCigarettesAvoidedText(String cigAvoided, String trigger) {
    return '${trigger}s avoided: $cigAvoided';
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
  String health2DaysTitle(String trigger) {
    return '2 days without using your ${trigger}s';
  }

  @override
  String health2DaysText(String trigger) {
    return '$trigger receptors begin to re-sensitize.';
  }

  @override
  String health3DaysTitle(String trigger) {
    return '3 days without using your ${trigger}s';
  }

  @override
  String get health3DaysText =>
      'Mental clarity begins to improve and focus increases.';

  @override
  String health7DaysTitle(String trigger) {
    return '7 days without using your ${trigger}s';
  }

  @override
  String get health7DaysText => 'Mood stability gradually returns.';

  @override
  String health2WeeksTitle(String trigger) {
    return '2 weeks without using your ${trigger}s';
  }

  @override
  String get health2WeeksText => 'Sleep quality improves.';

  @override
  String health1MonthTitle(String trigger) {
    return '1 month without using your ${trigger}s';
  }

  @override
  String get health1MonthText => 'Willpower becomes stronger.';

  @override
  String health2MonthsTitle(String trigger) {
    return '2.5 months without using your ${trigger}s';
  }

  @override
  String get health2MonthsText => 'Natural joy in simple activities returns.';

  @override
  String health3MonthsTitle(String trigger) {
    return '3 months without using your ${trigger}s';
  }

  @override
  String health3MonthsText(String trigger) {
    return '$trigger levels are mostly restored to baseline.';
  }

  @override
  String health1YearTitle(String trigger) {
    return '1 year without using your ${trigger}s';
  }

  @override
  String get health1YearText => 'Brain pathways have significantly rewired.';

  @override
  String health5YearsTitle(String trigger) {
    return '5 years without using your ${trigger}s';
  }

  @override
  String get health5YearsText =>
      'Sustained long-term cognitive health benefits.';

  @override
  String health15YearsTitle(String trigger) {
    return '10-15 without using your ${trigger}s';
  }

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
  String homeCigarettesAvoidedText(String cigarettesAvoided, String trigger) {
    return '${trigger}s avoided: \n $cigarettesAvoided';
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
  String homeSinceLastTitle(String trigger) {
    return 'Time since last used $trigger';
  }

  @override
  String homeLastSmokedLabel(String date) {
    return 'Last logged: $date';
  }

  @override
  String get homeNotStartedYet => 'Not started yet';

  @override
  String get homeQuickActionsTitle => 'Quick actions';

  @override
  String homeSmokedTodayText(String cigarettesSmoked, String trigger) {
    return '${trigger}s used today: \n $cigarettesSmoked';
  }

  @override
  String homeHoursWithoutSmokingText(String hours, String trigger) {
    return 'Hours without using $trigger: \n $hours';
  }

  @override
  String homeLogCigaretteButton(String trigger) {
    return 'Log a $trigger';
  }

  @override
  String get homeViewCalendarLogButton => 'View calendar log';

  @override
  String homeSnackBarCigaretteLogged(String trigger) {
    return '$trigger logged for today.';
  }

  @override
  String logScreenTitle(String trigger) {
    return '$trigger log';
  }

  @override
  String get logScreenToday => 'Today';

  @override
  String logScreenCigaretteSingular(String trigger) {
    return '$trigger';
  }

  @override
  String logScreenCigarettePlural(String trigger) {
    return '${trigger}s';
  }

  @override
  String get logScreenSelectedDayHeader => 'Selected Day';

  @override
  String logScreenSelectedDayText(String count, String date, String trigger) {
    return '$count ${trigger}s $date';
  }

  @override
  String logScreenEmptyHint(String trigger) {
    return 'No entries yet. Log each $trigger to build your calendar.';
  }

  @override
  String logScreenChartTitle(String trigger) {
    return '${trigger}s logged';
  }

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
  String logEditCountLabel(String date, String trigger) {
    return '${trigger}s $date';
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
  String healthScreenNoCigarettesYetTitle(String trigger) {
    return 'Goals - Log your first $trigger';
  }

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

  @override
  String logTodayHR(Object hr) {
    return 'Heart Rate: $hr BPM';
  }

  @override
  String logTodayStress(Object stress) {
    return 'Stress (HRV): $stress ms';
  }

  @override
  String get addCustomItemTitle => 'Add custom item';

  @override
  String get addCustomItemNameLabel => 'Name';

  @override
  String get addCustomItemCategoryLabel => 'Category';

  @override
  String get categoryMood => 'Mood';

  @override
  String get categoryActivity => 'Activity';

  @override
  String get categoryOther => 'Other';
}
