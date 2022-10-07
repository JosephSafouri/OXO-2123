import 'package:drawing_app/drawing_page.dart';
import 'package:flutter/material.dart';
///
/// This is the main file that acts as the entry point for the app. 
/// It contains a MyApp that contains MaterialApp. 
/// This widget uses DrawingPage as the child.
///
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DrawingPage(),
    );
  }
}
