import 'dart:async';
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
          builder: (context) => HomePage()));
}


class Users {
  String? id = '';
  String? firstName = '';
  String? lastName = '';
  String? email = '';
  String? phoneNumber = '';
  String? password = '';

  Users({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phoneNumber": phoneNumber,
    "password": password,
  };

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
    );
  }

  //Function to login the user using email
  loginByEmail(_user, context, mode) async {
    print(_user);
    final verifyUser = await  http.post(
      Uri.parse("https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${URL.verificationKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _user['email'],
        'password': _user['password'],
      }),
    );
    var data1 = verifyUser;

    if(data1.statusCode==200){
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
      Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
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
    else if(data1.statusCode==400){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent, content: Text("Invalid Email / Password")));
    }
  }

  //Function to login the user using phone number
  loginByPhone(_user, context, mode) async {
    print("USER");
    print(_user['email']);
    var body;
    if(_user['email']!=''||_user['email']==null){
      body=jsonEncode(<String, String>{
        'phoneNumber': _user['email'],
        'password': _user['password'],
      });
    }else{
      body=jsonEncode(<String, String>{
        'phoneNumber': _user.phoneNumber,
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.green,content: Text('Successfully logged in')));
      _navigateToHomeScreen(context);
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
    print("USER");
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
          '${URL.apiURL}/user/sign-in-web'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    print(response.statusCode);
    print(response.body);
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
    } else {
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

}
