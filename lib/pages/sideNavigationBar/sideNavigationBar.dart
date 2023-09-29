import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/auth/loginPage.dart';
import 'package:flutter_orol_v2/pages/floodAlertMap.dart';
import 'package:flutter_orol_v2/pages/home.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/models/user.dart';
import '../../services/providers/AppSharedPreferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';


class AppSideNavigationBar extends StatefulWidget {
  
  const AppSideNavigationBar({Key? key, required Null Function(dynamic ctx, dynamic i) onTap}) : super(key: key);

  @override
  State<AppSideNavigationBar> createState() => _AppSideNavigationBarState();
}

class _AppSideNavigationBarState extends State<AppSideNavigationBar> {
  Users _user = new Users();
  String _appVersion = '';
  var _buildNumber;


  @override
  void initState() {
    _getUserDetails();
    super.initState();
    _getAppVersion();
  }

  void _getUserDetails() async {
    _user = (await AppSharedPreference().getUserInfo())as Users;
    setState(() {
      _user.firstName=_user.firstName;
    });
  }
  void _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
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
              decoration: BoxDecoration(color: Resources.colors.appTheme.primary),
              child: SingleChildScrollView( // Wrap the content in SingleChildScrollView
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: _user.avatarURL != null && _user.avatarURL!.isNotEmpty
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(_user.avatarURL![0]),
                          radius: 30.0,
                        )
                            : CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: SvgPicture.asset(
                            'assets/images/profile-user.svg', // Default SVG image
                            width: 60, // Specify the width of the SVG
                            height: 60, // Specify the height of the SVG
                            color: Colors.black, // Change the color here
                          ),
                          radius: 30.0,
                        ),
                      ),
                      const SizedBox(height: 15,),
                      Text(
                        '${_user.firstName} ${_user.lastName}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF242424),
                        ),
                      ),
                      const SizedBox(height: 3,),
                      Text(
                        '${_user.email}',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF242424),
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        'Version $_appVersion',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          // fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF242424),
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        'Build $_buildNumber',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          // fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF242424),
                        ),
                      ),
                    ],
                  ),
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
              title: Text('River Monitoring',style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Resources.colors.appTheme.seondary,),),
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
              title: Text('Flood Watch',style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Resources.colors.appTheme.seondary,),),
              onTap: (){
                _navigateToFloodAlertMapScreen(context);
              },
            ),
            const Divider(height: 1,),
            ListTile(
              leading:  Icon(Icons.logout_outlined,color: Resources.colors.appTheme.blue,),
              title: Text('Logout',style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Resources.colors.appTheme.seondary,),),
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
