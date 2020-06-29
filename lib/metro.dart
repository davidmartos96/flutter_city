import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hack20/cyber_shape.dart';
import 'package:hack20/metro_line.dart';
import 'package:hack20/metro_map.dart';

class MetroPage extends StatelessWidget {
  const MetroPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: ColorizeAnimatedTextKit(
            text: ["FLUTTER CITY"],
            pause: Duration(milliseconds: 3000),
            textStyle: GoogleFonts.audiowide(
                fontWeight: FontWeight.bold, fontSize: 24),
            repeatForever: true,
            colors: [
              Color(0xffff19de),
              Color(0xff00e7fb),
              Color(0xff6b38e7),
            ],
          ),
          centerTitle: true,
        ),
        body: MetroCanvas());
  }
}

class TyperText extends StatelessWidget {
  const TyperText(
    this.text, {
    this.style,
    this.pause = const Duration(days: 1),
    Key key,
  }) : super(key: key);

  final String text;
  final TextStyle style;
  final Duration pause;

  @override
  Widget build(BuildContext context) {
    return TyperAnimatedTextKit(
      speed: Duration(milliseconds: 100),
      pause: pause,
      text: [
        text,
      ],
      textStyle: style,
      textAlign: TextAlign.start,
      alignment: AlignmentDirectional.topStart,
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
  var _globalTrainId = 0;

  MetroLine selectedMetroLine;
  int selectedMetroStopIndex;

  AnimationController initAnimController, selectedTrackAnimController;

  List<Widget> overlays = [];

  GlobalKey canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initAnimController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2500));
    initAnimController.addListener(() {
      setState(() {});
    });

    selectedTrackAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    selectedTrackAnimController.addListener(() {
      setState(() {});
    });
  }

  void startMetroStation() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final box = canvasKey.currentContext.findRenderObject() as RenderBox;
      initializeOverlays(allMetroLines, box.size.width, box.size.height);

      initializeSpawner(box.size);
    });
  }

  void initializeSpawner(Size size) {
    Random r = Random();
    trySpawnTrains(r, 0.8);

    Timer.periodic(Duration(milliseconds: 300), (timer) {
      trySpawnTrains(r, 0.3);

      if (r.nextDouble() < 0.13) {
        const lastDuration = Duration(milliseconds: 3000);
        // Event
        final int tick = timer.tick;
        Widget eventOverlay = Positioned(
          key: ValueKey(tick),
          left: r.nextDouble() * size.width,
          top: r.nextDouble() * size.height,
          child: SpinKitRipple(
            color: Colors.red,
            size: 80.0,
            borderWidth: 10,
            duration: Duration(milliseconds: (lastDuration.inMilliseconds / 2).round()) ,
          ),
        );
        overlays.add(eventOverlay);

        Timer(lastDuration, () {
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
    final controller = AnimationController(vsync: this, duration: duration);

    final currentTrainId = _globalTrainId;
    _globalTrainId++;

    track.trainsMap[currentTrainId] = 0;
    controller.addListener(() {
      final t = controller.value;

      if (t == 1.0) {
        track.trainsMap.remove(currentTrainId);
        controller.dispose();
      } else {
        track.trainsMap[currentTrainId] = t;
      }

      setState(() {});
    });

    controller.forward();
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
                  selectedTrackAnimController.value,
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
                ? Align(
                    key: ValueKey("$selectedMetroLine $selectedMetroStopIndex"),
                    alignment: Alignment.bottomCenter,
                    child: buildSelection(
                        selectedMetroLine, selectedMetroStopIndex),
                  )
                : SizedBox(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: bottomPanelHeight,
            child: Center(
              child: Opacity(
                opacity: 1 - initAnimController.value,
                child: FlatButton(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 40.0,
                  ),
                  shape: buildCyberBorder(),
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  void initializeOverlays(
      List<MetroLine> metroLines, double width, double height) async {
    Random r = Random();
    for (var metroLine in metroLines..shuffle()) {
      await Future.delayed(Duration(milliseconds: 100));
      for (int i = 0; i < metroLine.stops.length; i++) {
        StopInfo info = metroLine.stopInfos[i];
        Offset stopPosRel = metroLine.stops[i];
        Offset stopPos = stopPosRel.scale(width, height);

        Offset stopNamePos = stopPos;
        if (info.nameOffset != null) {
          stopNamePos += info.nameOffset;
        } else {
          stopNamePos += Offset(-20, -39);
        }

        // Stop name
        overlays.add(
          Positioned(
            top: stopNamePos.dy,
            left: stopNamePos.dx,
            child: TyperText(
              info.name,
              //stopPosRel.toString().substring(6),
              pause: Duration(milliseconds: 2000 + r.nextInt(2000)),
            ),
          ),
        );

        // Stop name
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
                selectedTrackAnimController.repeat(reverse: true);
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

  Widget buildSelection(MetroLine metroLine, int stopIndex) {
    StopInfo stopInfo = metroLine.stopInfos[stopIndex];
    String stopName = stopInfo.name;
    Color stopColor = metroLine.color;

    Widget child = Container(
      margin: EdgeInsets.only(left: 20, bottom: 10, right: 20),
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 20.0,
      ),
      width: double.infinity,
      decoration: ShapeDecoration(
          shape: buildCyberBorderOutline(),
          color: Theme.of(context).primaryColor),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Station",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    StopColorIndicator(stopColor),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      stopName,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                NextTrainDetails(),
              ],
            ),
          ),
          SpinKitWave(
            color: Colors.white,
            size: 40.0,
          ),
        ],
      ),
    );

    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: Offset(0, 1), end: Offset.zero),
      duration: Duration(milliseconds: 400),
      builder: (context, Offset offset, child) {
        return FractionalTranslation(
          translation: offset,
          child: child,
        );
      },
      child: child,
    );
  }
}

class StopColorIndicator extends StatelessWidget {
  const StopColorIndicator(this.color, {Key key}) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: ShapeDecoration(
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(100)),
        color: color,
      ),
    );
  }
}

class NextTrainDetails extends StatefulWidget {
  const NextTrainDetails({Key key}) : super(key: key);

  @override
  _NextTrainDetailsState createState() => _NextTrainDetailsState();
}

class _NextTrainDetailsState extends State<NextTrainDetails> {
  Timer timer;

  int secondsRemaining;
  int trainId;

  @override
  void initState() {
    super.initState();
    Random r = Random();
    trainId = 1000 + r.nextInt(9000);
    secondsRemaining = 5 + r.nextInt(5);
    timer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      setState(() {
        secondsRemaining -= 1;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (secondsRemaining >= 0) ...[
          Text("Train $trainId arriving in "),
          TyperText(
            "$secondsRemaining",
            key: ValueKey(secondsRemaining),
          ),
          Text(" seconds")
        ] else
          TyperText(
            "Train $trainId is leaving...",
          ),
      ],
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
      child: Container(
          //color: Colors.blue,
          ),
    );
  }
}
