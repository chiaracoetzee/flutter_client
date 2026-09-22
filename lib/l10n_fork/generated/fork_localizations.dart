import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fork_localizations_ar.dart';
import 'fork_localizations_bg.dart';
import 'fork_localizations_cs.dart';
import 'fork_localizations_da.dart';
import 'fork_localizations_de.dart';
import 'fork_localizations_el.dart';
import 'fork_localizations_en.dart';
import 'fork_localizations_es.dart';
import 'fork_localizations_fi.dart';
import 'fork_localizations_fr.dart';
import 'fork_localizations_he.dart';
import 'fork_localizations_hi.dart';
import 'fork_localizations_hr.dart';
import 'fork_localizations_hu.dart';
import 'fork_localizations_id.dart';
import 'fork_localizations_it.dart';
import 'fork_localizations_ja.dart';
import 'fork_localizations_ko.dart';
import 'fork_localizations_lt.dart';
import 'fork_localizations_nb.dart';
import 'fork_localizations_nl.dart';
import 'fork_localizations_pl.dart';
import 'fork_localizations_pt.dart';
import 'fork_localizations_ro.dart';
import 'fork_localizations_ru.dart';
import 'fork_localizations_sv.dart';
import 'fork_localizations_th.dart';
import 'fork_localizations_tr.dart';
import 'fork_localizations_uk.dart';
import 'fork_localizations_vi.dart';
import 'fork_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ForkLocalizations
/// returned by `ForkLocalizations.of(context)`.
///
/// Applications need to include `ForkLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/fork_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ForkLocalizations.localizationsDelegates,
///   supportedLocales: ForkLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the ForkLocalizations.supportedLocales
/// property.
abstract class ForkLocalizations {
  ForkLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ForkLocalizations of(BuildContext context) {
    return Localizations.of<ForkLocalizations>(context, ForkLocalizations)!;
  }

  static const LocalizationsDelegate<ForkLocalizations> delegate =
      _ForkLocalizationsDelegate();

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
    Locale('ar'),
    Locale('bg'),
    Locale('cs'),
    Locale('da'),
    Locale('de'),
    Locale('el'),
    Locale('en', 'GB'),
    Locale('en', 'US'),
    Locale('es'),
    Locale('es', '419'),
    Locale('fi'),
    Locale('fr'),
    Locale('he'),
    Locale('hi'),
    Locale('hr'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('lt'),
    Locale('nb'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ro'),
    Locale('ru'),
    Locale('sv'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// Action label for changing the persona of a message.
  ///
  /// In en, this message translates to:
  /// **'Change Persona'**
  String get chatMessageChangePersona;

  /// No description provided for @advancedSettingQuickSwitcherButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick Switcher button'**
  String get advancedSettingQuickSwitcherButtonLabel;

  /// No description provided for @advancedSettingQuickSwitcherButtonDescription.
  ///
  /// In en, this message translates to:
  /// **'Replace the voice message button in the message input with a Quick Switcher button for fast navigation'**
  String get advancedSettingQuickSwitcherButtonDescription;

  /// Title of the persona selection modal sheet.
  ///
  /// In en, this message translates to:
  /// **'Select Persona'**
  String get personaSelectTitle;

  /// Header for persona settings row in the persona picker sheet.
  ///
  /// In en, this message translates to:
  /// **'Persona Settings'**
  String get personaSettingsHeader;

  /// Action button to open settings to manage personas.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get personaManageAction;

  /// Placeholder in the persona picker search input.
  ///
  /// In en, this message translates to:
  /// **'Search personas, tags, pronouns...'**
  String get personaSearchPlaceholder;

  /// Label for Off mode in persona active mode selector.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get personaModeOff;

  /// Label for Manual mode in persona active mode selector.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get personaModeManual;

  /// Label for Last Used mode in persona active mode selector.
  ///
  /// In en, this message translates to:
  /// **'Last Used'**
  String get personaModeLast;

  /// Helper text explaining Off persona mode.
  ///
  /// In en, this message translates to:
  /// **'Sends as root account unless persona tags are typed.'**
  String get personaModeOffDescription;

  /// Helper text explaining Manual persona mode.
  ///
  /// In en, this message translates to:
  /// **'Always sends as selected persona until changed.'**
  String get personaModeManualDescription;

  /// Helper text explaining Last Used persona mode.
  ///
  /// In en, this message translates to:
  /// **'Auto-switches to the persona used in your last message.'**
  String get personaModeLastDescription;

  /// Section header for recently used personas.
  ///
  /// In en, this message translates to:
  /// **'RECENT PERSONAS'**
  String get personaRecentHeader;

  /// Section header for all user personas with count.
  ///
  /// In en, this message translates to:
  /// **'ALL PERSONAS ({count})'**
  String personaAllHeader(int count);

  /// Section header for search results with count.
  ///
  /// In en, this message translates to:
  /// **'SEARCH RESULTS ({count})'**
  String personaSearchResultsHeader(int count);

  /// Label for the user's default/root account in persona picker.
  ///
  /// In en, this message translates to:
  /// **'Root Account (Default)'**
  String get personaRootAccountLabel;

  /// Empty state text when user has no personas.
  ///
  /// In en, this message translates to:
  /// **'No personas configured yet. Create one via Manage Personas.'**
  String get personaEmptyState;

  /// Empty state text when search yields no personas.
  ///
  /// In en, this message translates to:
  /// **'No matching personas found.'**
  String get personaEmptySearch;

  /// Title of the edit persona sheet.
  ///
  /// In en, this message translates to:
  /// **'Edit Persona'**
  String get personaEditTitle;

  /// Title of the create persona sheet.
  ///
  /// In en, this message translates to:
  /// **'Create Persona'**
  String get personaCreateTitle;

  /// Form label for persona display name field.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get personaDisplayNameLabel;

  /// Form label for persona pronouns field.
  ///
  /// In en, this message translates to:
  /// **'Pronouns'**
  String get personaPronounsLabel;

  /// Hint text for persona pronouns input.
  ///
  /// In en, this message translates to:
  /// **'e.g. they/them'**
  String get personaPronounsHint;

  /// Form label for persona biography field.
  ///
  /// In en, this message translates to:
  /// **'Bio / About Me'**
  String get personaBioLabel;

  /// Hint text for persona biography input.
  ///
  /// In en, this message translates to:
  /// **'Tell others about this persona...'**
  String get personaBioHint;

  /// Toast message displayed when persona is successfully updated.
  ///
  /// In en, this message translates to:
  /// **'Persona updated'**
  String get personaUpdatedToast;

  /// Toast message displayed when persona update fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to update persona: {error}'**
  String personaUpdateFailedToast(String error);

  /// Title for the personas settings section.
  ///
  /// In en, this message translates to:
  /// **'Personas'**
  String get personaSectionTitle;

  /// Hint text for persona display name input.
  ///
  /// In en, this message translates to:
  /// **'Persona name'**
  String get personaDisplayNameHint;

  /// Tooltip when composer will send as persona matched by tag.
  ///
  /// In en, this message translates to:
  /// **'Sending as {name} (Matched by tag)'**
  String personaSendingAsTag(String name);

  /// Tooltip when composer will send as latched persona.
  ///
  /// In en, this message translates to:
  /// **'Sending as {name} (Latched)'**
  String personaSendingAsLatched(String name);

  /// Tooltip when composer will send as root user account.
  ///
  /// In en, this message translates to:
  /// **'Sending as @{username}'**
  String personaSendingAsRoot(String username);

  /// Header for root account section in persona profile card.
  ///
  /// In en, this message translates to:
  /// **'Main account'**
  String get personaMainAccount;

  /// Button to edit persona in persona profile card.
  ///
  /// In en, this message translates to:
  /// **'Edit persona'**
  String get personaEditPersona;

  /// Navigation item label for Personas in user settings.
  ///
  /// In en, this message translates to:
  /// **'Personas'**
  String get userSettingsNavPersonas;

  /// Description at the top of the persona settings section.
  ///
  /// In en, this message translates to:
  /// **'Configure your active persona mode, custom display tag, and manage individual personas.'**
  String get personaSettingsDescription;

  /// Header for display tag section in persona settings.
  ///
  /// In en, this message translates to:
  /// **'Display Tag'**
  String get personaDisplayTagSection;

  /// Description explaining what the display tag does.
  ///
  /// In en, this message translates to:
  /// **'Display tag will appear next to all persona names in messages. If no display tag is set, your account profile picture will be shown.'**
  String get personaDisplayTagDescription;

  /// Label for the display tag text input.
  ///
  /// In en, this message translates to:
  /// **'Display Tag Text'**
  String get personaDisplayTagLabel;

  /// Placeholder for the display tag text input.
  ///
  /// In en, this message translates to:
  /// **'e.g. SYS'**
  String get personaDisplayTagHint;

  /// Label for display tag icon upload in persona settings.
  ///
  /// In en, this message translates to:
  /// **'Display Tag Icon'**
  String get personaDisplayTagIconLabel;

  /// Button to upload an icon for the display tag.
  ///
  /// In en, this message translates to:
  /// **'Upload Icon'**
  String get personaUploadTagIcon;

  /// Button to change the display tag icon.
  ///
  /// In en, this message translates to:
  /// **'Change Icon'**
  String get personaChangeTagIcon;

  /// Button to remove the display tag icon.
  ///
  /// In en, this message translates to:
  /// **'Remove Icon'**
  String get personaRemoveTagIcon;

  /// Title of the live chat message preview card in persona settings.
  ///
  /// In en, this message translates to:
  /// **'Chat Preview'**
  String get personaChatPreviewTitle;

  /// Sample message body shown in the chat preview.
  ///
  /// In en, this message translates to:
  /// **'Hello! This is a preview of how messages look with your display tag and active persona.'**
  String get personaChatPreviewSampleMessage;

  /// Title of the configured personas list in settings.
  ///
  /// In en, this message translates to:
  /// **'Configured Personas'**
  String get personaListTitle;

  /// Button to create a new persona in settings.
  ///
  /// In en, this message translates to:
  /// **'Add Persona'**
  String get personaAddButton;

  /// Badge indicating this persona is currently active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get personaActiveBadge;

  /// Button to make this persona the active one.
  ///
  /// In en, this message translates to:
  /// **'Set Active'**
  String get personaMakeActive;

  /// Title of confirmation dialog when deleting a persona.
  ///
  /// In en, this message translates to:
  /// **'Delete Persona'**
  String get personaDeleteTitle;

  /// Confirmation message when deleting a persona.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This cannot be undone.'**
  String personaDeleteMessage(String name);

  /// Confirmation button to delete a persona.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get personaDeleteConfirm;

  /// Toast shown after deleting a persona.
  ///
  /// In en, this message translates to:
  /// **'Persona deleted'**
  String get personaDeletedToast;

  /// Toast shown after successfully creating a new persona.
  ///
  /// In en, this message translates to:
  /// **'Persona created'**
  String get personaCreatedToast;

  /// Toast shown when persona creation fails.
  ///
  /// In en, this message translates to:
  /// **'Failed to create persona: {error}'**
  String personaCreateFailedToast(String error);

  /// Button to change persona avatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get personaChangeAvatar;

  /// Button to remove persona avatar.
  ///
  /// In en, this message translates to:
  /// **'Remove Avatar'**
  String get personaRemoveAvatar;

  /// Button to upload persona avatar.
  ///
  /// In en, this message translates to:
  /// **'Upload Avatar'**
  String get personaUploadAvatar;

  /// Label for persona tags section in persona form.
  ///
  /// In en, this message translates to:
  /// **'Persona Tags'**
  String get personaTagsLabel;

  /// Label for tag prefix input.
  ///
  /// In en, this message translates to:
  /// **'Prefix'**
  String get personaTagPrefixLabel;

  /// Label for tag suffix input.
  ///
  /// In en, this message translates to:
  /// **'Suffix'**
  String get personaTagSuffixLabel;

  /// Label for persona visibility selector.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get personaVisibilityLabel;

  /// Label for unlisted visibility option.
  ///
  /// In en, this message translates to:
  /// **'Unlisted'**
  String get personaVisibilityUnlisted;

  /// Label for public visibility option.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get personaVisibilityPublic;

  /// Label for private visibility option.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get personaVisibilityPrivate;

  /// Validation toast error when saving a persona with an empty display name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a persona display name'**
  String get personaNameRequired;

  /// Validation toast error when persona display name exceeds 100 characters.
  ///
  /// In en, this message translates to:
  /// **'Persona display name must be 100 characters or less'**
  String get personaNameTooLong;

  /// Validation toast error when persona tag prefix exceeds 32 characters.
  ///
  /// In en, this message translates to:
  /// **'Persona tag prefix must be 32 characters or less'**
  String get personaTagPrefixTooLong;

  /// Validation toast error when persona tag suffix exceeds 32 characters.
  ///
  /// In en, this message translates to:
  /// **'Persona tag suffix must be 32 characters or less'**
  String get personaTagSuffixTooLong;

  /// Validation toast error when a persona prefix/suffix matches an existing persona's tag.
  ///
  /// In en, this message translates to:
  /// **'The tag \'{tag}\' is already in use by \'{name}\'.'**
  String personaTagCollisionError(String tag, String name);
}

class _ForkLocalizationsDelegate
    extends LocalizationsDelegate<ForkLocalizations> {
  const _ForkLocalizationsDelegate();

  @override
  Future<ForkLocalizations> load(Locale locale) {
    return SynchronousFuture<ForkLocalizations>(
      lookupForkLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bg',
    'cs',
    'da',
    'de',
    'el',
    'en',
    'es',
    'fi',
    'fr',
    'he',
    'hi',
    'hr',
    'hu',
    'id',
    'it',
    'ja',
    'ko',
    'lt',
    'nb',
    'nl',
    'pl',
    'pt',
    'ro',
    'ru',
    'sv',
    'th',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_ForkLocalizationsDelegate old) => false;
}

ForkLocalizations lookupForkLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return ForkLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return ForkLocalizationsEnGb();
          case 'US':
            return ForkLocalizationsEnUs();
        }
        break;
      }
    case 'es':
      {
        switch (locale.countryCode) {
          case '419':
            return ForkLocalizationsEs419();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return ForkLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return ForkLocalizationsAr();
    case 'bg':
      return ForkLocalizationsBg();
    case 'cs':
      return ForkLocalizationsCs();
    case 'da':
      return ForkLocalizationsDa();
    case 'de':
      return ForkLocalizationsDe();
    case 'el':
      return ForkLocalizationsEl();
    case 'en':
      return ForkLocalizationsEn();
    case 'es':
      return ForkLocalizationsEs();
    case 'fi':
      return ForkLocalizationsFi();
    case 'fr':
      return ForkLocalizationsFr();
    case 'he':
      return ForkLocalizationsHe();
    case 'hi':
      return ForkLocalizationsHi();
    case 'hr':
      return ForkLocalizationsHr();
    case 'hu':
      return ForkLocalizationsHu();
    case 'id':
      return ForkLocalizationsId();
    case 'it':
      return ForkLocalizationsIt();
    case 'ja':
      return ForkLocalizationsJa();
    case 'ko':
      return ForkLocalizationsKo();
    case 'lt':
      return ForkLocalizationsLt();
    case 'nb':
      return ForkLocalizationsNb();
    case 'nl':
      return ForkLocalizationsNl();
    case 'pl':
      return ForkLocalizationsPl();
    case 'pt':
      return ForkLocalizationsPt();
    case 'ro':
      return ForkLocalizationsRo();
    case 'ru':
      return ForkLocalizationsRu();
    case 'sv':
      return ForkLocalizationsSv();
    case 'th':
      return ForkLocalizationsTh();
    case 'tr':
      return ForkLocalizationsTr();
    case 'uk':
      return ForkLocalizationsUk();
    case 'vi':
      return ForkLocalizationsVi();
    case 'zh':
      return ForkLocalizationsZh();
  }

  throw FlutterError(
    'ForkLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
