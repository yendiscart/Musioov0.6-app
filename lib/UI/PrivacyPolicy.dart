import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musioo/Model/ModelAppInfo.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/AppInfoPresenter.dart';
import 'package:musioo/UI/AppInfo.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';


class PrivacyPolicy extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

class MyState extends State<PrivacyPolicy> {
  SharedPref sharePrefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;
  String token = '';
  List<Data> list = [];
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  bool allowDown = false, allowAds = true,isLoad=true;


  Future<dynamic> value() async {
    token = await sharePrefs.getToken();
    getAPI();
    model = await sharePrefs.getUserData();
    sharedPreThemeData = await sharePrefs.getThemeData();
    setState(() {});
    return model;
  }

  Future<void> getAPI() async {
    String data = await AppInfoPresenter().getInfo(token);
    final Map<String, dynamic> parsed = json.decode(data.toString());
    ModelAppInfo mList = ModelAppInfo.fromJson(parsed);
    list = mList.data;
     isLoad=false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    value();
    getSettings();
  }

  Future<void> getSettings() async {
    String? sett = await sharePrefs.getSettings();

    final Map<String, dynamic> parsed = json.decode(sett!);
    ModelSettings modelSettings = ModelSettings.fromJson(parsed);
    if (modelSettings.data.download == 1) {
      allowDown = true;
    } else {
      allowDown = false;
    }
    if (modelSettings.data.ads == 1) {
      allowAds = true;
    } else {
      allowAds = false;
    }


      _initGoogleMobileAds();

    setState(() {});
  }

  void _initGoogleMobileAds() {
    MobileAds.instance.initialize();

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
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
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
              height: 45,
              child: Text("App Info",
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
              margin: EdgeInsets.all(3),
              child: IconButton(
                alignment: Alignment.topLeft,
                icon: new Icon(
                  Icons.arrow_back_ios_outlined,
                  color: (sharedPreThemeData.themeImageBack.isEmpty)
                      ? Color(int.parse(AppSettings.colorText))
                      : Color(int.parse(sharedPreThemeData.themeColorFont)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          if (allowAds)
            (_isBannerAdReady)
                ? Container(
                    height: 90,
                    alignment: Alignment.center,
                    margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    width: _bannerAd.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  )
                : Container(),
          if(!isLoad)Container(
            margin: (allowAds)
                ? EdgeInsets.fromLTRB(0, 147, 0, 0)
                : EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: (list.length== 0)?Container(
           margin: EdgeInsets.fromLTRB(0, 177, 0, 0) ,child: Text('No Record Found ',  style: TextStyle(
                fontSize: 16.5,
                color: (sharedPreThemeData.themeImageBack.isEmpty)
                    ? Color(int.parse(AppSettings.colorText))
                    : Color(int.parse(
                    sharedPreThemeData.themeColorFont)),
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold)),):ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 58,
                    margin: EdgeInsets.fromLTRB(8, 4, 5, 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().colorBackEditText,
                          appColors().colorBackEditText
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: appColors().colorBorder),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => AppInfo(
                                  list[index].title, list[index].detail)),
                        );
                      },
                      title: Text(
                        list[index].title,
                        style: TextStyle(
                            fontSize: 16.5,
                            color: (sharedPreThemeData.themeImageBack.isEmpty)
                                ? Color(int.parse(AppSettings.colorText))
                                : Color(int.parse(
                                    sharedPreThemeData.themeColorFont)),
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
          ),

        ],
      ),
    )));
  }
}
