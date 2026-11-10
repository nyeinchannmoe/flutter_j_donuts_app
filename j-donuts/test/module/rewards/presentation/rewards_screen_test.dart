import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/widgets/state_views/empty_state_view.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/domain/entities/tier.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/challenges/challenges_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_summary/rewards_summary_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_tabs/rewards_tabs_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/tier_ladder/tier_ladder_bloc.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/rewards_screen.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/widgets/rewards_tabs.dart';

import '../../../helpers/device_matrix.dart';
import '../../../helpers/pump_app.dart';

class _MockSummary
    extends MockBloc<RewardsSummaryEvent, ViewState<MemberProfile>>
    implements RewardsSummaryBloc {}

class _MockTiers extends MockBloc<TierLadderEvent, ViewState<List<Tier>>>
    implements TierLadderBloc {}

class _MockChallenges
    extends MockBloc<ChallengesEvent, ViewState<List<Challenge>>>
    implements ChallengesBloc {}

const MemberProfile _member = MemberProfile(
  name: 'Hania',
  photoAsset: 'assets/seed/images/user_profile.webp',
  tierId: 't_silver',
  tierName: 'Silver',
  tierRank: 1,
  totalPoints: 680000,
  pointsToNextTier: 500,
  notificationsCount: 2,
  pendingRewardsCount: 3,
  currentTierMinPoints: 678500,
  nextTierName: 'Gold',
  nextTierMinPoints: 680500,
);

const List<Tier> _tiers = [
  Tier(id: 't_silver', name: 'Silver', minPoints: 678500, rank: 1),
  Tier(id: 't_gold', name: 'Gold', minPoints: 680500, rank: 2),
  Tier(id: 't_platinum', name: 'Platinum', minPoints: 1000000, rank: 3),
];

const List<Challenge> _challenges = [
  Challenge(
    id: 'ch_coco_complete',
    title: 'Eat 4 Coco donuts',
    kind: ChallengeKind.donut,
    progressCurrent: 4,
    progressTarget: 4,
    rewardPoints: 100,
    imageAsset: 'assets/seed/images/c_coco_donut.webp',
    claimed: false,
  ),
  Challenge(
    id: 'ch_coco_progress',
    title: 'Eat 4 Coco donuts',
    kind: ChallengeKind.donut,
    progressCurrent: 1,
    progressTarget: 4,
    rewardPoints: 100,
    imageAsset: 'assets/seed/images/c_coco_donut.webp',
    claimed: false,
  ),
  Challenge(
    id: 'ch_americano',
    title: 'Drink 12 cups americano',
    kind: ChallengeKind.coffee,
    progressCurrent: 9,
    progressTarget: 12,
    rewardPoints: 100,
    imageAsset: 'assets/seed/images/c_americano.webp',
    claimed: false,
  ),
];

void main() {
  testWidgets('shows the gift empty state on the gift tab', (tester) async {
    final tabs = RewardsTabsBloc(initialIndex: 1);
    addTearDown(tabs.close);
    await tester.pumpApp(
      BlocProvider<RewardsTabsBloc>.value(
        value: tabs,
        child: const Scaffold(body: RewardsTabs()),
      ),
      tier: MotionTier.minimal,
    );
    await tester.pump();
    expect(find.byType(EmptyStateView), findsOneWidget);
    expect(find.text('Gifts will appear here soon.'), findsOneWidget);
  });

  group('RewardsScreen', () {
    late _MockSummary summary;
    late _MockTiers tiers;
    late _MockChallenges challenges;
    late RewardsTabsBloc tabs;

    setUp(() {
      summary = _MockSummary();
      tiers = _MockTiers();
      challenges = _MockChallenges();
      tabs = RewardsTabsBloc();
      whenListen(
        summary,
        const Stream<ViewState<MemberProfile>>.empty(),
        initialState: const ViewState.data(_member),
      );
      whenListen(
        tiers,
        const Stream<ViewState<List<Tier>>>.empty(),
        initialState: const ViewState.data(_tiers),
      );
      whenListen(
        challenges,
        const Stream<ViewState<List<Challenge>>>.empty(),
        initialState: const ViewState.data(_challenges),
      );
    });

    tearDown(() async {
      await tabs.close();
    });

    List<BlocProvider<StateStreamableSource<Object?>>> providers() => [
      BlocProvider<RewardsSummaryBloc>.value(value: summary),
      BlocProvider<TierLadderBloc>.value(value: tiers),
      BlocProvider<ChallengesBloc>.value(value: challenges),
      BlocProvider<RewardsTabsBloc>.value(value: tabs),
    ];

    Future<void> pumpRewards(WidgetTester tester) async {
      await tester.pumpApp(
        const RewardsScreen(),
        providers: providers(),
        tier: MotionTier.minimal,
      );
      await tester.pump();
    }

    testWidgets('marks complete challenges with an active Earn chip', (
      tester,
    ) async {
      await pumpRewards(tester);
      expect(find.text('EARN'), findsWidgets);
      expect(find.text('680,000'), findsOneWidget);
      expect(find.text("You're here now"), findsOneWidget);
    });

    testWidgets('survives text scale 1.3 on reference phones', (tester) async {
      for (final size in [
        DeviceMatrix.smallPhone,
        DeviceMatrix.phone,
        DeviceMatrix.largePhone,
      ]) {
        await tester.pumpApp(
          const RewardsScreen(),
          providers: providers(),
          size: size,
          textScale: 1.3,
          tier: MotionTier.minimal,
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('reduce-motion still paints rewards content', (tester) async {
      await pumpRewards(tester);
      expect(find.text("J' Donuts Rewards"), findsOneWidget);
      expect(find.text('680,000'), findsOneWidget);
    });
  });
}
