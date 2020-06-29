import 'package:flutter/material.dart';

import 'package:fluttercity/metro_page.dart';
import 'package:fluttercity/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: createTheme(),
      home: MetroPage(), // MyHomePage(),
    );
  }
}
