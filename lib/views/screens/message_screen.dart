// import 'package:flutter/material.dart';
// import 'package:shorts/constants.dart';
//
// class MessageScreen extends StatelessWidget {
//   const MessageScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:  Center(
//         child: TextButton(onPressed: (){
//           authController.signOut();
//         }, child: const Text("Sign out")),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  VideoPlayerController? _videoPlayerController;
  final List<String> _framePaths = [];
  File? _videoFile;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  // Function to pick a video from files or camera
  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
      });
      _initializeVideoPlayer();
      _generateFrames(_videoFile!);
    }
  }

  // Initialize video player
  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.file(_videoFile!)
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController?.play();
      });
  }

  // Function to generate frames from the video
  Future<void> _generateFrames(File videoFile) async {
    debugPrint("File path: ${videoFile.path}");

    final directory = await getTemporaryDirectory();
    final outputDir = Directory('${directory.path}/frames');
    if (!outputDir.existsSync()) {
      outputDir.createSync();
    }

    final duration = await _getVideoDuration(videoFile);
    final videoLengthInSeconds = duration.inSeconds;

    for (int i = 0; i <= videoLengthInSeconds; i++) {
      String outputPath = '${outputDir.path}/frame_$i.png';
      String ffmpegCommand =
          '-i ${videoFile.path} -r 1/1  $outputPath';

      await FFmpegKit.execute(ffmpegCommand).then((session) async {
        final returnCode = await session.getReturnCode();
        if (returnCode!.isValueSuccess()) {
          setState(() {
            _framePaths.add(outputPath);
            debugPrint('Frame generated at $outputPath');
          });
        }
      });
    }
    debugPrint( "Frames generated: ${_framePaths.length}");
  }

  // Get video duration
  Future<Duration> _getVideoDuration(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    Duration duration = controller.value.duration;
    controller.dispose();
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            TextButton(
              onPressed: _pickVideo,
              child: const Text("Select Video"),
            ),
            const SizedBox(height: 20),
            // Video player
            _videoPlayerController != null &&
                    _videoPlayerController!.value.isInitialized
                ? SizedBox(
                    height: Get.height * 0.5,
                  child: AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                )
                : const Text('No video selected'),
            const SizedBox(height: 20),
            // Horizontal scroll view to show frames
            _framePaths.isNotEmpty
                ? SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _framePaths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(File(_framePaths[index])),
                        );
                      },
                    ),
                  )
                : const Text('Frames will appear here after generation'),
          ],
        ),
      ),
    );
  }
}
