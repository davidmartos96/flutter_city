import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlutterCityTitle extends StatelessWidget {
  const FlutterCityTitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColorizeAnimatedTextKit(
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
    );
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
