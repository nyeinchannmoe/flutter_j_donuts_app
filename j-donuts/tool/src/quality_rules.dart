import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

/// Rule identifiers, also used in waiver comments.
abstract final class QualityRule {
  static const String fileLength = 'file-length';
  static const String functionLength = 'function-length';
  static const String rawColor = 'raw-color';
  static const String curves = 'curves';
  static const String duration = 'duration';
  static const String textLiteral = 'text-literal';
  static const String layoutLiteral = 'layout-literal';
  static const String debugOutput = 'debug-output';
  static const String taskComment = 'task-comment';
}

abstract final class QualityLimits {
  static const int maxFileLines = 300;
  static const int maxFunctionLines = 30;
}

class Violation {
  const Violation({
    required this.path,
    required this.line,
    required this.rule,
    required this.message,
  });

  final String path;
  final int line;
  final String rule;
  final String message;

  @override
  String toString() => '$path:$line [$rule] $message';
}

/// Where a file sits, which decides the rules that apply to it.
class FileScope {
  FileScope(String path) : path = path.replaceAll(r'\', '/');

  final String path;

  bool get isTheme => path.startsWith('lib/core/theme/');

  bool get isMotionTokens => path == 'lib/core/motion/motion_tokens.dart';

  bool get isPresentation =>
      path.contains('/presentation/') ||
      path.startsWith('lib/core/widgets/') ||
      path.startsWith('lib/config/routes/') ||
      path == 'lib/app.dart';
}

const Set<String> _layoutTypes = {
  'EdgeInsets',
  'EdgeInsetsDirectional',
  'SizedBox',
};
const Set<String> _textTypes = {'Text', 'SnackBar'};
const Set<String> _debugFunctions = {'print', 'debugPrint'};

/// Collects rule violations for one parsed file.
class QualityVisitor extends RecursiveAstVisitor<void> {
  QualityVisitor({required this.scope, required this.lineInfo});

  final FileScope scope;
  final LineInfo lineInfo;
  final List<Violation> violations = [];

  int _line(AstNode node) => lineInfo.getLocation(node.offset).lineNumber;

  void _report(AstNode node, String rule, String message) => violations.add(
    Violation(
      path: scope.path,
      line: _line(node),
      rule: rule,
      message: message,
    ),
  );

  void _checkBody(AstNode declaration, String name, FunctionBody body) {
    final start = lineInfo.getLocation(body.offset).lineNumber;
    final end = lineInfo.getLocation(body.end).lineNumber;
    final lines = end - start + 1;
    if (lines > QualityLimits.maxFunctionLines) {
      _report(
        declaration,
        QualityRule.functionLength,
        '$name has $lines lines (max ${QualityLimits.maxFunctionLines})',
      );
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkBody(node, node.name.lexeme, node.functionExpression.body);
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkBody(node, node.name.lexeme, node.body);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _checkBody(node, node.name?.lexeme ?? 'constructor', node.body);
    super.visitConstructorDeclaration(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final prefix = node.prefix.name;
    final member = node.identifier.name;
    if (prefix == 'Colors' && !scope.isTheme) {
      _report(node, QualityRule.rawColor, 'Colors.$member outside theme');
    }
    if (prefix == 'Curves' && !scope.isMotionTokens) {
      _report(node, QualityRule.curves, 'Curves.$member outside tokens');
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _checkCreation(
      node,
      node.constructorName.type.name.lexeme,
      node.argumentList,
    );
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    final method = node.methodName.name;
    if (target == null && _debugFunctions.contains(method)) {
      _report(node, QualityRule.debugOutput, '$method call');
    }
    if (target == null && _startsUpperCase(method)) {
      _checkCreation(node, method, node.argumentList);
    } else if (target is SimpleIdentifier && _startsUpperCase(target.name)) {
      _checkCreation(node, target.name, node.argumentList);
    }
    super.visitMethodInvocation(node);
  }

  void _checkCreation(AstNode node, String type, ArgumentList arguments) {
    if (type == 'Color' && !scope.isTheme) {
      _report(node, QualityRule.rawColor, 'Color value outside theme');
    }
    if (type == 'Duration') _checkDuration(node);
    if (!scope.isPresentation) return;
    if (_textTypes.contains(type) && _firstIsStringLiteral(arguments)) {
      _report(node, QualityRule.textLiteral, 'string literal in $type');
    }
    if (_layoutTypes.contains(type) && _hasNumericLiteral(arguments)) {
      _report(node, QualityRule.layoutLiteral, 'numeric literal in $type');
    }
  }

  void _checkDuration(AstNode node) {
    if (scope.isPresentation) {
      _report(node, QualityRule.duration, 'Duration in presentation code');
      return;
    }
    final parent = node.parent;
    final grandparent = parent?.parent;
    final isNamedConstant =
        parent is VariableDeclaration &&
        grandparent is VariableDeclarationList &&
        (grandparent.isConst || grandparent.isFinal);
    if (!isNamedConstant) {
      _report(node, QualityRule.duration, 'Duration not a named constant');
    }
  }

  static bool _startsUpperCase(String name) =>
      name.isNotEmpty && name[0].toUpperCase() == name[0] && name[0] != '_';

  static bool _firstIsStringLiteral(ArgumentList arguments) {
    final positional = arguments.arguments.whereType<Expression>().where(
      (argument) => argument is! NamedExpression,
    );
    return positional.isNotEmpty && positional.first is StringLiteral;
  }

  static bool _hasNumericLiteral(ArgumentList arguments) {
    final finder = _NumericLiteralFinder();
    for (final argument in arguments.arguments) {
      final isChild =
          argument is NamedExpression &&
          _childArguments.contains(argument.name.label.name);
      if (!isChild) argument.accept(finder);
    }
    return finder.found;
  }

  static const Set<String> _childArguments = {'child', 'children'};
}

class _NumericLiteralFinder extends RecursiveAstVisitor<void> {
  bool found = false;

  @override
  void visitIntegerLiteral(IntegerLiteral node) => found = true;

  @override
  void visitDoubleLiteral(DoubleLiteral node) => found = true;
}
