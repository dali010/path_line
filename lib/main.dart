import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DrawLineScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DrawLineScreen extends StatefulWidget {
  const DrawLineScreen({super.key});


  @override
  State<DrawLineScreen> createState() => _DrawLineScreenState();
}

class _DrawLineScreenState extends State<DrawLineScreen> {
  final List<Offset> _points = [];
  final List<List<Offset>> _lines = [];
  final Map<int, Offset?> _controlPoints = {};
  bool _isDragging = false;
  bool _isNewLine = false;

  // Method to add a point
  void _addPoint(Offset tappedPoint) {
    if (_isDragging) return; // Prevent adding points while dragging

    Offset? nearbyPoint = _findNearbyPoint(tappedPoint);
    Offset pointToUse = nearbyPoint ?? tappedPoint;

    setState(() {
      if (_isNewLine) {
        _points.clear();
        _points.add(pointToUse);
        _isNewLine = false;
      } else if (_points.isEmpty && _lines.isEmpty) {
        _points.add(pointToUse);
      } else if (_points.length == 1) {
        _points.add(pointToUse);
        _lines.add(List.from(_points));
        _points.clear();
      } else if (_lines.isNotEmpty) {
        _points.add(_lines.last[1]);
        _points.add(pointToUse);
        _lines.add(List.from(_points));
        _points.clear();
      }
    });
  }

  // Method to handle starting a new independent line
  void _startNewLine() {
    setState(() {
      _isNewLine = true;
    });
  }

  // Method to handle the long press start event
  void _onLongPressStart(LongPressStartDetails details) {
    Offset pressedPoint = details.localPosition;

    if (_lines.isNotEmpty) {
      final lastLine = _lines.last;

      if ((pressedPoint - lastLine[1]).distance <= 10.0) {
        setState(() {
          _controlPoints[_lines.length - 1] = pressedPoint;
          _isDragging = true;
        });
      }
    }
  }

  // Method to handle finger movement during long press
  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _controlPoints[_lines.length - 1] = details.localPosition; // Update control point
      });
    }
  }

  // Method to handle the end of the long press
  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _isDragging = false; // Stop dragging
    });
  }

  // Function to find nearby point within 10.0 radius
  Offset? _findNearbyPoint(Offset tappedPoint) {
    const double radius = 10.0;

    for (final line in _lines) {
      for (final point in line) {
        if ((point - tappedPoint).distance <= radius) {
          return point;
        }
      }
    }

    for (final point in _points) {
      if ((point - tappedPoint).distance <= radius) {
        return point;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elastic Segment Example'),
        actions: [
          IconButton(
            onPressed: _startNewLine,
            icon: const Icon(Icons.add),
            tooltip: 'Start New Independent Line',
          ),
        ],
      ),
      body: GestureDetector(
        onTapDown: (TapDownDetails details) {
          _addPoint(details.localPosition); // Add points on tap
        },
        onLongPressStart: _onLongPressStart,
        onLongPressMoveUpdate: _onLongPressMoveUpdate,
        onLongPressEnd: _onLongPressEnd,
        child: CustomPaint(
          painter: LinePainter(
            lines: _lines,
            controlPoints: _controlPoints,
            currentPoints: _points, // Show points that were clicked
          ),
          child: Container(),
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<List<Offset>> lines;
  final Map<int, Offset?> controlPoints;
  final List<Offset> currentPoints; // Keep track of currently added points

  LinePainter({required this.lines, required this.controlPoints, required this.currentPoints});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw all the lines
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final controlPoint = controlPoints[i];

      if (controlPoint != null) {
        // Draw a quadratic Bézier curve if a control point is set
        final path = Path();
        path.moveTo(line[0].dx, line[0].dy);
        path.quadraticBezierTo(
          controlPoint.dx, controlPoint.dy,
          line[1].dx, line[1].dy,
        );
        canvas.drawPath(path, paint);
      } else {
        // Draw a straight line if no control point is set
        canvas.drawLine(line[0], line[1], paint);
      }
    }

    // Draw small red circles at all completed line points
    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (final line in lines) {
      canvas.drawCircle(line[0], 5.0, pointPaint); // Circle at the first point
      canvas.drawCircle(line[1], 5.0, pointPaint); // Circle at the second point
    }

    // Draw circles for control points (if any)
    for (final controlPoint in controlPoints.values) {
      if (controlPoint != null) {
        final controlPointPaint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;
        canvas.drawCircle(controlPoint, 5.0, controlPointPaint);
      }
    }

    // Draw circles for the clicked points
    for (final point in currentPoints) {
      canvas.drawCircle(point, 5.0, pointPaint); // Circle for each clicked point
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
}



