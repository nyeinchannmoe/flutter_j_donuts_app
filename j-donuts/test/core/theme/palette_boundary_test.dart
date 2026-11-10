import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('palette references and raw colours stay inside the theme', () {
    final violations = <String>[];
    final forbidden = RegExp(
      r'\bAppPalette\b|app_palette\.dart|\bColors\s*\.|'
      r'\bColor\s*(?:\(\s*0[xX]|\.\s*(?:fromARGB|fromRGBO|from)\s*\()',
    );

    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      final path = file.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || path.startsWith('lib/core/theme/')) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (final (index, line) in lines.indexed) {
        if (forbidden.hasMatch(line)) violations.add('$path:${index + 1}');
      }
    }

    expect(violations, isEmpty);
  });
}
