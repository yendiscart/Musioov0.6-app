import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'appColors.dart';


@immutable
class AppSettings {
static String colorBackground='0xFF171926';
static String colorText='0xffd7dbf6';
static String colorPrimary='0xFFff0065';
static String colorSecondary='0xFFfe563c';
static String imageBackground='assets/images/default_screen.jpg';

  static ThemeData define() {
    return ThemeData(
      primaryColor: Color(int.parse(colorPrimary)),
      accentColor: Color(int.parse(colorSecondary)),
      focusColor: appColors().primaryColorApp,
      unselectedWidgetColor: appColors().colorTextHead,
      backgroundColor: Color(int.parse(colorBackground)),
        buttonColor : Color(int.parse(colorText)),
      primarySwatch:appColors().primaryColorApp,
      cardColor: Color(int.parse(colorPrimary))


    );
  }

  AppSettings();
}
