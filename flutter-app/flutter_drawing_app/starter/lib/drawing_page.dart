import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:drawing_app/drawn_line.dart';
import 'package:drawing_app/sketcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:screenshot/screenshot.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'line_type.dart';
import 'text_box.dart';

// Status keeps track of what action the user is trying to execute, default to none on start
enum Status {
  none,
  free_draw,
  line_drawing,
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
  List<TextBox> textBoxes = <TextBox>[];
  DrawnLine line = DrawnLine([], Colors.white, 0, LineType.free_draw);
  ScreenshotController screenshotController = ScreenshotController();

  Uint8List _image = Uint8List.fromList([0]);

  Status state = Status.none;
  Color selectedColor = Colors.red;
  double selectedWidth = 5.0;
  // bool strokeWidthIsClicked = false;

  StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  /*
  * This will allow the user to be able to save
  * the image that is being displayed whether there
  * are lines on the image or just itself.
  * That'll allow the potential users to also send an
  * already annotated image instead of the base canvas if
  * they annotate it.
  */
  Future<void> save() async {
    if (this.displayImage == null) {
      return;
    }
    print("User saved the image");
    await screenshotController.capture().then((image) => {_image = image!});
    await ImageGallerySaver.saveImage(
      _image,
      quality: 100,
      name: DateTime.now().toIso8601String(),
    );
  }

  /*
  * This will let the user clear the page of all notations
  * if it the canvas was modified in a way they do not like.
  */
  Future<void> clear() async {
    setState(() {
      lines = [];
      line = DrawnLine([], Colors.white, 0, LineType.free_draw);
      textBoxes = [];
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
      if (image == null) {
        return;
      }
      final imageTemp = File(image.path);

      setState(() => {this.displayImage = imageTemp, state = Status.free_draw});
    } on PlatformException catch (e) {
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

    if (state == Status.free_draw || state == Status.line_drawing) {
      line = DrawnLine([point], selectedColor, selectedWidth,
          state == Status.free_draw ? LineType.free_draw : LineType.straight);
      currentLineStreamController.add(line);
    }
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
    if (state == Status.line_drawing || state == Status.free_draw) {
      if (state == Status.line_drawing) {
        if (path.length <= 1) {
          path.add(point);
        } else {
          path[1] = point;
        }
      } else if (state == Status.free_draw) {
        path.add(point);
      }
      line = DrawnLine(path, selectedColor, selectedWidth,
          state == Status.free_draw ? LineType.free_draw : LineType.straight);

      // if (lines.length == 0) {
      //   lines.add(line);
      // } else {
      //   lines[lines.length - 1] = line;
      // }
      currentLineStreamController.add(line);
    }
  }

  /*
 * This method tells the system when the user has let go of the
 * drawing something on the canvas and adds it to the list of lines.
 */
  void lineDrawEnd(DragEndDetails details) {
    if (state == Status.free_draw || state == Status.line_drawing) {
      print('User has ended drawing');
      lines.add(line);
      linesStreamController.add(lines);
    }
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
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<DrawnLine>(
              stream: currentLineStreamController.stream,
              builder: (context, snapshot) {
                return CustomPaint(
                    painter: Sketcher(
                  lines: [line],
                ));
              }),
        ),
      ),
    );
  }

  buildAllTextBoxes() {
    return Stack(children: [
      for (TextBox box in textBoxes)
        box
    ],);

  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: lines,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildToolbar() {
    double space_between = 10;
    return Positioned(
      top: 180,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        color: Colors.grey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildColorPickerButton(),
            SizedBox(height: space_between),
            buildFreeDrawButton(),
            SizedBox(height: space_between),
            buildLineButton(),
            SizedBox(height: space_between),
            buildTextFieldButton(),
            SizedBox(height: space_between),
            buildUploadButton(),
            SizedBox(height: space_between),
            buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget buildLineButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: selectedColor,
        child: Icon(Icons.straighten),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: const Text("Line Measurement Mode")
            )
          );
          setState(() {
            if (displayImage != null) {
              state = Status.line_drawing;
            }
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
            child: Icon(Icons.file_upload),
            onPressed: () {
              pickImage();
            }));
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
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: const Text("Text Box Mode")
              )
          );
          setState(() {
            if (this.displayImage != null)
              textBoxes.add(TextBox(selectedColor));
          });
        },
        child: Text('Text'),
      ),
    );
  }

  Widget buildMeasurementView(BuildContext context) {
    return StreamBuilder(
        stream: linesStreamController.stream,
        builder: (context, snapshot) {
          return Container(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Stack(
                children: [
                  for (line in lines)
                    if (line.lineType == LineType.straight)
                      Container(
                          child: Positioned.fill(
                              left: (line.path[0].dx +
                                          line.path[line.path.length - 1].dx)
                                      .abs() /
                                  2 + 10,
                              top: (line.path[0].dy +
                                          line.path[line.path.length - 1].dy)
                                      .abs() /
                                  2 + 10,
                              child: Text(findMeasurement(line.path[0],
                                      line.path[line.path.length - 1])
                                  .toString() + " cm",
                              style: new TextStyle(color: Colors.white),)))

                ],
              ));
        });
  }

  Widget buildCurrentMeasurementView(BuildContext context) {
    return StreamBuilder(
        stream: currentLineStreamController.stream,
        builder: (context, snapshot) {
          return Container(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Stack(
                children: [
                  if (line.lineType == LineType.straight)
                    Container(
                        child: Positioned.fill(
                            left: ((line.path[0].dx +
                                        line.path[line.path.length - 1].dx)
                                    .abs() /
                                2) + 20 ,
                            top: ((line.path[0].dy +
                                        line.path[line.path.length - 1].dy)
                                    .abs() /
                                2) + 20,
                            child: Text(findMeasurement(line.path[0],
                                    line.path[line.path.length - 1])
                                .toString() + " cm",
                            style: new TextStyle(color: Colors.white),)
                        )
                    )
                ],
              ));
        });
  }

  double findMeasurement(Offset first, Offset second) {
    double distance =
        sqrt(pow(first.dx - second.dx, 2) + pow(first.dy - second.dy, 2));
    return double.parse((distance).toStringAsFixed(2));
  }

  Widget buildColorPicker() {
    return BlockPicker(
      pickerColor: selectedColor,
      onColorChanged: (Color color) {
        setState(() {
          selectedColor = color;
        });
      },
    );
  }

  Widget buildColorPickerButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.color_lens,
          size: 20.0,
          color: Colors.black,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Choose a Color & Stroke Width'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      buildColorPicker(),
                      StatefulBuilder(builder: (context, state) {
                        return Slider(
                          value: selectedWidth,
                          min: 1,
                          max: 10,
                          divisions: 10,
                          label: selectedWidth.round().toString(),
                          onChanged: (double value) {
                            state(() {
                              selectedWidth = value;
                              // selectedWidth = value;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildSaveButton() {
    return FloatingActionButton(
      mini: true,
      onPressed: save,
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

  Widget buildFreeDrawButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: selectedColor,
        child: Icon(Icons.draw),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: const Text("Free Drawing Mode")
              )
          );
          setState(() {
            if (displayImage != null) {
              state = Status.free_draw;
            }
          });
        },
      ),
    );
  }

  Widget determineDisplayContent(double width, double height) {
    if (displayImage != null) {
      if (kIsWeb) {
        return Container(
            width: 0.95 *
                width, //setting picture to take up 95 percent of the screen to leave room for the toolbar
            child: Image.network(displayImage!.path, fit: BoxFit.fill));
      } else {
        return Container(
            width: 0.95 * width,
            child: Image.file(displayImage!, fit: BoxFit.fill));
      }
    }
    return Container(
      child: Center(
          child: Text('Upload an Image!', style: TextStyle(fontSize: 25))),
      decoration: BoxDecoration(color: Colors.white),
      width: width,
      height: height,
    );
  }

  /*
    * TODO: Unfinished skeleton of the point button.
    */
 /*  Widget buildPointButton() {
    return GestureDetector(
      child: CircleAvatar(
        child: Icon(
          Icons.add_circle,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  } */

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white10,
        body: Container(
            width: _width,
            child: Stack(
              children: <Widget>[
                Screenshot(
                    child: Stack(
                      children: [
                        determineDisplayContent(_width, _height),
                        buildMeasurementView(context),
                        buildCurrentMeasurementView(context),
                        buildAllPaths(context),
                        buildCurrentPath(context),
                        buildAllTextBoxes(),
                      ],
                    ),
                    controller: screenshotController),
                Positioned(
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.centerRight,
                  ),
                  right: 0,
                  top: 0,
                  width: 0.05 * _width,
                  height: _height,
                ),
                buildToolbar(),
              ],
            )));
  }

  @override
  void dispose() {
    linesStreamController.close();
    currentLineStreamController.close();
    super.dispose();
  }
}
