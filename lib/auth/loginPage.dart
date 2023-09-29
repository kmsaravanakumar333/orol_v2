import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/auth/forgotPasswordPage.dart';
import 'package:flutter_orol_v2/auth/registerPage.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/models/user.dart';
import '../services/providers/AppSharedPreferences.dart';
import 'otpPage.dart';

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
  FirebaseAuth _auth = FirebaseAuth.instance;
  var actualCode;
  var errorMessage;

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

  Future<bool> checkAndRequestLocationPermission() async {
    // Check if location permission is already granted
    PermissionStatus permissionStatus = await Permission.location.status;

    if (permissionStatus == PermissionStatus.granted) {
      return true;
    } else if (permissionStatus == PermissionStatus.denied) {
      // Request location permission if denied
      permissionStatus = await Permission.location.request();
      if (permissionStatus == PermissionStatus.granted) {
        return true;
      }
    }

    // Permission not granted
    return false;
  }

  _navigateToVerifyOtpScreen(BuildContext context){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OtpPage(verificationID:actualCode,mode:"login")));
  }

  // Function to check if the phone number exists in Firebase database
  Future<bool> checkPhoneNumberExistsInDatabase(String phoneNumber) async {
    // Replace this with your own logic to check the database
    // You can use Firebase Firestore or Realtime Database to perform the check
    // Return true if the number exists, false otherwise
    // Example using Firebase Firestore:
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(phoneNumber).get();
    return snapshot.exists;
    return true; // Replace with your actual check logic
  }
  Future<void> _sendMobileOTP(context,phoneNumber) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.green,content: Text("Sending OTP...")));
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91'+phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (_auth.currentUser == null) {
          await _auth.signInWithCredential(credential);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.green,content: Text("The provided phone number is not valid.")));
        }
      },
      codeSent: (String verificationId, int? resendToken) async{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.green,content: Text("OTP sent")));
        actualCode=verificationId;
        _navigateToVerifyOtpScreen(context);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        actualCode = verificationId;
      },
    );
  }

  Future<bool> isUserAuthenticated(email,password) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      print('Signed in user: ${user?.uid}');
      return true;
    } catch (e) {
      print('Error signing in with email and password: ${e}');
      setState(() {
        errorMessage="$e";
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            onChanged: (value){
                              setState(() {
                                form.control('email').value =value.value;
                              });
                            },
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
                          Visibility(
                            visible:emailRegex.hasMatch(form.value['email'].toString()),
                            child: ReactiveTextField<String>(
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
                          ),
                          // Row(
                          //   children: [
                          //     ReactiveCheckbox(formControlName: 'rememberMe'),
                          //     const Text('Remember me')
                          //   ],
                          // ),
                          // const SizedBox(height: 16.0),
                          ElevatedButton(
                            style:ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Resources.colors.appTheme.blue),
                              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.only(top: 10.0,bottom: 10.0,left: 20.0,right: 20.0)),
                            ),
                            onPressed: () async {
                              if (phoneRegex.hasMatch(form.value['email'].toString())) {
                                if(form.control('email').valid){
                                  AppSharedPreference().saveUserInfo(Users.fromJson(form.value));
                                  var userDetails = await AppSharedPreference().getUserInfo() as Users;
                                  setState(() {
                                    _isLoggedIn=true;
                                  });
                                  var loggedInUser =  await _user.loginByPhone(userDetails, context, "loginUser");
                                  if(loggedInUser.firstName != null && loggedInUser.email != null){
                                    _sendMobileOTP(context,form.value['email'].toString());
                                  } else{
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.red,content: Text("Mobile number not register")));
                                  }
                                  setState(() {
                                    _isLoggedIn=false;
                                  });
                                  print(loggedInUser);
                                  // _auth.signOut();
                                }else{
                                  form.control('email').markAsTouched();
                                  setState(() {
                                    _isLoggedIn=false;
                                  });
                                }
                                // var response = await _user.loginByPhone(form.value,context,"UserLogin");
                                // bool hasLocationPermission = await checkAndRequestLocationPermission();
                                // setState(() {
                                //   _isLoggedIn=false;
                                // });
                              }else{
                                if (form.valid) {
                                  // setState(() {
                                  //   _isLoggedIn=true;
                                  // });
                                  var registeredUser = await isUserAuthenticated(form.value['email'],form.value['password']);
                                  if(registeredUser == true){
                                    _user.loginByEmail(form.value, context, "UserLogin");
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor:Colors.redAccent,content: Text('$errorMessage')));
                                  }
                                  bool hasLocationPermission = await checkAndRequestLocationPermission();
                                }else{
                                  form.markAllAsTouched();
                                  setState(() {
                                    _isLoggedIn=false;
                                  });
                                }
                              }
                            },
                            child:  Text(
                                emailRegex.hasMatch(form.value['email'].toString())?'LOGIN':
                                phoneRegex.hasMatch(form.value['email'].toString())?'SEND OTP':'LOGIN'),
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