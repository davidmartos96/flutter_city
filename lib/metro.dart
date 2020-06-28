import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hack20/metro_line.dart';
import 'package:hack20/metro_map.dart';

class MetroPage extends StatefulWidget {
  const MetroPage({Key key}) : super(key: key);

  @override
  _MetroPageState createState() => _MetroPageState();
}

class _MetroPageState extends State<MetroPage> with TickerProviderStateMixin {
  List<AnimationController> controllers = [];
  var _globalTrainId = 0;

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 250.0,
          child: TyperAnimatedTextKit(
              speed: Duration(milliseconds: 100),
              pause: Duration(days: 1),
              text: [
                "My app",
              ],
              textAlign: TextAlign.start,
              alignment: AlignmentDirectional.topStart // or Alignment.topLeft
              ),
        ),
      ),
      body: CustomPaint(
        painter: MetroMapPainter([lineA]),
        child: Container(),
      ),
    );
  }
}
