import 'package:flutter/material.dart';
import 'package:redfootprintios/pages/NewsAndTestimonials/PublicNewsPage.dart';

import 'TestimonialListType.dart';
import 'TestimonialPage.dart';
import 'Trainings.dart';

class NewsTestimonialHolder extends StatefulWidget {
  @override
  _NewsTestimonialHolderState createState() => _NewsTestimonialHolderState();
}

class _NewsTestimonialHolderState extends State<NewsTestimonialHolder> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          //backgroundColor: Color(0xFFA41D21),
          appBar: PreferredSize(
            preferredSize: Size(0, 55),
            child: AppBar(
              backgroundColor: Color(0xFFA41D21),
              bottom: TabBar(
                tabs: [
                  Tab(
                      icon: Column(
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: Colors.white,
                      ),
                      Text("News"),
                    ],
                  )),
                  Tab(
                      icon: Column(
                    children: [
                      Icon(
                        Icons.fireplace,
                        color: Colors.white,
                      ),
                      Text("Testimonials"),
                    ],
                  )),   Tab(
                      icon: Column(
                    children: [
                      Icon(
                        Icons.book,
                        color: Colors.white,
                      ),
                      Text("Trainings"),
                    ],
                  )),
                ],
              ),
            ),
          ),
          body: TabBarView(children: [
            PublicNewsPage(),
           TestimonialVideosListType(),
            Trainings(),
          ]),
        ));
  }
}
