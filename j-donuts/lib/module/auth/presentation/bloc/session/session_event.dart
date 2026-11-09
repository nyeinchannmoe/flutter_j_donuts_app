part of 'session_bloc.dart';

sealed class SessionEvent {
  const SessionEvent();
}

/// The app started and should follow session changes.
final class SessionStarted extends SessionEvent {
  const SessionStarted();
}

final class SessionSignOutRequested extends SessionEvent {
  const SessionSignOutRequested();
}
