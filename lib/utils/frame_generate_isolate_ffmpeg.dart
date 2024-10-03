import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FrameExtractor {
  final String videoFilePath;

  FrameExtractor({required this.videoFilePath});

  Future<List<Uint8List>> extractFrames() async {
    List<Uint8List> frames = [];

    // FFmpeg command to extract frames in PNG format
    final String ffmpegCommand = '-i $videoFilePath -vf "fps=1" -f image2pipe -vcodec png pipe:1';

    // Capture FFmpeg logs
    FFmpegKitConfig.enableLogCallback((Log log) {
      print("FFmpeg Log: ${log.getMessage()}");
    });

    // Run the FFmpeg command
    final session = await FFmpegKit.execute(ffmpegCommand);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print("FFmpeg command succeeded.");

      // Capture the output from the FFmpeg command
      final output = await session.getOutput();

      if (output != null) {
        // Process the output to extract frames
        // This part needs to be implemented based on your specific requirements
      } else {
        print("No output from FFmpeg command.");
      }
    } else {
      print("FFmpeg command failed with return code: $returnCode");
    }

    return frames; // Return captured frames in memory
  }
}

Future<List<Uint8List>> extractFramesInIsolate(String videoFilePath) async {
  // Ensure the BackgroundIsolateBinaryMessenger is initialized
  BackgroundIsolateBinaryMessenger.ensureInitialized(RootIsolateToken.instance!);

  FrameExtractor frameExtractor = FrameExtractor(videoFilePath: videoFilePath);
  return await frameExtractor.extractFrames();
}