import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/home.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:flutter_orol_v2/widgets/features/getStartedPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  var accessToken;

  @override
  void initState() {
    _loggedInStatus();
    super.initState();
  }

  Future<void> _loggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString('access_token') ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Our River Our Life',
      theme: ThemeData(
          primaryColor: Resources.colors.appTheme.lightTeal,
          // colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Resources.colors.appTheme.darkBlue),
          colorScheme: ColorScheme.light().copyWith(
            primary: Resources.colors.appTheme.darkBlue, // Set your custom active color here
          ),
          appBarTheme:  AppBarTheme(
            // Customize the app bar theme here
            color: Resources.colors.appTheme.darkBlue, // Set the background color of the app bar
            elevation: 2.0, // Set the elevation (shadow) of the app bar
            iconTheme: IconThemeData(color: Resources.colors.appTheme.lightTeal),
            toolbarTextStyle: TextTheme(
              titleLarge: TextStyle(
                color: Resources.colors.appTheme.lightTeal,// Set the color of the title text in the app bar
                fontSize: 20.0, // Set the font size of the title text in the app bar
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat'// Set the font weight of the title text in the app bar
              ),
            ).bodyMedium,
            titleTextStyle: TextTheme(
              titleLarge: TextStyle(
                color: Resources.colors.appTheme.lightTeal, // Set the color of the title text in the app bar
                fontSize: 20.0, // Set the font size of the title text in the app bar
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat'// Set the font weight of the title text in the app bar
              ),
            ).titleLarge,
          ),
          fontFamily: 'Montserrat',
        ),
      home: AnimatedSplashScreen(
          duration: 1000,
          splash: const Image(image: AssetImage('assets/logos/logo_app.png')),
          nextScreen:  (accessToken!=""&&accessToken!=null)?HomePage():GetStartedPage(),
          // nextScreen:GetStartedPage(),
          // nextScreen:  MultiImageUploader(mode:"Camera"),
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Color.fromRGBO(236, 238, 244, 1)),
    );
  }
}

