import 'package:flutter/material.dart';
import 'package:flutter_orol_v2/pages/sideNavigationBar/sideNavigationBar.dart';
import 'package:flutter_orol_v2/utils/resources.dart';
import 'bottomNavigationBar/bottomNavigationBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Resources.colors.scaffold.background,
        body:AppBottomNavigationBar()
    );
  }
}
