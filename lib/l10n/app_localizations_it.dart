// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get close => 'Chiudi';

  @override
  String get confirm => 'Conferma';

  @override
  String get name => 'Nome';

  @override
  String get n_a => 'N/D';

  @override
  String get save => 'Salva';

  @override
  String aboutScreenTitle(String trigger) {
    return 'Informazioni su Dopamine Tracker';
  }

  @override
  String aboutDescriptionTitle(String trigger) {
    return 'Dopamine Tracker';
  }

  @override
  String aboutDescriptionText(String trigger) {
    return 'Dopamine Tracker è un app open-source pensata per aiutarti a tracciare il tempo dall\'ultimo stimolo di dopamina e vedere i progressi fatti. Calcola gli stimoli evitati e i benefici per la salute in base alle tue abitudini. Questa app è un fork di https://codeberg.org/retiolus/ExHale che aggiunge la funzionalità calendario.';
  }

  @override
  String get aboutPrivacyTitle => 'Privacy e Open Source';

  @override
  String aboutPrivacyText(String trigger) {
    return 'Dopamine Tracker rispetta la tua privacy. Non traccia i tuoi dati e tutte le tue informazioni sono memorizzate localmente sul tuo dispositivo. Il codice sorgente è disponibile per la revisione, garantendo completa trasparenza.';
  }

  @override
  String get aboutLinksTitle => 'Collegamenti';

  @override
  String get aboutLinksViewSourceCode => 'Visualizza Codice Sorgente';

  @override
  String get aboutLinksReportAnIssue => 'Segnala un Problema';

  @override
  String get aboutCreditsTitle => 'Crediti';

  @override
  String get aboutCreditsText =>
      'L\'icona dell\'app è fornita da OpenMoji - un progetto emoji open-source. Grazie a OpenMoji per il loro fantastico lavoro!';

  @override
  String get aboutCreditsOpenMoji => 'Visita OpenMoji';

  @override
  String get aboutCreditsMyWebsite =>
      'Sito di Retiolus. Lo ringrazio infinitamente per la base di questa app.';

  @override
  String get aboutCreditsLiberapay => 'Supportami su Liberapay';

  @override
  String get configSnackBarValidNumber =>
      'Inserisci numeri validi prima di salvare.';

  @override
  String get configDialogEnableFriendsTitle => 'Abilita Amici';

  @override
  String get configDialogEnableFriendsDataText =>
      'Abilitare gli Amici richiede una connessione internet e condividerà l\'UID casuale del tuo dispositivo e le statistiche con il server: dopamine-tracker.retiolus.net.';

  @override
  String get configDialogEnableFriendsSourceCodeText =>
      'Il codice sorgente dell\'API è disponibile su:';

  @override
  String get configScreenTitle => 'Impostazioni';

  @override
  String get configOptionEnableFriendsText => 'Abilita Amici';

  @override
  String configOptionPacketsPerWeekText(String trigger) {
    return 'Media occorrenze settimanali';
  }

  @override
  String configOptionCigarettesPerPacketText(String trigger) {
    return 'Intensità media giornaliera';
  }

  @override
  String get configOptionCounterStartDateText => 'Data di Inizio Contatore';

  @override
  String get configOptionCounterStartDateSelectText => 'Seleziona una data';

  @override
  String get configOptionPriceHistoryText => 'Cronologia Miglioramenti';

  @override
  String get configOptionPriceHistoryPriceText => 'Intensità';

  @override
  String get configButtonAddPriceText => 'Aggiungi voce';

  @override
  String get configOptionThemeTitle => 'Tema';

  @override
  String get configOptionThemeLight => 'Chiaro';

  @override
  String get configOptionThemeDark => 'Scuro';

  @override
  String get configOptionThemeSystem => 'Sistema';

  @override
  String get configDataBackupTitle => 'Backup dati';

  @override
  String get configExportDataButton => 'Esporta dati (JSON)';

  @override
  String get configImportDataButton => 'Importa dati (JSON)';

  @override
  String get configExportSuccessMessage =>
      'Export pronto. Usa il menu condividi per salvare il file.';

  @override
  String get configExportErrorMessage => 'Export fallito. Riprova.';

  @override
  String get configImportSuccessMessage =>
      'Dati importati con successo. Riavvia l\'app se necessario.';

  @override
  String configImportErrorMessage(String trigger) {
    return 'File non valido o corrotto. Usa un file di backup JSON di Dopamine Tracker.';
  }

  @override
  String get configImportCancelled => 'Importazione annullata.';

  @override
  String get configDeleteAddictionTitle => 'Elimina dipendenza';

  @override
  String configDeleteAddictionButton(String trigger) {
    return 'Elimina tutti i dati per $trigger';
  }

  @override
  String configDeleteAddictionConfirmation(String trigger) {
    return 'Sei sicuro di voler eliminare tutti i dati per $trigger? Questa operazione non può essere annullata.';
  }

  @override
  String get configDeleteAddictionSuccess =>
      'Dipendenza eliminata con successo';

  @override
  String get friendsDialogUIDYourQRText => 'Il Tuo Codice QR';

  @override
  String get friendsDialogUIDNotAvailable => 'Nessun UID Utente disponibile';

  @override
  String get friendsDialogUIDNoUserUID => 'Nessun UID Utente';

  @override
  String get friendsDialogUIDCopiedToClipboard => 'Copiato negli appunti!';

  @override
  String get friendsDialogUIDCopyUID => 'Copia UID';

  @override
  String get friendsDialogAddFriendTitle => 'Aggiungi Amico';

  @override
  String get friendsDialogAddFriendNameText => 'Nome';

  @override
  String get friendsDialogAddFriendUIDText => 'UID';

  @override
  String get friendsSnackBarSyncSuccessfull =>
      'Dati sincronizzati con successo!';

  @override
  String get friendsSnackBarSyncFailed => 'Sincronizzazione dati fallita.';

  @override
  String get friendsScreenTitle => 'Amici';

  @override
  String get friendsNoFriendsText =>
      'Nessun amico ancora, aggiungine alcuni per vedere i loro progressi!';

  @override
  String friendsLastSmokedText(String lastSmoked, String trigger) {
    return 'Ultimo Reset: \n $lastSmoked';
  }

  @override
  String friendsCigarettesAvoidedText(String cigAvoided, String trigger) {
    return 'Stimoli evitati: \n $cigAvoided';
  }

  @override
  String friendsMoneySavedText(String moneySaved) {
    return 'Punti beneficio: \n $moneySaved';
  }

  @override
  String friendsLastAnnouncedText(String lastAnnounced) {
    return 'Ultimo Annuncio: \n $lastAnnounced';
  }

  @override
  String get friendsButtonShowUID => 'Mostra il Mio UID';

  @override
  String get friendsButtonShowUIDEnterUIDText => 'Inserisci UID Manualmente';

  @override
  String get friendsButtonAddFriend => 'Aggiungi Amico';

  @override
  String get friendsDialogEditFriendsNameTitle => 'Modifica Nome Amico';

  @override
  String health2DaysTitle(String trigger) {
    return '2 giorni dopo il reset';
  }

  @override
  String health2DaysText(String trigger) {
    return 'I recettori della dopamina iniziano a ri-sensibilizzarsi.';
  }

  @override
  String health3DaysTitle(String trigger) {
    return '3 giorni dopo il reset';
  }

  @override
  String get health3DaysText =>
      'La chiarezza mentale inizia a migliorare e la concentrazione aumenta.';

  @override
  String health7DaysTitle(String trigger) {
    return '7 giorni dopo il reset';
  }

  @override
  String get health7DaysText =>
      'La stabilità dell\'umore ritorna gradualmente.';

  @override
  String health2WeeksTitle(String trigger) {
    return '2 settimane dopo il reset';
  }

  @override
  String get health2WeeksText => 'La qualità del sonno migliora.';

  @override
  String health1MonthTitle(String trigger) {
    return '1 mese dopo il reset';
  }

  @override
  String get health1MonthText => 'La forza di volontà diventa più forte.';

  @override
  String health2MonthsTitle(String trigger) {
    return '2 mesi e mezzo dopo il reset';
  }

  @override
  String get health2MonthsText =>
      'Ritorna la gioia naturale nelle attività semplici.';

  @override
  String health3MonthsTitle(String trigger) {
    return '3 mesi dopo il reset';
  }

  @override
  String health3MonthsText(String trigger) {
    return 'I livelli di dopamina sono quasi completamente tornati alla normalità.';
  }

  @override
  String health1YearTitle(String trigger) {
    return '1 anno dopo il reset';
  }

  @override
  String get health1YearText =>
      'I percorsi cerebrali si sono significativamente ricollegati.';

  @override
  String health5YearsTitle(String trigger) {
    return '5 anni dopo il reset';
  }

  @override
  String get health5YearsText =>
      'Benefici cognitivi sostenuti a lungo termine.';

  @override
  String health15YearsTitle(String trigger) {
    return '10-15 anni dopo il reset';
  }

  @override
  String get health15YearsText => 'Massima resilienza mentale raggiunta.';

  @override
  String get homeMenuConfig => 'Impostazioni';

  @override
  String get homeMenuAbout => 'Informazioni';

  @override
  String get homeSnackBarFriendsDisabled =>
      'La schermata Amici è disabilitata nelle impostazioni.';

  @override
  String homeCigarettesAvoidedText(String cigarettesAvoided, String trigger) {
    return 'Stimoli evitati: \n $cigarettesAvoided';
  }

  @override
  String homeMoneySavedText(String moneySaved) {
    return 'Punteggio benefici: \n $moneySaved';
  }

  @override
  String get homeRestartProgressText => 'Riavvia Progresso';

  @override
  String get homeTagline => 'Traccia, registra e resta costante.';

  @override
  String homeSinceLastTitle(String trigger) {
    return 'Tempo dall\'ultimo reset';
  }

  @override
  String homeLastSmokedLabel(String date) {
    return 'Ultima registrazione: $date';
  }

  @override
  String get homeNotStartedYet => 'Non ancora iniziato';

  @override
  String get homeQuickActionsTitle => 'Azioni rapide';

  @override
  String homeSmokedTodayText(String cigarettesSmoked, Object trigger) {
    return 'Reset oggi: \n $cigarettesSmoked';
  }

  @override
  String homeHoursWithoutSmokingText(String hours, String trigger) {
    return 'Ore senza stimoli: \n $hours';
  }

  @override
  String homeLogCigaretteButton(String trigger) {
    return 'Registra un reset';
  }

  @override
  String get homeViewCalendarLogButton => 'Calendario';

  @override
  String homeSnackBarCigaretteLogged(String trigger) {
    return 'Reset registrato per oggi.';
  }

  @override
  String logScreenTitle(String trigger) {
    return 'Registro Dopamina';
  }

  @override
  String get logScreenToday => 'Oggi';

  @override
  String logScreenCigaretteSingular(String trigger) {
    return 'reset';
  }

  @override
  String logScreenCigarettePlural(String trigger) {
    return 'reset';
  }

  @override
  String get logScreenSelectedDayHeader => 'Giorno selezionato';

  @override
  String logScreenSelectedDayText(String count, String date, String trigger) {
    return '$count reset il $date';
  }

  @override
  String logScreenEmptyHint(String trigger) {
    return 'Nessuna voce ancora. Registra ogni reset per costruire il tuo calendario.';
  }

  @override
  String logScreenChartTitle(String trigger) {
    return 'Reset registrati';
  }

  @override
  String get logScreenRange7d => '7 giorni';

  @override
  String get logScreenRange14d => '14 giorni';

  @override
  String get logScreenRange30d => '1 mese';

  @override
  String get logScreenRange180d => '6 mesi';

  @override
  String get logScreenRange365d => '1 anno';

  @override
  String get logScreenChartEmpty => 'Nessun dato in questo intervallo ancora.';

  @override
  String get logEditTitle => 'Modifica voce';

  @override
  String logEditCountLabel(String date, String trigger) {
    return 'Reset il $date';
  }

  @override
  String get navigationFriendsDisabled =>
      'La funzione Amici è disabilitata. Abilitala nelle impostazioni.';

  @override
  String get navigationBarHome => 'Home';

  @override
  String get navigationBarHealthGoals => 'Traguardi';

  @override
  String get navigationBarCalendar => 'Calendario';

  @override
  String healthScreenNoCigarettesYetTitle(String trigger) {
    return 'Traguardi - Registra il tuo primo reset';
  }

  @override
  String get statsScreenTitle => 'Statistiche Salute';

  @override
  String get statsHeartRateTitle => 'Battito Cardiaco (Media 7gg)';

  @override
  String get statsStressTitle => 'Livello Stress / HRV (Media 7gg)';

  @override
  String get statsAuthorizeButton => 'Autorizza Accesso Salute';

  @override
  String get statsNoData => 'Nessun dato disponibile';

  @override
  String get statsLoading => 'Caricamento dati salute...';

  @override
  String get navigationBarDailyLog => 'Registro Giornaliero';

  @override
  String get dailyLogCategoryMood => 'Umore';

  @override
  String get dailyLogCategorySymptoms => 'Sintomi';

  @override
  String get dailyLogCategoryActivity => 'Attività fisica';

  @override
  String get dailyLogCategoryOther => 'Altro';

  @override
  String get dailyLogCategoryContraceptives => 'Contraccettivi orali';

  @override
  String get moodCalm => 'Calma';

  @override
  String get moodHappy => 'Felice';

  @override
  String get moodEnergetic => 'Energetica';

  @override
  String get moodLively => 'Vivace';

  @override
  String get moodMoodSwings => 'Sbalzi di umore';

  @override
  String get moodIrritated => 'Irritata';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodAnxious => 'Ansiosa';

  @override
  String get moodDepressed => 'Depressa';

  @override
  String get moodGuilt => 'Sensi di colpa';

  @override
  String get moodObsessiveThoughts => 'Pensieri ossessivi';

  @override
  String get moodLowEnergy => 'Poca energia';

  @override
  String get moodApathetic => 'Apatica';

  @override
  String get moodConfused => 'Confusa';

  @override
  String get moodSelfCritical => 'Molto autocritica';

  @override
  String get symptomFine => 'Va tutto bene';

  @override
  String get symptomCramps => 'Crampi';

  @override
  String get symptomBreastTension => 'Tensione al seno';

  @override
  String get symptomHeadache => 'Mal di testa';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomBackPain => 'Mal di schiena';

  @override
  String get symptomFatigue => 'Stanchezza';

  @override
  String get symptomCravings => 'Voglie';

  @override
  String get symptomInsomnia => 'Insonnia';

  @override
  String get activityNone => 'Nessuna attività';

  @override
  String get activityYoga => 'Yoga';

  @override
  String get activityGym => 'Palestra';

  @override
  String get activityAerobics => 'Aerobica e danza';

  @override
  String get activitySwimming => 'Nuoto';

  @override
  String get activityTeamSports => 'Sport di squadra';

  @override
  String get activityRunning => 'Corsa';

  @override
  String get activityCycling => 'Bicicletta';

  @override
  String get activityWalking => 'Camminare';

  @override
  String get otherTravel => 'Viaggio';

  @override
  String get otherStress => 'Stress';

  @override
  String get otherMeditation => 'Meditazione';

  @override
  String get otherJournaling => 'Scrivere un diario';

  @override
  String get otherKegel => 'Esercizi di Kegel';

  @override
  String get otherBreathing => 'Esercizi di respirazione';

  @override
  String get otherIllness => 'Malattia o trauma';

  @override
  String get otherAlcohol => 'Alcool';

  @override
  String get contraceptiveTaken => 'Preso';

  @override
  String get contraceptiveMissed => 'Dimenticato';

  @override
  String logDailyScore(String score) {
    return 'Punteggio Benessere Giornaliero: $score';
  }

  @override
  String logTodayHR(Object hr) {
    return 'Battito Cardiaco: $hr BPM';
  }

  @override
  String logTodayStress(Object stress) {
    return 'Stress (HRV): $stress ms';
  }
}
