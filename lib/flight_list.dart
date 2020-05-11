import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flighttickets/CustomShapeClipper.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Color discountBackgroundColor = Color(0xFFFFE08D);
final Color flightBorder = Color(0xFFE6E6E6);
final Color chipBackgroundColor = Color(0xFFF6F6F6);

class InheritedFlightListing extends InheritedWidget {
  final String toLocation, fromLocation;

  InheritedFlightListing({this.toLocation, this.fromLocation, Widget child})
      : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static InheritedFlightListing of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(InheritedFlightListing);
}

class FlightListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Result"),
        centerTitle: true,
        leading: InkWell(
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            FlightListTopPart(),
            SizedBox(
              height: 20.0,
            ),
            FlightListingBottomPart()
          ],
        ),
      ),
    );
  }
}

class FlightListTopPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            height: 160.0,
            decoration: BoxDecoration(
                color: Color(0xFFFFF17C2B),
                gradient: LinearGradient(colors: [
                  firstColor,
                  secondColor,
                ])),
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              elevation: 10.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${InheritedFlightListing.of(context).fromLocation}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Divider(
                              color: Colors.grey,
                              height: 20.0,
                            ),
                            Text(
                              "${InheritedFlightListing.of(context).toLocation}",
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.import_export,
                          color: Colors.black,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class FlightListingBottomPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("Best Deals for the Next 6 Month",
                style: dropDownMenuItemStyle),
          ),
          SizedBox(height: 10.0),
//          ListView(
//            physics: ClampingScrollPhysics(),
//            shrinkWrap: true,
//            scrollDirection: Axis.vertical,
//            children: <Widget>[
//              FlightCard(),
//              FlightCard(),
//              FlightCard(),
//              FlightCard(),
//              FlightCard(),
//              FlightCard(),
//            ],
//          )
          StreamBuilder(
            stream: Firestore.instance.collection('deal').snapshots(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _buildDealsList(context, snapshot.data.documents);
            },
          )
        ],
      ),
    );
  }
}

Widget _buildDealsList(BuildContext context, List<DocumentSnapshot> snapshots) {
  return ListView.builder(
      physics: ClampingScrollPhysics(),
      itemCount: snapshots.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        return FlightCard(
            flightDetails: FlightDetails.fromSnapshot(snapshots[index]));
      });
}

class FlightDetails {
  final String airlines, date, discount, rating;
  final int oldPrice, newPrice;

  FlightDetails.fromMap(Map<String, dynamic> map)
      : assert(map['airlines'] != null),
        assert(map['date'] != null),
        assert(map['discount'] != null),
        assert(map['rating'] != null),
        airlines = map['airlines'],
        date = map['date'],
        discount = map['discount'],
        oldPrice = map['oldPrice'],
        newPrice = map['newPrice'],
        rating = map['rating'];

  FlightDetails.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}

class FlightCard extends StatelessWidget {
  final FlightDetails flightDetails;

  FlightCard({this.flightDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 16.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: flightBorder)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '${formatCurrency.format(flightDetails.newPrice)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      '${formatCurrency.format(flightDetails.oldPrice)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough),
                    )
                  ],
                ),
//              Wrap(
//                spacing: 8.0,
//                runSpacing:-8.0 ,
//                children: <Widget>[
//                  FlightDetailChip(iconData: Icons.calendar_today,label:'June 2019'),
//                  FlightDetailChip(iconData: Icons.flight_takeoff,label:'Nigerian Airways'),
//                  FlightDetailChip(iconData: Icons.star,label:'4.4'),
//                ],
//              )
                Row(
                  children: <Widget>[
                    FlightDetailChip(
                        iconData: Icons.calendar_today,
                        label: '${flightDetails.date}'),
                    FlightDetailChip(
                        iconData: Icons.flight_takeoff,
                        label: '${flightDetails.airlines}'),
                    FlightDetailChip(
                        iconData: Icons.star, label: '${flightDetails.rating}'),
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 10.0,
          right: 10.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
                color: discountBackgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Text("${flightDetails.discount}",
                style: TextStyle(
                  color: appTheme.primaryColor,
                  fontSize: 14.0,
                )),
          ),
        )
      ]),
    );
  }
}

class FlightDetailChip extends StatelessWidget {
  final IconData iconData;
  final String label;

  FlightDetailChip({this.iconData, this.label});

  @override
  Widget build(BuildContext context) {
    return RawChip(
      padding: EdgeInsets.symmetric(),
      label: Text(label),
      labelStyle: TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ),
      backgroundColor: chipBackgroundColor,
      avatar: Icon(iconData),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
    );
  }
}
