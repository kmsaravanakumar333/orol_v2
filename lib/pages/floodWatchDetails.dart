import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/services/models/floodWatch.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:intl/intl.dart';
import '../services/models/user.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';

class FloodWatchDetailsPage extends StatefulWidget {
  var floodDetailsId;

  FloodWatchDetailsPage({Key? key, required this.floodDetailsId})
      : super(key: key);

  @override
  State<FloodWatchDetailsPage> createState() =>
      _FloodWatchDetailsPageState();
}

class _FloodWatchDetailsPageState extends State<FloodWatchDetailsPage> {
  FloodAlert _floodalert = new FloodAlert();
  Users _user = new Users();
  var floodAlert;
  var floodDetailsId;
  var waterDetailsId;
  var userId;
  bool isLoading=false;

  @override
  void initState() {
    floodAlert = getFloodAlert();
    super.initState();
  }

  Future<FloodAlert> getFloodAlert() async {
    final floodAlert = await _floodalert.getFloodAlertById(
        widget.floodDetailsId);
    setState(() {
      floodDetailsId = floodAlert.id;
    });
    return floodAlert;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Flood Alert Details",
          style: TextStyle(
              fontFamily: 'WorkSans', fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list), // This is the filter icon
            onPressed: () {
              // You can open a filter dialog or perform any other filter-related action
            },
          ),
        ],
      ),
      body: FutureBuilder<FloodAlert>(
        future: floodAlert,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: NutsActivityIndicator(
                  radius: 10,
                  activeColor: Colors.lightGreen,
                  inactiveColor: Colors.grey,
                  tickCount: 8,
                  relativeWidth: 0.6,
                  startRatio: 2.0,)));
          } else {
            if (snapshot.hasError) {
              return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')));
            } else {
              return Scaffold(
                  body: isLoading?Center(child: NutsActivityIndicator(
                    radius: 10,
                    activeColor: Colors.lightGreen,
                    inactiveColor: Colors.grey,
                    tickCount: 8,
                    relativeWidth: 0.6,
                    startRatio: 2.0,)):SingleChildScrollView(
                    child: Column(
                        children: [
                          Container(
                              margin:
                              const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Resources.colors.appTheme.lightGray,
                                border: Border.all(
                                  color: Resources.colors.appTheme.gray,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      margin: EdgeInsets.only(bottom: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children:  <Widget>[
                                          Text(
                                            "Alert Information",
                                            style: TextStyle(
                                              fontFamily: "WorkSans",
                                              color: Resources.colors.appTheme.blue,
                                              fontWeight: FontWeight.w600,
                                            ),

                                          )
                                        ],
                                      )),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                width: (MediaQuery.of(context).size.width - 100) / 2,
                                                child: Text(
                                                  "Activity Date",
                                                  style: TextStyle(
                                                    color: Resources.colors.appTheme.lable,
                                                    fontFamily: "WorkSans",
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: (MediaQuery.of(context).size.width - 100) / 2,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  snapshot.data.date != null
                                                      ? '${DateFormat.yMMMd().format(DateTime.parse(snapshot.data.date).toLocal())}'
                                                      : '', // Handle null case gracefully
                                                  style: TextStyle(
                                                    color: Resources.colors.appTheme.seondary,
                                                    fontFamily: "WorkSans",
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  child: Text("Activity Time",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.lable,
                                                          fontFamily: "WorkSans"))),
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(snapshot.data
                                                      .time !=
                                                      null
                                                      ? "${snapshot.data
                                                      .time}"
                                                      : "",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.seondary,
                                                          fontFamily: "WorkSans",
                                                          fontWeight: FontWeight
                                                              .bold)))
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  child: Text("Location",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.lable,
                                                          fontFamily: "WorkSans"))),
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text("${snapshot.data.location}",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.seondary,
                                                          fontFamily: "WorkSans",
                                                          fontWeight:
                                                          FontWeight.w600))),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  child: Text("Latitude",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.lable,
                                                          fontFamily: "WorkSans"))),
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  alignment: Alignment.centerLeft,
                                                  child:
                                                    Text("${snapshot.data.latitude}",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.seondary,
                                                          fontFamily: "WorkSans",
                                                          fontWeight: FontWeight
                                                              .w600)))
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  child: Text("Longitude",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.lable,
                                                          fontFamily: "WorkSans"))),
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  alignment: Alignment.centerLeft,
                                                  child:
                                                Text("${snapshot.data.longitude}",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.seondary,
                                                          fontFamily: "WorkSans",
                                                          fontWeight: FontWeight
                                                              .w600)))
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  child: Text("Experience",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.lable,
                                                          fontFamily: "WorkSans"))),
                                              Container(
                                                  width: (MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width -
                                                      100) /
                                                      2,
                                                  alignment: Alignment.centerLeft,
                                                  child:
                                                  Text("${snapshot.data.experience}",
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.seondary,
                                                          fontFamily: "WorkSans",
                                                          fontWeight: FontWeight
                                                              .w600)))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          Container(
                              margin:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Resources.colors.appTheme.lightGray,
                                border: Border.all(
                                  color: Resources.colors.appTheme.gray,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      margin: EdgeInsets.only(bottom: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            "Pictures",
                                            style: TextStyle(
                                              fontFamily: "WorkSans",
                                              color: Resources.colors.appTheme.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )),
                                  if (snapshot.data.photos.length > 0)
                                    Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Container(
                                            height: 235,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.horizontal,
                                                itemCount: snapshot.data
                                                    .photos.length,
                                                itemBuilder:
                                                    (BuildContext ctxt,
                                                    int Index) {
                                                  return Column(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.only(right: 10),
                                                        height: (MediaQuery.of(context).size.width - 30) / 1.6,
                                                        width: (MediaQuery.of(context).size.width - 220) / 1.6,
                                                        padding: const EdgeInsets.only(bottom: 10, left: 5),
                                                        alignment: Alignment.bottomLeft,
                                                        decoration: BoxDecoration(
                                                          color: Resources.colors.appTheme.lightGray, // Use the desired background color
                                                          image: DecorationImage(
                                                            image: NetworkImage(
                                                                snapshot.data
                                                                    .photos[Index]),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }))),
                                ],
                              )),
                        ],
                    ),
                  )
              );
            }
          }
        },
      ),
    );
  }
}