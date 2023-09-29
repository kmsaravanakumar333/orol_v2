import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../services/models/user.dart';
import '../utils/resources.dart';
import 'loginPage.dart';
class ForgorPasswordPage extends StatefulWidget {
  const ForgorPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgorPasswordPage> createState() => _ForgorPasswordPageState();
}

class _ForgorPasswordPageState extends State<ForgorPasswordPage> {
  bool _isLoggedIn = false;
  Users _user = Users();

  FormGroup buildForm() => fb.group(<String, Object>{
    'email': FormControl<String>(validators: [Validators.email]),
  });

  _navigateToLogin(){
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context){
          return const LoginPage();
        }
        ), (Route<dynamic> route) => false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            alignment: Alignment.center,
            children:[
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 40, bottom: 40),
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 75,
                      width: 175,
                      child: Image.asset("assets/logos/logo_app.png"),
                    ),
                  ),
                  ReactiveFormBuilder(
                    form: buildForm,
                    builder: (context, form, child) {
                      return Column(
                        children: [
                          Text('Please enter your email to request a password reset.'),
                          const SizedBox(height: 16.0),
                          ReactiveTextField<String>(
                            formControlName: 'email',
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Resources.colors.appTheme.darkBlue),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color:Resources.colors.appTheme.darkBlue,  // Replace with your desired focus border color
                                  width: 1.0,         // Replace with your desired focus border width
                                ),
                              ),
                              helperText: '',
                              helperStyle: TextStyle(height: 0.7),
                              errorStyle: TextStyle(height: 0.7),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            style:ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Resources.colors.appTheme.darkBlue),
                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.only(top: 10.0,bottom: 10.0,left: 20.0,right: 20.0)),
                            ),
                            onPressed: () async {
                              if (form.valid) {
                                setState(() {
                                  _isLoggedIn=true;
                                });
                                var response = await _user.resetPassword(form.value, context, "UserLogin");
                                if(response.statusCode==200){
                                  _navigateToLogin();
                                }
                                setState(() {
                                  _isLoggedIn=false;
                                });
                              } else {
                                form.markAllAsTouched();
                              }
                            },
                            child:  Text('Reset password'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:  [
                                    Text(
                                        "Go back to",
                                        style: TextStyle(
                                            fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold,color: Resources.colors.appTheme.darkBlue)),
                                    TextButton(
                                      onPressed: () async {
                                        _navigateToLogin();
                                      },
                                      child: const Text("Login?",style: TextStyle(
                                        fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 2.0,
                                      ),
                                      ),
                                    )
                                  ],
                                )),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              if (_isLoggedIn)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              if (_isLoggedIn)
                CircularProgressIndicator(
                  backgroundColor: Resources.colors.appTheme.lightTeal,
                ),
            ],
          ), 
        ),
      ),
    );
  }
}
