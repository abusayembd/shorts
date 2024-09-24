import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shorts/constants.dart';
import 'package:shorts/models/video.dart';
import 'package:video_compress/video_compress.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../views/widgets/add_sound_bottom_sheet.dart';

class UploadAudioVideoController extends GetxController {
  final TextEditingController songNameController = TextEditingController();
  final TextEditingController captionController = TextEditingController();
  RxBool uploading = false.obs;
  RxDouble progress = 0.0.obs;

  late VideoPlayerController videoController;
  RxBool isVideoInitialized = false.obs;

  RxString selectedAudio = ''.obs;
  RxString selectedAudioPath = ''.obs; // Store the audio path here
  RxBool isOriginalSoundSelected = true.obs;
  final RxBool tabStatus = true.obs;

  final RxList<Map<String, String>> recommendedSounds =
      <Map<String, String>>[].obs;
  var deviceSongs = <SongModel>[].obs;

  final RxString currentlyPlayingAudio = ''.obs;

  final player = AudioPlayer();

  RxDouble videoVolume = 1.0.obs; // Volume for the original video (1.0 = 100%)
  RxDouble selectedAudioVolume =
      1.0.obs; // Volume for the selected audio (1.0 = 100%)

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  @override
  void dispose() {
    videoController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    videoController.dispose();
    player.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure that the audio player is properly initialized
    player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        currentlyPlayingAudio.value = '';
      }
    });
  }

  void initializeVideo(File videoFile) {
    videoController = VideoPlayerController.file(videoFile,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) {
        isVideoInitialized.value = true;
        videoController.play();
        videoController.setVolume(videoVolume.value);
        videoController.setLooping(true);
      });
  }

  void playVideo() {
    if (!videoController.value.isPlaying) {
      videoController.play();
    }
  }

  void pauseVideo() {
    if (videoController.value.isPlaying) {
      videoController.pause();
    }
  }

  ///******** Method for opening bottom sheet of audio selection  *********///
  void selectAudioBottomSheet() async {
    await fetchRecommendedSounds().then((value) {
      Get.bottomSheet(
        backgroundColor: Colors.black,
        AddSoundBottomSheet(),
      );
    });
  }

  ///***************** Method to tab toggle ***************///
  //
  void toggleTabs() {
    tabStatus.value = !tabStatus.value;
    if (tabStatus.value == true) {
      fetchRecommendedSounds();
    } else {
      querySongsWithPermission();
    }
  }

  ///******** Method to fetch recommended sounds from Firebase Storage*******///
  //
  Future<void> fetchRecommendedSounds() async {
    try {
      ListResult result =
          await FirebaseStorage.instance.ref('audios').listAll();
      recommendedSounds.value =
          await Future.wait(result.items.map((audio) async {
        return {'name': audio.name, "fullPath": await audio.getDownloadURL()};
      }).toList());
      debugPrint("sayem recommended sounds");
      debugPrint(recommendedSounds.toString());
      selectedAudio.value = recommendedSounds.first['name'] ?? '';
      songNameController.text = recommendedSounds.first['name'] ?? '';
      playAudio(
        audioName: recommendedSounds.first['name'] ?? '',
        audioPath: recommendedSounds.first['fullPath'] ?? '',
      );
    } catch (e) {
      recommendedSounds.value = [];
      debugPrint("Error fetching recommended sounds: $e");
    }
  }

  ///***** Method to query songs on the device with permission handling *****///
  //
  Future<void> querySongsWithPermission() async {
    final PermissionStatus permissionStatus = await Permission.storage.status;

    // Check if permission is already granted or request it
    if (permissionStatus.isGranted ||
        await Permission.storage.request().isGranted) {
      try {
        // Query songs if permission is granted
        final songs = await OnAudioQuery().querySongs(
          sortType: SongSortType.DISPLAY_NAME,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );
        deviceSongs.value = songs;
      } catch (e) {
        // Handle query failure (optional)
        Get.snackbar('Error', 'Failed to load songs: $e');
        deviceSongs.value = [];
      }
    } else {
      // Handle permission denied case
      Get.snackbar(
          'Permission Denied', 'Storage access is required to load songs.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Handle song selection ///
  void selectSong(String songName) {
    songNameController.text = songName;
    selectedAudio.value = songName;
    playAudio(audioName: songName);
    Get.back();
  }

  /// Play audio and update UI ///
  void playAudio({required String audioName, audioPath}) {
    if (currentlyPlayingAudio.value == audioName) {
      // If the currently selected audio is tapped again, stop and unselect it
      stopAudio();
      currentlyPlayingAudio.value = ''; // Unselect the audio
      selectedAudio.value = ''; // Unselect the audio in the UI
    } else {
      currentlyPlayingAudio.value = audioName;
      selectedAudio.value = audioName; // Update selected audio in the UI
      setAudio(audioPath);
      if (!videoController.value.isPlaying) {
        videoController.play(); // Ensure the video keeps playing
      }
      debugPrint("Playing audio: $audioName");
      // Add logic for actual audio playing
    }
  }

  void setAudio(String audioPath) async {
    try {
      await player
          .setAudioSource(AudioSource.uri(Uri.parse(audioPath)))
          .then((value) {
        player.play();
        player.setVolume(selectedAudioVolume.value);
      });
    } on PlayerException catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  /// Stop currently playing audio ///
  void stopAudio() {
    currentlyPlayingAudio.value = '';
    player.stop();
    debugPrint("Audio stopped");
  }

  Future<double> getVideoDuration(String videoPath) async {
    final info = await FFprobeKit.getMediaInformation(videoPath);
    final durationString = info.getMediaInformation()?.getDuration();
    return double.parse(durationString ?? '0');
  }


  ///************ Code for Replacing Audio with FFmpeg: ************///
  //
  Future<String?> replaceAudioInVideo(
      String videoPath, String audioPath) async {
    try {
      double videoDuration = await getVideoDuration(videoPath);
      debugPrint(' AAA Video duration: $videoDuration');
      final directory = await getTemporaryDirectory();
      String replacedSongOutputFilePath =
          '${directory.path}/${getRandomString(15)}.mp4';

      // FFmpeg command to replace audio in the video

      // String ffmpegCommand = isOriginalSoundSelected.value
      //     ? '-i $videoPath -i $audioPath -filter_complex "[0:a][1:a]amix=inputs=2:duration=shortest" -c:v copy -map 0:v:0 -map 0:a -map 1:a:0 -shortest $replacedSongOutputFilePath'
      //     : '-i $videoPath -i $audioPath -c:v copy -map 0:v:0 -map 1:a:0 -shortest $replacedSongOutputFilePath';

      // String ffmpegCommand = isOriginalSoundSelected.value
      //     ? '-i $videoPath -i $audioPath -filter_complex "[1:a]volume=${selectedAudioVolume.value}[a1];[0:a][a1]amix=inputs=2:duration=shortest" -c:v copy -map 0:v:0 -map 0:a -map 1:a:0 -shortest $replacedSongOutputFilePath'
      //     : '-i $videoPath -i $audioPath -filter:a "volume=${selectedAudioVolume.value}" -c:v copy -map 0:v:0 -map 1:a:0 -shortest $replacedSongOutputFilePath';

      String ffmpegCommand = isOriginalSoundSelected.value
          ? '-i $videoPath -i $audioPath -filter_complex "[1:a]volume=${selectedAudioVolume.value}[a1];[0:a][a1]amix=inputs=2:duration=shortest" -c:v copy -map 0:v:0 -map 0:a -map 1:a:0 -t $videoDuration $replacedSongOutputFilePath'
          : '-i $videoPath -i $audioPath -filter:a "volume=${selectedAudioVolume.value}" -c:v copy -map 0:v:0 -map 1:a:0 -t $videoDuration $replacedSongOutputFilePath';


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

  Future<String> _uploadImageToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('thumbnails').child(id);
    UploadTask uploadTask = ref.putFile(await _getThumbnail(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  ///************ Method to show volume slider dialog ************///
  // Show Volume Slider in Bottom Sheet
  void showVolumeSliderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(34),
        ),
        side: BorderSide(
          color: Colors.red,
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: isOriginalSoundSelected.value,
                child: const Padding(
                  padding: EdgeInsets.only(left: 24.0),
                  child: Text('Original Sound'),
                ),
              ),
              Visibility(
                visible: isOriginalSoundSelected.value,
                child: Obx(() => Slider(
                      value: videoVolume.value,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (newValue) {
                        videoVolume.value =
                            double.parse(newValue.toStringAsFixed(1));
                        videoController.setVolume(videoVolume.value);
                      },
                    )),
              ),
              Visibility(
                visible: selectedAudio.value != '' ,
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 24.0,
                  ),
                  child: Text('Added Sound'),
                ),
              ),
              Visibility(
                visible: selectedAudio.value != '',
                child: Obx(
                  () => Slider(
                    value: selectedAudioVolume.value,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      selectedAudioVolume.value =
                          double.parse(value.toStringAsFixed(1));

                      // Update the player volume in real-time
                      player.setVolume(selectedAudioVolume.value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
