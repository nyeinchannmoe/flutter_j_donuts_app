import 'package:bloc/bloc.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/view_state/view_state.dart';

/// Emits loading, then one ViewState per element of [source] until the
/// handler is cancelled. Shared by every read-only section Bloc.
///
/// Callers must instantiate generic mappers (for example
/// `nullableViewState<MemberProfile>`): a bare tear-off infers `T` as
/// `Object` and the loading emit then fails the [Emitter] type check,
/// leaving the Bloc stuck on its initial loading state.
Future<void> emitViewStates<S, T>(
  Emitter<ViewState<T>> emit,
  Stream<S> source,
  ViewState<T> Function(S value) toViewState,
) {
  emit(ViewState<T>.loading());
  return emit.forEach<S>(source, onData: toViewState);
}

/// Maps a list result: an empty list becomes the empty state.
ViewState<List<T>> listViewState<T>(Result<List<T>> result) =>
    ViewState<List<T>>.fromResult(result, isEmpty: (items) => items.isEmpty);

/// Maps a nullable result: null becomes the empty state.
ViewState<T> nullableViewState<T extends Object>(Result<T?> result) =>
    result.fold(
      onOk: (value) =>
          value == null ? ViewState<T>.empty() : ViewState<T>.data(value),
      onErr: ViewState<T>.failure,
    );
