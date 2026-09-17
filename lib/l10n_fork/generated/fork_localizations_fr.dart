// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class ForkLocalizationsFr extends ForkLocalizations {
  ForkLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get personaSelectTitle => 'Sélectionner un persona';

  @override
  String get personaSettingsHeader => 'Paramètres des personas';

  @override
  String get personaManageAction => 'Gérer';

  @override
  String get personaSearchPlaceholder =>
      'Rechercher des personas, balises, pronoms…';

  @override
  String get personaModeOff => 'Désactivé';

  @override
  String get personaModeManual => 'Manuel';

  @override
  String get personaModeLast => 'Dernier utilisé';

  @override
  String get personaModeOffDescription =>
      'Envoie avec le compte principal sauf si des balises de proxy sont saisies.';

  @override
  String get personaModeManualDescription =>
      'Envoie toujours en tant que ce persona jusqu\'à modification.';

  @override
  String get personaModeLastDescription =>
      'Bascule automatiquement sur le persona utilisé dans votre dernier message.';

  @override
  String get personaRecentHeader => 'PERSONAS RÉCENTS';

  @override
  String personaAllHeader(int count) {
    return 'TOUS LES PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'RÉSULTATS DE RECHERCHE ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Compte principal (par défaut)';

  @override
  String get personaEmptyState =>
      'Aucun persona configuré pour l\'instant. Créez-en un dans Gérer les personas.';

  @override
  String get personaEmptySearch => 'Aucun persona correspondant trouvé.';

  @override
  String get personaEditTitle => 'Modifier le persona';

  @override
  String get personaDisplayNameLabel => 'Nom affiché';

  @override
  String get personaSystemTagLabel => 'Badge / Nom de système';

  @override
  String get personaPronounsLabel => 'Pronoms';

  @override
  String get personaPronounsHint => 'ex. iel/elle/il';

  @override
  String get personaBioLabel => 'Biographie / À propos';

  @override
  String get personaBioHint => 'Présentez ce persona aux autres…';

  @override
  String get personaSaveChanges => 'Enregistrer les modifications';

  @override
  String get personaUpdatedToast => 'Persona mis à jour';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Échec de la mise à jour du persona : $error';
  }

  @override
  String get personaDisplayNameHint => 'Nom du persona';

  @override
  String get personaSystemTagHint => 'ex. NOM DU SYSTÈME';

  @override
  String personaSendingAsTag(String name) {
    return 'Envoi en tant que $name (Associé par balise)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Envoi en tant que $name (Verrouillé)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Envoi en tant que @$username';
  }

  @override
  String get personaMainAccount => 'Compte principal';

  @override
  String get personaEditPersona => 'Modifier le persona';
}
