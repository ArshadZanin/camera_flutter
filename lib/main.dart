import 'package:camera_flutter/gallery.dart';
import 'package:flutter/material.dart';
 
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'camera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      // home: HomePage(),
      home: Gallery(),
    );
  }
}
