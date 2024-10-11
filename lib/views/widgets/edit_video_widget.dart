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
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 10),
        child: Obx(() {
          return widget.uploadAudioVideoController.videoFrames.isEmpty
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : Column(
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
                    aspectRatio: widget.uploadAudioVideoController
                        .videoController.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius:
                      const BorderRadius.all(Radius.circular(20)),
                      child: VideoPlayer(widget
                          .uploadAudioVideoController.videoController),
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
                      valueListenable: widget
                          .uploadAudioVideoController.videoController,
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
                          widget.uploadAudioVideoController
                              .videoController.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          widget.uploadAudioVideoController
                              .videoController.value.isPlaying
                              ? widget.uploadAudioVideoController
                              .videoController
                              .pause()
                              : widget.uploadAudioVideoController
                              .videoController
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Obx(
                                    () => widget.uploadAudioVideoController
                                    .videoFrames.isEmpty
                                    ? const Center(
                                  child:
                                  CircularProgressIndicator(),
                                )
                                    : Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: List.generate(
                                      widget.uploadAudioVideoController
                                          .videoFrames.length +
                                          1,
                                          (index) {
                                        widget
                                            .uploadAudioVideoController
                                            .timeInSeconds
                                            .value = (index *
                                            (widget
                                                .uploadAudioVideoController
                                                .videoDuration
                                                .value /
                                                widget
                                                    .uploadAudioVideoController
                                                    .videoFrames
                                                    .length))
                                            .round(); // Calculate the time for each thumbnail
                                        return SizedBox(
                                          width: Get.width * 0.19,
                                          child: Text(
                                            "${(widget.uploadAudioVideoController.timeInSeconds.value ~/ 60).toString().padLeft(2, '0')}:${(widget.uploadAudioVideoController.timeInSeconds.value % 60).toString().padLeft(2, '0')}",
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
                                    () => Stack(
                                  children: [
                                    // Thumbnail List
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: Get.height * 0.06,
                                          child: SingleChildScrollView(
                                            scrollDirection:
                                            Axis.horizontal,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.only(
                                                    topLeft: Radius
                                                        .circular(
                                                        Get.width *
                                                            .01),
                                                    bottomLeft: Radius
                                                        .circular(
                                                        Get.width *
                                                            .01)),
                                              ),
                                              width: widget
                                                  .uploadAudioVideoController
                                                  .videoFrames
                                                  .length *
                                                  Get.width *
                                                  0.2,
                                              height: Get.height * 0.04,
                                              child: Row(
                                                children: List.generate(
                                                  widget
                                                      .uploadAudioVideoController
                                                      .videoFrames
                                                      .length,
                                                      (index) {
                                                    return Image.memory(
                                                      widget.uploadAudioVideoController
                                                          .videoFrames[
                                                      index],
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
                                                .videoFrames
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
                                    Positioned(
                                      left: 0,
                                      child: Container(
                                        width: widget
                                            .uploadAudioVideoController
                                            .startHandlePosition
                                            .value,
                                        height: Get.height * 0.06,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: Container(
                                        width: widget
                                            .uploadAudioVideoController
                                            .endHandlePosition
                                            .value,
                                        height: Get.height * 0.06,
                                        color: Colors.black,
                                      ),
                                    ),

                                    //Start Handle
                                    Positioned(
                                      left: widget
                                          .uploadAudioVideoController
                                          .startHandlePosition
                                          .value,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate:
                                            (details) {
                                          setState(() {
                                            debugPrint(
                                                "1. initial start handler position ${widget.uploadAudioVideoController.startHandlePosition.value}");
                                            double
                                            newStartHandlePosition =
                                                widget
                                                    .uploadAudioVideoController
                                                    .startHandlePosition
                                                    .value +
                                                    details.delta.dx;
                                            debugPrint(
                                                "2 left handler delta:${details.delta.dx}");
                                            debugPrint(
                                                "3. New Start Handle Position: $newStartHandlePosition");

                                            if (newStartHandlePosition <=
                                                0) {
                                              newStartHandlePosition = 0;
                                            }
                                            else if(
                                            newStartHandlePosition >= (((widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2)-(Get.width * 0.2)) )
                                            ){
                                              newStartHandlePosition = (((widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2)-(Get.width * 0.2)) );
                                            }
                                            widget
                                                .uploadAudioVideoController
                                                .startHandlePosition
                                                .value =
                                                newStartHandlePosition;

                                            // Update startTrim based on the handle position
                                            widget
                                                .uploadAudioVideoController
                                                .startTrim
                                                .value = ((newStartHandlePosition /
                                                (widget
                                                    .uploadAudioVideoController
                                                    .videoFrames
                                                    .length *
                                                    Get.width *
                                                    .2)) *
                                                ((widget
                                                    .uploadAudioVideoController
                                                    .videoDuration
                                                    .value)
                                                )).toPrecision(2);

                                            debugPrint("4. video Frame length : ${widget.uploadAudioVideoController.videoFrames.length}");
                                            debugPrint("5. Get.width * 0.2: ${Get.width * 0.2}");
                                            debugPrint("6. video Frame length * Get.width * 0.2: ${widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2}");

                                            debugPrint(
                                                "7. Start Trim full calculation : ${((newStartHandlePosition / (widget.uploadAudioVideoController.videoFrames.length * Get.width * .2)) * ((widget.uploadAudioVideoController.videoDuration.value).toPrecision(2)))}");
                                            debugPrint(
                                                "8. Start Trim: ${widget.uploadAudioVideoController.startTrim.value}");
                                            debugPrint("9. end restriction : ${((widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2)-(Get.width * 0.2))}");
                                          });
                                        },
                                        child: Container(
                                          width: Get.width * 0.028,
                                          height: Get.height * 0.06,
                                          padding: EdgeInsets.zero,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.only(
                                              topLeft: Radius.circular(
                                                Get.width * .01,
                                              ),
                                              bottomLeft: Radius.circular(
                                                Get.width * .01,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: Get.width * .006,
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.black,
                                              size: 14,
                                            ),
                                          ),
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
                                        onHorizontalDragUpdate:
                                            (details) {
                                          setState(() {

                                            debugPrint(
                                                "1. initial end handler position ${widget.uploadAudioVideoController.endHandlePosition.value}");
                                            double newEndHandlePosition =
                                                widget
                                                    .uploadAudioVideoController
                                                    .endHandlePosition
                                                    .value -
                                                    details.delta.dx;
                                            debugPrint(
                                                "2 end handler delta:${details.delta.dx}");
                                            debugPrint(
                                                "3. New end Handle Position: $newEndHandlePosition");
                                            // Prevent the end handle from moving past the start handle or beyond the frame width
                                            if (newEndHandlePosition <=  0) {
                                              newEndHandlePosition =  0;
                                            } else if (newEndHandlePosition >= (( widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2)-(Get.width * 0.2))) {
                                              newEndHandlePosition = (( widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2)-(Get.width * 0.2));
                                            }



                                            widget
                                                .uploadAudioVideoController
                                                .endHandlePosition
                                                .value = newEndHandlePosition;


                                            // Calculate endTrim in reverse (from right to left)
                                            widget
                                                .uploadAudioVideoController
                                                .endTrim
                                                .value = (widget
                                                .uploadAudioVideoController
                                                .videoDuration
                                                .value -
                                                ((newEndHandlePosition /
                                                    (widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2)) *
                                                    widget
                                                        .uploadAudioVideoController
                                                        .videoDuration
                                                        .value))
                                                .toPrecision(2);

                                            debugPrint("4. video Frame length : ${widget.uploadAudioVideoController.videoFrames.length}");
                                            debugPrint("5. Get.width * 0.2: ${Get.width * 0.2}");
                                            debugPrint("6. video Frame length * Get.width * 0.2: ${widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2}");

                                            debugPrint(
                                                "7. end Trim full calculation : ${(widget
                                                    .uploadAudioVideoController
                                                    .videoDuration
                                                    .value -
                                                    ((newEndHandlePosition /
                                                        (widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2)) *
                                                        widget
                                                            .uploadAudioVideoController
                                                            .videoDuration
                                                            .value))
                                                    .toPrecision(2)}");
                                            debugPrint(
                                                "8. end Trim: ${widget.uploadAudioVideoController.endTrim.value}");
                                            debugPrint("9. end restriction : ${((widget.uploadAudioVideoController.videoFrames.length * Get.width * 0.2)-(Get.width * 0.2))}");
                                          });
                                          // debugPrint(
                                          //     "${widget.uploadAudioVideoController.endTrim.value.runtimeType}");
                                        },
                                        child: Container(
                                          width: Get.width * 0.028,
                                          height: Get.height * 0.06,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.only(
                                                topRight:
                                                Radius.circular(
                                                    Get.width *
                                                        .01),
                                                bottomRight:
                                                Radius.circular(
                                                    Get.width *
                                                        .01)),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: Get.width * .005),
                                            child: const Icon(
                                              Icons.arrow_back_ios,
                                              color: Colors.black,
                                              size: 15,
                                            ),
                                          ),
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
                  // Center(
                  //   //vertical white line of 4 px
                  //   child: Container(
                  //     // margin: EdgeInsets.only(left: Get.width * 0.085),
                  //     width: Get.width * .005,
                  //     height: Get.height * 0.20,
                  //     color: Colors.white,
                  //   ),
                  // ),
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
          );
        }),
      ),
    );
  }
}
