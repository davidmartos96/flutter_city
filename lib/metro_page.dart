import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttercity/cyber_shape.dart';
import 'package:fluttercity/metro_line.dart';
import 'package:fluttercity/metro_map.dart';
import 'package:fluttercity/selection_panel.dart';
import 'package:fluttercity/typer_texts.dart';

class MetroPage extends StatelessWidget {
  const MetroPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FlutterCityTitle(),
        centerTitle: true,
      ),
      body: MetroCanvas(),
    );
  }
}

class MetroCanvas extends StatefulWidget {
  const MetroCanvas({Key key}) : super(key: key);

  @override
  _MetroCanvasState createState() => _MetroCanvasState();
}

class _MetroCanvasState extends State<MetroCanvas>
    with TickerProviderStateMixin {
  int _globalTrainId = 0;

  MetroLine selectedMetroLine;
  int selectedMetroStopIndex;

  AnimationController initAnimController, selectedStopAnimController;
  List<AnimationController> trainAnimControllers = [];
  Timer spawnerTimer;

  List<Widget> overlays = [];

  GlobalKey canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Controller for the metro initialization
    initAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );
    initAnimController.addListener(() {
      setState(() {});
    });

    // Controller for the metro stop selection
    selectedStopAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    selectedStopAnimController.addListener(() {
      setState(() {});
    });
  }

  void startMetroStation() {
    // Get canvas size in the next frame
    final box = canvasKey.currentContext.findRenderObject() as RenderBox;

    initializeOverlays(allMetroLines, box.size.width, box.size.height);
    initializeSpawner(box.size);
  }

  @override
  void dispose() {
    initAnimController.dispose();
    selectedStopAnimController.dispose();
    spawnerTimer?.cancel();
    trainAnimControllers.forEach((c) {
      c.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double bottomPanelHeight = 105;

    return Stack(
      children: <Widget>[
        BackgroundGrid(),
        Padding(
          padding: const EdgeInsets.only(bottom: bottomPanelHeight),
          child: Stack(
            key: canvasKey,
            children: <Widget>[
              CustomPaint(
                painter: MetroMapPainter(
                  allMetroLines,
                  selectedMetroLine,
                  selectedMetroStopIndex,
                  initAnimController.value,
                  selectedStopAnimController.value,
                ),
                child: Container(),
              ),
              ...overlays,
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: bottomPanelHeight,
            child: (selectedMetroStopIndex != null)
                ? KeyedSubtree(
                    key: ValueKey(
                        "${selectedMetroLine.hashCode} $selectedMetroStopIndex"),
                    child: SelectionPanel(
                      selectedMetroLine,
                      selectedMetroStopIndex,
                    ),
                  )
                : null,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: bottomPanelHeight,
            child: Center(
              child: buildStartButton(),
            ),
          ),
        ),
      ],
    );
  }

  void initializeSpawner(Size size) {
    Random r = Random();
    // Spawn trains at the beginning
    trySpawnTrains(r, 0.8);

    // Periodically try to spawn certain objects with different probabilities
    spawnerTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      trySpawnTrains(r, 0.3);

      // Spawn event
      if (r.nextDouble() < 0.13) {
        const eventDuration = Duration(milliseconds: 3000);

        final int tick = timer.tick;
        Widget eventOverlay = Positioned(
          key: ValueKey(tick),
          left: r.nextDouble() * size.width,
          top: r.nextDouble() * size.height,
          child: buildEventRipple(eventDuration),
        );
        overlays.add(eventOverlay);

        Timer(eventDuration, () {
          overlays.removeWhere((w) => w.key == ValueKey(tick));
        });
      }

      setState(() {});
    });
  }

  void trySpawnTrains(Random r, double chance) {
    for (var metroLine in allMetroLines) {
      if (r.nextDouble() < chance) {
        int trackIndex = r.nextInt(metroLine.tracks.length);
        int millis = 1000 + r.nextInt(3000);
        addTrain(metroLine.tracks[trackIndex], Duration(milliseconds: millis));
      }
    }
  }

  void addTrain(MetroTrack track, Duration duration) {
    // Each train needs an animation controller
    final controller = AnimationController(vsync: this, duration: duration);

    final currentTrainId = _globalTrainId;
    _globalTrainId++;

    track.trainsMap[currentTrainId] = 0;
    controller.addListener(() {
      final t = controller.value;

      if (t == 1.0) {
        // Dispose the controller once the animation finishes
        track.trainsMap.remove(currentTrainId);
        controller.dispose();
      } else {
        // Update the train animation value
        track.trainsMap[currentTrainId] = t;
      }

      setState(() {});
    });

    controller.forward();

    trainAnimControllers.add(controller);
  }

  void initializeOverlays(
      List<MetroLine> metroLines, double width, double height) async {
    Random r = Random();
    for (var metroLine in metroLines..shuffle()) {
      // Add stop labels at different points in time, so that they are not in sync
      await Future.delayed(Duration(milliseconds: 500));

      for (int i = 0; i < metroLine.stops.length; i++) {
        StopInfo info = metroLine.stopInfos[i];
        Offset stopPosRel = metroLine.stops[i];
        Offset stopPos = stopPosRel.scale(width, height);

        Offset stopNamePos = stopPos;
        if (info.nameOffset != null) {
          stopNamePos += info.nameOffset;
        } else {
          // Default offset
          stopNamePos += Offset(-20, -39);
        }

        // Stop name
        overlays.add(
          Positioned(
            top: stopNamePos.dy,
            left: stopNamePos.dx,
            child: TyperText(
              info.name,
              pause: Duration(milliseconds: 2000 + r.nextInt(2000)),
            ),
          ),
        );

        // Gesture detector
        const size = 36.0;
        overlays.add(
          Positioned(
            top: stopPos.dy - size / 2,
            left: stopPos.dx - size / 2,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedMetroLine = metroLine;
                  selectedMetroStopIndex = i;
                });
                selectedStopAnimController.repeat(reverse: true);
              },
              child: Container(
                height: size,
                width: size,
                color: Colors.transparent,
              ),
            ),
          ),
        );
      }
      setState(() {});
    }
  }

  Widget buildStartButton() {
    return Opacity(
      opacity: 1 - initAnimController.value,
      child: FlatButton(
        padding: EdgeInsets.symmetric(
          vertical: 20.0,
          horizontal: 40.0,
        ),
        shape: buildCyberBorder(radius: 25),
        child: Text(
          "START",
          style: GoogleFonts.audiowide(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.black,
          ),
        ),
        color: Colors.white,
        onPressed: initAnimController.isAnimating
            ? () {}
            : () {
                initAnimController
                    .forward()
                    .then((value) => startMetroStation());
              },
      ),
    );
  }

  Widget buildEventRipple(Duration eventDuration) {
    return SpinKitRipple(
      color: Theme.of(context).accentColor,
      size: 80.0,
      borderWidth: 10,
      duration:
          Duration(milliseconds: (eventDuration.inMilliseconds / 2).round()),
    );
  }
}

class BackgroundGrid extends StatelessWidget {
  const BackgroundGrid({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridPaper(
      interval: 70,
      divisions: 4,
      subdivisions: 1,
      color: Colors.white24,
      child: Container(),
    );
  }
}
