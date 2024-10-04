import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../controllers/upload_audio_video_controller.dart';

class EditVideoFullScreenPreviewWidget extends StatelessWidget {
  const EditVideoFullScreenPreviewWidget({
    super.key,
    required this.uploadAudioVideoController,
  });

  final UploadAudioVideoController uploadAudioVideoController;

  @override
  Widget build(BuildContext context) {

    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      elevation: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            // video player in full screen
            SizedBox(
              height: Get.height * 0.8,
              width: Get.width,
              child: Hero(
                tag: 'videoHero',
                child: AspectRatio(
                  aspectRatio: uploadAudioVideoController
                      .videoController.value.aspectRatio,
                  child: VideoPlayer(
                      uploadAudioVideoController
                          .videoController),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                padding: const EdgeInsets.all(20.0),
                onPressed: () {
                  Get.back(); // Close the dialog
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: Get.width * 1.2,
              right: Get.width * 0.35,
              child: ValueListenableBuilder(
                valueListenable: uploadAudioVideoController
                    .videoController,
                builder:
                    (context, VideoPlayerValue value, child) {
                  //Do Something with the value.
                  return IconButton(
                    icon: Icon(
                      uploadAudioVideoController
                          .videoController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: Get.height * 0.10,
                    ),
                    onPressed: () {
                      uploadAudioVideoController
                          .videoController.value.isPlaying
                          ? uploadAudioVideoController
                          .videoController
                          .pause()
                          : uploadAudioVideoController
                          .videoController
                          .play();
                    },
                  );
                },
              ),
            ),
            Positioned(
              bottom: Get.width * .2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
                  children: [
                    ValueListenableBuilder(
                      valueListenable:
                      uploadAudioVideoController
                          .videoController,
                      builder: (context,
                          VideoPlayerValue value, child) {
                        //Do Something with the value.
                        return Text(
                          "${uploadAudioVideoController.videoController.value.position.inMinutes}:${(uploadAudioVideoController.videoController.value.position.inSeconds.remainder(60)).toString().padLeft(2, '0')} ",
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 5),
                      child: SizedBox(
                        width: Get.width * 0.7,
                        height: Get.height * 0.01,
                        child: VideoProgressIndicator(
                          uploadAudioVideoController
                              .videoController,
                          allowScrubbing: true,
                          // Allow user to scrub through the video

                          colors: VideoProgressColors(
                            playedColor: Colors.white,
                            // Color for played portion
                            bufferedColor:
                            Colors.grey.withOpacity(0.35),
                            // Color for buffered portion
                            backgroundColor: Colors
                                .black, // Background color
                          ),
                        ),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable:
                      uploadAudioVideoController
                          .videoController,
                      builder: (context,
                          VideoPlayerValue value, child) {
                        //Do Something with the value.
                        return Text(
                          "${uploadAudioVideoController.videoController.value.duration.inMinutes}:${(uploadAudioVideoController.videoController.value.duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}",
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}