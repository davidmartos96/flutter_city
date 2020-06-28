import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hack20/metro_line.dart';

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

    path.moveTo(points.first.dx * size.width,
        points.first.dy * size.height);
    for (var point in points.skip(1)) {
      path.lineTo(point.dx * size.width, point.dy * size.height);
    }

    canvas.drawPath(path, paint);

    paint.style = PaintingStyle.fill;
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
    paint.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
