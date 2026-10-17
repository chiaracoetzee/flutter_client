import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/core/api/fork_call_site_interceptor.dart';

class _RecordingAdapter implements HttpClientAdapter {
  final List<Map<String, dynamic>> sentHeaders = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    sentHeaders.add(Map<String, dynamic>.of(options.headers));
    return ResponseBody.fromString(
      '{}',
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _loadLoungeMessages(Dio dio) async {
  await dio.get<dynamic>('/channels/1/messages');
}

const String _vmTrace = '''
#0      DioMixin.request (package:dio/src/dio_mixin.dart:404:28)
#1      DioMixin.get (package:dio/src/dio_mixin.dart:62:12)
#2      MessageRepository.fetchPage (package:fluxer_app/features/chat/data/message_repository.dart:723:18)
#3      ChatViewModel._loadOlder.<anonymous closure> (package:fluxer_app/features/chat/providers/core/chat_view_model.dart:3650:9)
<asynchronous suspension>
#4      ChatViewModel._loadOlder (package:fluxer_app/features/chat/providers/core/chat_view_model.dart:3600:5)
#5      MessageListDemand.request (package:fluxer_app/features/chat/presentation/widgets/messages/message_list_demand.dart:88:7)
#6      MessageListState._onScroll (package:fluxer_app/features/chat/presentation/widgets/messages/message_list.dart:410:5)
#7      _rootRun (dart:async/zone.dart:1525:13)
''';

void main() {
  test('names the innermost app frames, innermost first, with short paths', () {
    expect(
      describeForkCallSite(StackTrace.fromString(_vmTrace)),
      'MessageRepository.fetchPage (features/chat/data/message_repository.dart:723)'
      ' < ChatViewModel._loadOlder.<anonymous closure> (features/chat/providers/core/chat_view_model.dart:3650)'
      ' < ChatViewModel._loadOlder (features/chat/providers/core/chat_view_model.dart:3600)'
      ' < MessageListDemand.request (features/chat/presentation/widgets/messages/message_list_demand.dart:88)',
    );
  });

  test('falls back to the first frame outside Dio and the Dart libraries', () {
    const String trace = '''
#0      DioMixin.request (package:dio/src/dio_mixin.dart:404:28)
#1      UsersApi.getPersona (package:fluxer_dart/api/users_api.dart:120:5)
#2      _rootRun (dart:async/zone.dart:1525:13)
''';
    expect(
      describeForkCallSite(StackTrace.fromString(trace)),
      'UsersApi.getPersona (package:fluxer_dart/api/users_api.dart:120)',
    );
  });

  test('gives nothing when no frame can be named', () {
    expect(describeForkCallSite(null), isNull);
    expect(
      describeForkCallSite(
        StackTrace.fromString(
          '#0      DioMixin.request (package:dio/src/dio_mixin.dart:404:28)\n',
        ),
      ),
      isNull,
    );
  });

  test('sends the caller of the request in the header', () async {
    final _RecordingAdapter adapter = _RecordingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ForkCallSiteInterceptor());

    await _loadLoungeMessages(dio);

    expect(adapter.sentHeaders, hasLength(1));
    expect(
      adapter.sentHeaders.single[kForkCallSiteHeader],
      startsWith('_loadLoungeMessages ('),
    );
  });

  test('keeps the header a request already has, as on a retry', () async {
    final _RecordingAdapter adapter = _RecordingAdapter();
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ForkCallSiteInterceptor());

    await dio.get<dynamic>(
      '/channels/1/messages',
      options: Options(
        headers: <String, dynamic>{kForkCallSiteHeader: 'first attempt'},
      ),
    );

    expect(adapter.sentHeaders.single[kForkCallSiteHeader], 'first attempt');
  });
}
