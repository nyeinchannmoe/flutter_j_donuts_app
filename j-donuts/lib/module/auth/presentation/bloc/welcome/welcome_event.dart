part of 'welcome_bloc.dart';

sealed class WelcomeEvent {
  const WelcomeEvent();
}

final class WelcomePrepared extends WelcomeEvent {
  const WelcomePrepared();
}

final class WelcomeExploreSelected extends WelcomeEvent {
  const WelcomeExploreSelected();
}
