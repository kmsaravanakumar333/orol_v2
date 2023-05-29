import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/auth/otpPage.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../services/models/user.dart';
import '../services/providers/AppSharedPreferences.dart';
import '../utils/resources.dart';
import 'loginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  Users _user = new Users();
  final RegExp phoneRegex = RegExp(r'^\d{10}$');
  bool _showPassword=false;
  bool _showConfirmPassword=false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var actualCode;
  Timer? timer;
  FormGroup buildForm() => fb.group(<String, Object>{
    'firstName': FormControl<String>(
      value:'',validators: [Validators.required],
    ),
    'lastName': FormControl<String>(
      value:'',validators: [Validators.required],
    ),
    'email': FormControl<String>(
      value:'',validators: [Validators.required, Validators.email],
    ),
    'phoneNumber': FormControl<String>(
      value:'',validators: [Validators.required, Validators.pattern(phoneRegex)],
    ),
    'password': ['', Validators.required, Validators.minLength(4)],
    'confirmPassword': FormControl<String>(validators: [
      Validators.required,
      _confirmPasswordValidator,
    ],),
    'emailOTP': false,
  },);

  static Map<String, dynamic>? _confirmPasswordValidator(AbstractControl<dynamic> control) {
    final password = control.parent?.findControl('password')?.value;
    final confirmPassword = control.value;

    if (password == confirmPassword) {
      return null;
    } else {
      return {'Password is not matching': ''};
    }
  }
  _navigateToVerifyOtpScreen(BuildContext context){
    print("NAVGATE TO OTP");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OtpPage(verificationID:actualCode)));
  }
  Future<void> _sendMobileOTP(context,user) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor:Colors.green,content: Text("Sending OTP...")));
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91'+user['phoneNumber'],
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

  Future<User?> _sendEmailVerification(context,user) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: user['email'], password: user['password']);
      verifyEmail();
      timer = Timer.periodic(
          const Duration(seconds: 3),
              (_)=>checkEmailVerified(user));
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.green,content: Text('The password provided is too weak.')));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.green,content: Text('The account already exists for that email.')));
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(backgroundColor:Colors.green,content: Text('$e')));
      return null;
    }
  }

  void verifyEmail(){
    User? user = FirebaseAuth.instance.currentUser;
    try{
      if(!(user!.emailVerified)){
        user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.green,content: Text('Verification link is sent')));
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.green,content: Text('Problem in sending verification link')));
    }
  }

  Future checkEmailVerified(user) async{
    await FirebaseAuth.instance.currentUser!.reload();
    if(FirebaseAuth.instance.currentUser!.emailVerified==true){
      timer?.cancel();
      _user.registerUser(user, context,'emailOTP');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor:Colors.green,content: Text('Email verified')));
      // _navigateToHomeScreen(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
        body:SingleChildScrollView(
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
                          formControlName: 'firstName',
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                            'The first name must not be empty'
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'First Name ',
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
                          formControlName: 'lastName',
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                            'The last name must not be empty',
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Last Name ',
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
                          formControlName: 'email',
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                            'The email must not be empty',
                            ValidationMessage.email: (_) =>
                            'The email value must be a valid email ',
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email ',
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
                          formControlName: 'phoneNumber',
                          validationMessages: {
                            ValidationMessage.required: (_) =>
                            'The phone must not be empty',
                            ValidationMessage.pattern: (_) =>
                            'The phone number value must be a valid number ',
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Phone',
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
                            'The password must be at least 4 characters',
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
                        const SizedBox(height: 16.0),
                        ReactiveTextField<String>(
                          formControlName: 'confirmPassword',
                          obscureText: !_showConfirmPassword,
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
                              icon: Icon(_showConfirmPassword?Icons.visibility:Icons.visibility_off),
                              onPressed: (){
                                setState(() {
                                  _showConfirmPassword=!_showConfirmPassword;
                                });
                              },
                            ),
                            labelText: 'Confirm Password',
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
                        Row(
                          children: [
                            ReactiveCheckbox(formControlName: 'emailOTP'),
                            const Text('Send verification link to mail')
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          style:ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Resources.colors.appTheme.darkBlue),
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.only(top: 10.0,bottom: 10.0,left: 20.0,right: 20.0)),
                          ),
                          onPressed: () {
                            print("Form value");
                            if (form.valid) {
                              AppSharedPreference().saveUserInfo(Users.fromJson(form.value));
                                if(form.value['emailOTP']==false){
                                  _sendMobileOTP(context,form.value);
                                }else{
                                  _sendEmailVerification(context,form.value);
                                }
                                // _user.registerUser(form.value, context);
                            } else {
                              form.markAllAsTouched();
                            }
                          },
                          child: const Text('Register'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:  [
                                  Text(
                                      "Already have an account?",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold,color: Resources.colors.appTheme.darkBlue)),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (context){
                                            return const LoginPage();
                                          }
                                          ), (Route<dynamic> route) => false);
                                    },
                                    child: const Text("Login",style: TextStyle(
                                        fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.bold)),
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
          ),
        )
    );
  }
}
