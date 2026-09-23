// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class ForkLocalizationsEl extends ForkLocalizations {
  ForkLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Αλλαγή persona';

  @override
  String get chatAttachmentPanelVoice => 'Φωνή';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Κουμπί γρήγορης εναλλαγής';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Αντικατάσταση του κουμπιού φωνητικού μηνύματος στο πεδίο μηνύματος με κουμπί γρήγορης εναλλαγής για ταχύτερη πλοήγηση';

  @override
  String get personaSelectTitle => 'Επιλογή persona';

  @override
  String get personaSettingsHeader => 'Ρυθμίσεις persona';

  @override
  String get personaManageAction => 'Διαχείριση';

  @override
  String get personaSearchPlaceholder =>
      'Αναζήτηση persona, ετικετών, αντωνυμιών...';

  @override
  String get personaModeOff => 'Ανενεργό';

  @override
  String get personaModeManual => 'Μη αυτόματα';

  @override
  String get personaModeLast => 'Τελευταία χρήση';

  @override
  String get personaModeOffDescription =>
      'Αποστέλλεται από τον κύριο λογαριασμό εκτός εάν πληκτρολογηθούν ετικέτες persona.';

  @override
  String get personaModeManualDescription =>
      'Αποστέλλεται πάντα ως η επιλεγμένη persona μέχρι να αλλάξει.';

  @override
  String get personaModeLastDescription =>
      'Μεταβαίνει αυτόματα στην persona που χρησιμοποιήθηκε στο τελευταίο σας μήνυμα.';

  @override
  String get personaRecentHeader => 'ΠΡΟΣΦΑΤΕΣ PERSONA';

  @override
  String personaAllHeader(int count) {
    return 'ΟΛΕΣ ΟΙ PERSONA ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'ΑΠΟΤΕΛΕΣΜΑΤΑ ΑΝΑΖΗΤΗΣΗΣ ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Κύριος λογαριασμός (Προεπιλογή)';

  @override
  String get personaEmptyState =>
      'Δεν έχουν ρυθμιστεί ακόμη persona. Δημιουργήστε μία μέσω της Διαχείρισης persona.';

  @override
  String get personaEmptySearch => 'Δεν βρέθηκαν αντίστοιχες persona.';

  @override
  String get personaEditTitle => 'Επεξεργασία persona';

  @override
  String get personaCreateTitle => 'Δημιουργία persona';

  @override
  String get personaDisplayNameLabel => 'Όνομα εμφάνισης';

  @override
  String get personaPronounsLabel => 'Αντωνυμίες';

  @override
  String get personaPronounsHint => 'π.χ. αυτοί/αυτές';

  @override
  String get personaBioLabel => 'Βιογραφικό / Σχετικά με εμένα';

  @override
  String get personaBioHint => 'Πείτε στους άλλους για αυτήν την persona...';

  @override
  String get personaUpdatedToast => 'Η persona ενημερώθηκε';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Αποτυχία ενημέρωσης persona: $error';
  }

  @override
  String get personaSectionTitle => 'Persona';

  @override
  String get personaDisplayNameHint => 'Όνομα persona';

  @override
  String personaSendingAsTag(String name) {
    return 'Αποστολή ως $name (Ταιριάζει με ετικέτα)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Αποστολή ως $name (Κλειδωμένο)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Αποστολή ως @$username';
  }

  @override
  String get personaMainAccount => 'Κύριος λογαριασμός';

  @override
  String get personaEditPersona => 'Επεξεργασία persona';

  @override
  String get userSettingsNavPersonas => 'Persona';

  @override
  String get personaSettingsDescription =>
      'Ρυθμίστε τη λειτουργία ενεργής persona, την προσαρμοσμένη ετικέτα εμφάνισης και διαχειριστείτε μεμονωμένες persona.';

  @override
  String get personaDisplayTagSection => 'Ετικέτα εμφάνισης';

  @override
  String get personaDisplayTagDescription =>
      'Η ετικέτα εμφάνισης θα εμφανίζεται δίπλα σε όλα τα ονόματα persona στα μηνύματα. Αν δεν οριστεί ετικέτα εμφάνισης, θα εμφανίζεται η εικόνα προφίλ του λογαριασμού σας.';

  @override
  String get personaDisplayTagLabel => 'Κείμενο ετικέτας εμφάνισης';

  @override
  String get personaDisplayTagHint => 'π.χ. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Εικονίδιο ετικέτας εμφάνισης';

  @override
  String get personaUploadTagIcon => 'Ανέβασμα εικονιδίου';

  @override
  String get personaChangeTagIcon => 'Αλλαγή εικονιδίου';

  @override
  String get personaRemoveTagIcon => 'Αφαίρεση εικονιδίου';

  @override
  String get personaChatPreviewTitle => 'Προεπισκόπηση συνομιλίας';

  @override
  String get personaChatPreviewSampleMessage =>
      'Γεια σας! Αυτή είναι μια προεπισκόπηση του πώς φαίνονται τα μηνύματα με την ετικέτα εμφάνισης και την ενεργή persona σας.';

  @override
  String get personaListTitle => 'Διαμορφωμένες persona';

  @override
  String get personaAddButton => 'Προσθήκη persona';

  @override
  String get personaActiveBadge => 'Ενεργό';

  @override
  String get personaMakeActive => 'Ορισμός ως ενεργό';

  @override
  String get personaDeleteTitle => 'Διαγραφή persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Είστε σίγουροι ότι θέλετε να διαγράψετε το \"$name\"; Αυτή η ενέργεια δεν μπορεί να αναιρεθεί.';
  }

  @override
  String get personaDeleteConfirm => 'Διαγραφή';

  @override
  String get personaDeletedToast => 'Η persona διαγράφηκε';

  @override
  String get personaCreatedToast => 'Η persona δημιουργήθηκε';

  @override
  String personaCreateFailedToast(String error) {
    return 'Αποτυχία δημιουργίας persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Αλλαγή εικόνας προφίλ';

  @override
  String get personaRemoveAvatar => 'Αφαίρεση εικόνας προφίλ';

  @override
  String get personaUploadAvatar => 'Ανέβασμα εικόνας προφίλ';

  @override
  String get personaTagsLabel => 'Ετικέτες persona';

  @override
  String get personaTagPrefixLabel => 'Πρόθεμα';

  @override
  String get personaTagSuffixLabel => 'Επίθημα';

  @override
  String get personaVisibilityLabel => 'Ορατότητα';

  @override
  String get personaVisibilityUnlisted => 'Μη καταχωρισμένο';

  @override
  String get personaVisibilityPublic => 'Δημόσιο';

  @override
  String get personaVisibilityPrivate => 'Ιδιωτικό';

  @override
  String get personaNameRequired => 'Εισαγάγετε ένα εμφανιζόμενο όνομα persona';

  @override
  String get personaNameTooLong =>
      'Το εμφανιζόμενο όνομα persona πρέπει να περιέχει έως 100 χαρακτήρες';

  @override
  String get personaTagPrefixTooLong =>
      'Το πρόθεμα ετικέτας persona πρέπει να περιέχει έως 32 χαρακτήρες';

  @override
  String get personaTagSuffixTooLong =>
      'Το επίθημα ετικέτας persona πρέπει να περιέχει έως 32 χαρακτήρες';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'Η ετικέτα \'$tag\' χρησιμοποιείται ήδη από την persona \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Εισαγωγή χρονικής σήμανσης';

  @override
  String get timestampPickerTitle => 'Εισαγωγή χρονικής σήμανσης';

  @override
  String get timestampPickerInsert => 'Εισαγωγή';

  @override
  String get timestampCopied => 'Η χρονική σήμανση αντιγράφηκε';

  @override
  String get timestampPickerTimeLabel => 'Ώρα';

  @override
  String get timestampPickerDateLabel => 'ΗΜΕΡΟΜΗΝΙΑ';

  @override
  String get timestampPickerTimeSectionLabel => 'ΩΡΑ';

  @override
  String get timestampPickerTimezoneLabel => 'ΖΩΝΗ ΩΡΑΣ';

  @override
  String get timestampPickerFormatPreviewLabel => 'ΠΡΟΕΠΙΣΚΟΠΗΣΗ ΜΟΡΦΗΣ';

  @override
  String get timestampPickerNlpPlaceholder =>
      'π.χ. αύριο στις 3 μ.μ., σε 2 ώρες, τώρα';

  @override
  String get timestampPickerSearchTimezones => 'Αναζήτηση ζωνών ώρας...';

  @override
  String get userProfileTimezoneSettingLabel => 'Ζώνη ώρας';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Χρησιμοποιείται για την εμφάνιση της τοπικής ώρας στο προφίλ σας.';

  @override
  String get userProfileTimezoneNone => 'Κανένα';
}
