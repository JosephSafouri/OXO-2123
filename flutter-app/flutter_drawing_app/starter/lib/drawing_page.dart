import 'dart:async';

import 'package:drawing_app/drawn_line.dart';
import 'package:drawing_app/sketcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  GlobalKey _globalKey = new GlobalKey();
  List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine line;
  //img
  Color selectedColor = Colors.red;
  double selectedWidth = 5.0;
  bool strokeWidthIsClicked = false;
  List<Color> toolbarColors = [
    Colors.red,
    Colors.blueAccent,
    Colors.deepOrange,
    Colors.green,
    Colors.lightBlue,
    Colors.black,
    Colors.cyanAccent,
    Colors.pinkAccent
  ];

  StreamController<List<DrawnLine>> linesStreamController = StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController = StreamController<DrawnLine>.broadcast();

  Future<void> save() async {
    // TODO
  }
  
  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
    });
  }
  
  void onPanStart(DragStartDetails details) {
    // TODO
    //print user has begun drawing 
    print('User has begun drawing');
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    setState(() {
      line = DrawnLine([point], selectedColor, selectedWidth);
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    // TODO
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    final path = List.from(line.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);

    setState(() {
      if (lines.length == 0) {
        lines.add(line);
      } else {
        lines[lines.length - 1] = line;
      }
    });
  }

  void onPanEnd(DragEndDetails details) {
    // TODO
    setState(() {
      print('User has ended drawing');
      lines.add(line);
    });
  }

  void onDoubleTap() {
    // Annotations should be cleared after double tap on screen
    clear();
  }

  Widget buildCurrentPath(BuildContext context) {
    // TODO
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onDoubleTap: onDoubleTap,
      child: RepaintBoundary(
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CustomPaint(
            painter: Sketcher(lines: lines),
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    // TODO
  }



  Widget buildStrokeToolbar() {
    return Positioned(
      bottom: 100.0,
      right: 10.0,
      child: Column(
        children: [
          buildStrokeButton(5.0),
          buildStrokeButton(10.0),
          buildStrokeButton(17.0),
        ],
      )
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        selectedWidth = strokeWidth;
        setState(() {
          strokeWidthIsClicked = !strokeWidthIsClicked;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(20.0), border: Border.all(style: strokeWidthIsClicked ? BorderStyle.solid : BorderStyle.none)),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: 40.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (Color color in toolbarColors) buildColorButton(color),
          buildLineButton()
        ],
      ),
    );
  }
  
  Widget buildLineButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.black,
        child: Icon(Icons.create_rounded),
        // onPressed: () {
        //   setState(() {
        //     selectedColor = color;
        //   });
        // },
      ),
    );
  }


  Widget buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: color,
        child: Container(),
        onPressed: () {
          setState(() {
            selectedColor = color;
          });
        },
      ),
    );
  }

  Widget buildSaveButton() {
    return GestureDetector(
      onTap: save,
      child: CircleAvatar(
        child: Icon(
          Icons.save,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: CircleAvatar(
        child: Icon(
          Icons.create,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white10,
      body: Stack(

        children: <Widget>[
          Container(
            //height: 400.4,
            width: 0.95 * _width, //setting picture to take up 95 percent of the screen to leave room for the toolbar

            decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("images/hand-xray.jpeg"),
                ),
                color: Colors.amberAccent,
                borderRadius: BorderRadius.only(
                    //topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
          ),
          buildCurrentPath(context),
          buildColorToolbar(),
          buildStrokeToolbar(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    linesStreamController.close();
    currentLineStreamController.close();
    super.dispose();
  }
}
