import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/home/domain/usecases/refresh_home_content.dart';

part 'home_refresh_bloc.freezed.dart';
part 'home_refresh_event.dart';
part 'home_refresh_state.dart';

/// Pull-to-refresh. Failures surface as a non-blocking message while the
/// cached sections stay on screen.
class HomeRefreshBloc extends Bloc<HomeRefreshEvent, HomeRefreshState> {
  HomeRefreshBloc({required this._refreshHomeContent})
    : super(const HomeRefreshState.idle()) {
    on<HomeRefreshRequested>(_onRequested, transformer: droppable());
  }

  final RefreshHomeContent _refreshHomeContent;

  Future<void> _onRequested(
    HomeRefreshRequested event,
    Emitter<HomeRefreshState> emit,
  ) async {
    emit(const HomeRefreshState.refreshing());
    final result = await _refreshHomeContent();
    emit(switch (result) {
      Ok() => const HomeRefreshState.succeeded(),
      Err(:final failure) => HomeRefreshState.failed(failure),
    });
  }
}
