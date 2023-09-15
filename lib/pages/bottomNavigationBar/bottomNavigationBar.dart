import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/floodAlertMap.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringList.dart';
import '../../utils/resources.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../floodWatch.dart';

class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    RiverMonitoringPage(),
    // WaterTestingPage(),
  ];
  void _onItemTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
    }

    // Check if the 'Flood Watch' tab is selected
    if (index == 1) {
      _navigateToFloodWatchScreen(context);
    }
  }

  void _navigateToFloodWatchScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FloodAlertMap(mode: "add")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/riverMonitoring.svg',
              color: Resources.colors.appTheme.blue,
              width: 24,
              height: 24,
            ),
            label: 'River Monitoring',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/floodWatch.svg',
              color: Resources.colors.appTheme.blue,
              width: 24,
              height: 24,
            ),
            label: 'Flood Watch',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Resources.colors.appTheme.veryDarkGray,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        unselectedItemColor: Resources.colors.appTheme.darkGray,
        onTap: _onItemTapped,

      ),
    );
  }
}
