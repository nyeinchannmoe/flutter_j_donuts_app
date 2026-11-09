import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';

import 'src/quality_rules.dart';

/// Enforces the limits in .cursor/rules/90-code-quality.mdc that the
/// analyzer cannot express. Exit code 1 when any unwaived violation exists.
///
/// Waiver: `quality-gate: allow <rule> - <reason>` on the line or the line
/// above the violation.
void main() {
  final files =
      Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => file.path.replaceAll(r'\', '/'))
          .where(_isHandWritten)
          .toList()
        ..sort();
  final violations = <Violation>[];
  var waived = 0;
  for (final path in files) {
    final result = _checkFile(path);
    violations.addAll(result.violations);
    waived += result.waived;
  }
  violations.forEach(stdout.writeln);
  stdout.writeln(
    'quality_gate: ${files.length} files, ${violations.length} violations, '
    '$waived waived',
  );
  if (violations.isNotEmpty) exitCode = 1;
}

bool _isHandWritten(String path) =>
    path.endsWith('.dart') &&
    !path.endsWith('.g.dart') &&
    !path.endsWith('.freezed.dart') &&
    !path.startsWith('lib/l10n/generated/') &&
    path != 'lib/core/database/migrations/schema_versions.dart';

final RegExp _waiver = RegExp(r'quality-gate: allow ([\w-]+) - \S');
final RegExp _taskComment = RegExp(r'//.*\b(TODO|FIXME)\b');

({List<Violation> violations, int waived}) _checkFile(String path) {
  final source = File(path).readAsStringSync();
  final lines = source.split('\n');
  final parsed = parseString(
    content: source,
    path: path,
    featureSet: FeatureSet.latestLanguageVersion(),
  );
  final visitor = QualityVisitor(
    scope: FileScope(path),
    lineInfo: parsed.lineInfo,
  );
  parsed.unit.accept(visitor);
  final found = [
    ...visitor.violations,
    ..._lineViolations(path, lines),
  ];
  final waivers = _waivers(lines);
  final kept = <Violation>[];
  for (final violation in found) {
    final waiver = waivers[violation.line] ?? waivers[violation.line - 1];
    if (waiver != null && waiver.contains(violation.rule)) {
      stdout.writeln('waived: $violation');
    } else {
      kept.add(violation);
    }
  }
  return (violations: kept, waived: found.length - kept.length);
}

List<Violation> _lineViolations(String path, List<String> lines) => [
  if (lines.length > QualityLimits.maxFileLines)
    Violation(
      path: path,
      line: 1,
      rule: QualityRule.fileLength,
      message: '${lines.length} lines (max ${QualityLimits.maxFileLines})',
    ),
  for (var i = 0; i < lines.length; i++)
    if (_taskComment.hasMatch(lines[i]))
      Violation(
        path: path,
        line: i + 1,
        rule: QualityRule.taskComment,
        message: 'task comment',
      ),
];

Map<int, Set<String>> _waivers(List<String> lines) {
  final waivers = <int, Set<String>>{};
  for (var i = 0; i < lines.length; i++) {
    for (final match in _waiver.allMatches(lines[i])) {
      (waivers[i + 1] ??= {}).add(match.group(1)!);
    }
  }
  return waivers;
}
