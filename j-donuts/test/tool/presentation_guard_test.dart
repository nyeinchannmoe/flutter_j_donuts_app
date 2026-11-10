import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _setState = RegExp(r'\bsetState\s*\(');
final _palette = RegExp(
  r'\bAppPalette\b|app_palette\.dart|\bColors\s*\.|'
  r'\bColor\s*(?:\(\s*0[xX]|\.\s*(?:fromARGB|fromRGBO|from)\s*\()',
);
final _inlineTextStyle = RegExp(
  r'TextStyle\s*\([^)]*(?:fontSize|fontWeight|letterSpacing|height)\s*:',
);
final _stateClass = RegExp(r'class\s+\w+\s+extends\s+State\s*<');
final _fieldDecl = RegExp(
  r'^  (?:late\s+)?(?:final\s+)?(?:static\s+const\s+)?'
  r'(?:[A-Za-z_][\w<>,\s\?]*)\s+_(\w+)\s*(?:=|;)',
);
final _allowedFieldType = RegExp(
  '(?:AnimationController|Animation<|CurvedAnimation|Tween<|'
  'TextEditingController|FocusNode|ScrollController|PageController|'
  'TapGestureRecognizer|ImageStreamListener|ImageStream|ImageInfo|'
  'AppLifecycleListener|StreamSubscription|GlobalKey|'
  'WidgetStatesController|AutoPlayCarouselController)',
);

bool _isPresentationPath(String path) =>
    path.contains('/module/') && path.contains('/presentation/');

Iterable<File> _dartFiles(String root) => Directory(root)
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.replaceAll(r'\', '/').endsWith('.dart'));

void main() {
  test('lib never calls setState', () {
    final violations = <String>[];
    for (final file in _dartFiles('lib')) {
      final path = file.path.replaceAll(r'\', '/');
      final lines = file.readAsLinesSync();
      for (final (index, line) in lines.indexed) {
        if (_setState.hasMatch(line)) violations.add('$path:${index + 1}');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('palette and raw colours stay inside the theme', () {
    final violations = <String>[];
    for (final file in _dartFiles('lib')) {
      final path = file.path.replaceAll(r'\', '/');
      if (path.startsWith('lib/core/theme/')) continue;
      final lines = file.readAsLinesSync();
      for (final (index, line) in lines.indexed) {
        if (line.contains('Colors.transparent')) continue;
        if (_palette.hasMatch(line)) violations.add('$path:${index + 1}');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation files avoid inline TextStyle metrics', () {
    final violations = <String>[];
    for (final file in _dartFiles('lib')) {
      final path = file.path.replaceAll(r'\', '/');
      if (!_isPresentationPath(path) && !path.contains('/core/widgets/')) {
        continue;
      }
      final lines = file.readAsLinesSync();
      for (final (index, line) in lines.indexed) {
        if (_inlineTextStyle.hasMatch(line)) {
          violations.add('$path:${index + 1}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation State classes only keep controllers and nodes', () {
    final violations = <String>[];
    for (final file in _dartFiles('lib')) {
      final path = file.path.replaceAll(r'\', '/');
      if (!_isPresentationPath(path)) continue;
      violations.addAll(_stateFieldViolations(path, file.readAsLinesSync()));
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

List<String> _stateFieldViolations(String path, List<String> lines) {
  final violations = <String>[];
  var inState = false;
  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    if (_stateClass.hasMatch(line)) {
      inState = true;
      continue;
    }
    if (!inState) continue;
    if (RegExp(r'^class\s+').hasMatch(line)) {
      inState = false;
      continue;
    }
    if (!line.startsWith('  ') || line.startsWith('    ')) continue;
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('static ')) continue;
    final match = _fieldDecl.firstMatch(line);
    if (match == null) continue;
    if (_allowedFieldType.hasMatch(line)) continue;
    violations.add('$path:${index + 1}: ${line.trim()}');
  }
  return violations;
}
