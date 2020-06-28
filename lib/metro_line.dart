import 'package:flutter/material.dart';

class MetroLine {
  final Color color;
  final List<MetroTrack> tracks;
  final Set<Offset> stops;

  MetroLine(this.color, this.tracks, this.stops)
      : assert(
            stops.containsAll(
                [tracks.first.points.first, tracks.first.points.last]),
            "Begin and end must be stops");

  List<Offset> getPoints() {
    List<Offset> points = [tracks.first.points.first];
    for (var segment in tracks) {
      points.addAll(segment.points.skip(1));
    }
    return points;
  }
}

MetroLine lineA = MetroLineBuilder(
  Colors.pink,
  Offset(0.1, 0.1),
).addTrack(
  [Offset(0.4, 0.1)],
).addTrack(
  [Offset(0.6, 0.5), Offset(0.75, 0.5)],
).addTrack(
  [Offset(0.9, 0.5)],
).build();

class MetroTrack {
  final List<Offset> points;

  MetroTrack(this.points) : assert(points.length > 1);

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
  List<MetroTrack> _tracks = [];
  MetroTrack _currentTrack;

  MetroLineBuilder(this.color, Offset start) {
    _stops.add(start);
    _currentTrack = MetroTrack([start]);
  }

  MetroLineBuilder addTrack(List<Offset> offsets) {
    _currentTrack.points.addAll(offsets);
    _tracks.add(_currentTrack);

    Offset last = offsets.last;
    _stops.add(last);

    _currentTrack = MetroTrack([last]);

    return this;
  }

  MetroLine build() {
    return MetroLine(color, _tracks, _stops);
  }
}
