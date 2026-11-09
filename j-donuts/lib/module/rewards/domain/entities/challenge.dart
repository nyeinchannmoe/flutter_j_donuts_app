import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge.freezed.dart';

/// Artwork family used to draw a challenge's progress.
enum ChallengeKind { donut, coffee }

@freezed
abstract class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String title,
    required ChallengeKind kind,
    required int progressCurrent,
    required int progressTarget,
    required int rewardPoints,
    required String imageAsset,
    required bool claimed,
  }) = _Challenge;

  const Challenge._();

  bool get isComplete => progressCurrent >= progressTarget;

  /// Progress from 0 to 1.
  double get progressFraction => progressTarget <= 0
      ? 0
      : (progressCurrent / progressTarget).clamp(0, 1).toDouble();
}
