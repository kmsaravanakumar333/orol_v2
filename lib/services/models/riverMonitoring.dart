import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_orol_v2/pages/home.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringList.dart';
import 'package:flutter_orol_v2/services/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/features/alertBox.dart';
import '../constants/constants.dart';
import '../providers/AppSharedPreferences.dart';

class WaterTestResult {
  List<WaterTestDetails> details;
  int count;

  WaterTestResult({required this.details, required this.count});
}

class WaterTestDetails {
  String? id='';
  String? userId = '';
  String? contributorName = '';
  Object? generalInformation = {};
  Object? waterLevelAndWeather = {};
  Object? waterTesting = {};
  List? surroundings = [];
  List? floraPictures = [];
  List? faunaPictures = [];
  List? artworkPictures = [];
  List? groupPictures = [];
  List? activityPictures = [];
  List? riverPictures = [];
  List? surroundingPictures = [];
  String? certificateURL="";
  String? createdAt='';
  int? count;

  WaterTestDetails({
    this.id,
    this.userId,
    this.contributorName,
    this.generalInformation,
    this.waterLevelAndWeather,
    this.waterTesting,
    this.surroundings,
    this.floraPictures,
    this.faunaPictures,
    this.artworkPictures,
    this.groupPictures,
    this.activityPictures,
    this.riverPictures,
    this.surroundingPictures,
    this.certificateURL,
    this.createdAt,
    this.count
  });

  Map<String, dynamic> toJson() => {
    "id":id,
    "userId":userId,
    "contributorName":contributorName,
    "generalInformation":generalInformation,
    "waterLevelAndWeather":waterLevelAndWeather,
    "waterTesting":waterTesting,
    "surroundings":surroundings,
    "floraPictures":floraPictures,
    "faunaPictures":faunaPictures,
    "artworkPictures":artworkPictures,
    "groupPictures":groupPictures,
    "activityPictures":activityPictures,
    "riverPictures":riverPictures,
    "surroundingPictures":surroundingPictures,
    "certificateURL":certificateURL,
    "createdAt":createdAt,
    "count":null
  };

  factory WaterTestDetails.fromJson(Map<String, dynamic> json) {
    return WaterTestDetails(
      id:json["id"],
      userId:json["userId"],
      contributorName:json["contributorName"],
      generalInformation:json["generalInformation"],
      waterLevelAndWeather:json["waterLevelAndWeather"],
      waterTesting:json["waterTesting"],
      surroundings:json["surroundings"],
      floraPictures:json["floraPictures"],
      faunaPictures:json["faunaPictures"],
      artworkPictures:json["artworkPictures"],
      groupPictures:json["groupPictures"],
      activityPictures:json["activityPictures"],
      riverPictures:json["riverPictures"],
      surroundingPictures:json["surroundingPictures"],
      certificateURL:json["certificateURL"],
      createdAt:json["createdAt"],
      count:null
    );
  }

  Future<WaterTestDetails> createWaterTestDetail(
      waterTestObj,
      riverPictures,
      surroundingPictures,
      faunaPictures,
      floraPictures,
      artworkPictures,
      activityPictures,
      groupPictures,
      context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await AppSharedPreference().getUserInfo() as Users;
    var accessToken = prefs.getString('access_token');
    // Set the headers
    ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
        backgroundColor: Colors.green, content: Text("Please wait creating record...")));
    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    // Prepare the request body
    var request = http.MultipartRequest('POST', Uri.parse(URL.apiURL + '/water-test-details/create-web'));

    // Add the river image files to the request
    for (int i = 0; i < riverPictures.length; i++) {
      var multipartFile = await http.MultipartFile.fromPath('riverFiles', riverPictures[i].path);
      request.files.add(multipartFile);
    }
    // Add the surrounding image files to the request
    for (int i = 0; i < surroundingPictures.length; i++) {
      var multipartFile = await http.MultipartFile.fromPath('surroundingFiles', surroundingPictures[i].path);
      request.files.add(multipartFile);
    }
    // Add the flora image files to the request
    for (int i = 0; i < floraPictures.length; i++) {
      var multipartFile = await http.MultipartFile.fromPath('floraFiles', floraPictures[i].path);
      request.files.add(multipartFile);
    }
    // Add the fauna image files to the request
    for (int i = 0; i < faunaPictures.length; i++) {
      var multipartFile = await http.MultipartFile.fromPath('faunaFiles', faunaPictures[i].path);
      request.files.add(multipartFile);
    }
    // Add the activity image files to the request
    for (int i = 0; i < activityPictures.length; i++) {
      var multipartFile = await http.MultipartFile.fromPath('activityFiles', activityPictures[i].path);
      request.files.add(multipartFile);
    }
    // Add the group image files to the request
    for (int i = 0; i < groupPictures.length; i++) {
      var multipartFile = await http.MultipartFile.fromPath('groupFiles', groupPictures[i].path);
      request.files.add(multipartFile);
    }
    // Add the artwork image files to the request
    for (int i = 0; i < artworkPictures.length; i++) {
      var multipartFile = await http.MultipartFile.fromPath('artworkFiles', artworkPictures[i].path);
      request.files.add(multipartFile);
    }

    request.fields['userId'] = user.id.toString();
    request.fields['generalInformation.activityDate'] = waterTestObj['generalInformation']["activityDate"] ;
    request.fields['generalInformation.activityTime'] = waterTestObj['generalInformation']["activityTime"] ;
    request.fields['generalInformation.testerName'] =  waterTestObj['generalInformation']["testerName"];
    request.fields['generalInformation.location'] =  waterTestObj['generalInformation']["location"];
    request.fields['generalInformation.latitude'] = waterTestObj['generalInformation']['latitude'];
    request.fields['generalInformation.longitude'] = waterTestObj['generalInformation']['longitude'];
    request.fields['waterLevelAndWeather.airTemperature'] = waterTestObj['waterLevelAndWeather']['airTemperature'];
    request.fields['waterLevelAndWeather.waterLevel'] = waterTestObj['waterLevelAndWeather']['waterLevel'];
    request.fields['waterLevelAndWeather.weather'] = waterTestObj['waterLevelAndWeather']['weather'];
    request.fields['waterTesting.dissolvedOxygen'] =waterTestObj['waterTesting']['dissolvedOxygen'] ?? '';
    request.fields['waterTesting.waterTemperature'] = waterTestObj['waterTesting']['waterTemperature']?? '';
    request.fields['waterTesting.pH'] = waterTestObj['waterTesting']['pH']?? '';
    request.fields['waterTesting.hardness'] = waterTestObj['waterTesting']['hardness']?? '';
    request.fields['waterTesting.nitrate'] = waterTestObj['waterTesting']['nitrate']?? '';
    request.fields['waterTesting.nitrite'] = waterTestObj['waterTesting']['nitrite']?? '';
    request.fields['waterTesting.chlorine'] = waterTestObj['waterTesting']['chlorine']?? '';
    request.fields['waterTesting.alkalinity'] = waterTestObj['waterTesting']['alkalinity']?? '';
    request.fields['waterTesting.iron'] = waterTestObj['waterTesting']['iron']?? '';
    request.fields['waterTesting.bacteria'] = waterTestObj['waterTesting']['bacteria']?? '';
    request.fields['waterTesting.turbidity'] = waterTestObj['waterTesting']['turbidity']?? '';
    request.fields['waterTesting.phosphate'] = waterTestObj['waterTesting']['phosphate']?? '';
    request.fields['waterTesting.ammonia'] = waterTestObj['waterTesting']['ammonia']?? '';
    request.fields['waterTesting.lead'] = waterTestObj['waterTesting']['lead']?? '';
    request.fields['surroundings'] = jsonEncode(waterTestObj['surroundings']);
    request.fields['surroundingPictures'] = jsonEncode(waterTestObj['surroundingPictures']);
    request.fields['riverPictures'] = jsonEncode(waterTestObj['riverPictures']);
    request.fields['floraPictures'] = jsonEncode(waterTestObj['floraPictures']);
    request.fields['faunaPictures'] = jsonEncode(waterTestObj['faunaPictures']);
    request.fields['artworkPictures'] = jsonEncode(waterTestObj['artworkPictures']);
    request.fields['groupPictures'] = jsonEncode(waterTestObj['groupPictures']);
    request.fields['activityPictures'] = jsonEncode(waterTestObj['activityPictures']);
    // Add generalInformation fields
    request.headers.addAll(headers);
    // var response;
    http.StreamedResponse response = await request.send();
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      generateCertificate(jsonDecode(responseBody),context,'create');
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ShowAlert("Thanks for your participation. Your data was submitted sucessfully","waterTestSubmit");
          });
      return WaterTestDetails.fromJson(jsonDecode(responseBody));
    }
    else {
      if (response.statusCode == 401) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ShowAlert("Unauthorized","waterTestSubmit");
            });;
        return WaterTestDetails.fromJson(jsonDecode(responseBody));
      }
      else if (response.statusCode == 400) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ShowAlert("Bad request","waterTestSubmit");
            });
        return WaterTestDetails.fromJson(jsonDecode(responseBody));
      }
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ShowAlert("Failed to create water test details","waterTestSubmit");
          });
      return WaterTestDetails.fromJson(jsonDecode(responseBody));
    }
  }

  Future<WaterTestDetails> updateWaterTestDetail(
      id,
      waterTestObj,
      riverPictures,
      surroundingPictures,
      faunaPictures,
      floraPictures,
      artworkPictures,
      activityPictures,
      groupPictures,
      context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await AppSharedPreference().getUserInfo() as Users;
    var accessToken = prefs.getString('access_token');
    // Set the headers
    ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
        backgroundColor: Colors.green, content: Text("Please wait creating record...")));
    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    // Prepare the request body
    var request = http.MultipartRequest('PUT', Uri.parse(URL.apiURL+'/water-test-details/'+id));
    // Add the river image files to the request
    for (int i = 0; i < riverPictures.length; i++) {
      if(riverPictures[i].runtimeType == XFile){
        var multipartFile = await http.MultipartFile.fromPath('riverFiles', riverPictures[i].path);
        request.files.add(multipartFile);
      }
    }
    // Add the surrounding image files to the request
    for (int i = 0; i < surroundingPictures.length; i++) {
      if(surroundingPictures[i].runtimeType == XFile){
        var multipartFile = await http.MultipartFile.fromPath('surroundingFiles', surroundingPictures[i].path);
        request.files.add(multipartFile);
      }
    }
    // Add the flora image files to the request
    for (int i = 0; i < floraPictures.length; i++) {
      if(floraPictures[i].runtimeType == XFile){
        var multipartFile = await http.MultipartFile.fromPath('floraFiles', floraPictures[i].path);
        request.files.add(multipartFile);
      }
    }
    // Add the fauna image files to the request
    for (int i = 0; i < faunaPictures.length; i++) {
      if(faunaPictures[i].runtimeType == XFile){
        var multipartFile = await http.MultipartFile.fromPath('faunaFiles', faunaPictures[i].path);
        request.files.add(multipartFile);
      }
    }
    // Add the activity image files to the request
    for (int i = 0; i < activityPictures.length; i++) {
      if(activityPictures[i].runtimeType == XFile){
        var multipartFile = await http.MultipartFile.fromPath('activityFiles', activityPictures[i].path);
        request.files.add(multipartFile);
      }
    }
    // Add the group image files to the request
    for (int i = 0; i < groupPictures.length; i++) {
      if(groupPictures[i].runtimeType == XFile){
        var multipartFile = await http.MultipartFile.fromPath('groupFiles', groupPictures[i].path);
        request.files.add(multipartFile);
      }
    }
    // Add the artwork image files to the request
    for (int i = 0; i < artworkPictures.length; i++) {
      if(artworkPictures[i].runtimeType == XFile){
        var multipartFile = await http.MultipartFile.fromPath('artworkFiles', artworkPictures[i].path);
        request.files.add(multipartFile);
      }
    }


    request.fields['userId'] = user.id.toString();
    request.fields['generalInformation.activityDate'] = waterTestObj['generalInformation']["activityDate"] ;
    request.fields['generalInformation.activityTime'] = waterTestObj['generalInformation']["activityTime"] ;
    request.fields['generalInformation.testerName'] =  waterTestObj['generalInformation']["testerName"];
    request.fields['generalInformation.location'] =  waterTestObj['generalInformation']["location"];
    request.fields['generalInformation.latitude'] = waterTestObj['generalInformation']['latitude'];
    request.fields['generalInformation.longitude'] = waterTestObj['generalInformation']['longitude'];
    request.fields['waterLevelAndWeather.airTemperature'] = waterTestObj['waterLevelAndWeather']['airTemperature'];
    request.fields['waterLevelAndWeather.waterLevel'] = waterTestObj['waterLevelAndWeather']['waterLevel'];
    request.fields['waterLevelAndWeather.weather'] = waterTestObj['waterLevelAndWeather']['weather'];
    request.fields['waterTesting.dissolvedOxygen'] =waterTestObj['waterTesting']['dissolvedOxygen'] ?? '';
    request.fields['waterTesting.waterTemperature'] = waterTestObj['waterTesting']['waterTemperature']?? '';
    request.fields['waterTesting.pH'] = waterTestObj['waterTesting']['pH']?? '';
    request.fields['waterTesting.hardness'] = waterTestObj['waterTesting']['hardness']?? '';
    request.fields['waterTesting.nitrate'] = waterTestObj['waterTesting']['nitrate']?? '';
    request.fields['waterTesting.nitrite'] = waterTestObj['waterTesting']['nitrite']?? '';
    request.fields['waterTesting.chlorine'] = waterTestObj['waterTesting']['chlorine']?? '';
    request.fields['waterTesting.alkalinity'] = waterTestObj['waterTesting']['alkalinity']?? '';
    request.fields['waterTesting.iron'] = waterTestObj['waterTesting']['iron']?? '';
    request.fields['waterTesting.bacteria'] = waterTestObj['waterTesting']['bacteria']?? '';
    request.fields['waterTesting.turbidity'] = waterTestObj['waterTesting']['turbidity']?? '';
    request.fields['waterTesting.phosphate'] = waterTestObj['waterTesting']['phosphate']?? '';
    request.fields['waterTesting.ammonia'] = waterTestObj['waterTesting']['ammonia']?? '';
    request.fields['waterTesting.lead'] = waterTestObj['waterTesting']['lead']?? '';
    request.fields['surroundings'] = jsonEncode(waterTestObj['surroundings']);
    request.fields['surroundingPictures'] = jsonEncode(waterTestObj['surroundingPictures']);
    request.fields['riverPictures'] = jsonEncode(waterTestObj['riverPictures']);
    request.fields['floraPictures'] = jsonEncode(waterTestObj['floraPictures']);
    request.fields['faunaPictures'] = jsonEncode(waterTestObj['faunaPictures']);
    request.fields['artworkPictures'] = jsonEncode(waterTestObj['artworkPictures']);
    request.fields['groupPictures'] = jsonEncode(waterTestObj['groupPictures']);
    request.fields['activityPictures'] = jsonEncode(waterTestObj['activityPictures']);
    // Add generalInformation fields
    request.headers.addAll(headers);
    // var response;
    http.StreamedResponse updateResponse = await request.send();
    var responseBody =await updateResponse.stream.bytesToString();
    if (updateResponse.statusCode == 200) {
      generateCertificate(jsonDecode(responseBody),context,'create');
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ShowAlert("Thanks for your participation. Your data was submitted sucessfully","waterTestSubmit");
          });
      return WaterTestDetails.fromJson(jsonDecode(responseBody));
    }
    else {
      if (updateResponse.statusCode == 401) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ShowAlert("Unauthorized","waterTestSubmit");
            });;
        return WaterTestDetails.fromJson(jsonDecode(responseBody));
      }
      else if (updateResponse.statusCode == 400) {
        await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ShowAlert("Bad request","waterTestSubmit");
            });
        return WaterTestDetails.fromJson(jsonDecode(responseBody));
      }
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ShowAlert("Failed to create water test details","waterTestSubmit");
          });
      return WaterTestDetails.fromJson(jsonDecode(responseBody));
    }
  }

  Future<WaterTestDetails> updateWaterTestDetail1(
      id,
      generalInformation,
      waterLevelAndWeather,
      surr,
      waterTesting,
      surroundingPictures,
      riverPictures,
      floraPictures,
      faunaPictures,
      artworkPictures,
      groupPictures,
      activityPictures,
      riverFiles,
      surroundingFiles,
      floraFiles,
      faunaFiles,
      groupFiles,
      activityFiles,
      artworkFiles,
      context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = await AppSharedPreference().getUserInfo() as Users;
    var accessToken = prefs.getString('access_token') ;
    String valuesString = surr.join(',');
    var request = http.MultipartRequest('PUT', Uri.parse(URL.apiURL+'/water-test-details/'+id));
    for (var i=0;i<riverFiles.length;i++) {
      final Uint8List bytes = riverFiles[i].bytes;
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/river_image_${i}.jpg');
      await tempFile.writeAsBytes(bytes);
      request.files.add(await http.MultipartFile.fromPath(
        'riverFiles',
        tempFile.path,
      ));
    }
    for (var i=0;i<surroundingFiles.length;i++) {
      final Uint8List bytes = surroundingFiles[i].bytes;
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/surrounding_image_${i}.jpg');
      await tempFile.writeAsBytes(bytes);
      request.files.add(await http.MultipartFile.fromPath(
        'surroundingFiles',
        tempFile.path,
      ));
    }
    for (var i=0;i<floraFiles.length;i++) {
      final Uint8List bytes = floraFiles[i].bytes;
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/flora_image_${i}.jpg');
      await tempFile.writeAsBytes(bytes);
      request.files.add(await http.MultipartFile.fromPath(
        'floraFiles',
        tempFile.path,
      ));
    }
    for (var i=0;i<faunaFiles.length;i++) {
      final Uint8List bytes = faunaFiles[i].bytes;
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/fauna_image_${i}.jpg');
      await tempFile.writeAsBytes(bytes);
      request.files.add(await http.MultipartFile.fromPath(
        'faunaFiles',
        tempFile.path,
      ));
    }
    for (var i=0;i<groupFiles.length;i++) {
      final Uint8List bytes = groupFiles[i].bytes;
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/group_image_${i}.jpg');
      await tempFile.writeAsBytes(bytes);
      request.files.add(await http.MultipartFile.fromPath(
        'groupFiles',
        tempFile.path,
      ));
    }
    for (var i=0;i<activityFiles.length;i++) {
      final Uint8List bytes = activityFiles[i].bytes;
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/activity_image_${i}.jpg');
      await tempFile.writeAsBytes(bytes);
      request.files.add(await http.MultipartFile.fromPath(
        'activityFiles',
        tempFile.path,
      ));
    }
    for (var i=0;i<artworkFiles.length;i++) {
      final Uint8List bytes = artworkFiles[i].bytes;
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/artwork_image_${i}.jpg');
      await tempFile.writeAsBytes(bytes);
      request.files.add(await http.MultipartFile.fromPath(
        'artworkFiles',
        tempFile.path,
      ));
    }
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.fields['userId'] = user.id.toString();
    request.fields['generalInformation.activityDate'] = generalInformation["activityDate"] ;
    request.fields['generalInformation.activityTime'] = generalInformation["activityTime"] ;
    request.fields['generalInformation.testerName'] =  generalInformation["testerName"];
    request.fields['generalInformation.location'] =  generalInformation["location"];
    request.fields['generalInformation.latitude'] = 12.124.toString();
    request.fields['generalInformation.longitude'] = 72.45.toString();
    request.fields['waterLevelAndWeather.airTemperature'] = 13.toString();
    request.fields['waterLevelAndWeather.waterLevel'] = waterLevelAndWeather['waterLevel'];
    request.fields['waterLevelAndWeather.weather'] = waterLevelAndWeather['weather'];
    request.fields['waterTesting.dissolvedOxygen'] = waterTesting['dissolvedOxygen'];
    request.fields['waterTesting.waterTemperature'] = waterTesting['waterTemperature'];
    request.fields['waterTesting.pH'] = waterTesting['pH'];
    request.fields['waterTesting.hardness'] = waterTesting['hardness'];
    request.fields['waterTesting.nitrate'] = waterTesting['nitrate'];
    request.fields['waterTesting.nitrite'] = waterTesting['nitrite'];
    request.fields['waterTesting.chlorine'] = waterTesting['chlorine'];
    request.fields['waterTesting.alkalinity'] = waterTesting['alkalinity'];
    request.fields['waterTesting.iron'] = waterTesting['iron'];
    request.fields['waterTesting.bacteria'] = waterTesting['bacteria'];
    request.fields['waterTesting.turbidity'] = waterTesting['turbidity'];
    request.fields['waterTesting.phosphate'] = waterTesting['phosphate'];
    request.fields['waterTesting.ammonia'] = waterTesting['ammonia'];
    request.fields['waterTesting.lead'] = waterTesting['lead'];
    request.fields['surroundings'] = jsonEncode(valuesString).toString();
    request.fields['surroundingPictures'] = jsonEncode(surroundingPictures).toString();
    request.fields['riverPictures'] = jsonEncode(riverPictures).toString();
    request.fields['floraPictures'] = jsonEncode(floraPictures).toString();
    request.fields['faunaPictures'] = jsonEncode(faunaPictures).toString();
    request.fields['artworkPictures'] = jsonEncode(artworkPictures).toString();
    request.fields['groupPictures'] = jsonEncode(groupPictures).toString();
    request.fields['activityPictures'] = jsonEncode(activityPictures).toString();

    http.StreamedResponse updateResponse = await request.send();
    var responseBody =await updateResponse.stream.bytesToString();
    if (updateResponse.statusCode == 200) {
      generateCertificate(responseBody,context,'update');
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ShowAlert("Thanks for your participation. Your data was submitted sucessfully","waterTestSubmit");
          });
      return WaterTestDetails.fromJson(responseBody as Map<String, dynamic>);
    }
    else {
      if (updateResponse.statusCode == 401) {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
            backgroundColor: Colors.green, content: Text("Unauthorized")));
        throw Exception('UnAuthorized.');
      } else if (updateResponse.statusCode == 400) {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
            backgroundColor: Colors.green, content: Text("Bad Request")));
        throw Exception('Bad request.');
      } else if (updateResponse.statusCode == 409) {
        ScaffoldMessenger.of(context!)
            .showSnackBar(const SnackBar(content: Text("User already registered")));
        throw Exception('Already registered.');
      }
      ScaffoldMessenger.of(context!)
          .showSnackBar(const SnackBar(content: Text("Failed to create user")));
      throw Exception('Failed to create user.');
    }
  }

   getWaterTestDetails(page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('access_token') ;
    var _user = (await AppSharedPreference().getUserInfo())as Users;
    final response = await http.get(
        Uri.parse(URL.apiURL+'/water-test-details?page=$page&limit=15'),
      headers: <String, String>{
        "Authorization": 'Bearer '+ accessToken!
      },
    );
    if (response.statusCode == 200) {
      var rows = jsonDecode(response.body);
      var count = rows['count'];
      var x = await List<WaterTestDetails>.from(
          (rows["rows"])
              .map((data) {
            var waterTestDetails = WaterTestDetails.fromJson(data);
            waterTestDetails.count = count;
            return waterTestDetails;
          }));
      return WaterTestResult(details: x, count: count);
    } else {
      throw Exception('Failed to load water test details');
    }
  }

  Future<WaterTestDetails> getWaterTestDetailsById(waterDetailsId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('access_token') ;
    var _user = (await AppSharedPreference().getUserInfo())as Users;
    final response = await http.get(
      Uri.parse(URL.apiURL+'/water-test-details/$waterDetailsId'),
      headers: <String, String>{
        "Authorization": 'Bearer '+ accessToken!
      },
    );
    if (response.statusCode == 200) {
      return WaterTestDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load water test details');
    }
  }

  Future<WaterTestDetails> deleteWaterTestDetailsById(waterDetailsId,context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('access_token') ;
    var _user = (await AppSharedPreference().getUserInfo())as Users;
    final response = await http.delete(
      Uri.parse(URL.apiURL+'/water-test-details/$waterDetailsId'),
      headers: <String, String>{
        "Authorization": 'Bearer '+ accessToken!
      },
    );
    if (response.statusCode == 204) {
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RiverMonitoringPage()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.green,content: Text("Record deleted successfully")));
      return WaterTestDetails.fromJson(jsonDecode(response.body));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.green,content: Text("Failed to delete water test details")));
      throw Exception('Failed to delete water test details');
    }
  }

  Future<WaterTestDetails> generateCertificate(waterDetails,context,mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('access_token') ;
    var _user = (await AppSharedPreference().getUserInfo())as Users;
    var waterDetailsId;
    if(mode=="create"){
      waterDetailsId=waterDetails['id'].toString();
    }else if(mode=="generate"){
      waterDetailsId=waterDetails.id.toString();
    }
    final response = await http.post(
      Uri.parse(URL.apiURL+'/pdf/generateReport'),
      headers: <String, String>{
        "Authorization": 'Bearer '+ accessToken!
      },
      body: {
        "id":'${waterDetailsId}'
      },
    );
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RiverMonitoringPage()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.green,content: Text("Certificate generated successfully")));
      return WaterTestDetails.fromJson(jsonDecode(response.body));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.green,content: Text("Failed to generate certificate")));
      throw Exception('Failed to generate certificate');
    }
  }

}
