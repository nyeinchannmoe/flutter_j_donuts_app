part of 'member_header_bloc.dart';

sealed class MemberHeaderEvent {
  const MemberHeaderEvent();
}

final class MemberHeaderStarted extends MemberHeaderEvent {
  const MemberHeaderStarted();
}

final class MemberHeaderRetried extends MemberHeaderEvent {
  const MemberHeaderRetried();
}
