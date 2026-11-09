import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_stream.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_shops.dart';

part 'shops_event.dart';

class ShopsBloc extends Bloc<ShopsEvent, ViewState<List<Shop>>> {
  ShopsBloc({required this._watchShops}) : super(const ViewState.loading()) {
    on<ShopsEvent>(_onWatch, transformer: restartable());
  }

  final WatchShops _watchShops;

  Future<void> _onWatch(
    ShopsEvent event,
    Emitter<ViewState<List<Shop>>> emit,
  ) => emitViewStates(emit, _watchShops(), listViewState<Shop>);
}
