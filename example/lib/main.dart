import 'package:flutter/material.dart';
import 'package:flutter_map_gesture_drawing/flutter_map_gesture_drawing.dart';

//import 'widgets/drawing_map.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Gesture Drawing Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: DrawingMap(),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DrawingMap(),
    );
  }
}
