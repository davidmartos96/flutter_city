import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttercity/cyber_shape.dart';
import 'package:fluttercity/metro_line.dart';
import 'package:fluttercity/typer_texts.dart';

class SelectionPanel extends StatelessWidget {
  const SelectionPanel(this.metroLine, this.stopIndex, {Key key})
      : super(key: key);

  final MetroLine metroLine;
  final int stopIndex;

  @override
  Widget build(BuildContext context) {
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
          shape: buildCyberBorderOutline(radius: 20),
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
    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
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
