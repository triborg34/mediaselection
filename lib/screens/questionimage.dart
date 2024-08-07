import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:mediaselection/controller.dart';

/// ImageDisplayScreen is a StatefulWidget that displays an image and allows
/// users to input a question and multiple answers associated with the image.
class ImageDisplayScreen extends StatefulWidget {
  final String imagePath;

  /// Constructor for ImageDisplayScreen.
  /// Takes the path of the image to be displayed.
  ImageDisplayScreen({required this.imagePath});

  @override
  _ImageDisplayScreenState createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  final AnswerController answerController = Get.find<AnswerController>();
  TextEditingController _questionController = TextEditingController();
  List<TextEditingController> _answerControllers = List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    // Set the image path in the answer controller
    answerController.setImagePath(widget.imagePath);
    // Initialize question and answers from the controller
    _questionController.text = answerController.question.value;
    for (int i = 0; i < 4; i++) {
      _answerControllers[i].text = answerController.answers[i];
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers to free up resources
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Saves the question and answers to the answer controller.
  void _saveQuestionAndAnswers() {
    answerController.setQuestion(_questionController.text);
    for (int i = 0; i < 4; i++) {
      answerController.setAnswer(i, _answerControllers[i].text);
    }
  }

  /// Displays a dialog for the user to input a question and answers.
  Future<void> _showQuestionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'طرح سوال',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _questionController,
                  maxLength: 200,
                  style: TextStyle(color: Colors.white),
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'سوال معما',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                for (int i = 0; i < 4; i++) ...[
                  TextField(
                    controller: _answerControllers[i],
                    maxLength: 50,
                    style: TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      labelText: 'گزینه ${i + 1}',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      suffixIcon: Obx(
                        () => Radio<int>(
                          value: i,
                          groupValue: answerController.correctAnswerIndex.value,
                          onChanged: (int? value) {
                            if (value != null) {
                              answerController.setCorrectAnswerIndex(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: Colors.white)),
              onPressed: () {
                _saveQuestionAndAnswers();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Handles the press event of the floating action button.
  void _handleFloatingActionButtonPress() {
    _showQuestionDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.visibility, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.view_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.deepPurple,
                onPressed: _handleFloatingActionButtonPress,
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
