part of 'banners_bloc.dart';

sealed class BannersEvent {
  const BannersEvent();
}

final class BannersStarted extends BannersEvent {
  const BannersStarted();
}

final class BannersRetried extends BannersEvent {
  const BannersRetried();
}
