import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class MediaController extends GetxController {
  var pickedFile = Rx<XFile?>(null);
  var isVideo = false.obs;
  var mediaType = 'all'.obs;
  var selectedIndex = (-1).obs;
  VideoPlayerController? videoController;

  Future<void> pickMedia(String filePath, String? mimeType, int index) async {
    if (isVideo.value) {
      videoController?.pause();
      videoController?.dispose();
      videoController = null;
    }
    pickedFile.value = XFile(filePath);
    isVideo.value = mimeType?.startsWith('video') ?? false;
    selectedIndex.value = index;

    if (isVideo.value) {
      videoController = VideoPlayerController.file(File(filePath))
        ..initialize().then((_) {
          videoController?.play();
          update();
        });
    } else {
      update();
    }
  }

  Future<void> pickFromCamera(ImageSource source, {bool isVideo = false}) async {
    final pickedMedia = isVideo
        ? await ImagePicker().pickVideo(source: source)
        : await ImagePicker().pickImage(source: source);
    if (pickedMedia != null) {
      pickMedia(pickedMedia.path, isVideo ? 'video/mp4' : 'image/jpeg', -1);  // Using -1 for camera captured media
    }
  }
}

class AnswerController extends GetxController {
  var question = ''.obs;
  var answers = List<String>.filled(4, '').obs;
  var correctAnswerIndex = (-1).obs;
  String imagePath = '';

  void setImagePath(String path) {
    imagePath = path;
    resetData();
  }

  void setQuestion(String newQuestion) {
    question.value = newQuestion;
    saveData();
  }

  void setAnswer(int index, String answer) {
    answers[index] = answer;
    saveData();
  }

  void setCorrectAnswerIndex(int index) {
    correctAnswerIndex.value = index;
    saveData();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('imageData');
    if (jsonData != null) {
      Map<String, dynamic> data = json.decode(jsonData);
      imagePath = data['imagePath'];
      question.value = data['question'];
      answers.value = List<String>.from(data['answers']);
      correctAnswerIndex.value = data['correctAnswerIndex'];
    }
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {
      'imagePath': imagePath,
      'question': question.value,
      'answers': answers,
      'correctAnswerIndex': correctAnswerIndex.value,
    };
    String jsonData = json.encode(data);
    prefs.setString('imageData', jsonData);
  }

  void resetData() {
    question.value = '';
    answers.value = List<String>.filled(4, '');
    correctAnswerIndex.value = -1;
    saveData();
  }
}