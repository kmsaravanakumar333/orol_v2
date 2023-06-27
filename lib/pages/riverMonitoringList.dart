import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringDetails.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringForm.dart';
import 'package:flutter_orol_v2/pages/sideNavigationBar/sideNavigationBar.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/models/riverMonitoring.dart';
class RiverMonitoringPage extends StatefulWidget {
  const RiverMonitoringPage({Key? key}) : super(key: key);

  @override
  State<RiverMonitoringPage> createState() => _RiverMonitoringPageState();
}

class _RiverMonitoringPageState extends State<RiverMonitoringPage> {
  int index =0;
  int currentPage = 1;
  int itemPerPage = 15;
  var totalItems;
  bool isScrolling = false;
  int pageSize=15;
  WaterTestDetails _waterTestDetails = new WaterTestDetails();
  List dataList = [];
  @override
  void initState() {
    super.initState();
  }

  _navigateToRiverMonitoringDetailsScreen(BuildContext context, id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RiverMonitoringDetailsPage(waterDetailsId:id)));
  }

  _navigateToAddRiverMonitoringScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RiverMonitoringForm(mode:"add")));
  }


  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('List of Rivers'),),
      drawer: AppSideNavigationBar(onTap: (ctx,i){
        setState(() {
          index=i;
          Navigator.pop(ctx);
        });
      }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Resources.colors.appTheme.darkBlue,
        foregroundColor: Resources.colors.appTheme.white,
        onPressed: () {
          // add your onPressed event handler here
          _navigateToAddRiverMonitoringScreen(context);
        },
        child: Icon(Icons.add),
      ),
      body: PagewiseListView(
        pageSize: pageSize,
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
        _navigateToRiverMonitoringDetailsScreen(context, item.id);
      },
      child: Container(
        margin: const EdgeInsets.all(15.0),
        width: w,
        height: 140.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Resources.colors.appTheme.white,
          border: Border.all(
            color: Resources.colors.appTheme.white,
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
                      "${item.generalInformation['testerName']}",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  item.certificateURL!=null?GestureDetector(
                      onTap: (){
                        if(item.certificateURL!='undefined'){
                          launch(item.certificateURL);
                        }
                      },
                      child: Icon(Icons.download)):Text(" ")
                ],
              ),
              const SizedBox(height: 10,),
              Text(
                '${DateFormat.yMMMd().format(DateTime.parse(item.createdAt).toLocal())} ${item.generalInformation['activityTime'] != null ? "${item.generalInformation['activityTime']}" : ""}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10,),
              Text(
                "${item.generalInformation['location']}",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchData(int pageIndex) async {
    final waterTestDetails = await _waterTestDetails.getWaterTestDetails(pageIndex);
    final List<dynamic> items = waterTestDetails.details;
    print(items);
    return items ;
  }
}
