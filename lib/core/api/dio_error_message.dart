import 'package:dio/dio.dart';
import 'package:fluxer_app/core/api/retry_after.dart';

String? apiErrorCodeFromDioException(DioException error) {
  final Object? data = error.response?.data;
  if (data is Map) {
    final Object? code = data['code'];
    if (code is String && code.isNotEmpty) {
      return code;
    }
    if (code is int) {
      return code.toString();
    }
  }
  return null;
}

int? retryAfterMsFromDioException(DioException error) {
  return featureRetryAfterMs(
    headers: error.response?.headers,
    data: error.response?.data,
  );
}

String? apiMessageFromDioException(DioException error) {
  final Object? data = error.response?.data;
  if (data is Map) {
    if (data is Map<String, dynamic>) {
      final String? fieldMessage = _invalidFormBodyMessage(data);
      if (fieldMessage != null) {
        return fieldMessage;
      }
    }
    // Fork: the first validation error with its field, for the response shapes
    // upstream's INVALID_FORM_BODY message above does not read (errors nested
    // under data, or under another code).
    final dynamic nestedData = data['data'];
    final dynamic errors = nestedData is Map
        ? nestedData['errors']
        : data['errors'];
    if (errors is List && errors.isNotEmpty) {
      final firstError = errors.first;
      if (firstError is Map) {
        final dynamic firstMsg = firstError['message'];
        final dynamic firstField = firstError['path'] ?? firstError['field'];
        if (firstMsg is String && firstMsg.isNotEmpty) {
          if (firstField is String && firstField.isNotEmpty) {
            return '$firstField: $firstMsg';
          }
          return firstMsg;
        }
      }
    }

    final dynamic message = data['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
  }
  return null;
}

String? _invalidFormBodyMessage(Map<String, dynamic> data) {
  if (data['code'] != 'INVALID_FORM_BODY') {
    return null;
  }
  final Object? errors = data['errors'];
  if (errors is! List<dynamic>) {
    return null;
  }
  final Set<String> messages = <String>{};
  for (final Object? item in errors) {
    if (item is Map<String, dynamic>) {
      final Object? message = item['message'];
      if (message is String && message.isNotEmpty) {
        messages.add(message);
      }
    }
  }
  return messages.isEmpty ? null : messages.join(' ');
}

String userFacingErrorMessage(Object error, String fallback) {
  if (error is DioException) {
    return apiMessageFromDioException(error) ?? fallback;
  }
  return fallback;
}
