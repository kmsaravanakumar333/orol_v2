import 'package:flutter_orol_v2/utils/resources.dart';
import 'package:flutter/material.dart';

class AppDecorations {
  _Container container = _Container();
}

class _Container {
  BoxDecoration rounded = BoxDecoration(
      borderRadius: BorderRadius.circular(10.0),
      color: Resources.colors.container.background);
}