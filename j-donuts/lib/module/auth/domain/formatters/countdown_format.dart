/// Formats a remaining duration as `m:ss` for countdown labels.
String formatCountdown(Duration remaining) {
  final totalSeconds = remaining.isNegative ? 0 : remaining.inSeconds;
  final minutes = totalSeconds ~/ Duration.secondsPerMinute;
  final seconds = totalSeconds % Duration.secondsPerMinute;
  final paddedSeconds = seconds.toString().padLeft(2, '0');
  return '$minutes:$paddedSeconds';
}
