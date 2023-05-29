import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringDetails.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringForm.dart';
import 'package:flutter_orol_v2/pages/sideNavigationBar/sideNavigationBar.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../services/models/riverMonitoring.dart';
class RiverMonitoringPage extends StatefulWidget {
  const RiverMonitoringPage({Key? key}) : super(key: key);

  @override
  State<RiverMonitoringPage> createState() => _RiverMonitoringPageState();
}

class _RiverMonitoringPageState extends State<RiverMonitoringPage> {
  int index =0;
  int currentPage = 1;
  bool isScrolling = false;

  ScrollController _scrollController = ScrollController();
  WaterTestDetails _waterTestDetails = new WaterTestDetails();
  var _waterTestDetailsList;
  List dataList = [];
  @override
  void initState() {
    super.initState();
  }

  Future<List<WaterTestDetails>> getWaterTestDetails(currentPage) async {
    final waterTestDetails = await _waterTestDetails.getWaterTestDetails(currentPage);
    return waterTestDetails;
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

  // Check if scroll reaches the top
  bool isScrollAtTop() {
    return _scrollController.position.pixels == 0;
  }

// Check if scroll reaches the bottom
  bool isScrollAtBottom() {
    return _scrollController.position.pixels == _scrollController.position.maxScrollExtent;
  }
  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      if(currentPage!=1){
        currentPage=currentPage-1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    _scrollController.addListener(() {
      if (!isScrolling &&_scrollController.position.atEdge) {
        isScrolling = true;
        if (_scrollController.position.pixels ==0) {
            Future.delayed(Duration(milliseconds: 50), () {
              setState(() {
                if(currentPage!=1){
                  currentPage= currentPage-1;
                }
                isScrolling = false;
              });
            });
          // TODO: Handle reaching the top
        }
        else {
          // Scroll reached the bottom
          Future.delayed(Duration(microseconds: 50), () {
            // currentPage++;
            setState(() {
              currentPage= currentPage+1;
              isScrolling = false;
            });
          });
          // TODO: Handle reaching the bottom
        }
      }
    });

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
      body: FutureBuilder<List<WaterTestDetails>>(
        future:  getWaterTestDetails(currentPage),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if( snapshot.connectionState == ConnectionState.waiting){
            return  const Scaffold(body: Center(child: CircularProgressIndicator()));
          }else{
            if (snapshot.hasError)
              return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
            else {
              // Data has been fetched successfully
              return RefreshIndicator(
                onRefresh: _refreshData,
                child: Builder(
                  builder: (context) {
                    return ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        var item = snapshot.data[index];
                        return item.generalInformation['testerName'] != null
                            ? GestureDetector(
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
                                  Flexible(
                                    child: Text(
                                      "${item.generalInformation['testerName']}",
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                        )
                            : GestureDetector(
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
                                  Flexible(
                                    child: Text(
                                      "${item.generalInformation['testerName']}",
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                      },
                    );
                  }
                ),
              );
            }
          }
        },
      ),
    );
  }
}
