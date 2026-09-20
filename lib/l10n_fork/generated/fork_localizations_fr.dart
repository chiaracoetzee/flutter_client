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
      'Envoie avec le compte principal sauf si les balises de persona sont saisies.';

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
  String get personaCreateTitle => 'Créer un persona';

  @override
  String get personaDisplayNameLabel => 'Nom affiché';

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
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Nom du persona';

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

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configurez votre mode de persona actif, votre badge d\'affichage personnalisé et gérez vos personas.';

  @override
  String get personaDisplayTagSection => 'Badge d\'affichage';

  @override
  String get personaDisplayTagDescription =>
      'Le badge d\'affichage apparaîtra à côté du nom de toutes vos personas dans les messages. Si aucun badge n\'est configuré, votre photo de profil de compte sera affichée.';

  @override
  String get personaDisplayTagLabel => 'Texte du badge';

  @override
  String get personaDisplayTagHint => 'ex. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Icône du badge';

  @override
  String get personaUploadTagIcon => 'Importer une icône';

  @override
  String get personaChangeTagIcon => 'Modifier l\'icône';

  @override
  String get personaRemoveTagIcon => 'Supprimer l\'icône';

  @override
  String get personaChatPreviewTitle => 'Aperçu du chat';

  @override
  String get personaChatPreviewSampleMessage =>
      'Bonjour ! Ceci est un aperçu de l\'affichage des messages avec votre badge d\'affichage et votre persona actif.';

  @override
  String get personaListTitle => 'Personas configurés';

  @override
  String get personaAddButton => 'Ajouter un persona';

  @override
  String get personaActiveBadge => 'Actif';

  @override
  String get personaMakeActive => 'Définir comme actif';

  @override
  String get personaDeleteTitle => 'Supprimer le persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Voulez-vous vraiment supprimer « $name » ? Cette action est irréversible.';
  }

  @override
  String get personaDeleteConfirm => 'Supprimer';

  @override
  String get personaDeletedToast => 'Persona supprimé';

  @override
  String get personaCreatedToast => 'Persona créé';

  @override
  String personaCreateFailedToast(String error) {
    return 'Échec de la création du persona : $error';
  }

  @override
  String get personaChangeAvatar => 'Modifier l\'avatar';

  @override
  String get personaRemoveAvatar => 'Supprimer l\'avatar';

  @override
  String get personaUploadAvatar => 'Importer un avatar';

  @override
  String get personaTagsLabel => 'Balises de persona';

  @override
  String get personaTagPrefixLabel => 'Préfixe';

  @override
  String get personaTagSuffixLabel => 'Suffixe';

  @override
  String get personaVisibilityLabel => 'Visibilité';

  @override
  String get personaVisibilityUnlisted => 'Non répertorié';

  @override
  String get personaVisibilityPublic => 'Public';

  @override
  String get personaVisibilityPrivate => 'Privé';

  @override
  String get personaNameRequired =>
      'Veuillez saisir un nom d\'affichage de persona';

  @override
  String get personaNameTooLong =>
      'Le nom d\'affichage du persona doit comporter 100 caractères ou moins';

  @override
  String get personaTagPrefixTooLong =>
      'Le préfixe de balise de persona doit comporter 32 caractères ou moins';

  @override
  String get personaTagSuffixTooLong =>
      'Le suffixe de balise de persona doit comporter 32 caractères ou moins';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'La balise « $tag » est déjà utilisée par « $name ».';
  }
}
