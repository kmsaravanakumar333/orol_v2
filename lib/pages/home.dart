import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:in_app_update/in_app_update.dart';
import 'bottomNavigationBar/bottomNavigationBar.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;
  HomePage({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final AppUpdateInfo? updateInfo = await InAppUpdate.checkForUpdate();
    if (updateInfo?.updateAvailability == UpdateAvailability.updateAvailable &&
        updateInfo?.immediateUpdateAllowed == true) {
      // A new update is available with high priority

      // Display a dialog to update the app
      showUpdateNotification(context, "message");
    }
  }

  Future<void> showUpdateNotification(BuildContext context, String message) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFf1eaf7),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 150,
                child: Image.asset('assets/logos/logo_app.png'),
              ), 
              const SizedBox(height: 15,),
              const Text('Update Required', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF116BB5), // Use the appropriate color
              )),
            ],
          ),
          content: Text("Orol recommends that you update to the latest version to use this app.", textAlign: TextAlign.left),
          actions: <Widget>[
            Container(
              margin: const EdgeInsets.all(20.0),
              child: TextButton(
                onPressed: () {
                  InAppUpdate.performImmediateUpdate()
                      .then((value) => print(value))
                      .catchError((error) => print(error));
                },
                child: const Text('UPDATE', style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                )),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 20.0, right: 20.0),
        backgroundColor: Color(0xFF116BB5), // Use the appropriate color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Use the appropriate color
      body: AppBottomNavigationBar(selectedIndex: widget.selectedIndex),
    );
  }
}
