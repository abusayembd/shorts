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

class _EditVideoWidgetState extends State<EditVideoWidget> {
  double startHandlePosition = 0.0;
  double endHandlePosition = 0.0;
  double handleWidth = 8.0; // Width of the draggable handle
  double trimAreaWidth = 0.0;
  late ScrollController _scrollController;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        endHandlePosition = trimAreaWidth;
        // Initialize end trim value
        widget.uploadAudioVideoController.endTrim.value =
            widget.uploadAudioVideoController.videoDuration.value;
        //set the initial scroll position to the middle of the list
        // Set the initial scroll position to the middle of the list
        final itemWidth =
            trimAreaWidth / widget.uploadAudioVideoController.thumbnails.length;
        final initialScrollPosition =
            (widget.uploadAudioVideoController.thumbnails.length * itemWidth) /
                    2 -
                (trimAreaWidth / 2); // Center the middle thumbnail
        _scrollController.jumpTo(initialScrollPosition);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            //
            //
            //
            Stack(
              children: [
                Obx(
                  () => widget.uploadAudioVideoController.thumbnails.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              widget
                                  .uploadAudioVideoController.thumbnails.length,
                              (index) {
                                int totalThumbnails = widget
                                    .uploadAudioVideoController
                                    .thumbnails
                                    .length;
                                double videoDurationInSeconds = widget
                                    .uploadAudioVideoController
                                    .videoDuration
                                    .value;
                                double secondsPerThumbnail =
                                    videoDurationInSeconds / totalThumbnails;

                                int timeInSeconds = (index *
                                        secondsPerThumbnail)
                                    .round(); // Calculate the time for each thumbnail

                                return Text(
                                  "${(timeInSeconds ~/ 60).toString().padLeft(2, '0')}:${(timeInSeconds % 60).toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      trimAreaWidth = constraints.maxWidth;
                      return Obx(
                        () => widget
                                .uploadAudioVideoController.thumbnails.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Stack(
                                children: [
                                  // Thumbnail List
                                  Column(
                                    children: [

                                      Container(
                                        height: 60,
                                        color: Colors.blue,
                                        child: ListView.builder(
                                          controller: _scrollController,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: widget
                                              .uploadAudioVideoController
                                              .thumbnails
                                              .length,
                                          itemBuilder: (context, index) {
                                            return Image.memory(
                                              widget.uploadAudioVideoController
                                                  .thumbnails[index],
                                              width: trimAreaWidth /
                                                  widget
                                                      .uploadAudioVideoController
                                                      .thumbnails
                                                      .length,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: //add sound to video
                                            () {},
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              top: Get.height * 0.010),
                                          height: Get.height * 0.04,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
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
                                                "Add Sound",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: Get.height * .02,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  //volume icon in the center

                                  // Start Handle
                                  Positioned(
                                    left: startHandlePosition,
                                    child: GestureDetector(
                                      onHorizontalDragUpdate: (details) {
                                        setState(() {
                                          startHandlePosition +=
                                              details.delta.dx;
                                          if (startHandlePosition < 0) {
                                            startHandlePosition = 0;
                                          }
                                          if (startHandlePosition >
                                              endHandlePosition - handleWidth) {
                                            startHandlePosition =
                                                endHandlePosition - handleWidth;
                                          }

                                          // Update start trim value in  widget.uploadAudioVideoController
                                          widget
                                              .uploadAudioVideoController
                                              .startTrim
                                              .value = (startHandlePosition /
                                                  trimAreaWidth) *
                                              widget.uploadAudioVideoController
                                                  .videoDuration.value;
                                        });
                                      },
                                      child: Container(
                                        width: handleWidth,
                                        height: 60,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),

                                  // End Handle
                                  Positioned(
                                    left: endHandlePosition,
                                    child: GestureDetector(
                                      onHorizontalDragUpdate: (details) {
                                        setState(() {
                                          endHandlePosition += details.delta.dx;
                                          if (endHandlePosition >
                                              trimAreaWidth) {
                                            endHandlePosition = trimAreaWidth;
                                          }
                                          if (endHandlePosition <
                                              startHandlePosition +
                                                  handleWidth) {
                                            endHandlePosition =
                                                startHandlePosition +
                                                    handleWidth;
                                          }

                                          // Update end trim value in  widget.uploadAudioVideoController
                                          widget
                                              .uploadAudioVideoController
                                              .endTrim
                                              .value = (endHandlePosition /
                                                  trimAreaWidth) *
                                              widget.uploadAudioVideoController
                                                  .videoDuration.value;
                                        });
                                      },
                                      child: Container(
                                        width: handleWidth,
                                        height: 60,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),

                                  // Shade the unselected areas
                                  Positioned(
                                    left: 0,
                                    child: Container(
                                      width: startHandlePosition,
                                      height: 60,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                  Positioned(
                                    left: endHandlePosition + handleWidth,
                                    child: Container(
                                      width: trimAreaWidth -
                                          endHandlePosition -
                                          handleWidth,
                                      height: 60,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },
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
