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
  upload_image,
  text_field //adds a text field state 
}

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}
/*
* This renders the canvas to have the drawing state containing
* the toolbar with all the types of colors in the list,
* the image selector button, and setting all the default variables.
*/
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
  /*
  * This will allow the user to be able to save
  * the image that is being displayed whether there
  * are lines on the image or just itself.
  * That'll allow the potential users to also send an
  * already annotated image instead of the base canvas if
  * they annotate it.
  */
  Future<void> save() async {
    // TODO
  }
  /*
  * This will let the user clear the page of all notations
  * if it the canvas was modified in a way they do not like.
  */
  Future<void> clear() async {
    setState(() {
      lines = [];
      line = DrawnLine([], Colors.white, 0);
    });
  }
  /*
  * This allows the user to pick an image file type
  * and set it as the canvas background to allow them
  * to annotate any image they want.
  */
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

  /*
  * This method allows the user to begin drawing a line by
  * using two variables which track the user's input and 
  * where the user's input is happening relative to their
  * resolution. The setState() checks which drawing mode
  * the user is in and adds a line that is being drawn depending
  * on the color and mode it is in.
  */
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
 /*
 * This method does a similar thing to the previous method
 * but has a variable that contains a list of points that
 * the user has made. This updates the dynamic line from a 
 * different class.
 */
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
 /*
 * This method tells the system when the user has let go of the 
 * drawing something on the canvas and adds it to the list of lines.
 */
  void lineDrawEnd(DragEndDetails details) {
    setState(() {
      if (state == Status.color || state == Status.linedrawing) {
        print('User has ended drawing');
        lines.add(line);
      }
    });
  }
  /*
  This method begins adding the text field on an X-ray image.
  */
  void textFieldBegin() {
    //TODO
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
          buildLineButton(), buildUploadButton(), buildPointButton(), buildTextFieldButton()
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
/*
  This is the button widget for the upload image feature.
  It is added on the tool bar.
  */
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
  /*
  This is the button widget for the text field feature.
  It is added on the tool bar.
  */

  Widget buildTextFieldButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: selectedColor,
        onPressed: () {
          setState(() {
            state = Status.none;
          });
        },
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
    /*
    * TODO: Unfinished skeleton of the point button.
    */
    Widget buildPointButton() {
    return GestureDetector(
      child: CircleAvatar(
        child: Icon(
          Icons.add_circle,
          size: 20.0,
          color: Colors.white,
        ),
      ),
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


