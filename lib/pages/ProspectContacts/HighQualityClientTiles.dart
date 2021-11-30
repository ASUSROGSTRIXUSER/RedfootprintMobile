
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:redfootprintios/services/authentication.dart';

import '../ProfilePages/PublicProfilePage.dart';

//import 'package:login_minimalist/pages/ProspectMember.dart';


class HighQualityClientWidgetTiles extends StatelessWidget {
  final String imgAssetPath;
  final String highQualityProspectname;
  final String highQualityClientEmail;
  final BaseAuth highQualityTilesAuth;
  final String contactNumber;
  final String chatRoomID;
  final String jobTitle;

  HighQualityClientWidgetTiles(
      {@required this.imgAssetPath,
      @required this.highQualityProspectname,
      this.highQualityClientEmail,
      this.highQualityTilesAuth,
      this.contactNumber,
      this.chatRoomID,
      this.jobTitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PublicProfilePage(
                            publicProfilePageEmail: highQualityClientEmail,
                            heroTag:
                                "AvatarHQ" + highQualityClientEmail.toString(),
                          )));
            },
            child: Container(
                color: Colors.white,
                height: 240,
                width: 390,
                child: Card(
                  //  color: Color(0xFFF0E68C),
                  child: Row(
                    children: [
                      Row(children: [
                        Container(
                            width: 160,
                            height: 200,
                            margin: EdgeInsets.all(10),
                            child: new ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Hero(
                                    tag: "AvatarHQ" +
                                        highQualityClientEmail.toString(),
                                    child: CachedNetworkImage(
                                      imageUrl: imgAssetPath,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ))))
                      ]),
                      Expanded(
                          child: Container(
                              //     height: 150,
                              //     width: 70,
                              /*       decoration: BoxDecoration(
                                color: Color(0xFFF0E68C),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20.0),
                                  topRight: const Radius.circular(20.0),
                                  bottomLeft: const Radius.circular(20.0),
                                  bottomRight: const Radius.circular(20.0),
                                ),
                              ),*/
                              child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            highQualityProspectname,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          /*  Container(
                            margin: EdgeInsets.all(10),
                            child: Container(
                              margin: EdgeInsets.all(8),
                              child: Text(jobTitle,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),*/
                        ],
                      )))
                    ],
                  ),
                )),
          ),
        )
      ],
    );
    /*   return Column(
      children: [
        GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PublicProfilePage(
                            publicProfilePageEmail: highQualityClientEmail,
                          )));
            },
            child: Container(
                height: 180,
                width: 360,
                margin: EdgeInsets.only(right: 16),
                child: (imgAssetPath != "")
                    ? new ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CachedNetworkImage(
                          imageUrl: imgAssetPath,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ))
                    : new ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: imgAssetPath,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        )))),
        SizedBox(
          height: 5,
        ),
        Flexible(
          child: Text(
            highQualityProspectname,
            textAlign: TextAlign.start,
            style: TextStyle(
                //  backgroundColor: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Colors.black),
          ),
        ),
      ],
    );*/
  }
}
