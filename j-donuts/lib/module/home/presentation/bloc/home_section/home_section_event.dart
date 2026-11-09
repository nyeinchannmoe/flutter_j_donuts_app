part of 'home_section_bloc.dart';

sealed class HomeSectionEvent {
  const HomeSectionEvent();
}

final class HomeSectionStarted extends HomeSectionEvent {
  const HomeSectionStarted();
}

final class HomeSectionRetried extends HomeSectionEvent {
  const HomeSectionRetried();
}
