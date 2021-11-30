import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:redfootprintios/pages/Events/SmallEventScape.dart';
import 'package:redfootprintios/services/animations/EnterExitAnimation.dart';
import 'package:redfootprintios/services/animations/TransparentAnimation.dart';
import 'package:video_player/video_player.dart';

import 'package:redfootprintios/pages/Events/SmallEventPage.dart';
import 'package:confetti/confetti.dart';

import 'ExclusiveEventsPage.dart';

class ExclusiveSmallEventsHolderPage extends StatefulWidget {
  @override
  _ExclusiveSmallEventsHolderPageState createState() =>
      _ExclusiveSmallEventsHolderPageState();
}

class _ExclusiveSmallEventsHolderPageState
    extends State<ExclusiveSmallEventsHolderPage> {
  VideoPlayerController _controller;
  VideoPlayerController _controller2;
  ConfettiController _controllerTopCenter = new ConfettiController();
  @override
  void initState() {
    super.initState();
    if (!mounted) {
      return;
    } else {
      _controllerTopCenter =
          ConfettiController(duration: const Duration(seconds: 10));
      _controllerTopCenter.play();
      _controller2 = VideoPlayerController.asset("assets/NTVideo4.mp4")
        ..initialize().then((_) {
          _controller2.play();
          _controller2.setLooping(true);
        });
      _controller = VideoPlayerController.asset('assets/videoplayback.mp4')
        ..initialize().then((_) {
          // Once the video has been loaded we play the video and set looping to true.
          _controller.play();

          //  _controller.setLooping(true);
          // Ensure the first frame is shown after the video is initialized.
        });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controllerTopCenter.dispose();
    _controller.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // extendBody: true,
        //  backgroundColor: Colors.black,
        body: Stack(
      alignment: AlignmentDirectional.center,
      children: [
        VideoPlayer(_controller),
        FadeIn(
          delay: Duration(seconds: 4),
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            child: VideoPlayer(_controller2),
          ),
        ),
        ListView(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                ZoomIn(
                    delay: Duration(milliseconds: 200),
                    duration: Duration(seconds: 2),
                    child: Hero(
                        tag: "EXvent",
                        child: Container(
                            margin: EdgeInsets.all(20),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(TransparentRoute(
                                    builder: (BuildContext context) =>
                                        ExclusiveEventsSubPage()));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child:
                                    Image.asset("assets/ExclusiveEvents.png"),
                              ),
                            )))),
                ZoomIn(
                    delay: Duration(milliseconds: 200),
                    duration: Duration(seconds: 2),
                    child: GestureDetector(
                        onTap: () {
                        /*  Navigator.of(context).push(TransparentRoute(
                              builder: (BuildContext context) =>
                                  SmallEventScrapePage()));*/
                            Navigator.of(context).push(TransparentRoute(
                              builder: (BuildContext context) => WebPageView(
                                  title: "Small Events",
                                  url:
                                      "https://redfootprint.org/online-events")));
                        },
                        child: Container(
                            margin: EdgeInsets.all(20),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child:
                                    Image.asset("assets/SmallEvents.png"))))),
              ],
            ),
          ],
        ),
        FadeIn(
          delay: Duration(seconds: 4),
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: ConfettiWidget(
              particleDrag: 0.1,
              numberOfParticles: 5,
              maxBlastForce: 10,
              // minimumSize: Size(5,5),
              maximumSize: Size(40, 20),
              gravity: 0.5,
              confettiController: _controllerTopCenter,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop:
                  true, // start again as soon as the animation is finished
              colors: const [
                Colors.red,
                Colors.yellow,
              ], // manually specify the colors to be used
            ),
          ),
        ),
        FadeIn(
          delay: Duration(seconds: 4),
          child: Align(
            alignment: AlignmentDirectional.topEnd,
            child: ConfettiWidget(
              particleDrag: 0.1,
              numberOfParticles: 5,

              // minimumSize: Size(5,5),
              maximumSize: Size(40, 20),
              gravity: 0.5,
              confettiController: _controllerTopCenter,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop:
                  true, // start again as soon as the animation is finished
              colors: const [
                Colors.red,
                Colors.yellow,
              ], // manually specify the colors to be used
            ),
          ),
        ),
        /* Column(
          children: [
            FadeOutLeftBig(
                duration: Duration(seconds: 4),
                animate: true,
                child: Container(
                    margin: EdgeInsets.all(20),
                    height: MediaQuery.of(context).size.height / 1.6,
                   
                    color: Colors.red)),
            FadeOutRight(
                duration: Duration(seconds: 4),
                animate: true,
                child: Container(
                    margin: EdgeInsets.all(20), height: 20, color: Colors.red)),
          ],
        )*/
      ],
    ));
  }
}
