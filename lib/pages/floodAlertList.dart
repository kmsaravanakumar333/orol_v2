import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/floodWatch.dart';
import 'package:flutter_orol_v2/pages/floodWatchDetails.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringDetails.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringForm.dart';
import 'package:flutter_orol_v2/pages/sideNavigationBar/sideNavigationBar.dart';
import 'package:flutter_orol_v2/services/models/floodWatch.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:intl/intl.dart';
import 'package:nuts_activity_indicator/nuts_activity_indicator.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/models/riverMonitoring.dart';
class FloodAlertList extends StatefulWidget {
  const FloodAlertList({Key? key}) : super(key: key);

  @override
  State<FloodAlertList> createState() => _FloodAlertListState();
}

class _FloodAlertListState extends State<FloodAlertList> {
  int index =0;
  int currentPage = 1;
  int itemPerPage = 15;
  var totalItems;
  bool isScrolling = false;
  int pageSize=15;
  FloodAlert _floodAlert = new FloodAlert();
  List dataList = [];
  @override
  void initState() {
    super.initState();
  }

  _navigateToFloodAlertDetailsScreen(BuildContext context, id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FloodWatchDetailsPage(floodDetailsId:id)));
  }

  _navigateToAddRiverMonitoringScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RiverMonitoringForm(mode:"add",id:'')));
  }

  _navigateToFloodWatchFormScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FloodWatchForm(mode: "add"),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('List of Flood Alert'),),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Resources.colors.appTheme.blue,
        foregroundColor: Resources.colors.appTheme.white,
        onPressed: () {
          // add your onPressed event handler here
          _navigateToFloodWatchFormScreen(context);
        },
        child: Icon(Icons.add),
      ),
      body: PagewiseListView(
        pageSize: pageSize,
        loadingBuilder: (context){
          return Center(child: NutsActivityIndicator(
            radius: 10,
            activeColor: Colors.lightGreen,
            inactiveColor: Colors.grey,
            tickCount: 8,
            relativeWidth: 0.6,
            startRatio: 2.0,));
        },
        itemBuilder: this._itemBuilder,
        pageFuture: (pageIndex) => fetchData(pageIndex! + 1),
        noItemsFoundBuilder: (context) => Center(child: Text('No items found.')),
      ),
    );
  }

  Widget _itemBuilder(context, dynamic item, _) {
    var w = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        _navigateToFloodAlertDetailsScreen(context, item.id);
      },
      child: Container(
        margin: const EdgeInsets.all(15.0),
        width: w,
        height: 140.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Resources.colors.appTheme.primary,
          border: Border.all(
            color: Resources.colors.appTheme.primary,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(124, 135, 157, 0.16),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(5, 5),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "${item.location}",
                        style: TextStyle(
                          fontFamily: "WorkSans",
                          color: Resources.colors.appTheme.seondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Text(
                  "${item.latitude} & ${item.longitude}",
                  style: TextStyle(
                    fontFamily: "WorkSans",
                    color: Resources.colors.appTheme.seondary,
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  "${item.date}",
                  // '${DateFormat.yMMMd().format(DateTime.parse(item.createdAt).toLocal())} ${item.floodAlert['activityTime'] != null ? "${item.floodAlert['activityTime']}" : ""}',
                  style: TextStyle(
                    fontFamily: "WorkSans",
                    color: Resources.colors.appTheme.seondary,
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  "${item.time}",
                  style: TextStyle(
                    fontFamily: "WorkSans",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchData(int pageIndex) async {
    final floodAlert = await _floodAlert.getFloodAlert(pageIndex);
    final List<dynamic> items = floodAlert.details;
    print(items);
    return items ;
  }
}
