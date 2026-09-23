import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';

/// Long-form relative time (e.g. "5 minutes ago", "just now").
///
/// Mirrors the long-form used in Security & Login. Uses the existing
/// `relativeTime*` ARB keys.
String relativeTime(DateTime date, FluxerLocalizations l10n, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(date);
  if (diff.inDays > 365) {
    return l10n.relativeTimeYears((diff.inDays / 365).floor());
  }
  if (diff.inDays > 30) {
    return l10n.relativeTimeMonths((diff.inDays / 30).floor());
  }
  if (diff.inDays > 0) {
    return l10n.relativeTimeDays(diff.inDays);
  }
  if (diff.inHours > 0) {
    return l10n.relativeTimeHours(diff.inHours);
  }
  if (diff.inMinutes > 0) {
    return l10n.relativeTimeMinutes(diff.inMinutes);
  }
  return l10n.relativeTimeJustNow;
}

/// Relative time for markdown timestamps (`<t:unix:R>`).
///
/// Matches the web unit cascade for both past and future instants.
String relativeTimestamp(
  DateTime date,
  FluxerLocalizations l10n, {
  DateTime? now,
}) {
  final Duration delta = date.difference(now ?? DateTime.now());
  final bool future = !delta.isNegative;
  final Duration abs = delta.abs();
  final int absSeconds = abs.inSeconds;

  if (absSeconds < 30) {
    return l10n.relativeTimeJustNow;
  }

  final int absMinutes = (absSeconds / 60).round();
  if (absMinutes < 60) {
    return future
        ? l10n.relativeTimeInMinutes(absMinutes)
        : l10n.relativeTimeMinutes(absMinutes);
  }

  final int absHours = (absSeconds / 3600).round();
  if (absHours < 24) {
    return future
        ? l10n.relativeTimeInHours(absHours)
        : l10n.relativeTimeHours(absHours);
  }

  final int absDays = (absSeconds / 86400).round();
  if (absDays < 7) {
    return future
        ? l10n.relativeTimeInDays(absDays)
        : l10n.relativeTimeDays(absDays);
  }

  final int absWeeks = (absDays / 7).round();
  if (absDays < 30) {
    return future
        ? l10n.relativeTimeInWeeks(absWeeks)
        : l10n.relativeTimeWeeks(absWeeks);
  }

  final int absMonths = (absDays / 30).round();
  if (absDays < 365) {
    return future
        ? l10n.relativeTimeInMonths(absMonths)
        : l10n.relativeTimeMonths(absMonths);
  }

  final int years = (absDays / 365).round();
  return future
      ? l10n.relativeTimeInYears(years)
      : l10n.relativeTimeYears(years);
}

/// Short-form relative time (e.g. "5m", "2h", "3d", "2mo", "1y", "now").
///
/// Mirrors the web app's `formatShortRelativeTime` output. Used in compact
/// card layouts like Linked Devices.
String relativeTimeShort(DateTime date, FluxerLocalizations l10n) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 365) {
    return l10n.relativeTimeShortYears((diff.inDays / 365).floor());
  }
  if (diff.inDays > 30) {
    return l10n.relativeTimeShortMonths((diff.inDays / 30).floor());
  }
  if (diff.inDays > 0) {
    return l10n.relativeTimeShortDays(diff.inDays);
  }
  if (diff.inHours > 0) {
    return l10n.relativeTimeShortHours(diff.inHours);
  }
  if (diff.inMinutes > 0) {
    return l10n.relativeTimeShortMinutes(diff.inMinutes);
  }
  return l10n.relativeTimeShortNow;
}
