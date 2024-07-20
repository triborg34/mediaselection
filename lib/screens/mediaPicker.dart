import 'dart:io';
// ignore: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediaselection/controller.dart';
import 'package:mediaselection/screens/questionimage.dart';
import 'package:mediaselection/screens/quistion.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class GalleryPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaController = Get.put(MediaController());
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('', style: TextStyle(color: Colors.purple)),
        actions: [
          TextButton(
            onPressed: () {
              if(mediaController.isVideo.value){
              Get.to(VideoPlayerScreen(videoPath: mediaController.pickedFile.value!.path));
              }else{
                Get.to(ImageDisplayScreen(imagePath: mediaController.pickedFile.value!.path));
          }
            },
            child: Text(
              'بعدی',
              style: TextStyle(color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SelectedMediaDisplay(),
          Expanded(
            child: MediaGrid(),
          ),
        ],
      ),
    );
  }
}

class SelectedMediaDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MediaController>(
      builder: (controller) {
        return Container(
          color: Colors.black,
          height: 400,
          width: MediaQuery.sizeOf(context).width,
          child: controller.pickedFile.value == null
              ? Text('No media selected.', style: TextStyle(color: Colors.white))
              : controller.isVideo.value
                  ? controller.videoController?.value.isInitialized ?? false
                      ? AspectRatio(
                          aspectRatio: controller.videoController!.value.aspectRatio,
                          child: VideoPlayer(controller.videoController!))
                      : CircularProgressIndicator()
                  : Image.file(
                      File(controller.pickedFile.value!.path),
                      fit: BoxFit.cover,
                    ),
        );
      },
    );
  }
}

class MediaGrid extends StatefulWidget {
  @override
  _MediaGridState createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  String mediaType = Get.find<MediaController>().mediaType.value;
  List<AssetEntity> mediaList = [];

  @override
  void initState() {
    super.initState();
    fetchMedia();
  }

  Future<void> fetchMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: mediaType == 'all'
            ? RequestType.common
            : mediaType == 'image'
                ? RequestType.image
                : RequestType.video,
      );
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(page: 0, size: 100);
      setState(() {
        mediaList = media;
      });
      if (mediaList.isNotEmpty) {
        final firstMedia = mediaList.first;
        final file = await firstMedia.file;
        if (file != null) {
          final mediaController = Get.find<MediaController>();
          mediaController.pickMedia(file.path, firstMedia.mimeType, 0);
        }
      }
    } else {
      // No permissions granted
    }
  }

  void onMediaTypeChanged(String newMediaType) {
    setState(() {
      mediaType = newMediaType;
      fetchMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
            padding: EdgeInsets.only(right: 15),
            child: MediaTypeSelector(onChanged: onMediaTypeChanged)),
        Expanded(
            child: GridView.builder(
              
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return GestureDetector(
                onTap: () {
                  _showCameraOptions(context);
                },
                child: Container(
                  color: Colors.black26,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
              );
            }
            final asset = mediaList[index - 1];
            return FutureBuilder<Widget>(
              
              future: buildThumbnail(asset, index - 1),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data ?? Container();
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          },
          itemCount: mediaList.length + 1,
        )),
      ],
    );
  }

  Future<Widget> buildThumbnail(AssetEntity asset, int index) async {
    final thumbData =
        await asset.thumbnailDataWithSize(ThumbnailSize(200, 200));

    return GestureDetector(
        onTap: () async {
          final file = await asset.file;
          if (file != null) {
            final mediaController = Get.find<MediaController>();
            mediaController.pickMedia(file.path, asset.mimeType, index);
          }
        },
        child: Obx(
          () => Get.find<MediaController>().selectedIndex.value == index
              ? Container(
                  child: Opacity(
                    opacity: 0.5,
                    child: Image.memory(
                      thumbData!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Image.memory(
                  thumbData!,
                  fit: BoxFit.cover,
                ),
        ));
  }

  void _showCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Get.find<MediaController>().pickFromCamera(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Record Video'),
              onTap: () {
                Get.find<MediaController>().pickFromCamera(ImageSource.camera, isVideo: true);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class MediaTypeSelector extends StatelessWidget {
  final Function(String) onChanged;
  const MediaTypeSelector({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return DropdownButton<String>(
          elevation: 0,
          icon: Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
          alignment: Alignment.centerRight,
          value: Get.find<MediaController>().mediaType.value,
          items: [
            DropdownMenuItem(value: 'all', child: Text('موارد اخیر', style: TextStyle(color: Colors.deepPurple))),
            DropdownMenuItem(value: 'image', child: Text('عکس ها', style: TextStyle(color: Colors.deepPurple))),
            DropdownMenuItem(value: 'video', child: Text('ویدیو ها', style: TextStyle(color: Colors.deepPurple))),
          ],
          onChanged: (String? value) {
            if (value != null) {
              Get.find<MediaController>().mediaType.value = value;
              onChanged(Get.find<MediaController>().mediaType.value);
            }
          },
        );
      },
    );
  }
}