import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  _Text text = _Text();
}

class _Text {
  TextStyle heading = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Resources.colors.text.heading);

  TextStyle subHeading = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Resources.colors.text.subheading);
}