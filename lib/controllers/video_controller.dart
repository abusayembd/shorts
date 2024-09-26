import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shorts/constants.dart';
import 'package:shorts/models/video.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  // late VideoPlayerController videoPlayerController;
  final Rx<List<Video>> _videoList = Rx<List<Video>>([]);
  RxBool isPlaying = false.obs; // Observed variable for play status

  // // method to get current video position
  // Duration get currentPosition => videoPlayerController.value.position;
  //
  // //  method to get video duration
  // Duration get videoDuration => videoPlayerController.value.duration;

  List<Video> get videoList => _videoList.value;


  @override
  void onInit() {
    super.onInit();
   // videoPlayerController.initialize();
    _videoList.bindStream(
        firestore.collection('videos').snapshots().map((QuerySnapshot query) {
      List<Video> retVal = [];
      for (var element in query.docs) {
        retVal.add(
          Video.fromSnap(element),
        );
      }
      return retVal;
    }));
  }

  // void initializeVideo(String videoUrl) {
  //   videoPlayerController =
  //       VideoPlayerController.networkUrl(Uri.parse(videoUrl))
  //         ..initialize().then((_) {
  //           play();
  //           videoPlayerController.setVolume(1);
  //
  //           // Add listener to loop the video
  //           videoPlayerController.addListener(() {
  //             if (videoPlayerController.value.position >=
  //                 videoPlayerController.value.duration) {
  //               videoPlayerController
  //                   .seekTo(Duration.zero); // Restart from beginning
  //               play(); // Play the video again
  //             }
  //           });
  //         });
  // }
  //
  // void play() {
  //   videoPlayerController.play();
  //   isPlaying.value = true; // Update play status
  // }
  //
  // void pause() {
  //   videoPlayerController.pause();
  //   isPlaying.value = false; // Update play status
  // }
  //
  // void disposeVideoController() {
  //   videoPlayerController.dispose();
  // }

  likeVideo(String id) async {
    DocumentSnapshot doc = await firestore.collection('videos').doc(id).get();
    var uid = authController.user.uid;
    if ((doc.data()! as dynamic)['likes'].contains(uid)) {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }
}
