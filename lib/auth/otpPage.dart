import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:permission_handler/permission_handler.dart';
import '../pages/home.dart';
import '../services/models/user.dart';
import '../services/providers/AppSharedPreferences.dart';
import '../utils/resources.dart';

class OtpPage extends StatefulWidget {
  var verificationID;
  var mode;
  OtpPage({Key? key, required this.verificationID, required this.mode}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  Users _user = new Users();

  FormGroup buildForm() => fb.group(<String, Object>{
    'verifyOtp': ['', Validators.required],
  });

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  Future<void>  _getUserDetails() async {
    _user = (await AppSharedPreference().getUserInfo())as Users;
  }
  void _verifyMobileOTP(BuildContext context,otp){
    FirebaseAuth.instance
        .signInWithCredential(PhoneAuthProvider.credential(
        verificationId: widget.verificationID, smsCode: otp['verifyOtp']))
        .catchError((e)async{
      showDialog(
          builder: (context) =>
              AlertDialog(
                content: Text(
                    "${e.message}"),
              ),
          context: context);
    })
        .then((value) async{
      if (value != null) {
        //send a request to create user
        if(widget.mode=="register"){
          _user.registerUser(_user, context,'mobileOTP');
        }else{
          _navigateToVerifyHomeScreen(context);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.green,content: Text("OTP Verified")));
        bool hasLocationPermission = await checkAndRequestLocationPermission();
      }});
  }

  _navigateToVerifyHomeScreen(context){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(selectedIndex: 0,)));
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
                        formControlName: 'verifyOtp',
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Verify OTP',
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
                        onPressed: () {
                          if (form.valid) {
                            _verifyMobileOTP(context,form.value);
                          } else {
                            form.markAllAsTouched();
                          }
                        },
                        child: const Text('Verify'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
