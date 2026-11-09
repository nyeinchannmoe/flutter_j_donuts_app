import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';

part 'view_state.freezed.dart';

/// UI state of a read-only section.
@freezed
sealed class ViewState<T> with _$ViewState<T> {
  const factory ViewState.loading() = ViewLoading<T>;

  const factory ViewState.data(T value) = ViewData<T>;

  const factory ViewState.empty() = ViewEmpty<T>;

  const factory ViewState.failure(AppFailure failure) = ViewFailure<T>;

  const ViewState._();

  /// Maps a repository result, using [isEmpty] to tell data from empty.
  factory ViewState.fromResult(
    Result<T> result, {
    required bool Function(T value) isEmpty,
  }) => result.fold(
    onOk: (value) =>
        isEmpty(value) ? ViewState<T>.empty() : ViewState<T>.data(value),
    onErr: ViewState<T>.failure,
  );
}
