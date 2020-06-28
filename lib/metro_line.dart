import 'package:flutter/material.dart';

class MetroLine {
  final Color color;
  final List<Offset> points;
  final Set<Offset> stops;

  MetroLine(this.color, this.points, this.stops)
      : assert(stops.containsAll([points.first, points.last]),
            "Begin and end must be stops");
}

MetroLine lineA = MetroLine(
  Colors.pink,
  [
    Offset(0.1, 0.1),
    Offset(0.4, 0.1),
    Offset(0.6, 0.5),
    Offset(0.9, 0.5),
  ],
  {
    Offset(0.1, 0.1),
    Offset(0.4, 0.1),
    Offset(0.75, 0.5),
    Offset(0.9, 0.5),
  },
);
