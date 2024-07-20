import 'package:get/get.dart';
import 'package:mediaselection/controller.dart';

/// Mybindings is a class that implements the Bindings interface from GetX.
/// It is used to set up dependency injection, ensuring that the necessary
/// controllers are available throughout the app.
class Mybindings extends Bindings {
  /// The dependencies method is called when the bindings are initialized.
  /// It is used to register the controllers with GetX's dependency injection system.
  @override
  void dependencies() {
    // Register MediaController with GetX
    Get.put(MediaController());
    // Register AnswerController with GetX
    Get.put(AnswerController());
  }
}
