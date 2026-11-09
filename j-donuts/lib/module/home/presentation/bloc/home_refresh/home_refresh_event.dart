part of 'home_refresh_bloc.dart';

sealed class HomeRefreshEvent {
  const HomeRefreshEvent();
}

final class HomeRefreshRequested extends HomeRefreshEvent {
  const HomeRefreshRequested();
}
