import 'package:flutter/material.dart';

List<MetroLine> allMetroLines = [
  lineA,
  lineB,
  lineC,
  lineD,
  lineE,
];

MetroLine lineA = MetroLineBuilder(Color(0xffccf041), Offset(0.1, 0.1), [
  StopInfo("Mobile"),
  StopInfo("Web", nameOffset: Offset(-12, -35)),
  StopInfo("Desktop", nameOffset: Offset(20, -7)),
  StopInfo("The Unknown", nameOffset: Offset(20, -7)),
]).addTrack(
  [
    Offset(0.1, 0.25),
    Offset(0.25, 0.25),
    Offset(0.38, 0.3),
  ],
).addTrack(
  [
    Offset(0.4, 0.4),
    Offset(0.4, 0.6),
    Offset(0.75, 0.7),
    Offset(0.75, 0.8),
  ],
).addTrack(
  [Offset(0.75, 0.95)],
).build();

MetroLine lineB = MetroLineBuilder(Color(0xff00fcfc), Offset(0.2, 0.6), [
  StopInfo("Provider", nameOffset: Offset(-25, 20)),
  StopInfo("Sqflite", nameOffset: Offset(-55, -7)),
  StopInfo("Bloc", nameOffset: Offset(-15, -35)),
  StopInfo("Firebase", nameOffset: Offset(-35, 20)),
]).addTrack(
  [
    Offset(0.2, 0.3),
  ],
).addTrack(
  [
    Offset(0.2, 0.15),
    Offset(0.3, 0.15),
  ],
).addTrack(
  [Offset(0.95, 0.35)],
).build();

MetroLine lineC = MetroLineBuilder(Color(0xffed00fa), Offset(0.25, 0.9), [
  StopInfo("Row", nameOffset: Offset(-17, 20)),
  StopInfo("Column", nameOffset: Offset(20, -10)),
  StopInfo("Stack", nameOffset: Offset(-15, -35)),
]).addTrack(
  [
    Offset(0.25, 0.8),
    Offset(0.33, 0.77),
    Offset(0.33, 0.7),
  ],
).addTrack(
  [
    Offset(0.33, 0.5),
    Offset(0.55, 0.35),
    Offset(0.6, 0.15),
  ],
).build();

MetroLine lineD = MetroLineBuilder(Color(0xffff5a83), Offset(0.12, 0.5), [
  StopInfo("Design", nameOffset: Offset(-40, 20)),
  StopInfo("Test", nameOffset: Offset(-12, -35)),
  StopInfo("Develop", nameOffset: Offset(-5, 20)),
  StopInfo("Release"),
]).addTrack(
  [
    Offset(0.12, 0.4),
    Offset(0.29, 0.4),
  ],
).addTrack(
  [
    Offset(0.65, 0.4),
    Offset(0.65, 0.35),
    Offset(0.7, 0.32),
  ],
).addTrack(
  [
    Offset(0.9, 0.24),
    Offset(0.90, 0.17),
  ],
).build();

MetroLine lineE = MetroLineBuilder(Color(0xFF1ad7a3), Offset(0.94, 0.6), [
  StopInfo("Widget"),
  StopInfo("Element"),
  StopInfo("Render Object", nameOffset: Offset(-35, 20)),
]).addTrack(
  [
    Offset(0.71, 0.55),
  ],
).addTrack(
  [
    Offset(0.57, 0.55),
    Offset(0.51, 0.8),
  ],
).build();

class MetroLine {
  final Color color;
  final List<MetroTrack> tracks;
  final List<Offset> stops;
  final List<StopInfo> stopInfos;

  MetroLine(this.color, this.tracks, this.stops, this.stopInfos);

  List<Offset> getPoints() {
    List<Offset> points = [tracks.first.points.first];
    for (var segment in tracks) {
      points.addAll(segment.points.skip(1));
    }
    return points;
  }
}

class MetroTrack {
  final List<Offset> points;
  Map<int, double> trainsMap = {};

  MetroTrack(this.points);

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
  List<Offset> _stops = [];
  List<MetroTrack> _tracks = [];
  MetroTrack _currentTrack;
  final List<StopInfo> stopInfos;

  MetroLineBuilder(this.color, Offset start, this.stopInfos) {
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
    return MetroLine(color, _tracks, _stops, stopInfos);
  }
}

class StopInfo {
  final String name;
  final Offset nameOffset;

  StopInfo(this.name, {this.nameOffset});
}
