import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/home.dart';

import '../../pages/riverMonitoringList.dart';
class ShowAlert extends StatefulWidget {
  String message;
  String mode;
  ShowAlert(this.message, this.mode, {Key? key}) : super(key: key);

  @override
  State<ShowAlert> createState() => _ShowAlertState();
}

class _ShowAlertState extends State<ShowAlert> {
  
  _navigateToRiverMonitoringScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(selectedIndex: 0,)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ) ,
      content: Container(
        height: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(bottom: 80),
                child: Text(widget.message, style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold))
            )
          ],
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.0),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFF1C3764)),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 50, vertical: 10)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Text("Okay"),
            onPressed: () {
              if(widget.mode=="waterTestSubmit"){
                Navigator.pop(context, "Okay");
                Navigator.pop(context, "Okay");
                Navigator.pop(context, "Okay");
                _navigateToRiverMonitoringScreen(context);
              }else{
                Navigator.pop(context, "Okay");
              }
              // Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
            },
          ),
        ),
      ],
    );
  }
}
