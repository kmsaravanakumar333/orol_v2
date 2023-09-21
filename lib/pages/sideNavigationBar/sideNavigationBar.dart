import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/auth/loginPage.dart';
import 'package:flutter_orol_v2/pages/floodAlertMap.dart';
import 'package:flutter_orol_v2/pages/home.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/models/user.dart';
import '../../services/providers/AppSharedPreferences.dart';
import 'package:flutter_svg/flutter_svg.dart';


class AppSideNavigationBar extends StatefulWidget {
  
  const AppSideNavigationBar({Key? key, required Null Function(dynamic ctx, dynamic i) onTap}) : super(key: key);

  @override
  State<AppSideNavigationBar> createState() => _AppSideNavigationBarState();
}

class _AppSideNavigationBarState extends State<AppSideNavigationBar> {
  Users _user = new Users();


  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  void _getUserDetails() async {
    _user = (await AppSharedPreference().getUserInfo())as Users;
    setState(() {
      _user.firstName=_user.firstName;
    });
  }

  _navigateToLoginScreen(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("access_token", "");
    await AppSharedPreference().saveUserInfo(Users.fromJson({}));
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context){
          return const LoginPage();
        }
        ), (Route<dynamic> route) => false);
  }


  _navigateToRiverMonitoringScreen(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(selectedIndex:0)));
  }
  _navigateToFloodAlertMapScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(selectedIndex:1)));

  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width*0.8,
      child :Drawer (
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              decoration:  BoxDecoration(color: Resources.colors.appTheme.blue),
              child: Padding(
                padding:const EdgeInsets.all(6),
                child:Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:  <Widget>[
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height:15,),
                    Text(
                      '${_user.firstName} ${_user.lastName}',
                      style: const TextStyle(
                          fontFamily: 'Montserrat', fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white),
                    ),
                    const SizedBox(height:3,),
                    Text(
                      '${_user.email}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFFFFFFFF),
                        )
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/riverMonitoring.svg', // Path to your custom SVG icon
                color: Resources.colors.appTheme.blue, // Set the color of the icon
                width: 24, // Set the width of the icon
                height: 24, // Set the height of the icon
              ),
              title:const Text('River Monitoring',style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold),),
              onTap: (){
                _navigateToRiverMonitoringScreen(context);
              },
            ),
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/floodWatch.svg', // Path to your custom SVG icon
                color: Resources.colors.appTheme.blue, // Set the color of the icon
                width: 24, // Set the width of the icon
                height: 24, // Set the height of the icon
              ),
              title:const Text('Flood Watch',style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold),),
              onTap: (){
                _navigateToFloodAlertMapScreen(context);
              },
            ),
            const Divider(height: 1,),
            ListTile(
              leading:  Icon(Icons.logout_outlined,color: Resources.colors.appTheme.blue,),
              title:const Text('Logout',style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold),),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                AppSharedPreference().removeUserInfo();
                prefs.remove("access_token");
                _navigateToLoginScreen(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
