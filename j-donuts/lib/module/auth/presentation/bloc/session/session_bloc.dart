import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:jdonuts/module/auth/domain/entities/session.dart';
import 'package:jdonuts/module/auth/domain/usecases/sign_out.dart';
import 'package:jdonuts/module/auth/domain/usecases/watch_session.dart';

part 'session_event.dart';

/// App-level owner of the session. Its state is the domain [Session],
/// which drives the router's redirect guard.
class SessionBloc extends Bloc<SessionEvent, Session> {
  SessionBloc({
    required this._watchSession,
    required this._signOut,
    Session initial = const Session.unknown(),
  }) : super(initial) {
    on<SessionStarted>(_onStarted, transformer: restartable());
    on<SessionSignOutRequested>(_onSignOutRequested, transformer: droppable());
  }

  final WatchSession _watchSession;
  final SignOut _signOut;

  Future<void> _onStarted(SessionStarted event, Emitter<Session> emit) =>
      emit.forEach<Session>(_watchSession(), onData: (session) => session);

  Future<void> _onSignOutRequested(
    SessionSignOutRequested event,
    Emitter<Session> emit,
  ) async {
    final result = await _signOut();
    if (!result.isOk) addError(result.failureOrNull!, StackTrace.current);
  }
}
