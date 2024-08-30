import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shorts/constants.dart';
import 'package:shorts/models/video.dart';
import 'package:video_compress/video_compress.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadAudioVideoController extends GetxController {
  final TextEditingController songNameController = TextEditingController();
  final TextEditingController captionController = TextEditingController();
  RxBool uploading = false.obs;
  RxDouble progress = 0.0.obs;

  final RxBool tabStatus = true.obs;

  final RxList<String> recommendedSounds = <String>[].obs;
  var isFetchingDeviceAudio = false.obs;
  var deviceAudioFiles = <File>[].obs;

  void toggleTabs(){
    tabStatus.value = !tabStatus.value;
    if(tabStatus.value==true){
      fetchRecommendedSounds();
    }
    else{
      querySongsWithPermission();
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchRecommendedSounds();
  }



  //***************** Method to fetch recommended sounds from Firebase Storage***************//
  Future<void> fetchRecommendedSounds() async {
    try {
      ListResult result = await FirebaseStorage.instance.ref('audios').listAll();
      recommendedSounds.value = result.items.map((item) => item.name).toList();
      print("sayem recommended sounds");
      print(recommendedSounds.toString());
    } catch (e) {
      recommendedSounds.value = [];
      print("Error fetching recommended sounds: $e");
    }
  }
  //************** Method to query songs on the device with permission handling **************//
  Future<List<SongModel>> querySongsWithPermission() async {
    // Request permission to access audio files
    if (await Permission.storage.request().isGranted) {
      // Permission granted, query the songs
      return OnAudioQuery().querySongs(
        sortType: SongSortType.DISPLAY_NAME,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
    } else {
      // Handle permission denied case
      Get.snackbar('Permission Denied', 'Please allow storage access to load songs.');
      return [];
    }
  }

  //***************** Method to scan the device for audio files***************//
  //
  Future<void> fetchAllDeviceAudio() async {
    isFetchingDeviceAudio.value = true;
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        // Get root directory of external storage
        Directory rootDir = await getExternalStorageDirectory() ?? Directory('/');
        // Recursively scan for audio files
        List<File> audioFiles = await _getAudioFilesFromDir(rootDir);
        deviceAudioFiles.value = audioFiles;
        print("sayem device sounds");
        print(deviceAudioFiles.toString());
      }
    } catch (e) {
      // Handle errors
      print("Error fetching device audio: $e");
    } finally {
      isFetchingDeviceAudio.value = false;
    }
  }

  // Helper method to scan directories recursively
  Future<List<File>> _getAudioFilesFromDir(Directory dir) async {
    List<File> audioFiles = [];
    try {
      var entities = dir.listSync(recursive: true);
      for (var entity in entities) {
        if (entity is File && (entity.path.endsWith('.mp3') || entity.path.endsWith('.wav'))) {
          audioFiles.add(entity);
        }
      }
    } catch (e) {
      print("Error scanning directory: $e");
    }
    return audioFiles;
  }



  Future<void> pickDeviceAudio() async {
    try {
      print("Opening file picker...");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null && result.paths.isNotEmpty) {
        String fileName = result.paths.first!.split('/').last;
        songNameController.text = fileName;
        Get.back(); // Close the bottom sheet after file selection
      } else {
        print("No file selected");
      }
    } catch (e) {
      print("Error picking device audio files: $e");
    }
  }


  ///Code for Replacing Audio with FFmpeg:

  Future<String?> replaceAudioInVideo(
      String videoPath, String audioPath) async {
    try {
      final directory = await getTemporaryDirectory();
      String replacedSongOutputFilePath = '${directory.path}/output_video.mp4';

      // FFmpeg command to replace audio in the video
      String ffmpegCommand =
          '-i $videoPath -i $audioPath -c:v copy -map 0:v:0 -map 1:a:0 -shortest $replacedSongOutputFilePath';

      // Execute the FFmpeg command
      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      // Check if the execution was successful
      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('Audio replaced successfully!');
        return replacedSongOutputFilePath;
      } else {
        final logs = await session.getAllLogsAsString();
        debugPrint('FFmpeg failed with return code: $logs');
        return null;
      }
    } catch (e) {
      debugPrint('Error replacing audio: $e');
      return null;
    }
  }

  _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo!.file;
  }

  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('videos').child(id);

    UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
    // listen to the upload process
    uploadTask.snapshotEvents.listen((event) {
      double percentage = 100 * (event.bytesTransferred / event.totalBytes);
      progress.value = percentage; // Update the progress
    });

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  Future<String> _uploadImageToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('thumbnails').child(id);
    UploadTask uploadTask = ref.putFile(await _getThumbnail(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  // upload video
  uploadVideo(String songName, String caption, String videoPath) async {
    try {
      uploading.value = true;
      progress.value = 0.0; // Reset progress
      String uid = firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(uid).get();
      // get id
      var allDocs = await firestore.collection('videos').get();
      int len = allDocs.docs.length;
      String videoUrl = await _uploadVideoToStorage("Video $len", videoPath);
      String thumbnail = await _uploadImageToStorage("Video $len", videoPath);

      Video video = Video(
        username: (userDoc.data()! as Map<String, dynamic>)['name'],
        uid: uid,
        id: "Video $len",
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl,
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'],
        thumbnail: thumbnail,
      );

      await firestore.collection('videos').doc('Video $len').set(
            video.toJson(),
          );
      Get.back();
    } on FirebaseException catch (e) {
      Get.snackbar(
        'firebase Error',
        e.message ?? 'Unknown Error Occurred',
      );
    } catch (e) {
      Get.snackbar(
        'Error Uploading Video',
        e.toString(),
      );
    } finally {
      uploading.value = false;
    }
  }
}
