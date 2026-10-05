import 'dart:ui' show Locale;

import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/l10n_fork/generated/fork_localizations.dart';

export 'package:fluxer_app/l10n_fork/generated/fork_localizations.dart';

final Map<String, ForkLocalizations> _forkLocalizationsByLocale =
    <String, ForkLocalizations>{};

/// Gives every [FluxerLocalizations] access to the strings that exist only in
/// this fork, so call sites read `l10n.fork.someKey`.
///
/// Fork strings live in `l10n_fork/*.arb` (see `l10n_fork/README.md`) so the
/// upstream catalogues under `lib/l10n` stay identical to upstream.
extension FluxerForkLocalizations on FluxerLocalizations {
  ForkLocalizations get fork =>
      _forkLocalizationsByLocale[localeName] ??= _lookup(localeName);
}

ForkLocalizations _lookup(String localeName) {
  final List<String> parts = localeName.split('_');
  final bool hasScript = parts.length > 1 && parts[1].length == 4;
  final Locale locale = Locale.fromSubtags(
    languageCode: parts.first,
    scriptCode: hasScript ? parts[1] : null,
    countryCode: hasScript
        ? (parts.length > 2 ? parts[2] : null)
        : (parts.length > 1 ? parts[1] : null),
  );
  return lookupForkLocalizations(
    ForkLocalizations.delegate.isSupported(locale)
        ? locale
        : const Locale('en'),
  );
}
