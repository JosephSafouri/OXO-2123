import 'package:flutter/material.dart';

import 'line_type.dart';

class DrawnLine {
  final List<dynamic> path;
  final Color color;
  final double width;
  final LineType lineType;

  DrawnLine(this.path, this.color, this.width, this.lineType);
}
