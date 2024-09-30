# shorts

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
//triming
const Text("Select Trim Range"),
Row(
children: [
Expanded(
child: ValueListenableBuilder(
valueListenable:
uploadAudioVideoController.videoController,
builder: (BuildContext context, VideoPlayerValue value,
Widget? child) {
return Slider(
min: 0.0,
max: uploadAudioVideoController
.videoController.value.duration.inSeconds
.toDouble(),
value: uploadAudioVideoController
.videoController.value.position.inSeconds
.toDouble(),
onChanged: (value) {
// Update the video's current position to visualize trimming
uploadAudioVideoController.videoController
.seekTo(Duration(seconds: value.toInt()));
},
);
}),
),
Obx(() {
return Text(
'${uploadAudioVideoController.startTrimTime.value.toInt()} s');
}),
],
),
Row(
children: [
Expanded(
child: ValueListenableBuilder(
valueListenable:
uploadAudioVideoController.videoController,
builder: (BuildContext context, VideoPlayerValue value,
Widget? child) {
return Slider(
min: 0.0,
max: uploadAudioVideoController
.videoController.value.duration.inSeconds
.toDouble(),
value: uploadAudioVideoController.endTrimTime.value,
onChanged: (value) {
// Update the end time for trimming
uploadAudioVideoController.endTrimTime.value =
value;
},
);
}),
),
Obx(() {
return Text(
'${uploadAudioVideoController.endTrimTime.value.toInt()} s');
}),
],
),

            ElevatedButton(
              onPressed: () async {
                // Call the trim function when the button is pressed
                final trimmedVideoPath =
                    await uploadAudioVideoController.trimVideo(
                  uploadAudioVideoController.videoPath, // Your video path
                  uploadAudioVideoController.startTrimTime.value,
                  uploadAudioVideoController.endTrimTime.value,
                );

                if (trimmedVideoPath != null) {
                  Get.snackbar('Success',
                      'Video trimmed successfully! Saved to: $trimmedVideoPath');
                } else {
                  Get.snackbar('Error', 'Failed to trim video.');
                }
              },
              child: Text("Trim Video"),
            ),

///
///
///----------------------------video trimming-------------------------------///
///
///
///
var startTrimTime = 0.0.obs; // Observable for start trim time
var endTrimTime = 0.0.obs;   // Observable for end trim time
String videoPath = '';
Future<String?> trimVideo(String videoPath, double startTime, double endTime) async {
try {
// Get the temporary directory for the output video
final directory = await getTemporaryDirectory();
String trimmedVideoPath = '${directory.path}/${getRandomString(15)}.mp4';

      // FFmpeg command to trim the video
      String ffmpegCommand = '-i $videoPath -ss $startTime -to $endTime -c:v copy -c:a copy $trimmedVideoPath';

      // Execute the FFmpeg command
      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      // Check if the execution was successful
      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('Video trimmed successfully to: $trimmedVideoPath');
        return trimmedVideoPath;
      } else {
        final logs = await session.getAllLogsAsString();
        debugPrint('FFmpeg failed with return code: $logs');
        return null;
      }
    } catch (e) {
      debugPrint('Error trimming video: $e');
      return null;
    }
}

///----------------------------video trimming-------------------------------///