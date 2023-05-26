import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/riverMonitoring.dart';
import '../models/user.dart';
// import '../models/waterTestDetails.dart';

class AppSharedPreference {
  static const String userDataPreference = "userData";
  static const String riverMonitoringPreference = "riverMonitoring";

  Future<bool> saveUserInfo(Users userData) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String user = jsonEncode(userData.toJson());
    return preferences.setString(userDataPreference, user);
  }

  Future<Users?> getUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString(userDataPreference) != null) {
      Map<String, dynamic> userDataMap = jsonDecode(preferences.getString(userDataPreference)!) as Map<String, dynamic>;
      Users userDataModel = Users.fromJson(userDataMap);
      return userDataModel;
    } else {
      return null;
    }
  }

  Future<bool> removeUserInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString(userDataPreference) != null) {
      return preferences.remove(userDataPreference);
    } else {
      return false;
    }
  }

  Future<bool> saveRiverMonitoringInfo(WaterTestDetails riverMonitoring) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String riverMonitor = jsonEncode(riverMonitoring.toJson());
    return preferences.setString(riverMonitoringPreference, riverMonitor);
  }

  Future<WaterTestDetails?> getRiverMonitoringInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString(riverMonitoringPreference) != null) {
      Map<String, dynamic> riverMonitoringMap = jsonDecode(preferences.getString(riverMonitoringPreference)!) as Map<String, dynamic>;
      WaterTestDetails riverMonitoringModel = WaterTestDetails.fromJson(riverMonitoringMap);
      return riverMonitoringModel;
    } else {
      return null;
    }
  }

  Future<bool> removeRiverMonitoringInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (preferences.getString(riverMonitoringPreference) != null) {
      return preferences.remove(riverMonitoringPreference);
    } else {
      return false;
    }
  }
}