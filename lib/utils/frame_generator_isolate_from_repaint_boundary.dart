// import 'dart:async';
// import 'dart:isolate';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
// import 'dart:io';
//
// class FrameGenerator {
//   final GlobalKey videoKey;
//   final VideoPlayerController videoController;
//
//   FrameGenerator({required this.videoKey, required this.videoController});
//
//   // Function to start the isolate
//   Future<void> generateFramesInIsolate(int numberOfFrames, double videoDuration, Function(RxList<Uint8List>) onFramesGenerated) async {
//     final ReceivePort receivePort = ReceivePort();
//     await Isolate.spawn(_generateFrames, receivePort.sendPort);
//
//     final SendPort sendPort = await receivePort.first;
//
//     // Send the required data to the isolate
//     final Map<String, dynamic> data = {
//       'videoPath': videoController.dataSource,
//       'numberOfFrames': numberOfFrames,
//       'videoDuration': videoDuration,
//       'videoKey': videoKey,
//     };
//
//     // Setup a listener to get the frames from the isolate
//     receivePort.listen((message) {
//       if (message is RxList<Uint8List>) {
//         onFramesGenerated(message);
//         receivePort.close(); // Close the port once frames are received
//       }
//     });
//
//     sendPort.send([data, receivePort.sendPort]);
//   }
//
//   // The actual isolate function to generate frames
//   static Future<void> _generateFrames(SendPort sendPort) async {
//     final ReceivePort port = ReceivePort();
//     sendPort.send(port.sendPort); // Send the port back to the main isolate
//
//     await for (final message in port) {
//       final Map<String, dynamic> data = message[0] as Map<String, dynamic>;
//       final String videoPath = data['videoPath'];
//       final int numberOfFrames = data['numberOfFrames'];
//       final double videoDuration = data['videoDuration'];
//       final GlobalKey videoKey = data['videoKey'];
//       final SendPort replyPort = message[1];
//
//       final VideoPlayerController videoController = VideoPlayerController.file(File(videoPath));
//       await videoController.initialize();
//
//       List<Uint8List> videoFrames = [];
//
//       double eachPart = videoDuration / numberOfFrames;
//
//       for (int i = 0; i < numberOfFrames; i++) {
//         await videoController.seekTo(Duration(milliseconds: (eachPart * i * 1000).toInt()));
//
//         // Capture the current frame from the video player
//         RenderObject? renderObject = videoKey.currentContext?.findRenderObject();
//         if (renderObject is RenderRepaintBoundary) {
//           RenderRepaintBoundary boundary = renderObject;
//           ui.Image image = await boundary.toImage(pixelRatio: 2.0);
//           ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//           Uint8List? bytes = byteData?.buffer.asUint8List();
//
//           if (bytes != null) {
//             videoFrames.add(bytes);
//           } else {
//             debugPrint('ERROR: Could not capture frame for time ${(eachPart * i).toInt()}');
//           }
//         } else {
//           debugPrint('ERROR: RenderObject is not a RenderRepaintBoundary');
//         }
//       }
//
//       videoController.dispose(); // Dispose the video controller in the isolate
//
//       // Send the captured videoFrames back to the main isolate
//       replyPort.send(videoFrames);
//     }
//   }
// }
// import 'dart:async';
// import 'dart:isolate';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class FrameGenerator {
//   final GlobalKey videoKey;
//   final VideoPlayerController videoController;
//
//   FrameGenerator({
//     required this.videoKey,
//     required this.videoController,
//   });
//
//   // Method to generate frames using an isolate
//   Future<void> generateFramesInIsolate(
//       int numberOfFrames, double videoDuration, Function(List<Uint8List>) onFramesGenerated) async {
//     final ReceivePort receivePort = ReceivePort();
//
//     // Create an isolate
//     await Isolate.spawn(_generateFrames, [receivePort.sendPort, numberOfFrames, videoDuration, videoController.value.duration.inSeconds]);
//
//     // Listen to the isolate's response
//     final List<Uint8List> generatedFrames = [];
//     await for (final message in receivePort) {
//       if (message is List<Uint8List>) {
//         generatedFrames.addAll(message);
//         receivePort.close(); // Close the port when done
//         onFramesGenerated(generatedFrames); // Pass frames back to the calling method
//         break; // Exit the loop once we receive the frames
//       }
//     }
//   }
//
//   // Static function that will be run inside the isolate
//   static void _generateFrames(List<dynamic> args) async {
//     SendPort sendPort = args[0];
//     int numberOfFrames = args[1];
//     double videoDuration = args[2];
//
//     // Logic to generate frames from the videoController (simplified)
//     List<Uint8List> frames = [];
//
//     // Example frame generation logic (you can replace this with actual frame capture code)
//     for (int i = 0; i < numberOfFrames; i++) {
//       // Simulate frame capture
//       Uint8List frame = Uint8List.fromList([i]); // Replace with actual frame data
//       frames.add(frame);
//     }
//
//     // Send frames back to the main isolate
//     sendPort.send(frames);
//   }
// }
// frame_generation_isolate.dart

// FrameGenerator.dart

//working but slow
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';

class FrameGeneratorIsolate {
  final VideoPlayerController videoController;
  final GlobalKey videoKey;

  FrameGeneratorIsolate({required this.videoController, required this.videoKey});

  Future<List<Uint8List>> generateFrames(int numberOfFrames, double videoDuration) async {
    List<Uint8List> frames = [];

    // Ensure the video player is initialized and ready to play
    if (videoController.value.isInitialized) {
      double eachPart = videoDuration / numberOfFrames;

      for (int i = 0; i < numberOfFrames; i++) {
        // Seek to the specific frame time
        await videoController.seekTo(Duration(milliseconds: (eachPart * i * 100).toInt()));
        await videoController.play();
        await Future.delayed(const Duration(milliseconds: 50)); // Slight delay to ensure frame is updated

        // Capture the current frame from the video player
        RenderObject? renderObject = videoKey.currentContext?.findRenderObject();
        if (renderObject is RenderRepaintBoundary) {
          RenderRepaintBoundary boundary = renderObject;
          ui.Image image = await boundary.toImage(pixelRatio: 2.0);
          ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          Uint8List? bytes = byteData?.buffer.asUint8List();

          if (bytes != null) {
            frames.add(bytes); // Add frame to the list
          } else {
            debugPrint('ERROR: Could not capture frame for time ${(eachPart * i).toInt()}');
          }
        } else {
          debugPrint('ERROR: RenderObject is not a RenderRepaintBoundary');
        }
      }
    } else {
      debugPrint('ERROR: Video player is not initialized');
    }

    return frames; // Return captured frames
  }
}








