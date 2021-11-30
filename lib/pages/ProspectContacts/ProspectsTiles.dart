
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:redfootprintios/services/authentication.dart';
import 'package:redfootprintios/services/database.dart';

import '../ProfilePages/PublicProfilePage.dart';




class ProspectsTilesWidget extends StatelessWidget {
  final String imgAssetPath;
  final String prospectName;
  final String bioG;
  final String number;
  final String email;
  final String schedule;
  final String currentUser;
  BaseAuth prospectTilesWidgetAuth;
  ProspectsTilesWidget(
      {@required this.imgAssetPath,
      @required this.prospectName,
      @required this.number,
      this.bioG,
      @required this.email,
      @required this.prospectTilesWidgetAuth,
      this.schedule,
      this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(children: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PublicProfilePage(
                              publicProfilePageEmail: email,
                              heroTag: "AvatarSP" + prospectName.toString(),
                            )));
              },
              child: Container(
                  width: 140,
                  height: 200,
                  margin: EdgeInsets.only(right: 20),
                  child: (imgAssetPath != null)
                      ? ShaderMask(
                          shaderCallback: (Rect rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.black
                              ],
                            ).createShader(rect);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Hero(
                                tag: "AvatarSP" + prospectName.toString(),
                                child: CachedNetworkImage(
                                  imageUrl: imgAssetPath,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                )),
                          ),
                          blendMode: BlendMode.hardLight,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl:
                                "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/925px-Unknown_person.jpg",
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          )))),
          Positioned(
            bottom: 25,
            left: 15,
            child: Container(
              width: 100,
              child: Text(
                prospectName,
                textAlign: TextAlign.start,
                style: TextStyle(
                    //  backgroundColor: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              ),
            ),
          )
        ]),
        SizedBox(
          height: 10,
        ),
        Column(
          //  mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Text("Schedule"),
            ),
            //  SizedBox(
            //     height: 5,
            //  ),
            Container(
              child:
                  Container(margin: EdgeInsets.all(8), child: Text(schedule)),
            ),
            RaisedButton.icon(
                color: Colors.redAccent,
                onPressed: () {
                  MyDatabaseMethods().doneSchedule(currentUser, email);
                },
                icon: Icon(Icons.check),
                label: Text("Done"))
          ],
        )
      ],
    );
  }
}
