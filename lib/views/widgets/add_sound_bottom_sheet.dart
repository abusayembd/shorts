import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shorts/controllers/upload_audio_video_controller.dart';

// import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'build_device_audio_list.dart';
import 'build_recommended_sound_list.dart';

class AddSoundBottomSheet extends StatelessWidget {
  final UploadAudioVideoController uploadAudioVideoController =
      Get.find<UploadAudioVideoController>();

  AddSoundBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.065,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    uploadAudioVideoController.toggleTabs();
                    debugPrint("Recommended tapped");
                  },
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.06,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.05,
                          width: MediaQuery.sizeOf(context).width * 0.3,
                          // color: Colors.blue,
                          child: const Center(
                            child: Text(
                              'Recommended',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        uploadAudioVideoController.tabStatus.value
                            ? Container(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.003,
                                width: MediaQuery.sizeOf(context).width * 0.3,
                                color: Colors.white,
                              )
                            : SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.003,
                                width: MediaQuery.sizeOf(context).width * 0.3,
                              )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    uploadAudioVideoController.toggleTabs();
                    debugPrint("your songs tapped");
                  },
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.06,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.05,
                          width: MediaQuery.sizeOf(context).width * 0.25,
                          // color: Colors.blue,
                          child: const Center(
                            child: Text(
                              'Your Songs',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        uploadAudioVideoController.tabStatus.value
                            ? SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.003,
                                width: MediaQuery.sizeOf(context).width * 0.3,

                                //color: Colors.white,
                              )
                            : Container(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.003,
                                width: MediaQuery.sizeOf(context).width * 0.3,
                                color: Colors.white,
                              )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            height: MediaQuery.sizeOf(context).height * 0.0009,
            color: Colors.white,
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.43,
              child: uploadAudioVideoController.tabStatus.value
                  ? buildRecommendedSoundsList()
                  : buildDeviceAudioList(),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: MediaQuery.sizeOf(context).height * 0.0009,
            color: Colors.white,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(
                () => GestureDetector(
                  onTap: () {
                    uploadAudioVideoController.isOriginalSoundSelected.value =
                        !uploadAudioVideoController
                            .isOriginalSoundSelected.value;
                  },
                  child: SizedBox(
                    height: Get.height * 0.03,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: uploadAudioVideoController
                                      .isOriginalSoundSelected.value
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            color: uploadAudioVideoController
                                    .isOriginalSoundSelected.value
                                ? Colors.red
                                : Colors.transparent,
                          ),
                          height: Get.height * 0.03,
                          width: Get.width * 0.04,
                          child: uploadAudioVideoController
                                  .isOriginalSoundSelected.value
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(width: Get.width * 0.02),
                        const Text(
                          'Original Sound',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  uploadAudioVideoController
                      .showVolumeSliderBottomSheet(context);
                },
                child: SizedBox(
                  height: Get.height * 0.03,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: Get.width * 0.02),
                      const Text(
                        'Volume',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
