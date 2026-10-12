// Fork: the app is called Tyne in the builds the fork ships. The name reaches them as a build
// setting of the shipped flavour, so that upstream's tests keep seeing upstream's name.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the shipped flavour is built as Tyne', () {
    final Object? defines = jsonDecode(
      File('tool/dart_defines/canary.json').readAsStringSync(),
    );
    expect(defines, isA<Map<String, dynamic>>());
    expect((defines! as Map<String, dynamic>)['FORK_APP_NAME'], 'Tyne');
  });

  test('the default name is taken from that build setting', () {
    final String source = File(
      'lib/core/instance/instance_constants.dart',
    ).readAsStringSync();
    expect(source, contains("String.fromEnvironment(\n    'FORK_APP_NAME'"));
  });
}
