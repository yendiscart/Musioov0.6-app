import 'dart:convert';
import 'package:musioo/Model/ModelAppInfo.dart';
import 'package:musioo/Presenter/AppInfoPresenter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/SignupPresenter.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/SharedPref.dart';

import 'AppInfo.dart';
import 'LanguageChoose.dart';
import 'Login.dart';

class SignView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<SignView> {
  bool _passwordVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController numController = TextEditingController();
  SharedPref sharePrefs = SharedPref();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool artist = false, listeners = true, isRegis = false;
  Color colorActive = appColors().colorBackEditText,
      colorInactive = appColors().colorBackground;
  List<Data> list = [];
  bool _checkbox = true;

  @override
  void initState() {
    getValue();
    super.initState();
  }

  getValue() async {
    String data = await AppInfoPresenter().getInfo("");
    final Map<String, dynamic> parsed = json.decode(data.toString());
    ModelAppInfo mList = ModelAppInfo.fromJson(parsed);
    for (int i = 0; i < mList.data.length; i++) {
      if (mList.data[i].title.contains("Privacy")) {
        list.add(mList.data[i]);
      }
      if (mList.data[i].title.contains("Terms")) {
        list.add(mList.data[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(9, 8, 9, 0),
            decoration: BoxDecoration(color: appColors().colorBackground),
            child: ListView(
              children: <Widget>[
                Image.asset(
                  "assets/images/login.png",
                  height: 260.0,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(6, 10, 6, 6),
                  child: Text(
                    'Just fill the details to continue...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        color: appColors().colorText),
                  ),
                ),
                Container(
                  height: 55,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  margin: EdgeInsets.fromLTRB(14, 8, 14, 6),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0)),
                  child: new TextField(
                    style: TextStyle(
                        color: appColors().colorText,
                        fontSize: 17.0,
                        fontFamily: 'Nunito'),
                    controller: nameController,
                    decoration: new InputDecoration(
                      suffixIcon: Image.asset(
                        'assets/icons/person.png',
                        height: 10.0,
                        width: 10.0,
                      ),
                      suffixIconConstraints:
                          BoxConstraints(minHeight: 18, minWidth: 18),
                      hintText: Resources.of(context).strings.enterNameHere,
                      hintStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17.0,
                          color: appColors().colorHint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  height: 57,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  margin: EdgeInsets.fromLTRB(14, 8, 14, 6),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0)),
                  child: new TextField(
                    maxLength: 20,
                    keyboardType: TextInputType.numberWithOptions(),
                    style: TextStyle(
                        color: appColors().colorText,
                        fontSize: 17.0,
                        fontFamily: 'Nunito'),
                    controller: numController,
                    decoration: new InputDecoration(
                      counterText: "",
                      suffixIcon: Image.asset(
                        'assets/icons/mobile.png',
                        height: 10.0,
                        width: 10.0,
                      ),
                      suffixIconConstraints:
                          BoxConstraints(minHeight: 18, minWidth: 18),
                      hintText: Resources.of(context).strings.enterMobileHere,
                      hintStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17.0,
                          color: appColors().colorHint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  height: 55,
                  padding: EdgeInsets.fromLTRB(20, 0, 22, 0),
                  margin: EdgeInsets.fromLTRB(14, 8, 14, 6),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0)),
                  child: new TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        color: appColors().colorText,
                        fontSize: 17.0,
                        fontFamily: 'Nunito'),
                    controller: emailController,
                    decoration: new InputDecoration(
                      suffixIcon: Image.asset(
                        'assets/icons/email.png',
                        height: 10.0,
                        width: 10.0,
                      ),
                      suffixIconConstraints:
                          BoxConstraints(minHeight: 19, minWidth: 20),
                      hintText:
                          Resources.of(context).strings.enterUserEmailHere,
                      hintStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17.0,
                          color: appColors().colorHint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  height: 55,
                  padding: EdgeInsets.fromLTRB(20, 0, 11, 0),
                  margin: EdgeInsets.fromLTRB(14, 8, 14, 6),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0)),
                  child: new TextField(
                    obscureText: !_passwordVisible,
                    controller: passwordController,
                    style: TextStyle(
                        color: appColors().colorText,
                        fontSize: 17.0,
                        fontFamily: 'Nunito'),
                    decoration: new InputDecoration(
                      hintText: Resources.of(context).strings.enterPassHere,
                      hintStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17.0,
                          color: appColors().colorHint),
                      suffixIcon: IconButton(
                          padding: EdgeInsets.all(12.5),
                          icon: _passwordVisible
                              ? Image.asset('assets/icons/hide.png')
                              : Image.asset('assets/icons/eyeshow.png'),
                          onPressed: () {
                            if (_passwordVisible) {
                              _passwordVisible = false;
                            } else {
                              _passwordVisible = true;
                            }
                            setState(() {
                              //  _passwordVisible = !_passwordVisible;
                            });
                          }),
                      suffixIconConstraints:
                          BoxConstraints(minHeight: 19, minWidth: 10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 12, 0, 2),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[

                      Container(height: 39,

                        width: MediaQuery.of(context).size.width-25,
                        alignment: Alignment.center,
                        child:   CheckboxListTile(
                            tileColor: appColors().colorText,
                          selectedTileColor: appColors().colorText,
                          controlAffinity: ListTileControlAffinity.leading,
                          title:Text(
                            'I\'ve read and accept the',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16.6,
                                color: appColors().colorText),
                          ),
                          value: _checkbox,
                          onChanged: (value) {
                            setState(() {
                              _checkbox = value!;
                            });
                          },
                        ),
                      ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            InkResponse(
                              child: Text(
                                "Terms of use ",
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16.5,
                                    color: appColors().primaryColorApp),
                              ),
                              onTap: () async {
                                if (list.length > 0) {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => AppInfo(
                                            list[0].title, list[0].detail)),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Not found!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: appColors().colorBackground,
                                      fontSize: 14.0);
                                }
                                //  await launch("https://playdrift.co/pages/eyJpdiI6Ijg3anh1am8wemlWTmtRRHBKR1lsSWc9PSIsInZhbHVlIjoiV0psUm1Wcys3R004eXhJeHloNnlYdz09IiwibWFjIjoiMzY1YjlkOTdkNWE4N2RhMzgxMmEyZjhkNzBlMTZiYjgxMWUxYmJjNTIxMDVhYjgyNzhjOTQ0ZDg2NjAxMTdhNCJ9");
                              },
                            ),
                            Text(
                              ' and ',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  color: appColors().colorText),
                            ),
                            InkResponse(
                              child: Text(
                                " Privacy policy",
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16.5,
                                    color: appColors().primaryColorApp),
                              ),
                              onTap: () async {
                                if (list.length > 0) {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => AppInfo(
                                            list[1].title, list[1].detail)),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Not found!",
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: appColors().colorBackground,
                                      fontSize: 14.0);
                                }
                                // await launch("https://playdrift.co/pages/eyJpdiI6InNYYXA5MmhiQ3J6OUFOYzdMUHIyS0E9PSIsInZhbHVlIjoiUnV3Yk5BMnkrZ21QbExKSzN3OHVSUT09IiwibWFjIjoiMmUzZDc3ZDE1N2ViODgzNzA1MTAwZTU1NWYwZDgwNmVhMzk4Nzc5YjQ3ZTMxZDE4ZWMzNDI0YzcyNDBlNTlmMyJ9");
                              },
                            )
                          ],
                        ),


                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(12, 14, 12, 0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().PrimaryDarkColorApp,
                          appColors().primaryColorApp
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0)),
                  child: TextButton(

                    child: Text(
                      Resources.of(context).strings.signin,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffffffff)),
                    ),
                    onPressed: () => {
                      if (!_checkbox)
                        {
                          Fluttertoast.showToast(
                              msg: "Accept all terms and conditions.",
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: appColors().colorBackground,
                              fontSize: 14.0),
                        }
                      else
                        {
                          if (nameController.text.isEmpty)
                            {
                              Fluttertoast.showToast(
                                  msg: Resources.of(context)
                                      .strings
                                      .enterNameContinue,
                                  toastLength: Toast.LENGTH_SHORT,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey,
                                  textColor: appColors().colorBackground,
                                  fontSize: 14.0),
                            }
                          else
                            {
                              if (emailController.text.isEmpty)
                                {
                                  Fluttertoast.showToast(
                                      msg: Resources.of(context)
                                          .strings
                                          .enterUserEmailContinue,
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: appColors().colorBackground,
                                      fontSize: 14.0),
                                }
                              else
                                {
                                  if (passwordController.text.isEmpty)
                                    {
                                      Fluttertoast.showToast(
                                          msg: Resources.of(context)
                                              .strings
                                              .enterPassContinue,
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey,
                                          textColor:
                                              appColors().colorBackground,
                                          fontSize: 14.0),
                                    }
                                  else
                                    {
                                      if (passwordController.text.length < 6)
                                        {
                                          Fluttertoast.showToast(
                                              msg: Resources.of(context)
                                                  .strings
                                                  .passwordLength,
                                              toastLength: Toast.LENGTH_SHORT,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.grey,
                                              textColor:
                                                  appColors().colorBackground,
                                              fontSize: 14.0),
                                        }
                                      else
                                        {
                                          if (!RegExp(
                                                  r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                              .hasMatch(emailController.text))
                                            {
                                              Fluttertoast.showToast(
                                                  msg: Resources.of(context)
                                                      .strings
                                                      .incorrectEmail,
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.grey,
                                                  textColor: appColors().black,
                                                  fontSize: 14.0),
                                            }
                                          else
                                            {
                                              if (!isRegis)
                                                {
                                                  isRegis = true,
                                                  showGeneralDialog(
                                                      barrierLabel: "Barrier",
                                                      barrierDismissible: true,
                                                      barrierColor: Colors.black
                                                          .withOpacity(0.5),
                                                      context: context,
                                                      pageBuilder:
                                                          (_, __, ___) {
                                                        return FutureBuilder<
                                                            UserModel>(
                                                          future: SignupPresenter()
                                                              .getRegister(
                                                                  context,
                                                                  nameController
                                                                      .text,
                                                                  emailController
                                                                      .text,
                                                                  passwordController
                                                                      .text,
                                                                  numController
                                                                      .text),
                                                          builder: (context,
                                                              projectSnap) {
                                                            if (projectSnap
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .none) {
                                                              isRegis = false;
                                                              Fluttertoast.showToast(
                                                                  msg: Resources.of(
                                                                          context)
                                                                      .strings
                                                                      .noConnection,
                                                                  toastLength:
                                                                      Toast
                                                                          .LENGTH_SHORT,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .grey,
                                                                  textColor:
                                                                      appColors()
                                                                          .colorBackground,
                                                                  fontSize:
                                                                      14.0);
                                                            }
                                                            if (projectSnap
                                                                .hasData) {
                                                              isRegis = false;
                                                              Fluttertoast.showToast(
                                                                  msg: Resources.of(context)
                                                                          .strings
                                                                          .welcome +
                                                                      projectSnap
                                                                          .data!
                                                                          .data
                                                                          .name
                                                                          .toString(),
                                                                  toastLength: Toast
                                                                      .LENGTH_SHORT,
                                                                  timeInSecForIosWeb:
                                                                      2,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .grey,
                                                                  textColor:
                                                                      appColors()
                                                                          .colorBackground,
                                                                  fontSize:
                                                                      14.0);
                                                              sharePrefs
                                                                  .setToken('' +
                                                                      projectSnap
                                                                          .data!
                                                                          .login_token);
                                                              sharePrefs.setThemeData(jsonEncode(
                                                                  new ModelTheme(
                                                                      '',
                                                                      '',
                                                                      'Default theme',
                                                                      '0xFFb5bada',
                                                                      'assets/images/default_screen.jpg',
                                                                      'free')));

                                                              emailController
                                                                  .text = '';
                                                              passwordController
                                                                  .text = '';

                                                              return Material(
                                                                child: LanguageChoose(
                                                                    'fromLogin'),
                                                              );
                                                            }
                                                            if (projectSnap
                                                                .hasError) {
                                                              isRegis = false;
                                                              Navigator.pop(
                                                                  context);
                                                              return Material();
                                                            } else {
                                                              isRegis = false;
                                                              return Material(
                                                                  type: MaterialType
                                                                      .transparency,
                                                                  child: Container(
                                                                      height: 100,
                                                                      width: 200,
                                                                      color: Color(0x2dff0008),
                                                                      child: Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          SizedBox(
                                                                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(appColors().primaryColorApp), backgroundColor: appColors().colorHint, strokeWidth: 4.0)),
                                                                          Container(
                                                                              margin: EdgeInsets.all(6),
                                                                              child: Text(
                                                                                Resources.of(context).strings.loadingPleaseWait,
                                                                                style: TextStyle(color: appColors().colorTextHead, fontSize: 18),
                                                                              )),
                                                                        ],
                                                                      )));
                                                            } //Android loading Widget
                                                          },
                                                        );
                                                      })
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    },
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 18, 0, 35),
                    child: Row(
                      children: <Widget>[
                        Text(
                          Resources.of(context).strings.alreadyhaveanaccount,
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              color: appColors().colorText),
                        ),
                        InkResponse(
                          child: Text(
                            " " + Resources.of(context).strings.loginhere,
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 17,
                                color: appColors().primaryColorApp),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new Login()),
                            );
                          },
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ))
              ],
            )));
  }
}

class Resources {
  BuildContext _context;

  Resources(this._context);

  StringsLocalization get strings {
    switch ('en') {
      case 'ar':
        return ArabicStrings();
      case 'fn':
        return FranchStrings();
      default:
        return EnglishStrings();
    }
  }

  static Resources of(BuildContext context) {
    return Resources(context);
  }
}
