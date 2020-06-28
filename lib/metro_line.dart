import 'package:flutter/material.dart';

class MetroLine {
  final Color color;
  final List<MetroSegment> segments;
  final Set<Offset> stops;

  MetroLine(this.color, this.segments, this.stops)
      : assert(
            stops.containsAll(
                [segments.first.points.first, segments.first.points.last]),
            "Begin and end must be stops");

  List<Offset> getPoints() {
    List<Offset> points = [segments.first.points.first];
    for (var segment in segments) {
      points.addAll(segment.points.skip(1));
    }
    return points;
  }
}

MetroLine lineA = MetroLineBuilder(
  Colors.pink,
  Offset(0.1, 0.1),
).addSegment(
  [Offset(0.4, 0.1)],
).addSegment(
  [Offset(0.6, 0.5), Offset(0.75, 0.5)],
).addSegment(
  [Offset(0.9, 0.5)],
).build();

class MetroSegment {
  final List<Offset> points;

  MetroSegment(this.points) : assert(points.length > 1);

  double distance() {
    return getDistances().reduce((a, b) => a + b);
  }

  List<double> getDistances() {
    List<double> distances = [];
    for (var i = 0; i < points.length - 1; i++) {
      Offset o1 = points[i];
      Offset o2 = points[i + 1];
      distances.add((o1 - o2).distance);
    }
    return distances;
  }
}

class MetroLineBuilder {
  final Color color;
  Set<Offset> _stops = {};
  List<MetroSegment> _segments = [];
  MetroSegment _currentSegment;

  MetroLineBuilder(this.color, Offset start) {
    _stops.add(start);
    _currentSegment = MetroSegment([start]);
  }

  MetroLineBuilder addSegment(List<Offset> offsets) {
    _currentSegment.points.addAll(offsets);
    _segments.add(_currentSegment);

    Offset last = offsets.last;
    _stops.add(last);

    _currentSegment = MetroSegment([last]);

    return this;
  }

  MetroLine build() {
    return MetroLine(color, _segments, _stops);
  }
}
