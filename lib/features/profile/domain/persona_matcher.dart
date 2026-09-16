// SPDX-License-Identifier: AGPL-3.0-or-later

import 'persona.dart';

class MatchResult {
  const MatchResult({
    required this.matched,
    required this.strippedContent,
    this.persona,
    this.wasEscaped = false,
    this.clearedLatch = false,
    this.isFromTag = false,
  });

  final bool matched;
  final String strippedContent;
  final Persona? persona;
  final bool wasEscaped;
  final bool clearedLatch;
  final bool isFromTag;
}

class PreviewResult {
  const PreviewResult({
    this.persona,
    this.isFromTag = false,
  });

  final Persona? persona;
  final bool isFromTag;
}

class _CandidateMatch {
  const _CandidateMatch({
    required this.persona,
    required this.totalLen,
    required this.innerContent,
  });

  final Persona persona;
  final int totalLen;
  final String innerContent;
}

MatchResult matchPersona(
  String text,
  List<Persona> personas,
  String? activeLatchedPersonaId,
  bool hasAttachments, {
  bool allowEmptyContent = false,
}) {
  Persona? latchedPersona;
  if (activeLatchedPersonaId != null && activeLatchedPersonaId.isNotEmpty) {
    for (final p in personas) {
      if (p.id == activeLatchedPersonaId && !p.autoTagDisabled) {
        latchedPersona = p;
        break;
      }
    }
  }

  // Check unlatch trigger: "\\" clears active latch if latched
  if (latchedPersona != null && text.trim() == r'\\') {
    return const MatchResult(
      matched: false,
      strippedContent: '',
      clearedLatch: true,
      wasEscaped: true,
    );
  }

  // Check double backslash with message: "\\ [message]" sends as root account and CLEARS latch
  if (latchedPersona != null && text.startsWith(r'\\')) {
    final rawRest = text.substring(2);
    final stripped = rawRest.startsWith(' ') ? rawRest.substring(1) : rawRest;
    return MatchResult(
      matched: false,
      strippedContent: stripped,
      clearedLatch: true,
      wasEscaped: true,
    );
  }

  // Check single backslash: "\ [message]" escapes proxy tag matching and suppresses latch
  if (text.startsWith(r'\')) {
    final rawRest = text.substring(1);
    final stripped = rawRest.startsWith(' ') ? rawRest.substring(1) : rawRest;
    return MatchResult(
      matched: false,
      strippedContent: stripped,
      wasEscaped: true,
    );
  }

  final candidates = <_CandidateMatch>[];

  for (final persona in personas) {
    if (persona.autoTagDisabled) continue;
    if (persona.personaTags.isEmpty) continue;

    for (final tag in persona.personaTags) {
      final prefix = tag.prefix ?? '';
      final suffix = tag.suffix ?? '';
      if (prefix.isEmpty && suffix.isEmpty) continue;

      if (text.startsWith(prefix) && text.endsWith(suffix)) {
        final innerStart = prefix.length;
        final innerEnd = text.length - suffix.length;
        if (innerEnd > innerStart) {
          final inner = text.substring(innerStart, innerEnd).trim();
          if (inner.isNotEmpty || allowEmptyContent) {
            candidates.add(
              _CandidateMatch(
                persona: persona,
                totalLen: prefix.length + suffix.length,
                innerContent: inner,
              ),
            );
          } else if (hasAttachments) {
            candidates.add(
              _CandidateMatch(
                persona: persona,
                totalLen: prefix.length + suffix.length,
                innerContent: '',
              ),
            );
          }
        } else if (innerEnd == innerStart &&
            (hasAttachments || allowEmptyContent)) {
          candidates.add(
            _CandidateMatch(
              persona: persona,
              totalLen: prefix.length + suffix.length,
              innerContent: '',
            ),
          );
        }
      } else if (hasAttachments || allowEmptyContent) {
        final trimmed = text.trim();
        final hasPrefix = prefix.isNotEmpty;
        final hasSuffix = suffix.isNotEmpty;

        if (hasPrefix && hasSuffix) {
          // Two-sided tag: ALWAYS requires both prefix and suffix
          if (trimmed.startsWith(prefix.trim()) &&
              trimmed.endsWith(suffix.trim())) {
            final innerStart = prefix.trim().length;
            final innerEnd = trimmed.length - suffix.trim().length;
            final inner = innerEnd >= innerStart
                ? trimmed.substring(innerStart, innerEnd).trim()
                : '';
            if (inner.isEmpty) {
              candidates.add(
                _CandidateMatch(
                  persona: persona,
                  totalLen: prefix.length + suffix.length,
                  innerContent: '',
                ),
              );
            }
          }
        } else if (hasPrefix && !hasSuffix) {
          // Prefix-only tag
          if (trimmed == prefix.trim() || trimmed.startsWith(prefix)) {
            final remainder = trimmed.startsWith(prefix)
                ? trimmed.substring(prefix.length).trim()
                : '';
            if (remainder.isEmpty) {
              candidates.add(
                _CandidateMatch(
                  persona: persona,
                  totalLen: prefix.length,
                  innerContent: '',
                ),
              );
            }
          }
        } else if (!hasPrefix && hasSuffix) {
          // Suffix-only tag
          if (trimmed == suffix.trim() || trimmed.endsWith(suffix)) {
            final remainder = trimmed.endsWith(suffix)
                ? trimmed.substring(0, trimmed.length - suffix.length).trim()
                : '';
            if (remainder.isEmpty) {
              candidates.add(
                _CandidateMatch(
                  persona: persona,
                  totalLen: suffix.length,
                  innerContent: '',
                ),
              );
            }
          }
        }
      }
    }
  }

  if (candidates.isNotEmpty) {
    // Longest match wins
    candidates.sort((a, b) => b.totalLen.compareTo(a.totalLen));
    final best = candidates.first;
    return MatchResult(
      matched: true,
      persona: best.persona,
      strippedContent: best.innerContent,
      isFromTag: true,
    );
  }

  if (latchedPersona != null) {
    if (text.trim().isEmpty && !hasAttachments && !allowEmptyContent) {
      return MatchResult(
        matched: false,
        strippedContent: text,
        isFromTag: false,
      );
    }
    return MatchResult(
      matched: true,
      persona: latchedPersona,
      strippedContent: text,
      isFromTag: false,
    );
  }

  return MatchResult(
    matched: false,
    strippedContent: text,
    isFromTag: false,
  );
}

PreviewResult previewPersona(
  String text,
  List<Persona> personas,
  String? activeLatchedPersonaId,
  bool hasAttachments,
) {
  final result = matchPersona(
    text,
    personas,
    activeLatchedPersonaId,
    hasAttachments,
    allowEmptyContent: true,
  );

  if (result.wasEscaped || result.clearedLatch) {
    return const PreviewResult(persona: null, isFromTag: false);
  }

  if (result.matched && result.persona != null) {
    return PreviewResult(
      persona: result.persona,
      isFromTag: result.isFromTag,
    );
  }

  return const PreviewResult(persona: null, isFromTag: false);
}
