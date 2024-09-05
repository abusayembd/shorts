import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/upload_audio_video_controller.dart';

Widget buildDeviceAudioList() {
  final uploadAudioVideoController = Get.find<UploadAudioVideoController>();

  // Calling queryDeviceSongs when the tab is opened
  uploadAudioVideoController.querySongsWithPermission();

  return Obx(() {
    if (uploadAudioVideoController.deviceSongs.isEmpty) {
      return const Center(
        child: Text('No songs found on device'),
      );
    }

    return ListView.builder(
      itemCount: uploadAudioVideoController.deviceSongs.length,
      itemBuilder: (context, index) {
        final song = uploadAudioVideoController.deviceSongs[index];

        return ListTile(
          title: Text(
            song.displayNameWOExt.length > 35
                ? '${song.displayNameWOExt.substring(0, 35)}...'
                : song.displayNameWOExt,
          ),
          subtitle: Text(song.artist ?? 'Unknown Artist'),
          onTap: () {
            uploadAudioVideoController.selectSong(song.displayNameWOExt);
          },
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        );
      },
    );
  });
}
