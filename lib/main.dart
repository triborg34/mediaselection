

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mediaselection/bindings.dart';
import 'package:mediaselection/screens/mediaPicker.dart';

void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: Mybindings(),
      debugShowCheckedModeBanner: false,
      home: GalleryPicker(),
    );
  }
}


