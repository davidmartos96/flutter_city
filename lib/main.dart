import 'package:flutter/material.dart';

import 'package:hack20/metro_page.dart';
import 'package:hack20/theme.dart';

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
