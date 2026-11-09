import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_stream.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_home_section.dart';

part 'home_section_event.dart';

/// One instance per product rail, so a failing rail never affects others.
class HomeSectionBloc extends Bloc<HomeSectionEvent, ViewState<HomeSection>> {
  HomeSectionBloc({
    required this._watchHomeSection,
    required this.kind,
  }) : super(const ViewState.loading()) {
    on<HomeSectionEvent>(_onWatch, transformer: restartable());
  }

  final WatchHomeSection _watchHomeSection;
  final HomeSectionKind kind;

  Future<void> _onWatch(
    HomeSectionEvent event,
    Emitter<ViewState<HomeSection>> emit,
  ) => emitViewStates(emit, _watchHomeSection(kind), _toViewState);

  /// A section without items is shown as empty.
  static ViewState<HomeSection> _toViewState(Result<HomeSection?> result) =>
      nullableViewState(
        result.map(
          (section) => section?.items.isEmpty ?? true ? null : section,
        ),
      );
}
