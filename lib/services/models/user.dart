import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../providers/AppSharedPreferences.dart';

_navigateToHomeScreen(BuildContext context) {
  Navigator.of(context).pop();
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(selectedIndex: 0,)));
}


class Users {
  String? id = '';
  String? firstName = '';
  String? lastName = '';
  String? email = '';
  String? phoneNumber = '';
  String? password = '';
  List? avatarURL = [];


  Users({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.password,
    this.avatarURL,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phoneNumber": phoneNumber,
    "password": password,
    "avatarURL": avatarURL,
  };

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
      avatarURL: json['avatarURL'],
    );
  }

  //Function to login the user using email
  loginByEmail(_user, context, mode) async {
      final response = await http.post(
        Uri.parse(
            '${URL.apiURL}/user/auth'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _user['email'],
        }),
      );
      var data;
      if(response.body!="Email is incorrect"){
        data = jsonDecode(response.body);
      }else{
        data=response.body;
      }
      if (response.statusCode == 200 && response.body!='Email is incorrect') {
        if(data['user']!=null){
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("access_token", "${data["accessToken"]}");
          AppSharedPreference().saveUserInfo(Users.fromJson(data['user']));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.green,content: Text('Successfully logged in')));
          _navigateToHomeScreen(context);
        }else{
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor:Colors.redAccent,content: Text('${response.body}')));
        }
        return Users.fromJson(data['user']);
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green, content: Text("Unauthorized")));
        return data;
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green, content: Text("Invalid Credentials")));
        return data;
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green, content: Text("Unauthorized")));
        return data;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green, content: Text("User not registered")));
      return data;
  }

  //Function to login the user using phone number
  loginByPhone(_user, context, mode) async {
    var body;
    var phoneNumber;
    if(_user.phoneNumber!=null){
      phoneNumber = _user.phoneNumber;
    }else{
      phoneNumber = _user.email;
    }
    if(_user.runtimeType==UnmodifiableMapView<String, Object?>){
      body=jsonEncode(<String, String>{
        'phoneNumber': _user['email'],
        'password': _user['password'],
      });
    }else{
      body=jsonEncode(<String, String>{
        'phoneNumber': phoneNumber,
        'password': _user.password,
      });
    }
    final response = await http.post(
      Uri.parse(
          '${URL.apiURL}/user/auth'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("access_token", "${data["accessToken"]}");
      AppSharedPreference().saveUserInfo(Users.fromJson(data['user']));
      if(mode=="registerUser"){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.green,content: Text("Successfully logged in")));
        _navigateToHomeScreen(context);
      }
      return Users.fromJson(data['user']);
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green, content: Text("Unauthorized")));
      throw Exception('Unauthorized.');
    } else if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green, content: Text("Invalid Credentials")));
      throw Exception('Bad request.');
    } else if (response.statusCode == 409) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green, content: Text("Unauthorized")));
      throw Exception('409.');
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green, content: Text("User not registered")));
    throw Exception('Failed to login.');
  }

  //Function to register the user
  Future<Users> registerUser(_user, context,mode) async {
    var body;
    if(mode=='emailOTP'){
      body=jsonEncode(<String, String>{
        'firstName': _user['firstName'].toString(),
        'lastName': _user['lastName'].toString(),
        'email': _user['email'].toString(),
        'phoneNumber': _user['phoneNumber'].toString(),
        'password': _user['password'].toString()
      });
    }
    else{
      body=jsonEncode(<String, String>{
        'firstName': _user.firstName.toString(),
        'lastName': _user.lastName.toString(),
        'email': _user.email.toString(),
        'phoneNumber': _user.phoneNumber.toString(),
        'password': _user.password.toString()
      });
    }
    final response = await http.post(
      Uri.parse(
          '${URL.apiURL}/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    print(response.statusCode);

    if (response.statusCode == 201) {
      Map<String, dynamic> data = jsonDecode(response.body);
      //Auto Login
      // _navigateToHomeScreen(context);
      if(mode=='emailOTP'){
        await loginByEmail(_user, context, "registerUser");
      }else {
        await loginByPhone(_user, context, "registerUser");
      }
      // await loginByEmail(_user, context, "registerUser");
      //Push to success only if we get 201

      return Users.fromJson(jsonDecode(response.body));
    }
    else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      if (response.statusCode == 401) {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
            backgroundColor: Colors.green, content: Text("Unauthorized")));
        throw Exception('Unauthorized.');
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
            backgroundColor: Colors.green, content: Text("Bad Request")));
        throw Exception('Bad request.');
      } else if (response.statusCode == 409) {
        ScaffoldMessenger.of(context!)
            .showSnackBar(const SnackBar(content: Text("User already registered")));
        throw Exception('Already registered.');
      }
      ScaffoldMessenger.of(context!)
          .showSnackBar(const SnackBar(content: Text("Failed to create user")));
      throw Exception('Failed to create user.');
    }
  }

  //Function to reset password
  resetPassword(_user, context, mode) async {
    var body=jsonEncode(<String, String>{
        'email': _user['email'],
        'requestType': "PASSWORD_RESET",
      });

    final response = await http.post(
      Uri.parse("https://www.googleapis.com/identitytoolkit/v3/relyingparty/getOobConfirmationCode?key=${URL.verificationKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.green,content: Text('Password reset email sent, please check your inbox')));
      return response;
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green, content: Text("Unauthorized")));
      return response;
    } else if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green, content: Text("Reset password exceed limit")));
      return response;
    } else if (response.statusCode == 409) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green, content: Text("Unauthorized")));
      return response;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green, content: Text("User not registered")));
    return response;
  }

}
