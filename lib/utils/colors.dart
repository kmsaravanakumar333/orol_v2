import 'package:flutter/material.dart';

class AppColors {
  _Container container = _Container();
  _Scaffold scaffold = _Scaffold();
  _Text text = _Text();
  _AppTheme appTheme = _AppTheme();
}

class _Container {
  Color background = const Color.fromARGB(255, 37, 76, 95);
}

class _Scaffold {
  Color background = Colors.white;
}

class _Text {
  Color heading = Colors.black;
  Color subheading = Colors.black38;
}
class _AppTheme {
  Color lightTeal = Color(0xFFECF4F4); //primary colour
  Color darkBlue = Color(0xFF34495E); //buttons background
  Color gray = Color(0xFFEFF1F1);  //primary colour
  Color white = Color(0xFFFFFFFF); //section color
  Color darkGray = Color(0xFF757575);//labels//input colour
  Color green = Color(0xFF7ABE32);
  Color blue = Color(0xFF116BB5);
  Color red = Color(0xFF7C0A02);
  Color lable = Color(0xFF67717B);
  Color seondary = Color(0xFF242424);
  Color primary = Color(0xFFF2F4F5);
  Color lightGray = Color(0xFFF2F5F5);
}