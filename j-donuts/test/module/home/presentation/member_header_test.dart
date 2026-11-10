import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/member/domain/usecases/watch_member_profile.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/presentation/bloc/member_header/member_header_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/member_header.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/member_header_chrome.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockWatchMemberProfile extends Mock implements WatchMemberProfile {}

const MemberProfile _member = MemberProfile(
  name: 'Hania',
  photoAsset: 'assets/seed/images/user_profile.jpg',
  tierId: 't_silver',
  tierName: 'Silver',
  tierRank: 1,
  totalPoints: 680000,
  pointsToNextTier: 500,
  notificationsCount: 2,
  pendingRewardsCount: 3,
  currentTierMinPoints: 500000,
  nextTierName: 'Gold',
  nextTierMinPoints: 680500,
);

void main() {
  late _MockWatchMemberProfile watch;

  setUp(() => watch = _MockWatchMemberProfile());

  testWidgets('renders name, tier, points copy and notification badge', (
    tester,
  ) async {
    when(
      () => watch(),
    ).thenAnswer((_) => Stream.value(const Ok(_member)));

    await tester.pumpApp(
      BlocProvider(
        create: (_) => MemberHeaderBloc(watchMemberProfile: watch)
          ..add(const MemberHeaderStarted()),
        child: Scaffold(
          body: MemberHeader(onNotificationsPressed: () {}),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Hania'), findsOneWidget);
    expect(find.text('Silver member'), findsOneWidget);
    expect(
      find.text('500 points left to become Gold Member'),
      findsOneWidget,
    );
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('invokes onNotificationsPressed when the bell is tapped', (
    tester,
  ) async {
    when(
      () => watch(),
    ).thenAnswer((_) => Stream.value(const Ok(_member)));
    var pressed = false;

    await tester.pumpApp(
      BlocProvider(
        create: (_) => MemberHeaderBloc(watchMemberProfile: watch)
          ..add(const MemberHeaderStarted()),
        child: Scaffold(
          body: MemberHeader(onNotificationsPressed: () => pressed = true),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byType(MemberNotificationBell));
    expect(pressed, isTrue);
  });

  testWidgets('shows skeleton blocks while loading', (tester) async {
    final controller = StreamController<Result<MemberProfile?>>();
    addTearDown(controller.close);
    when(() => watch()).thenAnswer((_) => controller.stream);

    await tester.pumpApp(
      BlocProvider(
        create: (_) => MemberHeaderBloc(watchMemberProfile: watch)
          ..add(const MemberHeaderStarted()),
        child: Scaffold(
          body: MemberHeader(onNotificationsPressed: () {}),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SkeletonBlock), findsWidgets);
  });
}
