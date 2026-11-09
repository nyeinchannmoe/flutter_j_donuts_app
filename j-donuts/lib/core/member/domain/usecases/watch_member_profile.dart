import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/member/domain/repositories/member_repository.dart';
import 'package:jdonuts/core/result/result.dart';

class WatchMemberProfile {
  const WatchMemberProfile(this._repository);

  final MemberRepository _repository;

  Stream<Result<MemberProfile?>> call() => _repository.watchMember();
}
