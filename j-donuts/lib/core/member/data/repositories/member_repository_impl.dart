import 'package:jdonuts/core/database/daos/member_dao.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/member/data/mappers/member_mapper.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/member/domain/repositories/member_repository.dart';
import 'package:jdonuts/core/result/result.dart';

class MemberRepositoryImpl implements MemberRepository {
  const MemberRepositoryImpl({
    required this._dao,
    required this._logger,
  });

  final MemberDao _dao;
  final AppLogger _logger;

  @override
  Stream<Result<MemberProfile?>> watchMember() => guardStream(
    _dao.watchMemberWithTier().map((row) => row?.toEntity()),
    logger: _logger,
  );
}
