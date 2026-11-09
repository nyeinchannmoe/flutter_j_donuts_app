import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/member/domain/usecases/watch_member_profile.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_stream.dart';

part 'member_header_event.dart';

class MemberHeaderBloc
    extends Bloc<MemberHeaderEvent, ViewState<MemberProfile>> {
  MemberHeaderBloc({required this._watchMemberProfile})
    : super(const ViewState.loading()) {
    on<MemberHeaderEvent>(_onWatch, transformer: restartable());
  }

  final WatchMemberProfile _watchMemberProfile;

  Future<void> _onWatch(
    MemberHeaderEvent event,
    Emitter<ViewState<MemberProfile>> emit,
  ) => emitViewStates(emit, _watchMemberProfile(), nullableViewState);
}
