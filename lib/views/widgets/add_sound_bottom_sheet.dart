import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shorts/controllers/upload_audio_video_controller.dart';

class AddSoundBottomSheet extends StatelessWidget {
  final UploadAudioVideoController uploadAudioVideoController =
      Get.find<UploadAudioVideoController>();

  AddSoundBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () { uploadAudioVideoController.toggleTabs();
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
                            height: MediaQuery.sizeOf(context).height * 0.01,
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            color: Colors.white,
                          )
                        : SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.01,
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
                            height: MediaQuery.sizeOf(context).height * 0.01,
                            width: MediaQuery.sizeOf(context).width * 0.3,

                            //color: Colors.white,
                          )
                        : Container(
                            height: MediaQuery.sizeOf(context).height * 0.01,
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
    );
    //   Obx(
    //   () => DefaultTabController(
    //     length: 2,
    //     initialIndex: uploadAudioVideoController.currentTabIndex.value,
    //     child: Scaffold(
    //       appBar: AppBar(
    //         automaticallyImplyLeading: false,
    //         bottom: const TabBar(
    //           tabs: [
    //             Tab(text: 'Recommended'),
    //             Tab(text: 'Your Sound',),
    //           ],
    //         ),
    //       ),
    //       body: TabBarView(
    //         children: [
    //           Obx(() {
    //             if (uploadAudioVideoController.recommendedSounds.isEmpty) {
    //               return const Center(child: Text('No audio files in DB'));
    //             }
    //
    //             final sounds = uploadAudioVideoController.recommendedSounds;
    //
    //             return ListView.builder(
    //               itemCount: sounds.length,
    //               itemBuilder: (context, index) {
    //                 return ListTile(
    //                   title: Text(sounds[index]),
    //                   onTap: () {
    //                     // Update the song name controller
    //                     uploadAudioVideoController.songNameController.text =
    //                         sounds[index];
    //                     Get.back();
    //                   },
    //                 );
    //               },
    //             );
    //           }),
    //            GestureDetector(
    //              onTap: () => uploadAudioVideoController.requestPermission(),
    //              child: FutureBuilder<List<SongModel>>(
    //                 future: OnAudioQuery().querySongs(
    //                   sortType: SongSortType.DISPLAY_NAME,
    //                   orderType: OrderType.ASC_OR_SMALLER,
    //                   uriType: UriType.EXTERNAL,
    //                   ignoreCase: true,
    //
    //                 ),
    //                 builder: (context, item) {
    //                   if (item.data == null) {
    //                     return const Center(
    //                       child: CircularProgressIndicator(),
    //                     );
    //                   }
    //                   if (item.data!.isEmpty) {
    //                     return const Center(
    //                       child: Text('No songs found'),
    //                     );
    //                   }
    //                   return ListView.builder(
    //                     itemCount: item.data!.length,
    //                     itemBuilder: (context, index) {
    //                       return ListTile(
    //                         title: Text(item.data![index].displayNameWOExt),
    //                         subtitle: Text(item.data![index].artist ?? 'Artist name not available'),
    //                         onTap: () {
    //                           // Update the song name controller
    //                           uploadAudioVideoController.songNameController.text =
    //                               item.data![index].displayNameWOExt;
    //                           // Pop the bottom sheet
    //                           Get.back();
    //                         },
    //                       );
    //                     },
    //                   );
    //                 },
    //               ),
    //            ),
    //
    //             // return ListView.builder(
    //             //   itemCount: 1,
    //             //   itemBuilder: (context, index) {
    //             //     String fileName = uploadAudioVideoController
    //             //         .deviceAudioFiles[index].path
    //             //         .split('/')
    //             //         .last;
    //             //     return ListTile(
    //             //       title: Text(fileName),
    //             //       onTap: () {
    //             //         // Update the song name controller
    //             //         uploadAudioVideoController.songNameController.text =
    //             //             fileName;
    //             //         // Pop the bottom sheet
    //             //         Get.back();
    //             //       },
    //             //     );
    //             //   },
    //             // );
    //           // }),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
