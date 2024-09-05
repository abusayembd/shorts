import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shorts/controllers/upload_audio_video_controller.dart';

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
                                  fontSize: 16,
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
                                  fontSize: 16,
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
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: MediaQuery.sizeOf(context).height * 0.0009,
            color: Colors.white,
          ),
          SingleChildScrollView(
            child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.495,
                child: uploadAudioVideoController.tabStatus.value
                    ? buildRecommendedSoundsList()
                    : buildDeviceAudioList()),
          )
        ],
      ),
    );
  }
}
