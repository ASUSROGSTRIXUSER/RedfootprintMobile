import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TestimonialPage extends StatefulWidget {
  @override
  _TestimonialPageState createState() => _TestimonialPageState();
}

class _TestimonialPageState extends State<TestimonialPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  YoutubePlayerController _controller;
  TextEditingController _idController;
  TextEditingController _seekToController;

  PlayerState _playerState;
  YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  List<dynamic> videos = new List<dynamic>();

  @override
  void initState() {
    super.initState();

    Firestore.instance
        .collection("Events")
        .document("TestimonialVideoID")
        .snapshots()
        .listen((videoids) async {
      setState(() {
        videos = videoids.data["VideoId"];
        _controller = YoutubePlayerController(
          initialVideoId: videos.first,
          flags: const YoutubePlayerFlags(
            mute: false,
            autoPlay: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: true,
            enableCaption: true,
          ),
        );
        _controller..addListener(listener);
        _idController = TextEditingController();
        _seekToController = TextEditingController();
        _videoMetaData = const YoutubeMetaData();
        _playerState = PlayerState.unknown;
      });
    });
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        aspectRatio: 16 / 12,
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Center(
              child: Text(
                _controller.metadata.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _controller
              .load(videos[(videos.indexOf(data.videoId) + 1) % videos.length]);
          _showSnackBar('Next Video Started!');
        },
      ),
      builder: (context, player) => Scaffold(
        key: _scaffoldKey,
        body: ListView(
          children: [
            player,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _space,
                  _text('Title', _videoMetaData.title),
                  _space,
                  //   _text('Channel', _videoMetaData.author),
                  //  _space,
                  //  _text('Video Id', _videoMetaData.videoId),
                  //  _space,
                  /*     Row(
                    children: [
                      _text(
                        'Playback Quality',
                        _controller.value.playbackQuality,
                      ),
                      const Spacer(),
                      _text(
                        'Playback Rate',
                        '${_controller.value.playbackRate}x  ',
                      ),
                    ],
                  ),*/
                  //  _space,
                  /*   Row(
                    children: [
                      _loadCueButton('Previous'),
                      const SizedBox(width: 10.0),
                      _loadCueButton('Next'),
                    ],
                  ),*/
                  _space,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: _isPlayerReady
                            ? () => _controller.load(videos[
                                (videos.indexOf(_controller.metadata.videoId) -
                                        1) %
                                    videos.length])
                            : null,
                      ),
                      IconButton(
                        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                        onPressed: _isPlayerReady
                            ? () {
                                _muted
                                    ? _controller.unMute()
                                    : _controller.mute();
                                setState(() {
                                  _muted = !_muted;
                                });
                              }
                            : null,
                      ),
                      /*  FullScreenButton(
                        controller: _controller,
                        color: Colors.blueAccent,
                      ),*/
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: _isPlayerReady
                            ? () => _controller.load(videos[
                                (videos.indexOf(_controller.metadata.videoId) +
                                        1) %
                                    videos.length])
                            : null,
                      ),
                    ],
                  ),
                  _space,
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return YoutubePlayer(
                        aspectRatio: 16 / 12,
                        controller: _controller,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.blueAccent,
                        topActions: <Widget>[
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Center(
                              child: Text(
                                _controller.metadata.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                        onReady: () {
                          _isPlayerReady = true;
                        },
                        onEnded: (data) {
                          _controller.load(videos[
                              (videos.indexOf(data.videoId) + 1) %
                                  videos.length]);
                          _showSnackBar('Next Video Started!');
                        },
                      );
                    },
                  ),

                  _space,

                  /* AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: _getStateColor(_playerState),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _playerState.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 17),
        children: [
          TextSpan(
            text: value ?? '',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500, fontSize: 17),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700];
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900];
      default:
        return Colors.blue;
    }
  }

  Widget get _space => const SizedBox(height: 10);

  Widget _loadCueButton(String action) {
    return Expanded(
      child: MaterialButton(
        color: Colors.blueAccent,
        onPressed: _isPlayerReady
            ? () {
                if (_idController.text.isNotEmpty) {
                  var id = YoutubePlayer.convertUrlToId(
                    _idController.text,
                  );
                  if (action == 'Previous')
                    _controller.load(videos[
                        (videos.indexOf(_controller.metadata.videoId) - 1) %
                            videos.length]);
                  if (action == 'Next')
                    _controller.load(videos[
                        (videos.indexOf(_controller.metadata.videoId) + 1) %
                            videos.length]);
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  _showSnackBar('Source can\'t be empty!');
                }
              }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
