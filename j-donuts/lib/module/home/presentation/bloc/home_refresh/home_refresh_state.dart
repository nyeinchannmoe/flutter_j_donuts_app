part of 'home_refresh_bloc.dart';

@freezed
sealed class HomeRefreshState with _$HomeRefreshState {
  const factory HomeRefreshState.idle() = HomeRefreshIdle;

  const factory HomeRefreshState.refreshing() = HomeRefreshInProgress;

  const factory HomeRefreshState.succeeded() = HomeRefreshSucceeded;

  const factory HomeRefreshState.failed(AppFailure failure) = HomeRefreshFailed;

  const HomeRefreshState._();

  bool get isRefreshing => this is HomeRefreshInProgress;
}
