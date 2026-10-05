# Fork-only translations

Strings that exist only in this fork live here, one `fork_<locale>.arb` per locale, with
`fork_en.arb` as the template. The upstream catalogues in `lib/l10n` (and their generated code)
are never edited by the fork, so they stay identical to upstream and cannot conflict on rebase.

To add or change a fork string:

1. Add the key to `fork_en.arb` (with its `@key` metadata) and to every other `fork_<locale>.arb`
   with a real translation. Do not copy the English text; if a value really is the same word in a
   language, list the key under that locale in `reviewed_unchanged.json`.
2. Run `bash tool/fork_l10n.sh` and commit `lib/l10n_fork/generated`.
3. Use it as `l10n.fork.myKey`, importing
   `package:fluxer_app/l10n_fork/fork_localizations_x.dart`.
4. `flutter test test/l10n_fork` checks that every locale has every key, that no value is empty or
   an untranslated English copy, and that placeholders match.

Never add fork keys to `lib/l10n/*.arb`.
