import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shorts/controllers/upload_audio_video_controller.dart';
import 'package:video_player/video_player.dart';

import 'edit_video_full_screen_preview_widget.dart';

class EditVideoWidget extends StatelessWidget {
  final UploadAudioVideoController uploadAudioVideoController;

  const EditVideoWidget({
    super.key,
    required this.uploadAudioVideoController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Cancel and Save buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Get.back(); // Close the dialog
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.back(); // Close the dialog
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.01),

            // Video Player
            SizedBox(
              height: Get.height * 0.5,
              width: Get.width * 0.70,
              child: Hero(
                tag: 'videoHero',
                child: AspectRatio(
                  aspectRatio: uploadAudioVideoController
                      .videoController.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child:
                        VideoPlayer(uploadAudioVideoController.videoController),
                  ),
                ),
              ),
            ),

            //Gap
            SizedBox(height: Get.height * 0.01),

            // video duration Play/Pause and Time controls and full screen button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display current position and duration

                ValueListenableBuilder(
                  valueListenable: uploadAudioVideoController.videoController,
                  builder: (context, VideoPlayerValue value, child) {
                    //Do Something with the value.
                    return Text(
                      "${uploadAudioVideoController.videoController.value.position.inMinutes}:${(uploadAudioVideoController.videoController.value.position.inSeconds.remainder(60)).toString().padLeft(2, '0')} / ${uploadAudioVideoController.videoController.value.duration.inMinutes}:${(uploadAudioVideoController.videoController.value.duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}",
                    );
                  },
                ),
                // Play/Pause Button
                ValueListenableBuilder(
                  valueListenable: uploadAudioVideoController.videoController,
                  builder: (context, VideoPlayerValue value, child) {
                    //Do Something with the value.
                    return IconButton(
                      icon: Icon(
                        uploadAudioVideoController
                                .videoController.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        uploadAudioVideoController
                                .videoController.value.isPlaying
                            ? uploadAudioVideoController.videoController.pause()
                            : uploadAudioVideoController.videoController.play();
                      },
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: () {
                    Get.dialog(
                      EditVideoFullScreenPreviewWidget(
                          uploadAudioVideoController:
                              uploadAudioVideoController),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.01),
          ],
        ),
      ),
    );
  }
}
