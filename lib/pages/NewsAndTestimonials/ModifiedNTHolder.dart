import 'dart:async';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:redfootprintios/pages/Events/SmallEventPage.dart';
import 'package:redfootprintios/pages/NewsAndTestimonials/TestimonialPage.dart';
import 'package:redfootprintios/pages/NewsAndTestimonials/Trainings.dart';
import 'package:redfootprintios/services/animations/TransparentAnimation.dart';
import 'package:video_player/video_player.dart';

import 'PublicNewsPage.dart';
import 'TestimonialListType.dart';

class ModifiedNTHolder extends StatefulWidget {
  @override
  _ModifiedNTHolderState createState() => _ModifiedNTHolderState();
}

class _ModifiedNTHolderState extends State<ModifiedNTHolder> {
  VideoPlayerController _controller;
  int _pos = 0;
  Timer _timer;
  List<String> photos = [
    //   "assets/Testimonials.png",
    "assets/Screenshot_1.png",
    "assets/Screenshot_2.png",
    "assets/Screenshot_3.png",
    "assets/Screenshot_4.png",
    "assets/Screenshot_6.png",
    "assets/Screenshot_7.png",
    "assets/Screenshot_8.png"
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Navigator.of(context).push(TransparentRoute(
          builder: (BuildContext context) => PublicNewsPage()));
    });

    super.initState();
    if (!mounted) {
      return;
    } else {
      _timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
        setState(() {
          _pos = (_pos + 1) % photos.length;
        });
      });
      _controller = VideoPlayerController.asset('assets/NTVideo3.mp4')
        ..initialize().then((_) {
          // Once the video has been loaded we play the video and set looping to true.
          _controller.play();
          _controller.setLooping(true);

          _controller.setVolume(0.0);
          //  _controller.setLooping(true);
          // Ensure the first frame is shown after the video is initialized.
        });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //  backgroundColor: Colors.transparent,
        body: Stack(
      alignment: AlignmentDirectional.center,
      children: [
        VideoPlayer(_controller),
        SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(TransparentRoute(
                      builder: (BuildContext context) => PublicNewsPage()));
                },
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height / 4),
                 Container(
                        margin: EdgeInsets.fromLTRB(30, 30, 30, 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            "assets/newsThumbnail.png",
                          ),
                        ),
                      ),
                    
                    /* Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black.withOpacity(0.6),
                          ),
                          height: MediaQuery.of(context).size.height /7,
                          width: MediaQuery.of(context).size.width / 1.2,
                        ),*/
                  Container(
                  child:   Text(
                            'News',
                            style: GoogleFonts.greatVibes(
                                fontSize: 50,
                               // fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                 
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(TransparentRoute(
                      builder: (BuildContext context) =>
                          TestimonialVideosListType()));
                },
                child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                             
                              margin: EdgeInsets.fromLTRB(30, 30, 30, 5),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(photos[_pos],
                                      height:
                                          MediaQuery.of(context).size.height /
                                              5))),
                  Container(
                        
                          alignment: AlignmentDirectional.center,
                          margin: EdgeInsets.all(30),
                          child: Text(
                            'Testimonials',
                            style: GoogleFonts.greatVibes(
                                //    fontFamily: "Georgia",
                                fontSize: 50,
                               // fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                    
                    ]),
              ),
             
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(TransparentRoute(
                        builder: (BuildContext context) => Trainings()));
                  },
                  child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        ZoomIn(
                            // delay: Duration(milliseconds: 2400),
                            //  duration: Duration(seconds: 2),
                            child: Container(
                                margin: EdgeInsets.fromLTRB(30, 30, 30, 5),
                                child: Pulse(
                                    infinite: true,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                          "assets/trainingsThumnail.png"),
                                    )))),
                        Container(
                            height: MediaQuery.of(context).size.height / 5,
                           
                            alignment: AlignmentDirectional.center,
                            margin: EdgeInsets.all(30),
                            child: Text(
                              'Trainings',
                              style: GoogleFonts.greatVibes(
                                  fontSize: 50,
                                //  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                       
                      ])),
            ],
          ),
        ),
      ],
    ));
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
