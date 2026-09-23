import 'dart:math';

import 'package:fluxer_app/features/quick_switcher/domain/quick_switcher_candidate.dart';

List<T> matchQuickSwitcherCandidates<T extends QuickSwitcherCandidate>(
  List<T> candidates,
  String search,
  int limit,
) {
  if (candidates.isEmpty) {
    return <T>[];
  }
  final String trimmed = search.trim();
  if (trimmed.isEmpty) {
    return _sortCandidatesByWeight(candidates).take(limit).toList();
  }
  final String fullQuery = trimmed.toLowerCase();
  final List<String> terms = fullQuery
      .split(RegExp(r'\s+'))
      .where((String t) => t.isNotEmpty)
      .toList();
  if (terms.isEmpty) {
    return _sortCandidatesByWeight(candidates).take(limit).toList();
  }

  final List<_ScoredCandidate<T>> scored = <_ScoredCandidate<T>>[];
  for (final T candidate in candidates) {
    final int score = _scoreCandidate(candidate, fullQuery, terms);
    if (score > 0) {
      scored.add(_ScoredCandidate<T>(candidate, score));
    }
  }

  scored.sort((_ScoredCandidate<T> a, _ScoredCandidate<T> b) {
    final int scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) {
      return scoreCompare;
    }
    final int weightCompare =
        b.candidate.sortWeight.compareTo(a.candidate.sortWeight);
    if (weightCompare != 0) {
      return weightCompare;
    }
    return a.candidate.title.toLowerCase().compareTo(
      b.candidate.title.toLowerCase(),
    );
  });

  return scored.take(limit).map((_ScoredCandidate<T> s) => s.candidate).toList();
}

List<T> _sortCandidatesByWeight<T extends QuickSwitcherCandidate>(
  List<T> candidates,
) {
  final List<T> sorted = List<T>.from(candidates)
    ..sort((T a, T b) {
      final int weightCompare = b.sortWeight.compareTo(a.sortWeight);
      if (weightCompare != 0) {
        return weightCompare;
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
  return sorted;
}

class _ScoredCandidate<T extends QuickSwitcherCandidate> {
  const _ScoredCandidate(this.candidate, this.score);
  final T candidate;
  final int score;
}

String _stripLeadingSymbols(String text) {
  final RegExp alphaNum = RegExp(r'[\p{L}\p{N}]', unicode: true);
  final Match? match = alphaNum.firstMatch(text);
  if (match != null) {
    return text.substring(match.start).trim();
  }
  return text.trim();
}

int _scoreTextMatch(
  String rawText,
  String cleanText,
  String term, {
  required bool isTitle,
}) {
  if (term.isEmpty) {
    return 0;
  }

  // Exact match
  if (cleanText == term || rawText == term) {
    return isTitle ? 100000 : 25000;
  }

  // Prefix match
  if (cleanText.startsWith(term) || rawText.startsWith(term)) {
    final int base = isTitle ? 80000 : 20000;
    final double ratio = cleanText.isNotEmpty ? term.length / cleanText.length : 1.0;
    return base + (ratio * (isTitle ? 5000 : 1500)).toInt();
  }

  // Word-start match
  final List<String> words = cleanText
      .split(RegExp(r'[\s\-_/.]+'))
      .where((String w) => w.isNotEmpty)
      .toList();

  for (int i = 0; i < words.length; i++) {
    final String word = words[i];
    if (word.startsWith(term)) {
      final int base = isTitle ? 60000 : 15000;
      final int positionBonus = max(0, 10 - i) * (isTitle ? 500 : 150);
      final int exactWordBonus = (word == term) ? (isTitle ? 2000 : 1000) : 0;
      final double ratio = cleanText.isNotEmpty ? term.length / cleanText.length : 1.0;
      final int ratioBonus = (ratio * (isTitle ? 3000 : 1000)).toInt();
      return base + positionBonus + exactWordBonus + ratioBonus;
    }
  }

  // Substring match
  if (cleanText.contains(term) || rawText.contains(term)) {
    final int base = isTitle ? 40000 : 10000;
    final double ratio = cleanText.isNotEmpty ? term.length / cleanText.length : 1.0;
    return base + (ratio * (isTitle ? 5000 : 1500)).toInt();
  }

  return 0;
}

int _scoreCandidate(
  QuickSwitcherCandidate candidate,
  String fullQuery,
  List<String> terms,
) {
  final String rawTitle = candidate.title.toLowerCase().trim();
  final String cleanTitle = _stripLeadingSymbols(rawTitle).toLowerCase();
  final String? rawSubtitle = candidate.subtitle?.toLowerCase().trim();
  final String? cleanSubtitle = rawSubtitle != null
      ? _stripLeadingSymbols(rawSubtitle).toLowerCase()
      : null;

  int totalScore = 0;
  int matchedTitleCount = 0;
  int matchedSubtitleCount = 0;

  for (final String term in terms) {
    final int titleScore = _scoreTextMatch(
      rawTitle,
      cleanTitle,
      term,
      isTitle: true,
    );
    final int subtitleScore =
        (rawSubtitle != null && cleanSubtitle != null)
            ? _scoreTextMatch(
                rawSubtitle,
                cleanSubtitle,
                term,
                isTitle: false,
              )
            : 0;

    int searchValueScore = 0;
    if (titleScore == 0 && subtitleScore == 0) {
      for (final String value in candidate.searchValues) {
        if (value.toLowerCase().contains(term)) {
          searchValueScore = 5000;
          break;
        }
      }
      if (searchValueScore == 0) {
        // Every term must match somewhere in the candidate.
        return 0;
      }
    }

    if (titleScore > 0) {
      matchedTitleCount++;
    }
    if (subtitleScore > 0) {
      matchedSubtitleCount++;
    }

    totalScore += max(titleScore, max(subtitleScore, searchValueScore));
  }

  // Cross-term bonuses
  if (terms.length > 1) {
    // Synergy: matches both title (channel) and subtitle (guild)
    if (matchedTitleCount > 0 && matchedSubtitleCount > 0) {
      totalScore += 20000;
    }
    // Phrase match bonus
    if (rawTitle.contains(fullQuery) || cleanTitle.contains(fullQuery)) {
      totalScore += 30000;
    } else if (rawSubtitle != null &&
        (rawSubtitle.contains(fullQuery) ||
            (cleanSubtitle != null && cleanSubtitle.contains(fullQuery)))) {
      totalScore += 10000;
    }
  } else if (terms.length == 1) {
    // Single term matches both title and subtitle
    if (matchedTitleCount > 0 && matchedSubtitleCount > 0) {
      totalScore += 5000;
    }
  }

  return totalScore;
}
