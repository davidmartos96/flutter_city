import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hack20/cyber_shape.dart';
import 'package:hack20/metro.dart';
import 'package:hack20/video_preview.dart';

void main() {
  runApp(MyApp());
}

ThemeData buildTheme() {
  final TextTheme textTheme = GoogleFonts.shareTechTextTheme(
    ThemeData.dark().textTheme,
  );

  ColorScheme colorScheme = ColorScheme.dark(
    primary: Color(0xFF292a2e),
    surface: Color(0xFF212629),
    secondary: Color(0xFFef1c71), //Color(0xFFeb004a),
    onSecondary: Colors.white,
    background: Color(0xFF111214),
  );

  final themeData = ThemeData.from(
    colorScheme: colorScheme,
    textTheme: textTheme,
  ).copyWith(
      accentTextTheme: textTheme,
      primaryTextTheme: textTheme,
      cursorColor: colorScheme.secondary,
      textSelectionHandleColor: colorScheme.secondary);

  return themeData.copyWith(
    appBarTheme: AppBarTheme(elevation: 0, color: colorScheme.background),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: buildTheme(),
      home: MetroPage(), // MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            //Icon(Feather.zap),
            Icon(MaterialCommunityIcons.gamepad),
            SizedBox(width: 10),
            Text("App name"),
            SizedBox(
              width: 10,
            ),
            Expanded(child: ExpandableInput()),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            VideoPreview(),
            MyButton(),
            FlatButton(
              padding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 40.0,
              ),
              onPressed: () {},
              shape: buildCyberBorderOutline(),
              splashColor: Colors.pink.withOpacity(0.3),
              child: Text(
                "Press me",
                style: TextStyle(fontSize: 16
                    // fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shape = buildCyberBorderOutline();
    return FlatButton(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 40.0,
      ),
      onPressed: () {},
      shape: shape,
      color: Colors.white,
      splashColor: Colors.lightGreenAccent.withOpacity(0.6),
      child: Text(
        "PRESS ME",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class ExpandableInput extends HookWidget {
  const ExpandableInput({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collapsed = useState(true);
    final focusNode = useFocusNode();
    final textController = useTextEditingController();

    useEffect(() {
      var l = () {
        if (!focusNode.hasFocus && textController.text.isEmpty) {
          collapsed.value = true;
        }
      };
      focusNode.addListener(l);
      return () => focusNode.removeListener(l);
    }, []);

    if (collapsed.value) {
      return Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {
            collapsed.value = false;
            focusNode.requestFocus();
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 9.0),
            child: SearchIcon(),
          ),
        ),
      );
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return Align(
          alignment: Alignment.centerRight,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 40, end: constraints.maxWidth),
            duration: Duration(milliseconds: 300),
            builder: (context, double width, Widget child) {
              return CyberSearchInput(
                width: width,
                focusNode: focusNode,
                controller: textController,
              );
            },
          ),
        );
      });
    }
  }
}

class CyberSearchInput extends StatelessWidget {
  const CyberSearchInput({
    Key key,
    this.width,
    this.focusNode,
    @required this.controller,
  }) : super(key: key);

  final double width;
  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shape = buildCyberBorder();
    return Ink(
      width: width,
      decoration: ShapeDecoration(
        shape: shape,
        color: Theme.of(context).primaryColor,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.only(left: 15.0, top: 10, bottom: 10),
          hintText: "Search",
          suffixIcon: InkWell(
            customBorder: CircleBorder(),
            onTap: controller.text.isEmpty
                ? null
                : () {
                    controller.clear();
                  },
            child: Icon(
              controller.text.isEmpty ? Feather.search : Icons.close,
              size: 20,
              color: Colors.white,
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            minHeight: 38,
            minWidth: 38,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class SearchIcon extends StatelessWidget {
  const SearchIcon({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Feather.search,
      size: 20,
      color: Colors.white,
    );
  }
}
