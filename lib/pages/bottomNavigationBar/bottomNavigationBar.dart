import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/riverMonitoringList.dart';
import '../../utils/resources.dart';

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
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar:
      BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water),
            label: 'River Monitoring',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.water),
          //   label: 'Water testing',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Resources.colors.appTheme.darkBlue,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
        unselectedItemColor: Resources.colors.appTheme.darkGray,
        onTap: _onItemTapped,
      ),
    );
  }
}
