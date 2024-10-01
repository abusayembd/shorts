import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shorts/controllers/upload_audio_video_controller.dart';
import 'package:video_player/video_player.dart';

import 'edit_video_full_screen_preview_widget.dart';

class EditVideoWidget extends StatefulWidget {
  final UploadAudioVideoController uploadAudioVideoController;

  const EditVideoWidget({
    super.key,
    required this.uploadAudioVideoController,
  });

  @override
  State<EditVideoWidget> createState() => _EditVideoWidgetState();
}

@override
class _EditVideoWidgetState extends State<EditVideoWidget> {
  @override
  void initState() {
    super.initState();

    setState(() {
      widget.uploadAudioVideoController.endHandlePosition.value =
          widget.uploadAudioVideoController.videoDuration.value;
      debugPrint(
          "Sayem End Handle Position: ${widget.uploadAudioVideoController.endHandlePosition.value}");
      debugPrint(
          "Sayem Video Duration: ${widget.uploadAudioVideoController.videoDuration.value}");
      debugPrint(
          "Sayem Trim Area Width: ${widget.uploadAudioVideoController.trimAreaWidth.value}");
      debugPrint(
          "Sayem Handle Width: ${widget.uploadAudioVideoController.handleWidth.value}");
      debugPrint(
          "Sayem Start Handle Position: ${widget.uploadAudioVideoController.startHandlePosition.value}");
      debugPrint(
          "Sayem End Handle Position: ${widget.uploadAudioVideoController.endHandlePosition.value}");
      debugPrint(
          "Sayem Start Trim: ${widget.uploadAudioVideoController.startTrim.value}");
      debugPrint(
          "Sayem End Trim: ${widget.uploadAudioVideoController.endTrim.value}");
    });
  }

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
                  aspectRatio: widget.uploadAudioVideoController.videoController
                      .value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: VideoPlayer(
                        widget.uploadAudioVideoController.videoController),
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

                SizedBox(
                  width: Get.width * 0.21,
                  child: ValueListenableBuilder(
                    valueListenable:
                        widget.uploadAudioVideoController.videoController,
                    builder: (context, VideoPlayerValue value, child) {
                      //Do Something with the value.
                      return Text(
                        "${widget.uploadAudioVideoController.videoController.value.position.inMinutes}:${(widget.uploadAudioVideoController.videoController.value.position.inSeconds.remainder(60)).toString().padLeft(2, '0')} / ${widget.uploadAudioVideoController.videoController.value.duration.inMinutes}:${(widget.uploadAudioVideoController.videoController.value.duration.inSeconds.remainder(60)).toString().padLeft(2, '0')}",
                      );
                    },
                  ),
                ),
                //
                ValueListenableBuilder(
                  valueListenable:
                      widget.uploadAudioVideoController.videoController,
                  builder: (context, VideoPlayerValue value, child) {
                    //Do Something with the value.
                    return IconButton(
                      icon: Icon(
                        widget.uploadAudioVideoController.videoController.value
                                .isPlaying
                            ? Icons.pause
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        widget.uploadAudioVideoController.videoController.value
                                .isPlaying
                            ? widget.uploadAudioVideoController.videoController
                                .pause()
                            : widget.uploadAudioVideoController.videoController
                                .play();
                      },
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 35),
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: () {
                      Get.dialog(
                        EditVideoFullScreenPreviewWidget(
                            uploadAudioVideoController:
                                widget.uploadAudioVideoController),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.01),
            //
            //
            //
            // Video Trimming Controls thumbnail and all the other controls related to video editor will go here
            Stack(
              children: [
                SizedBox(
                  height: Get.height * 0.20,
                  width: Get.width,
                  // color: Colors.blue,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Obx(
                              () => widget.uploadAudioVideoController.thumbnails
                                      .isEmpty
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          widget.uploadAudioVideoController
                                                  .thumbnails.length +
                                              1,
                                          (index) {
                                            int totalThumbnails = widget
                                                .uploadAudioVideoController
                                                .thumbnails
                                                .length;
                                            double videoDurationInSeconds =
                                                widget
                                                    .uploadAudioVideoController
                                                    .videoDuration
                                                    .value;
                                            double secondsPerThumbnail =
                                                videoDurationInSeconds /
                                                    totalThumbnails;

                                            int timeInSeconds = (index *
                                                    secondsPerThumbnail)
                                                .round(); // Calculate the time for each thumbnail
                                            return SizedBox(
                                              width: Get.width * 0.19,
                                              child: Text(
                                                "${(timeInSeconds ~/ 60).toString().padLeft(2, '0')}:${(timeInSeconds % 60).toString().padLeft(2, '0')}",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                            ),

                            ///
                            /// Thumbnail List
                            Obx(
                              () => widget.uploadAudioVideoController.thumbnails
                                      .isEmpty
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : Stack(
                                      children: [
                                        // Thumbnail List
                                        Column(
                                          children: [
                                            Container(
                                              height: Get.height * 0.06,
                                              color: Colors.blue,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: SizedBox(
                                                  width: widget
                                                          .uploadAudioVideoController
                                                          .thumbnails
                                                          .length *
                                                      Get.width *
                                                      0.2,
                                                  height: Get.height * 0.04,
                                                  child: Row(
                                                    children: List.generate(
                                                      widget
                                                          .uploadAudioVideoController
                                                          .thumbnails
                                                          .length,
                                                      (index) {
                                                        return Image.memory(
                                                          widget
                                                              .uploadAudioVideoController
                                                              .thumbnails[index],
                                                          width:
                                                              Get.width * 0.2,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: //add sound to video
                                                  () => widget
                                                      .uploadAudioVideoController
                                                      .selectAudioBottomSheet(),
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: Get.height * 0.010),
                                                height: Get.height * 0.04,
                                                width: widget
                                                        .uploadAudioVideoController
                                                        .thumbnails
                                                        .length *
                                                    Get.width *
                                                    0.2,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Get.width * 0.01),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.music_note,
                                                      color: Colors.white,
                                                      size: Get.height * .025,
                                                    ),
                                                    Text(
                                                      widget
                                                              .uploadAudioVideoController
                                                              .selectedAudio
                                                              .value
                                                              .isEmpty
                                                          ? "Add Sound"
                                                          : widget
                                                              .uploadAudioVideoController
                                                              .selectedAudio
                                                              .value,

                                                      //todo render-flex
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            Get.height * .02,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        //volume icon in the center

                                        //Start Handle
                                        Positioned(
                                          left: widget
                                              .uploadAudioVideoController
                                              .startHandlePosition
                                              .value,
                                          child: GestureDetector(
                                            onHorizontalDragUpdate: (details) {
                                              setState(() {
                                                double newPosition = widget
                                                        .uploadAudioVideoController
                                                        .startHandlePosition
                                                        .value +
                                                    details.delta.dx;
                                                double thumbnailWidth = widget
                                                        .uploadAudioVideoController
                                                        .thumbnails
                                                        .length *
                                                    Get.width *
                                                    0.2;
                                                double maxPosition = widget
                                                        .uploadAudioVideoController
                                                        .endHandlePosition
                                                        .value -
                                                    widget
                                                        .uploadAudioVideoController
                                                        .handleWidth
                                                        .value;

                                                if (newPosition < 0) {
                                                  newPosition = 0;
                                                } else if (newPosition >
                                                    maxPosition) {
                                                  newPosition = maxPosition;
                                                }

                                                widget
                                                    .uploadAudioVideoController
                                                    .startHandlePosition
                                                    .value = newPosition;

                                                // Update startTrim based on the handle position
                                                widget
                                                    .uploadAudioVideoController
                                                    .startTrim
                                                    .value = (newPosition /
                                                        thumbnailWidth) *
                                                    widget
                                                        .uploadAudioVideoController
                                                        .videoDuration
                                                        .value;

                                                debugPrint(
                                                    "Start Trim: ${widget.uploadAudioVideoController.startTrim.value}");
                                              });
                                            },
                                            child: Container(
                                              width: widget
                                                      .uploadAudioVideoController
                                                      .handleWidth
                                                      .value *
                                                  2,
                                              height: Get.height * 0.5,
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                        // End Handle
                                        Positioned(
                                          right: widget
                                              .uploadAudioVideoController
                                              .endHandlePosition
                                              .value,
                                          child: GestureDetector(
                                            onHorizontalDragUpdate: (details) {
                                              setState(() {
                                                double newPosition = widget
                                                        .uploadAudioVideoController
                                                        .endHandlePosition
                                                        .value -
                                                    details.delta.dx;
                                                double thumbnailWidth = widget
                                                        .uploadAudioVideoController
                                                        .thumbnails
                                                        .length *
                                                    Get.width *
                                                    0.2;
                                                double minPosition = widget
                                                        .uploadAudioVideoController
                                                        .startHandlePosition
                                                        .value +
                                                    widget
                                                        .uploadAudioVideoController
                                                        .handleWidth
                                                        .value;

                                                if (newPosition < minPosition) {
                                                  newPosition = minPosition;
                                                } else if (newPosition >
                                                    thumbnailWidth -
                                                        widget
                                                            .uploadAudioVideoController
                                                            .handleWidth
                                                            .value) {
                                                  newPosition = thumbnailWidth -
                                                      widget
                                                          .uploadAudioVideoController
                                                          .handleWidth
                                                          .value;
                                                }

                                                widget
                                                    .uploadAudioVideoController
                                                    .endHandlePosition
                                                    .value = newPosition;

                                                // Update endTrim based on the handle position
                                                widget
                                                    .uploadAudioVideoController
                                                    .endTrim
                                                    .value = (newPosition /
                                                        thumbnailWidth) *
                                                    widget
                                                        .uploadAudioVideoController
                                                        .videoDuration
                                                        .value;

                                                debugPrint(
                                                    "End Trim: ${widget.uploadAudioVideoController.endTrim.value}");
                                              });
                                            },
                                            child: Container(
                                              width: widget
                                                      .uploadAudioVideoController
                                                      .handleWidth
                                                      .value *
                                                  2,
                                              height: Get.height * 0.5,
                                              color:
                                                  Colors.red.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  //vertical white line of 4 px
                  child: Container(
                    // margin: EdgeInsets.only(left: Get.width * 0.085),
                    width: Get.width * .005,
                    height: Get.height * 0.20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Trim Button

            SizedBox(height: Get.height * 0.01),
            ElevatedButton(
              onPressed: () {
                widget.uploadAudioVideoController.trimVideo();
              },
              child: const Text("Trim Video"),
            ),
          ],
        ),
      ),
    );
  }
}
