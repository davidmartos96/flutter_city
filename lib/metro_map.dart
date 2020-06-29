import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercity/metro_line.dart';
import 'dart:math';

double stopRadius = 15;
double lineStroke = 8;

class MetroMapPainter extends CustomPainter {
  final List<MetroLine> metroLines;
  final MetroLine selectedMetroLine;
  final int selectedMetroStopIndex;

  /// Keeps track of the Flutter Sity start animation
  final double initializationAnimValue;

  /// Keeps track of the selected stop animation
  final double selectionAnimValue;

  MetroMapPainter(
      this.metroLines,
      this.selectedMetroLine,
      this.selectedMetroStopIndex,
      this.initializationAnimValue,
      this.selectionAnimValue);

  Color lineColorBasedOnStatus(MetroLine line) {
    double luminance = line.color.computeLuminance();
    int gray = (luminance * 255).round();
    Color grayColor = Color.fromRGBO(gray, gray, gray, 1.0);

    return Color.lerp(grayColor, line.color, initializationAnimValue);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var metroLine in metroLines) {
      paintMetroLine(canvas, size, metroLine);
    }
  }

  void paintMetroLine(Canvas canvas, Size size, MetroLine metroLine) {
    var paint = Paint()
      ..color = lineColorBasedOnStatus(metroLine).withOpacity(metroLine == selectedMetroLine ? 1.0 : 0.75)
      ..strokeWidth = lineStroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Path path = Path();
    final points = metroLine.getPoints();

    path.moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (var point in points.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }

    canvas.drawPath(path, paint);

    for (var track in metroLine.tracks) {
      if (track.trainsMap.isNotEmpty) {
        paintTrains(canvas, size, metroLine, track);
      }
    }

    paintStops(canvas, size, metroLine);
  }

  void paintStops(Canvas canvas, Size size, MetroLine metroLine) {
    var paint = Paint()
      ..strokeWidth = lineStroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    Color metroLineColor = lineColorBasedOnStatus(metroLine);
    for (var i = 0; i < metroLine.stops.length; i++) {
      var stop = metroLine.stops[i];
      bool selected =
          metroLine == selectedMetroLine && i == selectedMetroStopIndex;

      double radius = stopRadius;
      if (selected) {
        radius = radius + selectionAnimValue * 3;
      }

      paint.color = selected ? Colors.white : metroLineColor;
      canvas.drawCircle(
        Offset(stop.dx * size.width, stop.dy * size.height),
        radius,
        paint,
      );

      Color tmpColor = paint.color;
      paint.color = selected ? metroLineColor : Colors.white;
      canvas.drawCircle(
        Offset(stop.dx * size.width, stop.dy * size.height),
        radius / (selected ? 1.5 : 3),
        paint,
      );
      paint.color = tmpColor;
    }
  }

  void paintTrains(
      Canvas canvas, Size size, MetroLine metroLine, MetroTrack track) {
    var paint = Paint()
      ..color = metroLine.color
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final double trackDistance = track.distance();
    final List<double> segmentDistances = track.getDistances();

    for (var entry in track.trainsMap.entries) {
      final totalTrackPercent = entry.value;
      final int segmentIndex =
          getSegmentIndex(segmentDistances, trackDistance, totalTrackPercent);

      final double prevDistancePercent = (segmentIndex == 0
          ? 0
          : segmentDistances.sublist(0, segmentIndex).reduce((a, b) => a + b) /
              trackDistance);

      final double a1 = prevDistancePercent;
      final double a2 = a1 + segmentDistances[segmentIndex] / trackDistance;
      final double localPercent = mapRange(totalTrackPercent, a1, a2, 0, 1);

      final Offset start = track.points[segmentIndex];
      final Offset end = track.points[segmentIndex + 1];

      final Offset dif = (end - start);

      final Offset normDif = dif / dif.distance;

      final double traveledDistance =
          localPercent * segmentDistances[segmentIndex];
      final offsetRel = (start + normDif * traveledDistance);
      final offset = offsetRel.scale(size.width, size.height);

      const fullTrainWidth = 35.0;
      double trainWidth = fullTrainWidth;
      if (segmentIndex == segmentDistances.length - 1) {
        double distanceToEnd = (end - offsetRel)
            .scale(size.width, size.height)
            .distance;
        trainWidth = min(trainWidth, distanceToEnd);
      }

      var rect = offset & Size(trainWidth, 20);
      rect = rect.shift(Offset(-rect.width / 2, -rect.height / 2));

      Offset diff = (end - start).scale(size.width, size.height);

      final angle = atan2(diff.dy, diff.dx);
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(angle);
      canvas.translate(-rect.center.dx, -rect.center.dy);

      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  double mapRange(
      double valueToMap, double a1, double a2, double b1, double b2) {
    return b1 + (((valueToMap - a1) * (b2 - b1)) / (a2 - a1));
  }

  int getSegmentIndex(List<double> distances, double trackDistance,
      double traveledDistancePercent) {
    double traveled = traveledDistancePercent;

    for (var i = 0; i < distances.length; i++) {
      final segmentDistance = distances[i];
      final percent = segmentDistance / trackDistance;

      traveled -= percent;

      if (traveled <= 0) {
        return i;
      }
    }

    return distances.length - 1;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
