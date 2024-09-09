import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shorts/controllers/upload_audio_video_controller.dart';
import 'package:shorts/views/widgets/text_input_field.dart';
import 'package:text_marquee/text_marquee.dart';
import 'package:video_player/video_player.dart';

class ConfirmScreen extends StatelessWidget {
  final File videoFile;
  final String videoPath;

  ConfirmScreen({
    super.key,
    required this.videoFile,
    required this.videoPath,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize the UploadAudioVideoController and video controller
    final UploadAudioVideoController uploadAudioVideoController = Get.put(
      UploadAudioVideoController(),
    )..initializeVideo(videoFile);
    return PopScope(
      onPopInvoked: (value) async {
        await Get.delete<UploadAudioVideoController>();
        Get.back();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Obx(() => uploadAudioVideoController.isVideoInitialized.value
                    ? Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * .75,
                        ),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: uploadAudioVideoController
                                .videoController.value.aspectRatio,
                            child: VideoPlayer(
                                uploadAudioVideoController.videoController),
                          ),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      )),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.21,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width - 20,
                          child: TextInputField(
                            controller:
                                uploadAudioVideoController.songNameController,
                            labelText: 'Song Name',
                            icon: Icons.music_note,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width - 20,
                          child: TextInputField(
                            controller:
                                uploadAudioVideoController.captionController,
                            labelText: 'Caption',
                            icon: Icons.closed_caption,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () => uploadAudioVideoController
                              .selectAudioBottomSheet(),
                          child: const TextMarquee(
                            spaceSize: 20,
                            'Add Sound',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              uploadAudioVideoController.uploadVideo(
                                  uploadAudioVideoController
                                      .songNameController.text,
                                  uploadAudioVideoController
                                      .captionController.text,
                                  videoPath),
                          child: const Text(
                            'Share!',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Obx(() {
              if (uploadAudioVideoController.uploading.value) {
                return AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Please wait, your video is uploading",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          LinearProgressIndicator(
                            value:
                                uploadAudioVideoController.progress.value / 100,
                            backgroundColor: Colors.white,
                            color: Colors.green,
                            minHeight: 8,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${uploadAudioVideoController.progress.value.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink(); // Empty widget if not uploading
              }
            }),
          ],
        ),
      ),
    );
  }
}
