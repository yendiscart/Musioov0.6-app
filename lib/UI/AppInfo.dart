import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:webview_flutter/webview_flutter.dart';


String title = '';
String detail = '';

class AppInfo extends StatefulWidget {
  AppInfo(String tit, String det) {
    title = tit;
    detail = det;
  }

  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

class MyState extends State<AppInfo> {
  SharedPref sharePrefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;
  bool allowDown = false, allowAds = true;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  Future<dynamic> value() async {
    model = await sharePrefs.getUserData();
    sharedPreThemeData = await sharePrefs.getThemeData();
    setState(() {});
    return model;
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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getSettings();

    value();
    _initGoogleMobileAds();
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
              child: Text("" + title,
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
                icon:  Icon(
                  Icons.arrow_back_ios_outlined,
                  color: (sharedPreThemeData.themeImageBack.isEmpty)
                      ? Color(int.parse(AppSettings.colorText))
                      : Color(int.parse(sharedPreThemeData.themeColorFont)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16, 55, 16, 6),

            child: ListView(
              children: [
                if (allowAds)
                  (_isBannerAdReady)
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            alignment: Alignment.center,
                            width: _bannerAd.size.width.toDouble(),
                            height: 95,
                            child: AdWidget(ad: _bannerAd),
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          ))
                      : Container(),
                HtmlWidget(
                  detail,
                  textStyle: TextStyle(color: appColors().white, fontSize: 18),
                )
              ],
            ),
          )
        ],
      ),
    )));
  }
}
