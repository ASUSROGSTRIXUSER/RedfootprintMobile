import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Trainings extends StatefulWidget {
  @override
  _TrainingsState createState() => _TrainingsState();
}

class _TrainingsState extends State<Trainings> {
   List<YoutubePlayerController> tvideos = new List<YoutubePlayerController>();
   List<YoutubePlayerController> tvideosforfocus = new List<YoutubePlayerController>();
 @override
  void initState() { 
  
 Firestore.instance.collection("Events").document("TrainingVideos").snapshots().listen((tvideoids) {
       if(!mounted){
      return;
    }else{
           setState(() {
         tvideosforfocus =  tvideoids.data["Tvideo"].map<YoutubePlayerController>(
        (videoId) => YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
          ),
        ),
      )
 .toList(); 
   });
         setState(() {
         tvideos =  tvideoids.data["Tvideo"].map<YoutubePlayerController>(
        (videoId) => YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay:false ,
            hideControls: true,
            

            
          ),
        ),
      )
 .toList(); 
   });
  }});
    
   
  super.initState();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     /* appBar: AppBar(
        title: const Text('Testimonial'),
        centerTitle: true,
        backgroundColor: Colors.red[900],
      ),*/
      body: 
      
      ListView.separated(
        itemBuilder: (context, index) {
    return Stack(
            alignment: AlignmentDirectional.center, children: [

           YoutubePlayer(
            key: ObjectKey(tvideos[index]),
            controller: tvideos[index],
            actionsPadding: const EdgeInsets.only(left: 16.0),
           
            bottomActions: [
              CurrentPosition(),
              const SizedBox(width: 10.0),
              ProgressBar(isExpanded: true),
              const SizedBox(width: 10.0),
              RemainingDuration(),
          
            ],
          ),
            IconButton(icon:Icon(Icons.play_arrow ,size: 40,color: Colors.white,),
          onPressed: (){
          //tvideos[index].reload();       
        Navigator.of(context).push(MaterialPageRoute(builder:(context) =>
        Scaffold(
          backgroundColor: Colors.black,
          body:   Center(child:
         YoutubePlayer(            
           // key: ObjectKey(videos[index]),
            controller: tvideosforfocus[index],
            actionsPadding: const EdgeInsets.only(left: 16.0),
            bottomActions: [
               const SizedBox(width: 10.0),
              ProgressBar(isExpanded: true),
              const SizedBox(width: 10.0),
              RemainingDuration(),          
             // FullScreenButton(),
            ],
          )
        ,) ,)  
        ));
          },
          )
            ]);
        },
        itemCount: tvideos.length,
        separatorBuilder: (context, _) => const SizedBox(height: 10.0),
      ),
    );
  }
}