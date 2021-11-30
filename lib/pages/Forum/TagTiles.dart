import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class TagTiles extends StatelessWidget {
  final String tagTile;

  TagTiles({this.tagTile});

  @override
  Widget build(BuildContext context) {
    var bgColor;
    if (tagTile == "Testimony Related") {
      bgColor = Colors.redAccent;
    } else if (tagTile == "Approach Related") {
      bgColor = Colors.redAccent;
    } else if (tagTile == "Strategy Related") {
      bgColor = Colors.purpleAccent;
    } else if (tagTile == "Problem Related") {
      bgColor = Colors.yellow;
    } else if (tagTile == "Health Related") {
      bgColor = Colors.green;
    } else if (tagTile == "Guide Related") {
      bgColor = Colors.tealAccent;
    } else if (tagTile == "Review Related") {
      bgColor = Colors.orangeAccent;
    }
    return Column(
      children: [
        Padding(padding: EdgeInsets.fromLTRB(5,0,5,0),child:
         Container(
            decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15.0),
                  topRight: const Radius.circular(15.0),
                  bottomLeft: const Radius.circular(15.0),
                  bottomRight: const Radius.circular(15.0),
                )),
            child: Container(
              margin: EdgeInsets.all(5),
              child: Center(
                  child: Text(
                tagTile,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),
            ),
          ),
          ),
        
      ],
    );
  }
}
