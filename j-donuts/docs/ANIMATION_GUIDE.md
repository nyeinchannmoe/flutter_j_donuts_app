# Animation guide

All motion flows through `lib/core/motion`. The hard rules live in
`.cursor/rules/60-motion-animation.mdc`; this guide explains how the pieces
fit and how to check motion on a device.

## Tokens

`MotionTokens` is the only place that defines motion durations, curves,
scales and distances. The quality gate rejects `Curves.` outside
`MotionTokens`, any `Duration(...)` in presentation code, and any other
`Duration(...)` that is not a named constant (ADR-010).

| Group | Values |
| --- | --- |
| Durations | `micro` 90 ms, `fast` 160 ms, `standard` 260 ms, `emphasized` 420 ms, `entrance` 560 ms, `countUp` 1400 ms, `ambient` 1800 ms, `shimmer` 1300 ms |
| Carousel | `carouselInterval` 4 s, `carouselResumeDelay` 6 s |
| Curves | `standardCurve`, `decelerate`, `accelerate`, `emphasizedCurve`, `popOvershoot`, `shake`, `spring` |
| Stagger | `staggerStep` 90 ms, `staggerItemSpan` 0.55, 8 items at full tier, 3 at reduced |
| Shape | `travelMedium` 32, `pressedScale` 0.96, `popStartScale` 0.6, `pulseScale` 1.06, `fadeThroughStartScale` 0.94, `shakeAmplitude` 10, `maxTilt` 0.18 rad |

Distances and amplitudes are multiplied by `LayoutMetrics.motionScale`, so
motion stays proportional on small phones and tablets.

## Tiers

`MotionPolicy` resolves a `MotionProfile`, read with `context.motion`:

| Tier | When | Effect |
| --- | --- | --- |
| full | Default | Every primitive, ambient motion and depth effects |
| reduced | After sustained jank | Durations times 0.6, 3 staggered items, no ambient or depth |
| minimal | `MediaQuery.disableAnimations` | Entrances and shimmer skipped, every duration capped at a 120 ms fade |

- `FrameBudgetMonitor` counts frames slower than 20 ms in windows of 120
  frames. Two consecutive windows with more than 25 % slow frames lower the
  ceiling from full to reduced once. The ceiling never rises again in that
  session.
- Ambient motion (pulse, carousel autoplay) also pauses while the app is in
  the background.

## Primitives

| Primitive | Use |
| --- | --- |
| `StaggeredEntrance` with `StaggerSchedule` | List and grid entrances from one controller; Welcome clips four hero tiles from one texture |
| `FadeSlideIn` | One-shot fade plus slide |
| `PopIn` | Overshoot scale entrance |
| `PressableScale` (`lib/core/widgets/buttons`) | Press feedback |
| `ShakeOnTrigger` | Error shake when a trigger value changes |
| `CountUpText` | Number count-up, for points |
| `AnimatedQuantityText` | Rolling quantity in steppers |
| `PulseAttention` | Ambient pulse on claimable challenges |
| `SlidingPillIndicator` | Tab and segment indicator |
| `PerspectiveTilt` | Drag tilt with spring-back on the product hero |
| `AutoPlayCarouselController` | Banner autoplay that pauses on touch |
| `MorphingProgressRing` with `ArcSweepPainter` and `CheckMorphPainter` | Challenge progress that ends in a check |
| `MotionTransitions` and `route_transitions.dart` | Shared-axis, fade-through and fade-scale route transitions |
| `FadeThroughTabStack` | Shell tabs that keep state and mute inactive tickers |
| `HeroTags` | Product image hero tags |
| `SkeletonScope` and `SkeletonGroup` | Shared shimmer that only ticks while a skeleton is visible |

## Adding motion

1. Pick an existing primitive. Add a new one only when none fits.
2. Read durations and curves from `MotionTokens` and scale them with
   `context.motion.scaleDuration`.
3. Give the primitive a minimal-tier path and a widget test for both full and
   minimal tiers (see `test/core/motion/motion_primitives_test.dart`).
4. Animate transforms and opacity only.

## Profile-mode checklist

Run `flutter run --profile` on a mid-range Android phone and check:

- Home, product detail and rewards scroll without frames over 20 ms in the
  performance overlay.
- The banner carousel and the challenge pulse stop when the app is
  backgrounded and when you switch tabs.
- With "Remove animations" on in Android accessibility settings, entrances
  are skipped and transitions are short fades.
- The shimmer stops once every skeleton has been replaced by content.
- DevTools shows no growing count of `AnimationController` or `Ticker`
  instances after navigating back and forth.
