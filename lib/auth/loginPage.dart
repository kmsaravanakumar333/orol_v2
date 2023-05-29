import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/auth/forgotPasswordPage.dart';
import 'package:flutter_orol_v2/auth/registerPage.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../services/models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp phoneRegex = RegExp(r'^\d{10}$');
  Users _user = Users();
  bool _showPassword =false;
  bool _isLoggedIn = false;

  FormGroup buildForm() => fb.group(<String, Object>{
    'email': FormControl<String>(validators: [requiredValidator]),
    'password': ['', Validators.required, Validators.minLength(4)],
    'rememberMe': false,
  });

  Map<String, dynamic>? requiredValidator(AbstractControl<dynamic> control) {
    final value = control.value;
    if (value == null || value.isEmpty) {
      return {'The email or phone must not be empty': ''};
    } else if (int.tryParse(value) != null) {
      if (!phoneRegex.hasMatch(value)) {
        return {'The phone number value must be valid': ''};
      }
    }
    else if (!emailRegex.hasMatch(value)) {
      return {'The email value must be a valid email': ''};
    }
    return null;
  }

  _navigateToRegister(context){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterPage()));
  }

  _navigateToForgotPassword(context){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ForgorPasswordPage()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
                        ReactiveTextField<String>(
                          formControlName: 'email',
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email / Phone',
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
                        ReactiveTextField<String>(
                          formControlName: 'password',
                          obscureText: !_showPassword,
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                            'The password must not be empty',
                            ValidationMessage.minLength: (_) =>
                            'The password must be at least 8 characters',
                          },
                          textInputAction: TextInputAction.done,
                          decoration:  InputDecoration(
                            suffixIconColor:Resources.colors.appTheme.darkBlue,
                            suffixIcon: IconButton(
                              icon: Icon(_showPassword?Icons.visibility:Icons.visibility_off),
                              onPressed: (){
                                setState(() {
                                  _showPassword=!_showPassword;
                                });
                              },
                            ),
                            labelText: 'Password',
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
                        Row(
                          children: [
                            ReactiveCheckbox(formControlName: 'rememberMe'),
                            const Text('Remember me')
                          ],
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
                              if (phoneRegex.hasMatch(form.value['email'].toString())) {
                               var response = await _user.loginByPhone(form.value,context,"UserLogin");
                               setState(() {
                                 _isLoggedIn=false;
                               });
                              }else{
                                var response = await _user.loginByEmail(form.value, context, "UserLogin");
                                setState(() {
                                  _isLoggedIn=false;
                                });
                              }

                            } else {
                              form.markAllAsTouched();
                            }
                          },
                          child:  Text('Login'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:  [
                                  Text(
                                      "Don't have an account?",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold,color: Resources.colors.appTheme.darkBlue)),
                                  TextButton(
                                    onPressed: () async {
                                      _navigateToRegister(context);
                                    },
                                    child: const Text("Register",style: TextStyle(
                                        fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 2.0,
                                    ),
                                    ),
                                  )
                                ],
                              )),
                        ),
                        TextButton(
                          onPressed: () async {
                            _navigateToForgotPassword(context);
                          },
                          child: const Text("Forgot Password?",style: TextStyle(
                            fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2.0,
                          ),
                          ),
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
