import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringDetails.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringForm.dart';
import 'package:flutter_orol_v2/pages/sideNavigationBar/sideNavigationBar.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:intl/intl.dart';
import '../services/models/riverMonitoring.dart';
class RiverMonitoringPage extends StatefulWidget {
  const RiverMonitoringPage({Key? key}) : super(key: key);

  @override
  State<RiverMonitoringPage> createState() => _RiverMonitoringPageState();
}

class _RiverMonitoringPageState extends State<RiverMonitoringPage> {
  int index =0;
  WaterTestDetails _waterTestDetails = new WaterTestDetails();
  var _waterTestDetailsList;
  @override
  void initState() {
    _waterTestDetailsList=getWaterTestDetails();
    super.initState();
  }

  Future<List<WaterTestDetails>> getWaterTestDetails() async {
    final waterTestDetails = await _waterTestDetails.getWaterTestDetails();
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
      body: FutureBuilder<List<WaterTestDetails>>(
        future:  _waterTestDetailsList,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if( snapshot.connectionState == ConnectionState.waiting){
            return  const Scaffold(body: Center(child: CircularProgressIndicator()));
          }else{
            if (snapshot.hasError)
              return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
            else {
              return Scaffold(
                  backgroundColor: Resources.colors.appTheme.gray,
                  body: SingleChildScrollView(
                    child: Column(
                        children: [
                          SingleChildScrollView(
                              child:Column(
                                  children: List.from(snapshot.data.map((item) =>
                                      item.generalInformation['testerName']!=null
                                      ?GestureDetector(
                                        onTap: (){
                                          _navigateToRiverMonitoringDetailsScreen(context,item.id);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(15.0),
                                          width: w,
                                          height: 140.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color: Resources.colors.appTheme.white,
                                            border: Border.all(
                                              color: Resources.colors.appTheme.white,  // red as border color
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
                                          child:
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Flexible(child: Text("${item.generalInformation['testerName']}",style: TextStyle(fontFamily: "Montserrat",fontWeight: FontWeight.w600),)),
                                                const SizedBox(height: 10,),
                                                Text('${DateFormat.yMMMd().format(DateTime.parse(item.createdAt).toLocal())} ${item.generalInformation['activityTime']!=null?"${item.generalInformation['activityTime']}":""}',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontWeight: FontWeight.w400,
                                                    )),
                                                const SizedBox(height: 10,),
                                                Text("${item.generalInformation['location']}",style: TextStyle(fontFamily: "Montserrat",fontWeight: FontWeight.w400))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      :GestureDetector(
                                        onTap: (){
                                          _navigateToRiverMonitoringDetailsScreen(context,item.id);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(15.0),
                                          width: w,
                                          height: 140.0,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color: Resources.colors.appTheme.white,
                                            border: Border.all(
                                              color: Resources.colors.appTheme.white,  // red as border color
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
                                          child:
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Flexible(child: Text("${item.generalInformation['testerName']}",style: TextStyle(fontFamily: "Montserrat",fontWeight: FontWeight.w600),)),
                                                const SizedBox(height: 10,),
                                                Text('${DateFormat.yMMMd().format(DateTime.parse(item.createdAt).toLocal())} ${item.generalInformation['activityTime']!=null?"${item.generalInformation['activityTime']}":""}',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontFamily: "Montserrat",
                                                      fontWeight: FontWeight.w400,
                                                    )),
                                                const SizedBox(height: 10,),
                                                Text("${item.generalInformation['location']}",style: TextStyle(fontFamily: "Montserrat",fontWeight: FontWeight.w400))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                  )
                                  )
                              )
                          )
                        ]),
                  )
              );
            }
          }
        },
      ),
    );
  }
}
