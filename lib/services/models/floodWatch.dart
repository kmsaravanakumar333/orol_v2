import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/services/constants/constants.dart';
import 'package:flutter_orol_v2/services/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/features/alertBox.dart';
import '../providers/AppSharedPreferences.dart';

class floodAlertResult {
  List<FloodAlert> details;
  int count;

  floodAlertResult({required this.details, required this.count});
}

class FloodAlert {
  String? id='';
  String? userId = '';
  String? latitude = '';
  String? longitude = '';
  String? location = '';
  String? date = '';
  String? time = '';
  String? experience = '';
  Object? floodAlert = {};
  List? floodPicture = [];
  List? photos = [];
  int? count;
  String? createdAt='';

  FloodAlert({
    this.id,
    this.userId,
    this.latitude,
    this.longitude,
    this.location,
    this.date,
    this.time,
    this.experience,
    this.floodAlert,
    this.floodPicture,
    this.photos,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    "id":id,
    "userId":userId,
    "latitude":latitude,
    "longitude":longitude,
    "location":location,
    "date":date,
    "time":time,
    "experience":experience,
    "floodAlert":floodAlert,
    "floodPicture":floodPicture,
    "photos":photos,
    "createdAt":createdAt,
    "count":null
  };

  factory FloodAlert.fromJson(Map<String, dynamic> json) {
    return FloodAlert(
        id:json["id"],
        userId:json["userId"],
      latitude:json["latitude"],
      longitude:json["longitude"],
      location:json["location"],
      date:json["date"],
      time:json["time"],
      experience:json["experience"],
        floodAlert:json["floodAlert"],
        floodPicture:json["floodPicture"],
      photos:json["photos"],
      createdAt:json["createdAt"],
    );
  }

  Future<FloodAlert> createFloodAlert(
      floodAlert,
      floodPicture,
      context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await AppSharedPreference().getUserInfo() as Users;
    var accessToken = prefs.getString('access_token');
    final apiUrl = 'https://api.ourriverourlife.com/flood-alert/create-alert';
    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    for (int i = 0; i < floodPicture.length; i++) {
      var multipartFile = await http.MultipartFile.fromPath('photos', floodPicture[i].path);
      request.files.add(multipartFile);
    }

    request.fields['userId'] = user.id.toString();
    request.fields['activityTime'] =  floodAlert['floodAlert']["activityTime"];
    request.fields['activityDate'] =  floodAlert['floodAlert']["activityDate"];
    request.fields['location'] =  floodAlert['floodAlert']["location"];
    request.fields['latitude'] =  floodAlert['floodAlert']["latitude"];
    request.fields['longitude'] =  floodAlert['floodAlert']["longitude"];
    request.fields['experience'] =  floodAlert['floodAlert']["experience"] ?? "";
    request.fields['photos'] = jsonEncode(floodAlert['photos']);

    // Add generalInformation fields
    request.headers.addAll(headers);
    // var response;
    http.StreamedResponse response = await request.send();
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ShowAlert("Thanks for your participation. Your data was submitted sucessfully","floodAlertSubmit");
          });
      return FloodAlert.fromJson(jsonDecode(responseBody));
    }
    else {
      if (response.statusCode == 401) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ShowAlert("Unauthorized","waterTestSubmit");
            });;
        return FloodAlert.fromJson(jsonDecode(responseBody));
      }
      else if (response.statusCode == 400) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ShowAlert("Bad request","waterTestSubmit");
            });
        return FloodAlert.fromJson(jsonDecode(responseBody));
      }
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ShowAlert("Failed to create water test details","waterTestSubmit");
          });
      return FloodAlert.fromJson(jsonDecode(responseBody));
    }
  }

  getFloodAlert(page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('access_token') ;
    var _user = (await AppSharedPreference().getUserInfo())as Users;
    final response = await http.get(
      Uri.parse('https://api.ourriverourlife.com/flood-alert?page=$page&limit=15'),
      headers: <String, String>{
        "Authorization": 'Bearer '+ accessToken!
      },
    );
    if (response.statusCode == 200) {
      var rows = jsonDecode(response.body);
      var count = rows['count'];
      var x = await List<FloodAlert>.from(
          (rows["rows"])
              .map((data) {
            var floodAlert = FloodAlert.fromJson(data);
            floodAlert.count = count;
            return floodAlert;
          }));
      return floodAlertResult(details: x, count: count);
    } else {
      throw Exception('Failed to load water test details');
    }
  }

  getFloodAlertByFilter(page,startDate,endDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('access_token') ;
    var _user = (await AppSharedPreference().getUserInfo())as Users;
    final response = await http.get(
      Uri.parse('https://api.ourriverourlife.com/flood-alert/searchByDate/search?start=$startDate&end=$endDate'),
      headers: <String, String>{
        "Authorization": 'Bearer '+ accessToken!
      },
    );
    if (response.statusCode == 200) {
      var rows = jsonDecode(response.body);
      var count = rows['count'];
      var x = await List<FloodAlert>.from(
          (rows["rows"])
              .map((data) {
            var floodAlert = FloodAlert.fromJson(data);
            floodAlert.count = count;
            return floodAlert;
          }));
      return floodAlertResult(details: x, count: count);
    } else {
      throw Exception('Failed to load water test details');
    }
  }

  Future<FloodAlert> getFloodAlertById(floodAlertId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('access_token') ;
    var _user = (await AppSharedPreference().getUserInfo())as Users;
    final response = await http.get(
      Uri.parse(URL.apiURL+'/flood-alert/$floodAlertId'),
      headers: <String, String>{
        "Authorization": 'Bearer '+ accessToken!
      },
    );
    if (response.statusCode == 200) {
      return FloodAlert.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load water test details');
    }
  }

}

