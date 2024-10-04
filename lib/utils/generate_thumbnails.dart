import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart'; // Assuming you're using VideoPlayerController

class ThumbnailGenerator {
  final String videoPath;
  final RxList<Uint8List> thumbnails;
  final VideoPlayerController videoController; // Explicit type annotation

  ThumbnailGenerator({
    required this.videoPath,
    required this.thumbnails,
    required this.videoController,
  });

  Future<void> generateThumbnails() async {
    // Clear existing thumbnails
    thumbnails.clear();

    // Calculate the number of thumbnails and each part duration
    int numberOfThumbnails = videoController.value.duration.inSeconds; // Adjust as needed

    // Cache of the last successful thumbnail
    Uint8List? lastBytes;

    for (int i = 0; i < numberOfThumbnails; i++) {
      Uint8List? bytes;

      try {
        // Generate thumbnail data for the specified time
        bytes = await VideoThumbnail.thumbnailData(
          video: videoPath,
          imageFormat: ImageFormat.JPEG,
          timeMs: (1 * i).toInt(),
          quality: 75,
        );
      } catch (e) {
        debugPrint('ERROR: Could not generate thumbnail for time ${(1 * i).toInt()}: $e');
      }

      // Use the last successful thumbnail if current is null
      if (bytes != null) {
        lastBytes = bytes;
        thumbnails.add(bytes); // Add successful thumbnail to the list
      } else {
        thumbnails.add(lastBytes!); // Fallback to the last successful thumbnail
      }
    }
  }
}
