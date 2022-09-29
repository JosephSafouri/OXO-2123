import 'dart:async';
import 'dart:io';

import 'package:drawing_app/drawn_line.dart';
import 'package:drawing_app/sketcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
 
// Status keeps track of what action the user is trying to execute, default to none on start
enum Status {
  none,
  color,
  linedrawing,
  upload_image
}

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  ImagePicker picker = ImagePicker();
  File? displayImage;
  GlobalKey _globalKey = new GlobalKey();
  List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine line = DrawnLine([], Colors.white, 0);
  
  Status state = Status.none;
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
      line = DrawnLine([], Colors.white, 0);
    });
  }
  
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
        if(image == null) {
          return;
        }
      final imageTemp = File(image.path);
      
      setState(() => this.displayImage = imageTemp);
      } on PlatformException catch(e) {
        print('Failed to pick image: $e');
      }
   }

  void beginLineDraw(DragStartDetails details) {
    print('User has begun drawing');
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    setState(() {
      if (state == Status.color || state == Status.linedrawing) {
        line = DrawnLine([point], selectedColor, selectedWidth);
      }
    });
  }

  void lineDrawUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    final path = List.from(line.path);

    setState(() {
      if (state == Status.linedrawing) {
        if (path.length <= 1) {
          path.add(point);
        } else {
          path[1] = point;
        }
      } else if (state == Status.color) {
        path.add(point);
      }
      line = DrawnLine(path, selectedColor, selectedWidth);

      if (lines.length == 0) {
        lines.add(line);
      } else {
        lines[lines.length - 1] = line;
      }
    });
  }

  void lineDrawEnd(DragEndDetails details) {
    setState(() {
      if (state == Status.color || state == Status.linedrawing) {
        print('User has ended drawing');
        lines.add(line);
      }
    });
  }

  // Annotations should be cleared after double tap on screen
  void erase() {
    clear();
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: beginLineDraw,
      onPanUpdate: lineDrawUpdate,
      onPanEnd: lineDrawEnd,
      onDoubleTap: erase,
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
          buildLineButton(), buildUploadButton()
        ],
      ),
    );
  }
  
  Widget buildLineButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: selectedColor,
        child:Icon(Icons.create_rounded),
        onPressed: () {
          setState(() {
            state = Status.linedrawing;
          });
        },
      ),
    );
  }

Widget buildUploadButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.black,
        child:Icon(Icons.add_to_photos),
        onPressed: () {
          pickImage();
         }
      ));
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
            state = Status.color;
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

  Widget determineDisplayContent(double width, double height) {
    if (displayImage != null) {
      if (kIsWeb) {
        return Container(
        width: 0.95 * width, //setting picture to take up 95 percent of the screen to leave room for the toolbar
        child: 
        Image.network(
            displayImage!.path,
            fit: BoxFit.fill
          )   
      );
      } else {
        //TODO: default sizing is wrong 
      return Container(
        width: 0.95 * width,
        child: 
        Image.file(
            displayImage!,
            fit: BoxFit.fill
          )   
      );
      } 
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[200]
      ),
      width: width,
      height: height,
    );
    
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white10,
      body: Stack(
        children: <Widget>[
          determineDisplayContent(_width, _height)
          ,
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


