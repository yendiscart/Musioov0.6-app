import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/Logout.dart';
import 'package:musioo/UI/Blog.dart';
import 'package:musioo/UI/Delete.dart';
import 'package:musioo/UI/Music.dart';
import 'package:musioo/UI/PlayList.dart';
import 'package:musioo/UI/PurchaseHistory.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/UI/Plans.dart';
import 'package:musioo/UI/LanguageChoose.dart';
import 'package:musioo/UI/Login.dart';
import 'package:musioo/UI/PrivacyPolicy.dart';
import 'package:musioo/UI/ProfileEdit.dart';
import 'Download.dart';
import 'FavoriteOrHistory.dart';
import 'HomeDiscover.dart';
import 'InAppPurch.dart';

String checkSelected = '';

class SideDrawer {
  late UserModel? model;
  SharedPref sharePrefs = SharedPref();
  static String name = '', email = '';
  static String imagePresent = '';
  String token = '';
  late ModelSettings modelSettings;
  bool hasPre = false;

  Drawer defineDrawer(BuildContext context, String tagSelected,
      AudioPlayerHandler? audioHandler) {
    checkSelected = tagSelected;
    Future<dynamic> value() async {
      model = await sharePrefs.getUserData();

      token = await sharePrefs.getToken();
      String? sett = await sharePrefs.getSettings();
      // print(sett!);
      final Map<String, dynamic> parsed = json.decode(sett!);
      modelSettings = ModelSettings.fromJson(parsed);
      if ((modelSettings.data.image.isNotEmpty)) {
        imagePresent = AppConstant.ImageUrl + modelSettings.data.image;
      }

      name = modelSettings.data.name;
      email = modelSettings.data.email;
      if (modelSettings.data.in_app_purchase == 1) {
        hasPre = true;
      }
      if (Platform.isAndroid) {
        hasPre = true;
      }
      return model!.data.email;
    }

    void showDialog(BuildContext context) {
      showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 700),
        context: context,
        pageBuilder: (_, __, ___) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              width: 259,
              height: 135,
              child: SizedBox.expand(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Material(
                    type: MaterialType.transparency,
                    child: Text(Resources.of(context).strings.doYouWantToLogout,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 19.0,
                            color: appColors().colorTextSideDrawer)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              audioHandler!.stop();
                              Logout().logout(context, token);
                              sharePrefs.removeValues();

                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Login()),
                                  (Route<dynamic> route) => false);
                            },
                            child: Container(
                                margin: EdgeInsets.fromLTRB(2, 2, 2, 0),
                                padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        appColors().PrimaryDarkColorApp,
                                        appColors().PrimaryDarkColorApp,
                                        appColors().primaryColorApp
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Text(
                                  Resources.of(context).strings.yes,
                                  style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14.0,
                                      color: appColors().white),
                                )),
                          )),
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(2, 2, 2, 0),
                                  padding: EdgeInsets.fromLTRB(22, 5, 22, 5),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          appColors().PrimaryDarkColorApp,
                                          appColors().primaryColorApp
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Text(
                                    Resources.of(context).strings.no,
                                    style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 14.0,
                                        color: appColors().white),
                                  ))))
                    ],
                  )
                ],
              )),
              margin: EdgeInsets.only(bottom: 1, left: 22, right: 22),
              padding: EdgeInsets.fromLTRB(22, 12, 22, 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: appColors().colorBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: appColors().colorBorder)),
            ),
          );
        },
        transitionBuilder: (_, anim, __, child) {
          return SlideTransition(
            position:
                Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
            child: child,
          );
        },
      );
    }

    value();
    return Drawer(child: StatefulBuilder(builder: (context, newState) {
      return Container(
        color: Color(0xff161826),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 13, 12, 1),
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 9, 0, 0),
                child: FutureBuilder<dynamic>(
                    future: value(),
                    builder: (context, projectSnap) {
                      if (projectSnap.hasData) {
                        return Column(
                          children: [
                            InkResponse(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (context) => ProfileEdit(),
                                    settings: RouteSettings(
                                      arguments: 'afterlogin',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(8, 18, 0, 18),
                                margin: EdgeInsets.fromLTRB(7, 9, 0, 9),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        appColors().colorBackEditText,
                                        appColors().colorBackEditText
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xffffb2b9),
                                              Color(0xffffb2b9)
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius:
                                              BorderRadiusDirectional.circular(
                                                  6.0),
                                          image: DecorationImage(
                                            image: (imagePresent.isEmpty)
                                                ? AssetImage(
                                                    'assets/icons/user2.png')
                                                : NetworkImage(imagePresent)
                                                    as ImageProvider,
                                            fit: BoxFit.fill,
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                        width: 37,
                                        height: 37,
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 180,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              name,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontFamily: 'Nunito-Bold',
                                                  fontSize: 15.0,
                                                  color: appColors()
                                                      .colorTextSideDrawer),
                                            ),
                                          ),
                                          Container(
                                            width: 180,
                                            alignment: Alignment.centerLeft,
                                            child: RichText(
                                              overflow: TextOverflow.ellipsis,
                                              strutStyle:
                                                  StrutStyle(fontSize: 11.0),
                                              text: TextSpan(
                                                  style: TextStyle(
                                                      fontFamily: 'Nunito',
                                                      fontSize: 12.5,
                                                      color: appColors()
                                                          .colorTextSideDrawer),
                                                  text: email),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: InkResponse(
                                          onTap: () {
                                            showDialog(context);
                                          },
                                          child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  2, 0, 7, 0),
                                              child: Icon(
                                                Icons.power_settings_new,
                                                color: appColors()
                                                    .colorTextSideDrawer,
                                              ))),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            if (hasPre)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: InkResponse(
                                  child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(14, 7, 14, 7),
                                      margin: EdgeInsets.fromLTRB(12, 8, 0, 2),
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
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                      child: Text(
                                        'Subscription plans',
                                        style: TextStyle(
                                            fontFamily: 'Nunito-Bold',
                                            fontSize: 15.0,
                                            color: appColors().white),
                                      )),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if (Platform.isAndroid) {
                                      // Android-specific code
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) => GoPro(),
                                          settings: RouteSettings(
                                            arguments: 'afterlogin',
                                          ),
                                        ),
                                      );
                                    } else if (Platform.isIOS) {
                                      // iOS-specific code
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (context) =>
                                              InAppPurch(email, name),
                                          settings: RouteSettings(
                                            arguments: 'afterlogin',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                          ],
                        );
                      } else {
                        return Text(
                          'Loading...',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13.0,
                              color: appColors().colorTextSideDrawer),
                        );
                      }
                    }),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 19, 8, 2),
              child: Text(
                Resources.of(context).strings.browseMusic,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.0,
                    color: appColors().colorTextSideDrawer),
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('Discover'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                    width: 36,
                    height: 36,
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xffee3b88),
                            Color(0xffee3b88),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Container(
                      padding: EdgeInsets.all(2),
                      child: Image.asset('assets/icons/discovericon.png'),
                    )),
                title: Text(
                  Resources.of(context).strings.discover,
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  checkSelected = 'Discover',
                  newState(() {}),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => HomeDiscover(),
                    ),
                  ),
                },
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('Playlist'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff42b5e8),
                          Color(0xff42b5e8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      padding: EdgeInsets.all(3),
                      child: Image.asset('assets/icons/music.png')),
                ),
                title: Text(
                  'Playlist',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  checkSelected = 'Playlist............',
                  newState(() {}),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => PlayList(),
                      settings: RouteSettings(
                        arguments: 'book',
                      ),
                    ),
                  ),
                },
              ),
            ),
            Container(
              height: 11,
              margin: EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Divider(
                color: appColors().colorHint,
                height: 2,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 9, 8, 2),
              child: Text(
                Resources.of(context).strings.yourMusic,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.0,
                    color: appColors().colorTextSideDrawer),
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('Downloads'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff59d3c9),
                          Color(0xff59d3c9),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset('assets/icons/downloadicon.png')),
                ),
                title: Text(
                  'Downloads',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  checkSelected = 'Downloads',
                  newState(() {}),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => Download(),
                        settings: RouteSettings(
                          arguments: 'afterlogin',
                        )),
                  ),
                },
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('Favorites'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffff5166),
                          Color(0xffff5166),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset('assets/icons/fav.png')),
                ),
                title: Text(
                  'Favorites',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  Navigator.pop(context),
                  checkSelected = 'Favorites',
                  newState(() {}),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => Favorite('fav'),
                      settings: RouteSettings(
                        arguments: 'fav',
                      ),
                    ),
                  ),
                },
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('History'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff8b5efb),
                          Color(0xff8b5efb),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset('assets/icons/history.png')),
                ),
                title: Text(
                  'History',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  checkSelected = 'History',
                  newState(() {}),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => Favorite('his'),
                        settings: RouteSettings(
                          arguments: 'his',
                        )),
                  ),
                },
              ),
            ),
            Container(
              height: 11,
              margin: EdgeInsets.fromLTRB(16, 1, 16, 0),
              child: Divider(
                color: appColors().colorHint,
                height: 2,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16, 9, 8, 2),
              child: Text(
                'Other',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.0,
                    color: appColors().colorTextSideDrawer),
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('Blogs'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffee3b88),
                          Color(0xffee3b88),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset('assets/icons/blog.png',color:appColors().white ,)),
                ),
                title: Text(
                  'Blogs',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  checkSelected = 'Blogs',
                  newState(() {}),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => Blog(),
                        settings: RouteSettings(
                          arguments: 'afterlogin',
                        )),
                  ),
                },
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('App Info'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffff5166),
                          Color(0xffff5166),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset('assets/icons/Info.png')),
                ),
                title: Text(
                  'App Info (Settings)',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  checkSelected = 'App Info',
                  newState(() {}),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => PrivacyPolicy(),
                        settings: RouteSettings(
                          arguments: 'afterlogin',
                        )),
                  ),
                },
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('App Info'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff42b5e8),
                          Color(0xff42b5e8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset(
                        'assets/icons/bin.png',
                        color: Color(0xffffffff),
                      )),
                ),
                title: Text(
                  'Delete account',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  checkSelected = 'App Info',
                  newState(() {}),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => delete(),
                        settings: RouteSettings(
                          arguments: 'afterlogin',
                        )),
                  ),
                },
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('Payment History'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff59d3c9),
                          Color(0xff59d3c9),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset('assets/icons/history.png')),
                ),
                title: Text(
                  'Purchase History',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  checkSelected = 'Payment History',
                  newState(() {}),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => PurchaseHistory(),
                        settings: RouteSettings(
                          arguments: 'his',
                        )),
                  ),
                },
              ),
            ),
            Container(
              decoration: (checkSelected.toString().contains('Change Language'))
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: Container(
                  width: 35,
                  height: 35,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff8b5efb),
                          Color(0xff8b5efb),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      padding: EdgeInsets.all(4),
                      child: Image.asset('assets/icons/lang.png')),
                ),
                title: Text(
                  'Change Language',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.0,
                      color: appColors().colorTextSideDrawer),
                ),
                onTap: () => {
                  checkSelected = 'Change Language',
                  newState(() {}),
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => LanguageChoose(''),
                        settings: RouteSettings(
                          arguments: 'fromDrawer',
                        )),
                  ),
                },
              ),
            ),
            ListTile(
              leading: Container(
                width: 35,
                height: 35,
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffee3b88),
                        Color(0xffee3b88),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8.0)),
                child: Container(
                    padding: EdgeInsets.all(4),
                    child: Image.asset('assets/icons/logout.png')),
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14.0,
                    color: appColors().colorTextSideDrawer),
              ),
              onTap: () => {showDialog(context)},
            ),
          ],
        ),
      );
    }));
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
