import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Represents a single datapoint to be displayed in the chart with polar coordinates.
/// [distance] is a double representing the distance from the center of the chart, with 0 being the center, and 1 being the outermost ring.
/// [angle] is a double representing the angle in radians, with 0 being the 3:00 position.
class PolarPosition {
  final double distance;
  final double angle;
  final Color strokeColor;
  final dynamic _debugSource;

  const PolarPosition({
    required this.distance,
    required this.angle,
    required this.strokeColor,
    dynamic debugSource,
  }) : _debugSource = debugSource;
}

class PositionPainterRing {
  final Color fillColor;
  final Color outerBorderColor;
  final double outerRingWidth;
  final String? outerLabel;

  const PositionPainterRing({
    required this.fillColor,
    required this.outerBorderColor,
    required this.outerRingWidth,
    this.outerLabel,
  });
}

class PositionPainter extends CustomPainter {
  final Iterable<PositionPainterRing> rings;
  final Iterable<PolarPosition> positions;

  const PositionPainter({
    required this.rings,
    required this.positions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _BackgroundPainter(rings: rings).paint(canvas, size);

    for (final position in positions) {
      _DatapointPainter(position: position).paint(canvas, size);
    }

    _LabelPainter(rings: rings).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _DatapointPainter extends CustomPainter {
  final PolarPosition position;

  const _DatapointPainter({
    required this.position,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final distance = size.width / 2 * position.distance;

    final point = Offset(
      center.dx + (distance * cos(position.angle)),
      center.dy + distance * sin(position.angle),
    );

    canvas.drawCircle(
      point,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      point,
      8,
      Paint()
        ..color = position.strokeColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _LabelPainter extends CustomPainter {
  final Iterable<PositionPainterRing> rings;

  const _LabelPainter({
    required this.rings,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final radiusStep = (size.width / 2) / rings.length;

    final ringsLabels =
        rings.map((ring) => ring.outerLabel).whereType<String>().toList();

    final labelPainters = List.generate(
      ringsLabels.length,
      (index) => () => _paintLabel(
            canvas,
            size,
            ringsLabels.elementAt(index),
            radiusStep * (index + 1),
          ),
    );

    for (final painter in labelPainters) {
      painter();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _paintLabel(Canvas canvas, Size size, String label, double radiusStep) {
    final labelOffset = Offset(
      size.width * 0.5 + radiusStep,
      size.height / 2,
    );

    const fontSize = 16.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: labelOffset,
          width: textPainter.width + 8,
          height: textPainter.height,
        ),
        const Radius.circular(5),
      ),
      Paint()
        ..color = const Color(0xc0ffffff)
        ..style = PaintingStyle.fill,
    );

    //canvas.drawRRect(
    //  RRect.fromRectAndRadius(
    //    Rect.fromCenter(
    //      center: labelOffset,
    //      width: textPainter.width + 8,
    //      height: textPainter.height,
    //    ),
    //    const Radius.circular(5),
    //  ),
    //  Paint()
    //    ..color = const Color(0xff5a5a5a)
    //    ..strokeWidth = 2
    //    ..style = PaintingStyle.stroke,
    //);

    textPainter.paint(
      canvas,
      Offset(
        labelOffset.dx - (textPainter.width / 2),
        labelOffset.dy - (textPainter.height / 2),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final Iterable<PositionPainterRing> rings;

  const _BackgroundPainter({
    required this.rings,
  });

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final radiusStep = (size.width / 2) / rings.length;

    final circlePainters = List.generate(rings.length, (index) {
      final circleRadius = radiusStep * (index + 1);

      return () => _paintRing(
            canvas,
            size,
            circleRadius,
            rings.elementAt(index).fillColor,
            rings.elementAt(index).outerBorderColor,
            rings.elementAt(index).outerRingWidth,
          );
    });

    for (final painter in circlePainters.reversed) {
      painter();
    }

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _paintRing(
    Canvas canvas,
    Size size,
    double radiusStep,
    Color fillColor,
    Color outerBorderColor,
    double outerRingWidth,
  ) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radiusStep,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radiusStep,
      Paint()
        ..color = outerBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerRingWidth,
    );
  }
}
