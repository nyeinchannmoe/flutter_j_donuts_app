import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_stream.dart';
import 'package:jdonuts/module/home/domain/entities/home_banner.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_banners.dart';

part 'banners_event.dart';

class BannersBloc extends Bloc<BannersEvent, ViewState<List<HomeBanner>>> {
  BannersBloc({required this._watchBanners})
    : super(const ViewState.loading()) {
    on<BannersEvent>(_onWatch, transformer: restartable());
  }

  final WatchBanners _watchBanners;

  Future<void> _onWatch(
    BannersEvent event,
    Emitter<ViewState<List<HomeBanner>>> emit,
  ) => emitViewStates(emit, _watchBanners(), listViewState<HomeBanner>);
}
