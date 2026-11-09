import 'package:bloc/bloc.dart';
import 'package:jdonuts/core/logging/app_logger.dart';

/// Logs Bloc transitions and errors. Registered in debug and profile only.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._logger);

  final AppLogger _logger;

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _logger.debug(
      '${bloc.runtimeType}: ${transition.event.runtimeType} '
      '${transition.currentState.runtimeType} -> '
      '${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      '${bloc.runtimeType} failed',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
