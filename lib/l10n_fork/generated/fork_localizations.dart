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
