import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  VideoPlayerScreen({required this.videoPath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  double _currentSliderValue = 0.0;
  double _videoDuration = 0.0;
  TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeVideo(widget.videoPath);
  }

  @override
  void dispose() {
    _controller.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo(String path) async {
    _controller = VideoPlayerController.file(File(path))
      ..addListener(() {
        setState(() {
          _currentSliderValue = _controller.value.position.inSeconds.toDouble();
        });
      })
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _videoDuration = _controller.value.duration.inSeconds.toDouble();
        });
        _controller.play();
      });
  }

  Future<void> _showQuestionDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Question'),
          content: TextField(
            controller: _answerController,
            decoration: InputDecoration(hintText: 'Enter your answer'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _saveVideoInfo(_answerController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveVideoInfo(String answer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('videoPath', widget.videoPath);
    await prefs.setDouble('videoPosition', _currentSliderValue);
    await prefs.setString('answer', answer);
  }

  void _seekToSecond(double second) {
    final Duration newPosition = Duration(seconds: second.toInt());
    _controller.seekTo(newPosition);
  }

  String _formatDuration(double seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds.toInt() % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
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
        child: _isInitialized
            ? Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 10,
                    child: ElevatedButton(
                      onPressed: _showQuestionDialog,
                      child: Icon(Icons.add),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        Text(
                          _formatDuration(_currentSliderValue),
                          style: TextStyle(color: Colors.white),
                        ),
                        Expanded(
                          child: Slider(
                            value: _currentSliderValue,
                            min: 0,
                            max: _videoDuration,
                            divisions: _videoDuration.toInt(),
                            onChanged: (value) {
                              setState(() {
                                _currentSliderValue = value;
                                _seekToSecond(value);
                              });
                            },
                          ),
                        ),
                        Text(
                          _formatDuration(_videoDuration),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
