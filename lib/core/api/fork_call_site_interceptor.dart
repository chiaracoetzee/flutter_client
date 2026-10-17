import 'package:dio/dio.dart';

/// Fork: the header that tells the instance where in the app a request was
/// made. When the global rate limit ends a session, the server logs it with
/// the requests that led there, so a request flood can be traced to its code.
const String kForkCallSiteHeader = 'X-Tyne-Call-Site';

const int _kMaxFrames = 4;
const int _kMaxLength = 480;
const String _kAppPackage = 'package:fluxer_app/';

final RegExp _framePattern = RegExp(r'^#\d+\s+(.+?)\s+\((.+)\)$');

/// Adds [kForkCallSiteHeader] to every request, from the stack trace Dio
/// records where the request is made (`RequestOptions.sourceStackTrace`).
/// A stack trace taken here would not reach the caller: Dio runs
/// interceptors through `Future.then`, which async stack traces do not follow.
class ForkCallSiteInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // A retried request keeps the header it was first sent with.
    if (!options.headers.containsKey(kForkCallSiteHeader)) {
      final String? callSite = describeForkCallSite(
        // Dio marks it internal, but it is the only record of the caller; Dio
        // itself reports it as the stack trace of a failed request.
        // ignore: invalid_use_of_internal_member
        options.sourceStackTrace,
      );
      if (callSite != null) {
        options.headers[kForkCallSiteHeader] = callSite;
      }
    }
    handler.next(options);
  }
}

/// The innermost frames of the app's own code in [trace], innermost first,
/// as `function (path:line) < caller (path:line)`. When no frame is the
/// app's, the innermost frame outside Dio and the Dart libraries. Null when
/// the trace has neither.
String? describeForkCallSite(StackTrace? trace) {
  if (trace == null) {
    return null;
  }
  final List<({String function, String location})> frames =
      <({String function, String location})>[];
  for (final String line in trace.toString().split('\n')) {
    final RegExpMatch? match = _framePattern.firstMatch(line.trim());
    if (match != null) {
      frames.add((function: match.group(1)!, location: match.group(2)!));
    }
  }
  final List<({String function, String location})> appFrames = frames
      .where((frame) => frame.location.startsWith(_kAppPackage))
      .take(_kMaxFrames)
      .toList();
  final List<({String function, String location})> chosen = appFrames.isNotEmpty
      ? appFrames
      : frames
            .where(
              (frame) =>
                  !frame.location.startsWith('package:dio/') &&
                  !frame.location.startsWith('dart:'),
            )
            .take(1)
            .toList();
  if (chosen.isEmpty) {
    return null;
  }
  final String described = chosen
      .map((frame) => '${frame.function} (${_shortLocation(frame.location)})')
      .join(' < ')
      .replaceAll(RegExp('[^\x20-\x7e]'), '?');
  return described.length > _kMaxLength
      ? described.substring(0, _kMaxLength)
      : described;
}

/// `package:fluxer_app/features/x.dart:12:3` becomes `features/x.dart:12`.
String _shortLocation(String location) {
  String short = location.startsWith(_kAppPackage)
      ? location.substring(_kAppPackage.length)
      : location;
  final RegExpMatch? lineAndColumn = RegExp(
    r'^(.*:\d+):\d+$',
  ).firstMatch(short);
  if (lineAndColumn != null) {
    short = lineAndColumn.group(1)!;
  }
  return short;
}
