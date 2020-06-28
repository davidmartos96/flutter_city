import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:hack20/metro_line.dart';
import 'package:hack20/metro_map.dart';

class MetroPage extends StatelessWidget {
  const MetroPage({Key key}) : super(key: key);

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
