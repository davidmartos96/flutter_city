import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hack20/metro_line.dart';
import 'dart:math';

double stopRadius = 15;
double lineStroke = 8;

class MetroMapPainter extends CustomPainter {
  final List<MetroLine> metroLines;

  MetroMapPainter(this.metroLines);
  @override
  void paint(Canvas canvas, Size size) {
    print("Canvas size");
    print(size);

    for (var metroLine in metroLines) {
      paintMetroLine(canvas, size, metroLine);
    }
  }

  void paintMetroLine(Canvas canvas, Size size, MetroLine metroLine) {
    var paint = Paint()
      ..color = metroLine.color
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

    paintStops(canvas, size, metroLine);

    for (var track in metroLine.tracks) {
      if (track.trainsMap.isNotEmpty) {
        paintTrains(canvas, size, track);
      }
    }
  }

  void paintStops(Canvas canvas, Size size, MetroLine metroLine) {
    var paint = Paint()
      ..color = metroLine.color
      ..strokeWidth = lineStroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    for (var stop in metroLine.stops) {
      canvas.drawCircle(
        Offset(stop.dx * size.width, stop.dy * size.height),
        stopRadius,
        paint,
      );

      paint.color = Colors.white;
      canvas.drawCircle(
        Offset(stop.dx * size.width, stop.dy * size.height),
        stopRadius / 3,
        paint,
      );
      paint.color = metroLine.color;
    }
  }

  void paintTrains(Canvas canvas, Size size, MetroTrack track) {
    var paint = Paint()
      ..color = Colors.white
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
      final offset =
          (start + normDif * traveledDistance).scale(size.width, size.height);

      var rect = offset & Size(45, 25);

      final angle = atan2(start.dy - end.dy, start.dx - end.dx);
      rect = rect.shift(Offset(-rect.width / 2, -rect.height / 2));
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
