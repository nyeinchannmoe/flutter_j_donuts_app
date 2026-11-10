import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/member/domain/usecases/watch_member_profile.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_stream.dart';

part 'rewards_summary_event.dart';

/// Points and pending rewards, read from the same member record as Home.
class RewardsSummaryBloc
    extends Bloc<RewardsSummaryEvent, ViewState<MemberProfile>> {
  RewardsSummaryBloc({required this._watchMemberProfile})
    : super(const ViewState<MemberProfile>.loading()) {
    on<RewardsSummaryEvent>(_onWatch, transformer: restartable());
  }

  final WatchMemberProfile _watchMemberProfile;

  Future<void> _onWatch(
    RewardsSummaryEvent event,
    Emitter<ViewState<MemberProfile>> emit,
  ) => emitViewStates<Result<MemberProfile?>, MemberProfile>(
    emit,
    _watchMemberProfile(),
    nullableViewState<MemberProfile>,
  );
}
