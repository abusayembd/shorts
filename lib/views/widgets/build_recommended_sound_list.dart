import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

import '../../controllers/upload_audio_video_controller.dart';

Widget buildRecommendedSoundsList() {
  final uploadAudioVideoController = Get.find<UploadAudioVideoController>();
  return Obx(() {
    final sounds = uploadAudioVideoController.recommendedSounds;
    bool favSound = false;

    if (sounds.isEmpty) {
      return const Center(
        child: Text('No audio files available'),
      );
    }
    return ListView.builder(
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        return Obx(
          () => Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            height: MediaQuery.of(context).size.height * 0.060,
            width: double.infinity,
            decoration: BoxDecoration(
              color: uploadAudioVideoController.selectedAudio.value ==
                      sounds[index]['name']
                  ? Colors.red
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    uploadAudioVideoController.songNameController.text =
                        sounds[index]['name'] ??
                            ''; // update song name controller
                    uploadAudioVideoController.selectedAudio.value =
                        sounds[index]['name'] ?? ''; // update selected audio
                    uploadAudioVideoController.selectedAudioPath.value =
                        sounds[index]['fullPath'] ?? ''; // Save the audio path
                    uploadAudioVideoController.playAudio(
                        audioName: sounds[index]['name'] ?? '',
                        audioPath:
                            sounds[index]['fullPath'] ?? ''); // play audio
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.765,
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.11,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                            image: DecorationImage(
                              image: Image.network(
                                'https://picsum.photos/200',
                              ).image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sounds[index]['name']!.length > 34
                                  ? '${sounds[index]['name']?.substring(0, 34)}...' // Truncate to 35 characters and add ellipsis
                                  : sounds[index]['name'] ?? '',
                              // Otherwise, show the full name
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              sounds[index]['name']!.length > 34
                                  ? '${sounds[index]['name']?.substring(0, 34)}...' // Truncate to 35 characters and add ellipsis
                                  : sounds[index]['name'] ?? '',
                              // Otherwise, show the full name
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    //navigate to trim nav bar
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.058,
                    width: MediaQuery.of(context).size.width * 0.09,
                    // color: Colors.amberAccent,
                    child: Transform.rotate(
                      angle: 4.7,
                      child: const Icon(Icons.content_cut_sharp,
                          color: Colors.white, size: 25),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    favSound = true;
                    //add to favourite sound
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.058,
                    width: MediaQuery.of(context).size.width * 0.09,
                    child: Icon(
                      !favSound ? Icons.bookmark_border : Icons.bookmark,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  });
}
