import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('font metrics are defined in the theme', () {
    final violations = <String>[];
    final files = Directory('lib').listSync(recursive: true).whereType<File>();
    for (final file in files) {
      final path = file.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || path.startsWith('lib/core/theme/')) {
        continue;
      }

      final parsed = parseString(
        content: file.readAsStringSync(),
        path: path,
        throwIfDiagnostics: false,
      );
      final visitor = _TypographyVisitor();
      parsed.unit.accept(visitor);
      for (final violation in visitor.violations) {
        final line = parsed.lineInfo.getLocation(violation.offset).lineNumber;
        violations.add('$path:$line ${violation.name.label.name}');
      }
    }

    expect(violations, isEmpty);
  });
}

class _TypographyVisitor extends RecursiveAstVisitor<void> {
  static const _metrics = {'fontSize', 'fontWeight', 'letterSpacing', 'height'};

  final violations = <NamedExpression>[];

  @override
  void visitNamedExpression(NamedExpression node) {
    if (_metrics.contains(node.name.label.name) && _definesStyle(node)) {
      violations.add(node);
    }
    super.visitNamedExpression(node);
  }

  bool _definesStyle(NamedExpression node) => switch (node.parent?.parent) {
    InstanceCreationExpression(:final constructorName) =>
      constructorName.type.name.lexeme == 'TextStyle',
    MethodInvocation(:final methodName) =>
      methodName.name == 'TextStyle' || methodName.name == 'copyWith',
    _ => false,
  };
}
