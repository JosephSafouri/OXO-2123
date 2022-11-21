import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextBox extends StatefulWidget {
  @override
  _TextBoxState createState() => _TextBoxState(this.color);
  Color color;

  TextBox(this.color);
}

class _TextBoxState extends State<TextBox> {
  Color color;
  Offset offset = Offset.zero;

  _TextBoxState(this.color);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: offset.dx,
        top: offset.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              offset = Offset(
                  offset.dx + details.delta.dx, offset.dy + details.delta.dy);
            });
          },
          child: buildTextBox(),
        ));
  }

  Widget buildTextBox() {
    return SizedBox(
      width: 175.0,
      height: 2000.0,
      child: TextField(
          style: TextStyle(
              fontSize: 20, color: color, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 1.0),
            ),
          )),
    );
  }
}
