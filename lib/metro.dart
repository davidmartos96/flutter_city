import 'dart:async';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hack20/cyber_shape.dart';
import 'package:hack20/metro_line.dart';
import 'package:hack20/metro_map.dart';

class MetroPage extends StatelessWidget {
  const MetroPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TyperText(
            "FLUTTER CITY",
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
    Key key,
  }) : super(key: key);

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TyperAnimatedTextKit(
        speed: Duration(milliseconds: 100),
        pause: Duration(days: 1),
        text: [
          text,
        ],
        textStyle: style,
        textAlign: TextAlign.start,
        alignment: AlignmentDirectional.topStart // or Alignment.topLeft
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
  List<AnimationController> controllers = [];
  var _globalTrainId = 0;

  MetroLine selectedMetroLine;
  int selectedMetroStopIndex;

  AnimationController selectedTrackAnimController;

  @override
  void initState() {
    super.initState();

    selectedTrackAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    selectedTrackAnimController.addListener(() {
      setState(() {});
    });

    //addTrain(lineA.tracks.first);
    addTrain(lineA.tracks[1]);
  }

  void addTrain(MetroTrack track) {
    final controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5));

    final currentTrainId = _globalTrainId;
    _globalTrainId++;

    track.trainsMap[currentTrainId] = 0;
    controller.addListener(() {
      final t = controller.value;
      track.trainsMap[currentTrainId] = t;

      setState(() {});
    });

    controller.forward();
    controllers.add(controller);
  }

  @override
  Widget build(BuildContext context) {
    const double selectionHeight = 105;
    return Stack(
      children: <Widget>[
        BackgroundGrid(),
        Padding(
          padding: const EdgeInsets.only(bottom: selectionHeight),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double height = constraints.maxHeight;
              final double width = constraints.maxWidth;

              final metroLines = allMetroLines;
              return Stack(
                children: <Widget>[
                  CustomPaint(
                    painter: MetroMapPainter(
                      metroLines,
                      selectedMetroLine,
                      selectedMetroStopIndex,
                      selectedTrackAnimController.value,
                    ),
                    child: Container(),
                  ),
                  ...getOverlays(metroLines, width, height),
                ],
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: selectionHeight,
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
      ],
    );
  }

  List<Widget> getOverlays(
      List<MetroLine> metroLines, double width, double height) {
    List<Widget> list = [];
    for (var metroLine in metroLines) {
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
        list.add(
          Positioned(
            top: stopNamePos.dy,
            left: stopNamePos.dx,
            child: TyperText(info.name
                //stopPosRel.toString().substring(6),
                ),
          ),
        );

        // Stop name
        const size = 36.0;
        list.add(
          Positioned(
            top: stopPos.dy - size / 2,
            left: stopPos.dx - size / 2,
            child: GestureDetector(
              onTap: () {
                print("METRO LINE TAPPED $metroLine  ${info.name}");
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
    }
    return list;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Station",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              StopStatus(),
            ],
          ),
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

class StopStatus extends StatelessWidget {
  const StopStatus({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "OK",
      style: TextStyle(
        color: Color.fromRGBO(39, 174, 96, 1.0),
        fontWeight: FontWeight.bold,
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
    secondsRemaining = 10 + r.nextInt(40);
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
