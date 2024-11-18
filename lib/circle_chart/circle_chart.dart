import 'dart:math';

import 'package:flutter/material.dart';

import 'position_painter.dart';

const _dummyShots = [
  ShotPosition(
    startDistanceToHole: 120,
    endDistanceToHole: 3,
    orientationAngle: 30,
  ),
  ShotPosition(
    startDistanceToHole: 35,
    endDistanceToHole: 2,
    orientationAngle: 18,
  ),
  ShotPosition(
    startDistanceToHole: 50,
    endDistanceToHole: 5,
    orientationAngle: 90,
  ),
  ShotPosition(
    startDistanceToHole: 100,
    endDistanceToHole: 10,
    orientationAngle: 180,
  ),
  ShotPosition(
    startDistanceToHole: 80,
    endDistanceToHole: 4,
    orientationAngle: 270,
  ),
];

class CircleChartRing {
  final double upperLimit;
  final bool showLabel;

  const CircleChartRing({
    required this.upperLimit,
    required this.showLabel,
  });
}

/// Configures a [CircleChart].
/// [ringUpperLimits] should be a list of values in ascending order, from 0.0 to 1.0.
class CircleChartConfig {
  final Color fillColor;
  final Color strokeColor;
  final List<CircleChartRing> rings;

  const CircleChartConfig({
    this.fillColor = const Color(0xff90cf8d),
    this.strokeColor = Colors.white,
    this.rings = const [
      CircleChartRing(upperLimit: 0.05, showLabel: true),
      CircleChartRing(upperLimit: 0.12, showLabel: true),
      CircleChartRing(upperLimit: 1, showLabel: false),
    ],
  });
}

class ShotPosition {
  final double startDistanceToHole;
  final double endDistanceToHole;
  final double orientationAngle;

  const ShotPosition({
    required this.startDistanceToHole,
    required this.endDistanceToHole,
    required this.orientationAngle,
  });
}

class CircleChart extends StatelessWidget {
  final CircleChartConfig config;

  const CircleChart({
    super.key,
    required this.config,
  });

  PolarPosition _clampWithinRange(ShotPosition shot) {
    final ringWidth = 1 / config.rings.length;
    final absoluteMagnitude = shot.endDistanceToHole / shot.startDistanceToHole;

    final containingRingIndex = config.rings.indexWhere(
      (ring) => absoluteMagnitude <= ring.upperLimit,
    );

    if (containingRingIndex == -1) {
      return PolarPosition(
        distance: 1,
        angle: shot.orientationAngle,
        strokeColor: Colors.red,
        debugSource: shot,
      );
    }

    if (containingRingIndex == 0) {
      final clampedRatio =
          (absoluteMagnitude - 0) / (config.rings[0].upperLimit - 0);

      final interpolatedRatio = interpolate(0, ringWidth, clampedRatio);

      return PolarPosition(
        distance: interpolatedRatio,
        angle: shot.orientationAngle,
        strokeColor: Colors.red,
        debugSource: shot,
      );
    }

    final clampedRatio =
        (absoluteMagnitude - config.rings[containingRingIndex - 1].upperLimit) /
            (config.rings[containingRingIndex].upperLimit -
                config.rings[containingRingIndex - 1].upperLimit);

    final interpolatedRatio = interpolate(
      ringWidth * containingRingIndex,
      ringWidth * (containingRingIndex + 1),
      clampedRatio,
    );

    return PolarPosition(
      distance: interpolatedRatio,
      angle: shot.orientationAngle,
      strokeColor: Colors.red,
      debugSource: shot,
    );
  }

  double interpolate(double start, double end, double percentage) {
    return start + (end - start) * (percentage);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      config.rings.isNotEmpty,
      'percentageSegments must not be empty',
    );

    assert(
      config.rings.map((r) => r.upperLimit).fold<double>(
                0.0,
                (last, current) => switch ((last, current)) {
                  (-1, _) => -1,
                  (double last, double current) when current < last => -1,
                  _ => current,
                },
              ) >=
          0,
      'percentageSegments must be in ascending order',
    );

    final positions = _dummyShots.map(_clampWithinRange).toList();

    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final smallerDimension =
              min(constraints.maxWidth, constraints.maxHeight);

          final size = Size.square(smallerDimension * 0.8);

          return CustomPaint(
            size: size,
            painter: PositionPainter(
              rings: config.rings
                  .map(
                    (r) => PositionPainterRing(
                      fillColor: config.fillColor,
                      outerBorderColor: config.strokeColor,
                      outerRingWidth: 3,
                      outerLabel: r.showLabel
                          ? '${(r.upperLimit * 100).toStringAsFixed(0)}%'
                          : null,
                    ),
                  )
                  .toList(),
              positions: positions,
            ),
          );
        },
      ),
    );
  }
}
