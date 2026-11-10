import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_stream.dart';
import 'package:jdonuts/module/rewards/domain/entities/tier.dart';
import 'package:jdonuts/module/rewards/domain/usecases/watch_tiers.dart';

part 'tier_ladder_event.dart';

class TierLadderBloc extends Bloc<TierLadderEvent, ViewState<List<Tier>>> {
  TierLadderBloc({required this._watchTiers})
    : super(const ViewState<List<Tier>>.loading()) {
    on<TierLadderEvent>(_onWatch, transformer: restartable());
  }

  final WatchTiers _watchTiers;

  Future<void> _onWatch(
    TierLadderEvent event,
    Emitter<ViewState<List<Tier>>> emit,
  ) => emitViewStates<Result<List<Tier>>, List<Tier>>(
    emit,
    _watchTiers(),
    listViewState<Tier>,
  );
}
