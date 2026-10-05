import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';

const String _forkDir = 'l10n_fork';
const String _upstreamDir = 'lib/l10n';

Map<String, dynamic> _readJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

Map<String, Map<String, dynamic>> _readCatalogues(String dir, String prefix) {
  final Map<String, Map<String, dynamic>> catalogues =
      <String, Map<String, dynamic>>{};
  for (final FileSystemEntity entity in Directory(dir).listSync()) {
    final String name = entity.uri.pathSegments.last;
    if (entity is File && name.startsWith(prefix) && name.endsWith('.arb')) {
      final String locale = name.substring(prefix.length, name.length - 4);
      catalogues[locale] = _readJson(entity.path);
    }
  }
  return catalogues;
}

Set<String> _messageKeys(Map<String, dynamic> catalogue) =>
    catalogue.keys.where((String key) => !key.startsWith('@')).toSet();

/// Argument names of an ICU message, descending into plural and select branches.
Set<String> _argumentNames(String message) {
  final Set<String> names = <String>{};
  void visit(String text, {required bool branchesOnly}) {
    int depth = 0;
    int start = -1;
    for (int index = 0; index < text.length; index++) {
      final String char = text[index];
      if (char == '{') {
        if (depth == 0) {
          start = index + 1;
        }
        depth += 1;
      } else if (char == '}' && depth > 0) {
        depth -= 1;
        if (depth == 0) {
          final String body = text.substring(start, index);
          if (branchesOnly) {
            visit(body, branchesOnly: false);
            continue;
          }
          final List<String> parts = body.split(',');
          names.add(parts.first.trim());
          final String type = parts.length > 1 ? parts[1].trim() : '';
          if (type == 'plural' || type == 'select' || type == 'selectordinal') {
            visit(body, branchesOnly: true);
          }
        }
      }
    }
  }

  visit(message, branchesOnly: false);
  return names;
}

bool _hasWords(String message) => RegExp(
  r'\p{L}{2}',
  unicode: true,
).hasMatch(message.replaceAll(RegExp(r'\{[^}]*\}'), ''));

void main() {
  final Map<String, Map<String, dynamic>> fork = _readCatalogues(
    _forkDir,
    'fork_',
  );
  final Map<String, Map<String, dynamic>> upstream = _readCatalogues(
    _upstreamDir,
    'fluxer_',
  );
  final Map<String, dynamic> template = fork['en']!;
  final Set<String> templateKeys = _messageKeys(template);
  final Map<String, dynamic> reviewedUnchanged =
      _readJson('$_forkDir/reviewed_unchanged.json')['locales']
          as Map<String, dynamic>;

  test('fork catalogue covers the same locales as upstream', () {
    expect(fork.keys.toSet(), upstream.keys.toSet());
  });

  test('fork keys do not shadow upstream keys', () {
    expect(templateKeys.intersection(_messageKeys(upstream['en']!)), isEmpty);
  });

  test('every locale translates every fork key', () {
    final List<String> problems = <String>[];
    for (final MapEntry<String, Map<String, dynamic>> entry in fork.entries) {
      final String locale = entry.key;
      final Set<String> keys = _messageKeys(entry.value)..remove('@@locale');
      for (final String key in templateKeys.difference(keys)) {
        problems.add('[$locale] $key is missing');
      }
      for (final String key in keys.difference(templateKeys)) {
        problems.add('[$locale] $key is not in fork_en.arb');
      }
      for (final String key in keys.intersection(templateKeys)) {
        final String source = template[key] as String;
        final String value = entry.value[key] as String;
        if (value.trim().isEmpty) {
          problems.add('[$locale] $key is empty');
        } else if (!_setEquals(_argumentNames(value), _argumentNames(source))) {
          problems.add('[$locale] $key has different placeholders: $value');
        } else if (!locale.startsWith('en') &&
            value == source &&
            _hasWords(source) &&
            !((reviewedUnchanged[locale] as List<dynamic>?)?.contains(key) ??
                false)) {
          problems.add(
            '[$locale] $key is an English copy; translate it or list the key '
            'in l10n_fork/reviewed_unchanged.json',
          );
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('every upstream locale resolves its own fork strings', () {
    for (final Locale locale in FluxerLocalizations.supportedLocales) {
      final FluxerLocalizations l10n = lookupFluxerLocalizations(locale);
      expect(l10n.fork.localeName, l10n.localeName);
    }
  });
}

bool _setEquals(Set<String> left, Set<String> right) =>
    left.length == right.length && left.containsAll(right);
