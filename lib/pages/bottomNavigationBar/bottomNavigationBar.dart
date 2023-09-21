import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/floodAlertMap.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringList.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/resources.dart';

class AppBottomNavigationBar extends StatefulWidget {
  int selectedIndex;
  AppBottomNavigationBar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    RiverMonitoringPage(),
    FloodAlertMap(mode: "add"),
  ];

  final List<String> _iconAssets = [
    'assets/icons/riverMonitoring.svg',
    'assets/icons/floodWatch.svg', // Add the path to your Flood Watch SVG asset
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    setState(() {
      _selectedIndex = widget.selectedIndex;
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _iconAssets[0], // Use the appropriate index for River Monitoring
              width: 24, // Customize the width and height as needed
              height: 24,
              color: Resources.colors.appTheme.blue,
            ),
            label: 'River Monitoring',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              _iconAssets[1], // Use the appropriate index for Flood Watch
              width: 24, // Customize the width and height as needed
              height: 24,
              color: Resources.colors.appTheme.blue,
            ),
            label: 'Flood Watch',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Resources.colors.appTheme.veryDarkGray,// Color for the selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        onTap: _onItemTapped,
      ),
    );
  }
}
