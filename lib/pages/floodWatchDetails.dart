import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringForm.dart';
import 'package:flutter_orol_v2/services/models/floodWatch.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/models/riverMonitoring.dart';
import '../services/models/user.dart';
import '../services/providers/AppSharedPreferences.dart';

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
                body: Center(child: CircularProgressIndicator()));
          } else {
            if (snapshot.hasError) {
              return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')));
            } else {
              return Scaffold(
                  body: isLoading?Center(child:CircularProgressIndicator()):SingleChildScrollView(
                    child: Column(
                        children: [
                          Container(
                              margin:
                              const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFF1C3764),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      margin: EdgeInsets.only(bottom: 20),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: const <Widget>[
                                          Text(
                                            "Alert Information",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(
                                                  0xFF1C3764,
                                                )),

                                          ),
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
                                                  child: Text("Activity Date",
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
                                                  child: Text(
                                                      '${DateFormat.yMMMd()
                                                          .format(DateTime.parse(
                                                          snapshot.data.date)
                                                          .toLocal())}',
                                                      style: TextStyle(
                                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                                          color: Resources.colors.appTheme.veryDarkGray,
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
                                border: Border.all(
                                  color: Color(0xFF1C3764),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      margin: EdgeInsets.only(bottom: 20),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: const <Widget>[
                                          Text(
                                            "Pictures",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(
                                                  0xFF1C3764,
                                                )),
                                          ),
                                        ],
                                      )),
                                  if (snapshot.data.photos.length > 0)
                                    Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Container(
                                            height: 165,
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
                                                        margin: EdgeInsets.only(
                                                            right: 10),
                                                        height: (MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width - 30) / 2,
                                                        width: (MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width - 30) / 2,
                                                        padding: const EdgeInsets
                                                            .only(
                                                            bottom: 10, left: 5),
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        decoration: BoxDecoration(
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