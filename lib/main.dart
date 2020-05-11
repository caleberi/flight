import 'package:flighttickets/flight_list.dart';
import "package:flutter/material.dart";
import 'CustomShapeClipper.dart';
import 'CustomerAppBar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
//import 'package:cached_network_image/cached_network_image.dart';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
      name: 'flight',
      options: Platform.isIOS
          ? const FirebaseOptions(
              googleAppID: '1:33021909484:android:ab660f1fe3c6917e1bc8c9', gcmSenderID: '33021909484', databaseURL: 'https://flight-app-8157a.firebaseio.com/')
          : const FirebaseOptions(
              googleAppID: '1:33021909484:android:42426e05c84305211bc8c9', apiKey: 'AIzaSyCTGxIPqqt5bdIicirmpShFEb3AQYWzKD4', databaseURL: 'https://flight-app-8157a.firebaseio.com/'));
  runApp(MaterialApp(
    title: "Flight List Mock Up",
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
    theme: appTheme,
  ));
}

Color firstColor = Color(0xFFF47D15);
Color secondColor = Color(0xFFEF772C);
ThemeData appTheme =
    ThemeData(primaryColor: Color(0xFFF3791A), fontFamily: 'Oxygen');

List<String> locations = [];

const TextStyle dropDownLabelStyle = TextStyle(
  color: Colors.white,
  fontSize: 16.0,
);
const TextStyle dropDownMenuItemStyle = TextStyle(
  color: Colors.black,
  fontSize: 16.0,
);
final _searchFieldController = TextEditingController();

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CustomAppBar(),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: <Widget>[
              HomeScreenTopPart(),
              homeScreenBottomPart,
              homeScreenBottomPart
            ])));
  }
}

class HomeScreenTopPart extends StatefulWidget {
  @override
  _HomeScreenTopPartState createState() => _HomeScreenTopPartState();
}

class _HomeScreenTopPartState extends State<HomeScreenTopPart> {
  var selectedLocationIndex = 0;
  var isFlightSelected = true;

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
              height: 400.0,
              decoration: BoxDecoration(
                color: Color(0xFFFFF17C2B),
//                  gradient: LinearGradient(colors: [
//                firstColor,
//                secondColor,
//              ])
              ),
              child: Column(children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                StreamBuilder(
                    stream:
                        Firestore.instance.collection('locations').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData)
                        addLocation(context, snapshot.data.documents);
                      return !snapshot.hasData
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 16.0,
                                ),
                                PopupMenuButton(
                                    onSelected: (index) {
                                      setState(() {
                                        selectedLocationIndex = index;
                                      });
                                    },
                                    child: Row(children: <Widget>[
                                      Text(locations[selectedLocationIndex],
                                          style: dropDownLabelStyle),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                      )
                                    ]),
                                    itemBuilder: (BuildContext context) =>
                                        _buildPopupMenuItem()),
                                Spacer(),
                                Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                ),
                              ]));
                    }),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  "Where would\nyou want to go?",
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                  ),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    child: TextField(
                      controller: _searchFieldController,
                      style: dropDownMenuItemStyle,
                      cursorColor: appTheme.primaryColor,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 14.0),
                          border: InputBorder.none,
                          suffix: Material(
                            elevation: 2.0,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                            child: InkWell(
                              child: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            InheritedFlightListing(
                                              fromLocation: locations[
                                                  selectedLocationIndex],
                                              toLocation:
                                                  _searchFieldController.text,
                                              child: FlightListingScreen(),
                                            )));
                              },
                            ),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          isFlightSelected = true;
                        });
                      },
                      child: ChoiceChip(
                          icon: Icons.flight_takeoff,
                          color: Colors.white,
                          text: "Flights",
                          isSelected: isFlightSelected),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isFlightSelected = false;
                        });
                      },
                      child: ChoiceChip(
                          icon: Icons.hotel,
                          color: Colors.white,
                          text: "Hotels",
                          isSelected: !isFlightSelected),
                    ),
                  ],
                )
              ]))),
    ]);
  }
}

List<PopupMenuItem<int>> _buildPopupMenuItem() {
  List<PopupMenuItem<int>> popupMenuItems = List();
  for (int i = 0; i < locations.length; i++) {
    popupMenuItems.add(PopupMenuItem(
      child: Text(locations[i], style: dropDownMenuItemStyle),
      value: i,
    ));
  }

  return popupMenuItems;
}

addLocation(BuildContext context, List<DocumentSnapshot> snapshots) {
  for (int i = 0; i < snapshots.length; i++) {
    final Location location = Location.fromSnapshot(snapshots[i]);
    locations.add(location.name);
  }
}

class ChoiceChip extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isSelected;
  final Color color;

  ChoiceChip({this.icon, this.text, this.isSelected, this.color});

  @override
  _ChoiceChipState createState() => _ChoiceChipState();
}

class _ChoiceChipState extends State<ChoiceChip> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      decoration: widget.isSelected
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.all(Radius.circular(20.0)))
          : null,
      child: Row(
        children: <Widget>[
          Icon(
            widget.icon,
            color: widget.color,
          ),
          Text(
            widget.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          )
        ],
      ),
    );
  }
}

var viewAllStyle = TextStyle(
  fontSize: 14.0,
  color: appTheme.primaryColor,
);

var homeScreenBottomPart = Column(
  children: <Widget>[
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("Currently watched Items", style: dropDownMenuItemStyle),
          Spacer(),
          Text(
            "VIEW ALL(12)",
            style: viewAllStyle,
          )
        ],
      ),
    ),
    Container(
      height: 220.0,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('cities')
              .orderBy('newPrice')
              .snapshots(),
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : _buildCitiesList(context, snapshot.data.documents);
          }),
    )
  ],
);

Widget _buildCitiesList(
    BuildContext context, List<DocumentSnapshot> snapshots) {
  return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: snapshots.length,
      itemBuilder: (context, index) {
        return CityCard(
          city: City.fromSnapshot(snapshots[index]),
        );
      });
}

class Location {
  final String name;

  Location.fromMap(Map<String, dynamic> map)
      : assert(map['name'] != null),
        name = map['name'];

  Location.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}

class City {
  final String imagePath, cityName, monthYear, discount;
  final int oldPrice, newPrice;

  City.fromMap(Map<String, dynamic> map)
      : assert(map['imagePath'] != null),
        assert(map['cityName'] != null),
        assert(map['discount'] != null),
        assert(map['monthYear'] != null),
        imagePath = map['imagePath'],
        cityName = map['cityName'],
        discount = map['discount'],
        oldPrice = map['oldPrice'],
        newPrice = map['newPrice'],
        monthYear = map['monthYear'];

  City.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data);
}

final formatCurrency = NumberFormat.simpleCurrency();

class CityCard extends StatelessWidget {
  final City city;

  CityCard({this.city});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                child: Stack(
                  children: <Widget>[
                    Container(
                        height: 200.0,
                        width: 160,
                        child:Image.network(
                          '${city.imagePath}',
                          fit: BoxFit.cover,
                        )),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      width: 160.0,
                      height: 60.0,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.transparent,
                            ])),
                      ),
                    ),
                    Positioned(
                      left: 10.0,
                      bottom: 10.0,
                      right: 10.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${city.cityName}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14.0),
                              ),
                              Text(
                                '${city.monthYear}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14.0),
                              ),
                            ],
                          ),
                          Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                "${city.discount}%",
                                style: TextStyle(
                                    fontSize: 14.0, color: Colors.black),
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    "(${formatCurrency.format(city.newPrice)})",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    "(${formatCurrency.format(city.oldPrice)})",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
