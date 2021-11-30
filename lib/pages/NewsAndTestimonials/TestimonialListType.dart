import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Creates list of video players
class TestimonialVideosListType extends StatefulWidget {
  @override
  _TestimonialVideosListTypeState createState() =>
      _TestimonialVideosListTypeState();
}

class _TestimonialVideosListTypeState extends State<TestimonialVideosListType> {
  List<YoutubePlayerController> videos = new List<YoutubePlayerController>();
  List<YoutubePlayerController> videosforfullFocus =
      new List<YoutubePlayerController>();
  @override
  void initState() {
    // TODO: implement initState

    Firestore.instance
        .collection("Events")
        .document("TestimonialVideoID")
        .snapshots()
        .listen((videoids) {
      //print(videoids.data["VideoId"]);
      if (!mounted) {
        return;
      } else {
        setState(() {
          videosforfullFocus = videoids.data["VideoId"]
              .map<YoutubePlayerController>(
                (videoId) => YoutubePlayerController(
                  initialVideoId: videoId,
                  flags: const YoutubePlayerFlags(
                    disableDragSeek: true,
                    autoPlay: true,
                    forceHD: true,
                  ),
                ),
              )
              .toList();
        });

        setState(() {
          videos = videoids.data["VideoId"]
              .map<YoutubePlayerController>(
                (videoId) => YoutubePlayerController(
                  initialVideoId: videoId,
                  flags: const YoutubePlayerFlags(
                    disableDragSeek: true,
                    hideControls: true,
                    controlsVisibleAtStart: false,
                    autoPlay: false,
                  ),
                ),
              )
              .toList();
        });
      }
    });

    super.initState();
  }

  /*final List<YoutubePlayerController> _controllers = [
    '-hHlFt_57D8',
    'SZFtjsquKew',
    'b8FLUHKIaq8',
    'Cu7q5OydUK4',
    'SE8R8uCa7Tk',
    'IAuyt1ViYcg',
    'kl68Y7d5N5k',
    'NMaz72yqXNU',
  ].map<YoutubePlayerController>(
        (videoId) => YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
          ),
        ),
      )
 .toList();*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        /* appBar: AppBar(
        title: const Text('Testimonial'),
        centerTitle: true,
        backgroundColor: Colors.red[900],
      ),*/
        body: ListView.separated(
          itemBuilder: (context, index) {
            return Stack(
              alignment: AlignmentDirectional.center,
              children: [
                YoutubePlayer(
                  // key: ObjectKey(videos[index]),
                  controller: videos[index],
                  actionsPadding: const EdgeInsets.only(left: 16.0),
                  bottomActions: [
                    const SizedBox(width: 10.0),
                    ProgressBar(isExpanded: true),
                    const SizedBox(width: 10.0),
                    RemainingDuration(),
                    // FullScreenButton(),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // videos[index].reload();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Scaffold(
                              backgroundColor: Colors.black,
                              body: Center(
                                child: YoutubePlayer(
                                  // key: ObjectKey(videos[index]),
                                  controller: videosforfullFocus[index],
                                  actionsPadding:
                                      const EdgeInsets.only(left: 16.0),
                                  bottomActions: [
                                    const SizedBox(width: 10.0),
                                    ProgressBar(isExpanded: true),
                                    const SizedBox(width: 10.0),
                                    RemainingDuration(),
                                    // FullScreenButton(),
                                  ],
                                ),
                              ),
                            )));
                  },
                )
              ],
            );
          },
          itemCount: videos.length,
          separatorBuilder: (context, _) => Container(
            height: 10.0,
            color: Colors.transparent,
          ),
        ));
  }
}
