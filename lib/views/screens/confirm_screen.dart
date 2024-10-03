import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shorts/controllers/upload_audio_video_controller.dart';
import 'package:shorts/views/widgets/text_input_field.dart';

import 'package:video_player/video_player.dart';

import '../widgets/edit_video_widget.dart';

class ConfirmScreen extends StatelessWidget {
  final File videoFile;
  final String videoPath;

  const ConfirmScreen({
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

    return WillPopScope(
      onWillPop: () async {
        // Pause and Dispose the video and audio players when back is pressed
        if (uploadAudioVideoController.videoController.value.isInitialized) {
          uploadAudioVideoController.videoController.pause();
          uploadAudioVideoController.videoController.dispose();
        }
        if (uploadAudioVideoController.player.playing) {
          uploadAudioVideoController.player.pause();
          uploadAudioVideoController.player.dispose();
        }
        Get.delete<
            UploadAudioVideoController>(); // Explicitly delete the controller
        uploadAudioVideoController.dispose();
        return true; // Allow navigation
      },
      // PopScope(
      // canPop: true,
      // onPopInvokedWithResult: (bool didPop, FormData? result) {
      //   if (!didPop) {
      //     uploadAudioVideoController.videoController.pause();
      //     uploadAudioVideoController.player.pause();
      //     Navigator.pop(context, result);
      //     Future.microtask(() async {
      //       await Get.delete<UploadAudioVideoController>();
      //     });
      //   }
      // },
      child: Scaffold(
        body: Stack(
          children: [
            Stack(
              children: [
                const SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: SizedBox(
                    height: 30,
                  ),
                ),
                Obx(
                  () => uploadAudioVideoController.isVideoInitialized.value
                      ? Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height * .75,
                          ),
                          child: Stack(children: [
                            Center(
                              child: Hero(
                                tag: 'videoHero',
                                child: AspectRatio(
                                  aspectRatio: uploadAudioVideoController
                                          .videoController.value.isInitialized
                                      ? uploadAudioVideoController
                                          .videoController.value.aspectRatio
                                      : 16 / 9,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    child: RepaintBoundary(
                                      key: uploadAudioVideoController
                                          .videoKey, // RepaintBoundary to capture frames
                                      child: VideoPlayer(
                                          uploadAudioVideoController
                                              .videoController),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 100,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(Icons.movie_edit,
                                    color: Colors.white),
                                onPressed: () => Get.dialog(
                                  EditVideoWidget(
                                    uploadAudioVideoController:
                                        uploadAudioVideoController,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.25,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => uploadAudioVideoController
                                  .selectAudioBottomSheet(),
                              child: const Text(
                                'Add Sound',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                ///updated code
                                // Check if a song is selected
                                //if not selected then upload the video as it is
                                uploadAudioVideoController
                                        .selectedAudio.value.isEmpty
                                    // Raw video upload flow
                                    ? uploadAudioVideoController.uploadVideo(
                                        uploadAudioVideoController
                                            .songNameController.text,
                                        uploadAudioVideoController
                                            .captionController.text,
                                        videoPath,
                                      )
                                    : // Replacing audio and then uploading the video
                                    uploadAudioVideoController
                                        .replaceAudioInVideo(
                                            videoPath,
                                            uploadAudioVideoController
                                                .selectedAudioPath.value)
                                        .then((replacedVideoPath) =>
                                            replacedVideoPath != null
                                                // // Upload the video with replaced audio
                                                ? uploadAudioVideoController
                                                    .uploadVideo(
                                                        uploadAudioVideoController
                                                            .songNameController
                                                            .text,
                                                        uploadAudioVideoController
                                                            .captionController
                                                            .text,
                                                        replacedVideoPath)
                                                : debugPrint(
                                                    'Error replacing audio'));
                              },

                              ///previously it was like this
                              // uploadAudioVideoController.uploadVideo(
                              //     uploadAudioVideoController
                              //         .songNameController.text,
                              //     uploadAudioVideoController
                              //         .captionController.text,
                              //     videoPath),
                              child: const Text(
                                'Share!',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: Get.height * 0.1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
