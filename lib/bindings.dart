

import 'package:get/get.dart';
import 'package:mediaselection/controller.dart';

class Mybindings extends Bindings{
  @override
  void dependencies() {
    Get.put(MediaController());
    Get.put(AnswerController());
    // TODO: implement dependencies
  }

}