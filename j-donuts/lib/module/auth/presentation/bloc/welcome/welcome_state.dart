part of 'welcome_bloc.dart';

@immutable
sealed class WelcomeState {
  const WelcomeState();
}

@immutable
final class WelcomePreparing extends WelcomeState {
  const WelcomePreparing();

  @override
  bool operator ==(Object other) => other is WelcomePreparing;

  @override
  int get hashCode => runtimeType.hashCode;
}

@immutable
final class WelcomeReady extends WelcomeState {
  const WelcomeReady();

  @override
  bool operator ==(Object other) => other is WelcomeReady;

  @override
  int get hashCode => runtimeType.hashCode;
}

@immutable
final class WelcomeExploring extends WelcomeState {
  const WelcomeExploring();

  @override
  bool operator ==(Object other) => other is WelcomeExploring;

  @override
  int get hashCode => runtimeType.hashCode;
}
