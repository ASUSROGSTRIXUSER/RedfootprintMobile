import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_scraper/web_scraper.dart';

class SmallEventScrapePage extends StatefulWidget {
  @override
  _SmallEventScrapePageState createState() => _SmallEventScrapePageState();
}

class _SmallEventScrapePageState extends State<SmallEventScrapePage> {
   final webScraper = WebScraper('https://redfootprint.org');

  // Response of getElement is always List<Map<String, dynamic>>
  List<Map<String, dynamic>> productNames;
  List<Map<String, dynamic>> productDescriptions;
  List<Map<String, dynamic>> testentry;
  void fetchProducts() async {
    // Loads web page and downloads into local state of library
    if (await webScraper
        .loadWebPage('/online-events')) {
      setState(() {
        // getElement takes the address of html tag/element and attributes you want to scrap from website
        // it will return the attributes in the same order passed
        testentry = webScraper.getElement('body > div.elementor.elementor-1068 > div > div > section.elementor-section.elementor-top-section.elementor-element.elementor-element-fcc550d.elementor-section-full_width.elementor-section-height-default.elementor-section-height-default.animated.fadeIn > div.elementor-container.elementor-column-gap-default > div > div > div > div > section.elementor-section.elementor-inner-section.elementor-element.elementor-element-1a0d843.elementor-section-boxed.elementor-section-height-default.elementor-section-height-default' ,[]);
        productNames = webScraper.getElement(
                  'div.elementor-widget-container > h2.elementor-heading-title.elementor-size-default', []);

        productDescriptions = webScraper.getElement(
            'div.elementor-widget-container > h2.elementor-heading-title.elementor-size-default',[]);
      });
      print(testentry);
    }
  }

  @override
  void initState() {
    super.initState();
    // Requesting to fetch before UI drawing starts
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        
          body: SafeArea(
              child: productNames == null
                  ? Center(
                      child:
                          CircularProgressIndicator(), // Loads Circular Loading Animation
                    )
                  : ListView.builder(
                      itemCount: productNames.length,
                      itemBuilder: (BuildContext context, int index) {
                        // Attributes are in the form of List<Map<String, dynamic>>.
                        Map<String, dynamic> attributes =
                            productNames[index]['attributes'];
                        return ExpansionTile(
                          title: Text(productNames[index][
                            'title'
                          ].toString()),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        productDescriptions[index]['title']),
                                    margin: EdgeInsets.only(bottom: 10.0),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // uses UI Launcher to launch in web browser & minor tweaks to generate url
                                      launch(webScraper.baseUrl +
                                          attributes['href']);
                                    },
                                    child: Text(
                                      "View Product",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      })),
    );
  }
  }
