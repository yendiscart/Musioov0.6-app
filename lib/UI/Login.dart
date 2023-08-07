import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelAppInfo.dart';
import 'package:musioo/Presenter/AppInfoPresenter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/LoginDataPresenter.dart';
import 'package:musioo/UI/HomeDiscover.dart';
import 'package:musioo/utils/ConnectionCheck.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/UI/ForgotPassword.dart';
import 'package:musioo/UI/SignView.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'AppInfo.dart';
import 'LanguageChoose.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  SharedPref sharePrefs = SharedPref();

  bool _passwordVisible = false, hasLoad = false;
  String version = '';
  String buildNumber = '';
  late UserModel model;
  List<Data> list = [];

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
    getValue();
  }

  getValue() async {
    String data = await AppInfoPresenter().getInfo("");
    final Map<String, dynamic> parsed = json.decode(data.toString());
    ModelAppInfo mList = ModelAppInfo.fromJson(parsed);
    for(int i =0;i<mList.data.length;i++){

      if(mList.data[i].title.contains("Privacy")){
    list.add(mList.data[i]);}
      if(mList.data[i].title.contains("Terms")){
        list.add(mList.data[i]);}

    }
  }

  Future<void> login() async {
    print('res------------------------------------------------------------start');
    String res = await LoginDataPresenter().getUser(
        context, buildNumber, emailController.text, passwordController.text);

    print('res------------------------------------------------------------' +
        res);
    if (res.contains("1")) {
      model = await sharePrefs.getUserData();
      Fluttertoast.showToast(
          msg: Resources.of(context).strings.welcome + model.data.name,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.grey,
          textColor: appColors().colorBackground,
          fontSize: 14.0);

      if (model.selectedLanguage.length >= 1) {
        print(model.selectedLanguage.length.toString() + "             ......");
        Navigator.pushReplacement(context, new MaterialPageRoute(
          builder: (context) {
            return HomeDiscover();
          },
        ));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return LanguageChoose('fromLogin');
          },
        ));
      }
    } else {
      Fluttertoast.showToast(
          msg: "Try Again !",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.grey,
          textColor: appColors().colorBackground,
          fontSize: 14.0);
      hasLoad = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(color: appColors().colorBackground),
            padding: EdgeInsets.fromLTRB(2, 6, 2, 0),
            child: ListView(
              children: <Widget>[
                Image.asset(
                  "assets/images/login.png",
                  height: 260.0,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(6, 12, 6, 6),
                  child: Text(
                    Resources.of(context).strings.appDesciption,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        color: appColors().colorText),
                  ),
                ),
                Container(
                  height: 55,
                  padding: EdgeInsets.fromLTRB(16, 2, 20, 0),
                  margin: EdgeInsets.fromLTRB(15, 17, 15, 6),
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
                        'assets/icons/person.png',
                        height: 5.0,
                        width: 5.0,
                      ),
                      suffixIconConstraints:
                          BoxConstraints(minHeight: 18, minWidth: 19),
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
                  padding: EdgeInsets.fromLTRB(16, 2, 9, 0),
                  margin: EdgeInsets.fromLTRB(15, 10, 15, 6),
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
                          icon: _passwordVisible
                              ? Image.asset('assets/icons/hide.png')
                              : Image.asset('assets/icons/eyeshow.png'),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            if (_passwordVisible) {
                              _passwordVisible = false;
                            } else {
                              _passwordVisible = true;
                            }
                            setState(() {});
                          }),
                      suffixIconConstraints:
                          BoxConstraints(minHeight: 16, minWidth: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (hasLoad)
                  Material(
                      type: MaterialType.transparency,
                      child: Container(
                          height: 90,
                          width: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(
                                          appColors().primaryColorApp),
                                      backgroundColor: appColors().colorHint,
                                      strokeWidth: 4.0)),
                              Container(
                                  margin: EdgeInsets.all(5),
                                  child: Text(
                                    Resources.of(context)
                                        .strings
                                        .loadingPleaseWait,
                                    style: TextStyle(
                                        color: appColors().colorTextHead,
                                        fontSize: 18),
                                  )),
                            ],
                          ))),

                Container(
                  margin: EdgeInsets.fromLTRB(10, 18, 10, 0),
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
                      Resources.of(context).strings.login,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffffffff)),
                    ),
                    onPressed: () => {
                      ConnectionCheck().checkConnection(),
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
                          if (RegExp(
                                  r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                              .hasMatch(emailController.text))
                            {
                              if (passwordController.text.isEmpty)
                                {
                                  Fluttertoast.showToast(
                                      msg: Resources.of(context).strings.enterPassContinue,
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: appColors().colorBackground,
                                      fontSize: 14.0),
                                }
                              else
                                {
                                  if (passwordController.text.length < 6)
                                    {
                                      Fluttertoast.showToast(
                                          msg: Resources.of(context).strings.passwordLength,
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey,
                                          textColor: appColors().colorBackground,
                                          fontSize: 14.0),
                                    }
                                  else
                                    {
                                      hasLoad = true,
                                      setState(() {}),
                                      login(),
                                    }
                                }
                            }
                          else
                            {
                              Fluttertoast.showToast(
                                  msg: Resources.of(context).strings.incorrectEmail,
                                  toastLength: Toast.LENGTH_SHORT,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey,
                                  textColor: appColors().colorBackground,
                                  fontSize: 14.0),
                            }
                        }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: TextButton(
                    onPressed: () {
                      //forgot password screen
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) =>
                                new ForgotPassword(false, '')),
                      );
                    },

                    child: Text(Resources.of(context).strings.forgotPassword,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            color: appColors().colorText)),
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          Resources.of(context).strings.dontHaveAnAccount,
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              color: appColors().colorText),
                        ),
                        TextButton(

                          child: Text(
                            Resources.of(context).strings.signin,
                            style:
                                TextStyle(fontFamily: 'Nunito',
                                    fontSize: 17
                                    ,color: appColors().primaryColorApp),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new SignView()),
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
