import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Model/ModelSettings.dart';
import '../Model/ModelTheme.dart';
import '../Model/UserModel.dart';
import '../Presenter/AppSettingsPresenter.dart';
import '../Presenter/Logout.dart';
import '../ThemeMain/AppSettings.dart';
import '../ThemeMain/appColors.dart';
import '../utils/SharedPref.dart';
import 'Login.dart';

class delete extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {

  return delete_state();
  }

}
class delete_state extends State{
  String token = '';
  SharedPref sharePrefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;


  Future<dynamic> value() async {
    token = await sharePrefs.getToken();
    String settingDetails = await AppSettingsPresenter().getAppSettings(token);
    sharePrefs.setSettingsData(settingDetails);
    String? sett = await sharePrefs.getSettings();

    final Map<String, dynamic> parsed = json.decode(sett!);
    ModelSettings modelSettings = ModelSettings.fromJson(parsed);



    model = await sharePrefs.getUserData();
    sharedPreThemeData = await sharePrefs.getThemeData();
   setState(() {

   });
    return model;
  }

  @override
  void initState() {
    super.initState();
    value();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (sharedPreThemeData.themeImageBack.isEmpty)
                    ? AssetImage(AppSettings.imageBackground)
                    : AssetImage(sharedPreThemeData.themeImageBack),
                fit: BoxFit.fill,
              ),
            ),
        padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
child:     Stack(
      alignment: Alignment.topCenter,
      children: [
      Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
        height: 45,
        child: Text("Delete account",
            style: TextStyle(
                fontSize: 20,
                color: (sharedPreThemeData.themeImageBack.isEmpty)
                    ? Color(int.parse(AppSettings.colorText))
                    : Color(int.parse(sharedPreThemeData.themeColorFont)),
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold)),
      ),
    ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
              margin: EdgeInsets.fromLTRB(8, 9, 6, 6),
              child: InkResponse(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/icons/backarrow.png',
                  width: 21,
                  height: 21,
                  color: (sharedPreThemeData.themeImageBack.isEmpty)
                      ? Color(int.parse(AppSettings.colorText))
                      : Color(int.parse(
                      sharedPreThemeData.themeColorFont)),
                ),
              )),
        ),

        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.fromLTRB(6, 65, 6, 0),

            child: Text("Do you want to parmantly delete your account ? after deleting your account and all related information will no longer exist and you have to register again.\n"
                "Click below button to continue..",
                style: TextStyle(
                    fontSize: 20,
                    color: (sharedPreThemeData.themeImageBack.isEmpty)
                        ? Color(int.parse(AppSettings.colorText))
                        : Color(int.parse(sharedPreThemeData.themeColorFont)),
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.normal)),
          ),
        ),

        Align(
          alignment: Alignment.centerLeft,
          child: InkResponse(
            child: Container(
                padding: EdgeInsets.fromLTRB(14, 7, 14, 7),
                margin: EdgeInsets.fromLTRB(12,8, 0, 2),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appColors().primaryColorApp,
                        appColors().primaryColorApp,
                        appColors().PrimaryDarkColorApp
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0)),
                child: Text(
                  'Delete my account',
                  style: TextStyle(
                      fontFamily: 'Nunito-Bold',
                      fontSize: 15.0,
                      color: appColors().white),
                )
            )
            ,
            onTap: () async {

          int res=  await  Logout().deleteApi(context, token,model.data.id);
          if(res==1) {
            sharePrefs.removeValues();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Login()),
                    (Route<dynamic> route) => false);
          }else{
            Fluttertoast.showToast(
                msg: Resources.of(context).strings.tryAgain,
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey,
                textColor: appColors().colorBackground,
                fontSize: 14.0);
          }

            },)
          ,)

    ])
    )
        )
    );
  }

}