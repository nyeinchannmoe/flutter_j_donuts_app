import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_stream.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/domain/usecases/watch_challenges.dart';

part 'challenges_event.dart';

class ChallengesBloc extends Bloc<ChallengesEvent, ViewState<List<Challenge>>> {
  ChallengesBloc({required this._watchChallenges})
    : super(const ViewState<List<Challenge>>.loading()) {
    on<ChallengesEvent>(_onWatch, transformer: restartable());
  }

  final WatchChallenges _watchChallenges;

  Future<void> _onWatch(
    ChallengesEvent event,
    Emitter<ViewState<List<Challenge>>> emit,
  ) => emitViewStates<Result<List<Challenge>>, List<Challenge>>(
    emit,
    _watchChallenges(),
    listViewState<Challenge>,
  );
}
