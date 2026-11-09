part of 'shops_bloc.dart';

sealed class ShopsEvent {
  const ShopsEvent();
}

final class ShopsStarted extends ShopsEvent {
  const ShopsStarted();
}

final class ShopsRetried extends ShopsEvent {
  const ShopsRetried();
}
