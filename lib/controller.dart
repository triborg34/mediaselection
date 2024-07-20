import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

/// MediaController is a GetX controller responsible for managing media selection,
/// such as picking images or videos from the gallery or camera.
class MediaController extends GetxController {
  var pickedFile = Rx<XFile?>(null); // Reactive variable to hold the picked file
  var isVideo = false.obs; // Reactive variable to check if the picked file is a video
  var mediaType = 'all'.obs; // Reactive variable to store the type of media (all, image, video)
  var selectedIndex = (-1).obs; // Reactive variable to store the selected index in the media grid
  VideoPlayerController? videoController; // Video controller to handle video playback

  /// Picks media from the given file path, sets the appropriate type (image/video), and updates the state.
  Future<void> pickMedia(String filePath, String? mimeType, int index) async {
    if (isVideo.value) {
      // If a video is currently being played, pause and dispose of the existing controller
      videoController?.pause();
      videoController?.dispose();
      videoController = null;
    }
    pickedFile.value = XFile(filePath); // Set the picked file
    isVideo.value = mimeType?.startsWith('video') ?? false; // Determine if the picked file is a video
    selectedIndex.value = index; // Update the selected index

    if (isVideo.value) {
      // Initialize and play the video if the picked file is a video
      videoController = VideoPlayerController.file(File(filePath))
        ..initialize().then((_) {
          videoController?.play();
          update();
        });
    } else {
      update();
    }
  }

  /// Picks media from the camera. It can pick either an image or a video based on the isVideo flag.
  Future<void> pickFromCamera(ImageSource source, {bool isVideo = false}) async {
    final pickedMedia = isVideo
        ? await ImagePicker().pickVideo(source: source)
        : await ImagePicker().pickImage(source: source);
    if (pickedMedia != null) {
      pickMedia(pickedMedia.path, isVideo ? 'video/mp4' : 'image/jpeg', -1);  // Using -1 for camera captured media
    }
  }
}

/// AnswerController is a GetX controller responsible for managing questions and answers
/// associated with an image. It also handles saving and loading this data using SharedPreferences.
class AnswerController extends GetxController {
  var question = ''.obs; // Reactive variable to store the question
  var answers = List<String>.filled(4, '').obs; // Reactive list to store answers
  var correctAnswerIndex = (-1).obs; // Reactive variable to store the index of the correct answer
  String imagePath = ''; // Variable to store the path of the associated image

  /// Sets the image path and resets the question and answers data.
  void setImagePath(String path) {
    imagePath = path;
    resetData();
  }

  /// Sets the question and saves the data to SharedPreferences.
  void setQuestion(String newQuestion) {
    question.value = newQuestion;
    saveData();
  }

  /// Sets an answer at the specified index and saves the data to SharedPreferences.
  void setAnswer(int index, String answer) {
    answers[index] = answer;
    saveData();
  }

  /// Sets the index of the correct answer and saves the data to SharedPreferences.
  void setCorrectAnswerIndex(int index) {
    correctAnswerIndex.value = index;
    saveData();
  }

  /// Loads the question and answers data from SharedPreferences.
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

  /// Saves the question and answers data to SharedPreferences.
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

  /// Resets the question and answers data to default values and saves them to SharedPreferences.
  void resetData() {
    question.value = '';
    answers.value = List<String>.filled(4, '');
    correctAnswerIndex.value = -1;
    saveData();
  }
}
