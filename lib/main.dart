import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediaselection/bindings.dart';
import 'package:mediaselection/screens/mediaPicker.dart';

void main() {
  runApp(MyApp());
}

/// The main function is the entry point of the application.
/// It initializes the app by running the MyApp widget.

/// The MyApp class is the root widget of the application.
/// It sets up the GetMaterialApp which is a part of the GetX package for state management.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // initialBinding sets the initial bindings for dependency injection
      // Mybindings is where all dependencies are initialized
      initialBinding: Mybindings(),
      // debugShowCheckedModeBanner is set to false to hide the debug banner
      debugShowCheckedModeBanner: false,
      // home specifies the default route of the app
      home: GalleryPicker(),
    );
  }
}