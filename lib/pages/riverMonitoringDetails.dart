import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringForm.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/models/riverMonitoring.dart';
import '../services/models/user.dart';
import '../services/providers/AppSharedPreferences.dart';
class RiverMonitoringDetailsPage extends StatefulWidget {
  var waterDetailsId;
  RiverMonitoringDetailsPage({Key? key, required this.waterDetailsId}) : super(key: key);

  @override
  State<RiverMonitoringDetailsPage> createState() => _RiverMonitoringDetailsPageState();
}

class _RiverMonitoringDetailsPageState extends State<RiverMonitoringDetailsPage> {
  WaterTestDetails _waterTestDetail = new WaterTestDetails();
  Users _user = new Users();
  var waterTestDetail;
  var waterDetailsUserId;
  var waterDetailsId;
  var userId;

  @override
  void initState() {
    _getUserDetails();
    waterTestDetail=getWaterTestDetail();
    super.initState();
  }

  Future<void>  _getUserDetails() async {
    _user = (await AppSharedPreference().getUserInfo())as Users;
    setState(() {
      userId=_user.id;
    });
  }

  Future<WaterTestDetails> getWaterTestDetail() async {
    final waterTestDetails = await _waterTestDetail.getWaterTestDetailsById(widget.waterDetailsId);
    setState(() {
      waterDetailsUserId = waterTestDetails.userId;
      waterDetailsId = waterTestDetails.id;
    });
    await AppSharedPreference().saveRiverMonitoringInfo(waterTestDetails);
    return waterTestDetails;
  }

  _navigateToRiverMonitoringScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RiverMonitoringForm(mode:"edit")));
  }

  Future<WaterTestDetails> deleteWaterTestDetail() async {
    final waterTestDetails = await _waterTestDetail.deleteWaterTestDetailsById(widget.waterDetailsId,context);
    return waterTestDetails;
  }

  _showAlertBox(context){
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
          title: const Text("Delete Water Test Detail",style: TextStyle(
              fontFamily: 'Montserrat', fontWeight: FontWeight.bold),),
          content:
          const Text("Are you sure you want to delete this record?",style: TextStyle(
            fontFamily: 'Montserrat',),),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text("NO",style: TextStyle(
                    fontFamily: 'Montserrat',)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>( Color(0xFF1C3764)),
                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(8.0)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                  ),
                ),
                SizedBox(width: 10,),
                TextButton(
                  child: const Text("YES",style: TextStyle(
                    fontFamily: 'Montserrat',)),
                  onPressed: () {
                    deleteWaterTestDetail();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor: MaterialStateProperty.all<Color>( Color(0xFF1C3764)),
                    padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(8.0)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                  ),
                ),
              ],
            )
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Water Test Details",
          style: TextStyle(
              fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        actions: [
          userId==waterDetailsUserId?
          Row(
            children: [
              // IconButton(
              //   icon: const Icon(Icons.edit),
              //   onPressed: () {
              //     _navigateToRiverMonitoringScreen(context);
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showAlertBox(context);
                },
              ),
            ],
          )
              :SizedBox(),
        ],
      ),
      body: FutureBuilder<WaterTestDetails>(
        future:  waterTestDetail,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if( snapshot.connectionState == ConnectionState.waiting){
            return  const Scaffold(body: Center(child: CircularProgressIndicator()));
          }else{
            if (snapshot.hasError) {
              return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
            } else {
              return Scaffold(
                  body: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            margin:
                            const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
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
                                          "General Information",
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Activity Date",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: Text('${DateFormat.yMMMd().format(DateTime.parse(snapshot.data.createdAt).toLocal())}',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Activity Time",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: Text(snapshot.data.generalInformation['activityTime']!=null?"${snapshot.data.generalInformation['activityTime']}":"",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.bold)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Location",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: Text("${snapshot.data.generalInformation['location']}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Montserrat",
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Name",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: Text("${snapshot.data.generalInformation['testerName']}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Latitude",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: Text("${snapshot.data.generalInformation['latitude']}",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Longitude",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: Text("${snapshot.data.generalInformation['longitude']}",
                                                    style: TextStyle(
                                                        color: Colors.black,fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600)))
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
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: const <Widget>[
                                        Text(
                                          "Water Level & Weather",
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Weather",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: Text("${snapshot.data.waterLevelAndWeather['weather']}",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Air Temperatue",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                    "${snapshot.data.waterLevelAndWeather['airTemperature']}" + " °C",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Water Level",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: Text("${snapshot.data.waterLevelAndWeather['waterLevel']}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                        FontWeight.bold))),
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
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: const <Widget>[
                                        Text(
                                          "Water Quality Testing",
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Water Temperature",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['waterTemperature']!=null?Text(
                                                    "${snapshot.data.waterTesting['waterTemperature']}" + " °C",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                                    :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600))
                                            )
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("pH",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child:snapshot.data.waterTesting['pH']!=null?
                                                Text("${snapshot.data.waterTesting['pH']}" + " ph",
                                                    style:  TextStyle(
                                                        color: snapshot.data.waterTesting['waterTemperature']!=null&&snapshot.data.waterTesting['waterTemperature']>=6.5&&snapshot.data.waterTesting['waterTemperature']!=null&&snapshot.data.waterTesting['waterTemperature']<=8.5
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['waterTemperature']!=null&&snapshot.data.waterTesting['waterTemperature']<6.5||snapshot.data.waterTesting['waterTemperature']!=null&&snapshot.data.waterTesting['waterTemperature']>8.5?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                                    :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Alkalinity",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['alkalinity']!=null?
                                                Text("${snapshot.data.waterTesting['alkalinity']}" + " mg/L",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['alkalinity']!=null&&snapshot.data.waterTesting['alkalinity']>=20&&snapshot.data.waterTesting['alkalinity']!=null&&snapshot.data.waterTesting['alkalinity']<=250
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['alkalinity']!=null&&snapshot.data.waterTesting['alkalinity']<20||snapshot.data.waterTesting['alkalinity']!=null&&snapshot.data.waterTesting['alkalinity']>250?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight:
                                                        FontWeight.w600))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600))),
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Nitrate",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['nitrate']!=null?
                                                Text("${snapshot.data.waterTesting['nitrate']}" + " mg/L",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['nitrate']!=null&&snapshot.data.waterTesting['nitrate']<=1
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['nitrate']!=null&&snapshot.data.waterTesting['nitrate']>1
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Nitrite",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['nitrite']!=null?
                                                Text("${snapshot.data.waterTesting['nitrite']}" + " mg/L",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['nitrite']!=null&&snapshot.data.waterTesting['nitrite']<=1
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['nitrite']!=null&&snapshot.data.waterTesting['nitrite']>1
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                                   :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Hardness",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['hardness']!=null?
                                                Text("${snapshot.data.waterTesting['hardness']}" + " mg/L",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Chlorine",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child:snapshot.data.waterTesting['chlorine']!=null?
                                                Text("${snapshot.data.waterTesting['chlorine']}"+ " mg/L",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['chlorine']!=null&&snapshot.data.waterTesting['chlorine']<=1.0
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['chlorine']!=null&&snapshot.data.waterTesting['chlorine']>1.0
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Iron",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['iron']!=null?
                                                Text("${snapshot.data.waterTesting['iron']}"+ " mg/L",
                                                    style: TextStyle(
                                                        color:  snapshot.data.waterTesting['iron']!=null&&snapshot.data.waterTesting['iron']>=4.0&&snapshot.data.waterTesting['iron']!=null&&snapshot.data.waterTesting['iron']<=20.0
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['iron']!=null&&snapshot.data.waterTesting['iron']<4.0||snapshot.data.waterTesting['iron']!=null&&snapshot.data.waterTesting['iron']>20.0
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Dissolved oxygen",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['dissolvedOxygen']!=null?
                                                Text("${snapshot.data.waterTesting['dissolvedOxygen']}" + " mg/L",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['dissolvedOxygen']!=null&&snapshot.data.waterTesting['dissolvedOxygen']>=4.0&&snapshot.data.waterTesting['dissolvedOxygen']!=null&&snapshot.data.waterTesting['dissolvedOxygen']<=20.0
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['dissolvedOxygen']!=null&&snapshot.data.waterTesting['dissolvedOxygen']<4.0||snapshot.data.waterTesting['dissolvedOxygen']!=null&&snapshot.data.waterTesting['dissolvedOxygen']>20.0
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                                    :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600))
                                            )
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text(
                                                    "E Coli/Coliform Bacteria",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['bacteria']!=""?
                                                Text("${snapshot.data.waterTesting['bacteria']}",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['bacteria']!=""&&snapshot.data.waterTesting['bacteria']=="Absent"
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['bacteria']!=""&&snapshot.data.waterTesting['bacteria']=="Present"
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontWeight: FontWeight.bold))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Turbidity",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['turbidity']!=null?
                                                Text("${snapshot.data.waterTesting['turbidity']}" + " NTU",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['turbidity']<=15000
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['turbidity']>15000
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Phosphate",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['phosphate']!=null?
                                                Text("${snapshot.data.waterTesting['phosphate']}" + " mg/L",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['phosphate']<=1.0
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['phosphate']>1.0
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Ammonia",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['ammonia']!=null?
                                                Text("${snapshot.data.waterTesting['ammonia']}" + " mg/L",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['ammonia']>=0.2&&snapshot.data.waterTesting['ammonia']<=1.2
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['ammonia']<0.2||snapshot.data.waterTesting['ammonia']>1.2
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Lead",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['lead']!=null?
                                                Text("${snapshot.data.waterTesting['lead']}" + " mg/L",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['lead']==0
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['lead']>0
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                            :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600)))
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Total Dissolved Solids",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['totalDissolvedSolids']!=null?Text("${snapshot.data.waterTesting['totalDissolvedSolids']}" + " ppm",
                                                    style:  TextStyle(
                                                        color: snapshot.data.waterTesting['totalDissolvedSolids']<900
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['totalDissolvedSolids']>=900
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                                    :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600))
                                            )
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
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                child: Text("Conductivity",
                                                    style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontFamily: "Montserrat"))),
                                            Container(
                                                width: (MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                    100) /
                                                    2,
                                                alignment: Alignment.centerLeft,
                                                child: snapshot.data.waterTesting['conductivity']!=null?Text("${snapshot.data.waterTesting['conductivity']}" + " µs",
                                                    style: TextStyle(
                                                        color: snapshot.data.waterTesting['conductivity']<1000&&snapshot.data.waterTesting['conductivity']>10000
                                                            ?Colors.green
                                                            :snapshot.data.waterTesting['conductivity']>=1000||snapshot.data.waterTesting['conductivity']<=10000
                                                            ?Colors.red
                                                            :Colors.black,
                                                        fontFamily: "Montserrat",
                                                        fontWeight: FontWeight.w600))
                                                    :const Text("--",style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: "Montserrat",
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600))
                                            )
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
                                          "Rivers",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(
                                                0xFF1C3764,
                                              )),
                                        ),
                                      ],
                                    )),
                                if (snapshot.data.riverPictures.length > 0)
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Container(
                                          height: 225,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: snapshot.data.riverPictures.length,
                                              itemBuilder:
                                                  (BuildContext ctxt, int Index) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      height: (MediaQuery.of(context).size.width - 30) / 2,
                                                      width: (MediaQuery.of(context).size.width - 30) / 2,
                                                      padding: const EdgeInsets.only(
                                                          bottom: 10, left: 5),
                                                      alignment: Alignment.bottomLeft,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(snapshot.data.riverPictures[Index]['imageURL']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Text('${snapshot.data.riverPictures[Index]['description']}')
                                                  ],
                                                );
                                              }))),
                              ],
                            )),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
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
                                          "Surroundings",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(
                                                0xFF1C3764,
                                              )),
                                        ),
                                      ],
                                    )),
                                if (snapshot.data.surroundingPictures.length > 0)
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Container(
                                          height: 225,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: snapshot.data.surroundingPictures.length,
                                              itemBuilder:
                                                  (BuildContext ctxt, int Index) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      height: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                          30) /
                                                          2,
                                                      width: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                          30) /
                                                          2,
                                                      padding: EdgeInsets.only(
                                                          bottom: 10, left: 5),
                                                      alignment: Alignment.bottomLeft,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(snapshot.data.surroundingPictures[Index]['imageURL']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Text('${snapshot.data.surroundingPictures[Index]['description']}'),
                                                  ],
                                                );
                                              }))),
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
                                          "Flora & Fauna",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(
                                                0xFF1C3764,
                                              )),
                                        )
                                      ],
                                    )),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            padding: const EdgeInsets.only(
                                              bottom: 5,
                                            ),
                                            child: SvgPicture.asset(
                                              "assets/images/Flora-1.svg",
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                          Container(
                                              padding: const EdgeInsets.only(
                                                left: 10,
                                                bottom: 5,
                                              ),
                                              child: const Text(
                                                "Flora",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Color(0xFF1C3764),
                                                    fontWeight: FontWeight.w900),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (snapshot.data.floraPictures.length > 0)
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Container(
                                          height: 225,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: snapshot.data.floraPictures.length,
                                              itemBuilder:
                                                  (BuildContext ctxt, int Index) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      height: (MediaQuery.of(context).size.width - 30) / 2,
                                                      width: (MediaQuery.of(context).size.width - 30) / 2,
                                                      padding: const EdgeInsets.only(
                                                          bottom: 10, left: 5),
                                                      alignment: Alignment.bottomLeft,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(snapshot.data.floraPictures[Index]['imageURL']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Text('${snapshot.data.floraPictures[Index]['description']}')
                                                  ],
                                                );
                                              }))),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        bottom: 5,
                                        top: 20,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/images/Fauna-1.svg",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(
                                          top: 20,
                                          left: 10,
                                          bottom: 5,
                                        ),
                                        child: const Text(
                                          "Fauna",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF1C3764),
                                              fontWeight: FontWeight.w900),
                                        )),
                                  ],
                                ),
                                if (snapshot.data.faunaPictures.length > 0)
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Container(
                                          height: 225,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: snapshot.data.faunaPictures.length,
                                              itemBuilder:
                                                  (BuildContext ctxt, int Index) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      height: (MediaQuery.of(context).size.width - 30) / 2,
                                                      width: (MediaQuery.of(context).size.width - 30) / 2,
                                                      padding: const EdgeInsets.only(
                                                          bottom: 10, left: 5),
                                                      alignment: Alignment.bottomLeft,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(snapshot.data.faunaPictures[Index]['imageURL']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Text('${snapshot.data.faunaPictures[Index]['description']}')
                                                  ],
                                                );
                                              }))),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(
                                        bottom: 5,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/images/Flora-1.svg",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          bottom: 5,
                                        ),
                                        child: const Text(
                                          "Groups",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF1C3764),
                                              fontWeight: FontWeight.w900),
                                        )),
                                  ],
                                ),
                                if (snapshot.data.groupPictures.length > 0)
                                  Container(
                                      margin:
                                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Container(
                                          height: 225,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: snapshot.data.groupPictures.length,
                                              itemBuilder: (BuildContext ctxt, int Index) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      height: (MediaQuery.of(context).size.width - 30) / 2,
                                                      width: (MediaQuery.of(context).size.width - 30) / 2,
                                                      padding: const EdgeInsets.only(
                                                          bottom: 10, left: 5),
                                                      alignment: Alignment.bottomLeft,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(snapshot.data.groupPictures[Index]['imageURL']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Text('${snapshot.data.groupPictures[Index]['description']}')
                                                  ],
                                                );
                                              }))),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(
                                        bottom: 5,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/images/Flora-1.svg",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          bottom: 5,
                                        ),
                                        child: const Text(
                                          "Activities",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF1C3764),
                                              fontWeight: FontWeight.w900),
                                        )),
                                  ],
                                ),
                                if (snapshot.data.activityPictures.length > 0)
                                  Container(
                                      margin:
                                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Container(
                                          height: 225,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: snapshot.data.activityPictures.length,
                                              itemBuilder: (BuildContext ctxt, int Index) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      height: (MediaQuery.of(context).size.width - 30) / 2,
                                                      width: (MediaQuery.of(context).size.width - 30) / 2,
                                                      padding: const EdgeInsets.only(
                                                          bottom: 10, left: 5),
                                                      alignment: Alignment.bottomLeft,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(snapshot.data.activityPictures[Index]['imageURL']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Text('${snapshot.data.activityPictures[Index]['description']}')
                                                  ],
                                                );
                                              }))),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.only(
                                        bottom: 5,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/images/Flora-1.svg",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          bottom: 5,
                                        ),
                                        child: const Text(
                                          "Artworks",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF1C3764),
                                              fontWeight: FontWeight.w900),
                                        )),
                                  ],
                                ),
                                if (snapshot.data.artworkPictures.length > 0)
                                  Container(
                                      margin:
                                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      child: Container(
                                          height: 225,
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: snapshot.data.artworkPictures.length,
                                              itemBuilder: (BuildContext ctxt, int Index) {
                                                return Column(
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      height: (MediaQuery.of(context).size.width - 30) / 2,
                                                      width: (MediaQuery.of(context).size.width - 30) / 2,
                                                      padding: const EdgeInsets.only(
                                                          bottom: 10, left: 5),
                                                      alignment: Alignment.bottomLeft,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(snapshot.data.artworkPictures[Index]['imageURL']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 15,),
                                                    Text('${snapshot.data.artworkPictures[Index]['description']}')
                                                  ],
                                                );
                                              }))),
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
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: const <Widget>[
                                        Text(
                                          "Certificate",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(
                                                0xFF1C3764,
                                              )),
                                        ),
                                      ],
                                    )),
                                Container(
                                  margin: EdgeInsets.all(5),
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                            width: (MediaQuery.of(context).size.width - 100) ,
                                            alignment: Alignment.centerLeft,
                                            child: snapshot.data.certificateURL!='undefined'&&snapshot.data.certificateURL!=null?
                                            InkWell(
                                                child: Center(child: Text(snapshot.data.certificateURL!='undefined'?'${snapshot.data.certificateURL}':'No certificate found',style: const TextStyle(color: Colors.indigo),)),
                                                onTap: (){
                                                  if(snapshot.data.certificateURL!='undefined'){
                                                    launch(snapshot.data.certificateURL);
                                                  }
                                                }
                                            ):
                                            Center(
                                              child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:Resources.colors.appTheme.darkBlue, // Set the background color
                                                  ),
                                                  onPressed: (){
                                                    _waterTestDetail.generateCertificate(snapshot.data.id,context);
                                                  },
                                                  child: Text('Generate certificate', style: TextStyle(
                                                    color: Colors.white, // Set the font color
                                                  ),)
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ),
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
