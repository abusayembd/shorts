import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerItem({
    super.key,
    required this.videoUrl,
  });

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  bool isPlaying = false;
  bool showProgress = false;
  double videoPosition = 0.0; // To manage slider dragging

  @override
  void initState() {
    super.initState();
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((value) {
            videoPlayerController.play();
            isPlaying = true;
            videoPlayerController.setVolume(1);

            //add listener to loop the video
            videoPlayerController.addListener(() {
              //Check if the video has finished playing
              if (videoPlayerController.value.position >=
                  videoPlayerController.value.duration) {
                videoPlayerController
                    .seekTo(Duration.zero); // Restart from beginning
                videoPlayerController.play(); // Play the video again
              }
            });
          });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: AspectRatio(
        aspectRatio: videoPlayerController.value.aspectRatio,
        child: VideoPlayer(
          videoPlayerController,
        ),
      ),
    );
  }
}
