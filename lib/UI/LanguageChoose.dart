import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musioo/Model/ModelMusicLanguage.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/AppSettingsPresenter.dart';
import 'package:musioo/Presenter/MusicLanguagePresenter.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/ConnectionCheck.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'HomeDiscover.dart';

String fromLogin = '';

class LanguageChoose extends StatefulWidget {
  LanguageChoose(String s) {
    fromLogin = s;
  }

  @override
  _State createState() {
    return _State();
  }
}

class LanguageDetails {
  const LanguageDetails({required this.title, required this.i});

  final String title;
  final String i;
}

class _State extends State<LanguageChoose> {


  void change(int index) {
    setState(() {});
  }


  String token = '';
  List<int> selectedIndexList = [];
  int colorChange = 0xff7c94b6, colorUnChange = 0x5Cff0065;
  String fromDrawer = '';
  SharedPref sharePrefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;
  String allSelected = '';
  List<String> tags = [];
  late Future<ModelMusicLanguage> myFuture;
  late Widget futureWidget;
  static bool isRemoveAny = false;
  bool futureCall = false;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  bool allowDown = false, allowAds = true;

  Future<void> apiSettings() async {
    String settingDetails = await AppSettingsPresenter().getAppSettings(token);
    sharePrefs.setSettingsData(settingDetails);
    getSettings();
    valueCall();
  }

  Future<dynamic> value() async {
    try {
      token = await sharePrefs.getToken();
      if (fromLogin.contains("fromLogin")) {
        apiSettings();
      } else {
        apiSettings();
      }

      model = await sharePrefs.getUserData();

      sharedPreThemeData = await sharePrefs.getThemeData();

      setState(() {});
      return sharedPreThemeData;
    } on Exception catch (e) {}
  }

  void _initGoogleMobileAds() {
    MobileAds.instance.initialize();

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
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

  Future<bool> isBack(BuildContext context) async {
    if (fromLogin.contains("fromLogin")) {
      return (await showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              elevation: 5,
              backgroundColor:appColors().colorBackEditText ,
              title: Text('Do you want to exit the application?',style: TextStyle(color: appColors().white),),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false), // passing false
                  child: Container(
                      margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
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
                        Resources.of(context).strings.no
                        ,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14.0,
                            color: appColors().white),
                      )),
                ),
                TextButton(
                  onPressed: () {
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else {
                      exit(0);
                    }
                  }, // passing true
                  child: Container(
                      margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
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
                ),
              ],
            ),
          )) ??
          false;
    } else {
      return true;
    }
  }

  Future<ModelMusicLanguage> valueCall() async {
    myFuture = MusicLanguagePresenter().getMusicLanguage(token);

    futureCall = true;
    setState(() {});

    return myFuture;
  }

  @override
  void initState() {
    isRemoveAny = false;
    super.initState();
    value();
    ConnectionCheck().checkConnection();
checkConn();
    _initGoogleMobileAds();
  }
  Future<void> checkConn() async {

    await ConnectionCheck().checkConnection();
    setState(() {});

  }
  @override
  void dispose() {
    super.dispose();
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {


    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);
    if (route!.settings.arguments != null) {
      fromDrawer = ModalRoute.of(context)!.settings.arguments.toString();

      setState(() {});
    }

    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () {
            return isBack(context);
          },
          child: Container(


            child: Container(
              padding: EdgeInsets.fromLTRB(6, 6, 6, 0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: (sharedPreThemeData.themeImageBack.isEmpty)
                      ? AssetImage(AppSettings.imageBackground)
                      : AssetImage(sharedPreThemeData.themeImageBack),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
                      child: Text(
                        Resources.of(context).strings.musicLanguage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: (sharedPreThemeData.themeImageBack.isEmpty)
                                ? Color(int.parse(AppSettings.colorText))
                                : Color(int.parse(
                                    sharedPreThemeData.themeColorFont))),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: fromDrawer.contains('fromDrawer')
                        ? Container(
                            margin: EdgeInsets.fromLTRB(8, 9, 6, 6),
                            child: InkResponse(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'assets/icons/backarrow.png',
                                width: 21,
                                height: 21,
                                color: (sharedPreThemeData
                                        .themeImageBack.isEmpty)
                                    ? Color(int.parse(AppSettings.colorText))
                                    : Color(int.parse(
                                        sharedPreThemeData.themeColorFont)),
                              ),
                            ))
                        : null,
                  ),
                  if(!fromDrawer.contains('fromDrawer'))Align(
                    alignment: Alignment.topRight,
                    child:Container(
                        margin: EdgeInsets.fromLTRB(8, 12, 6, 6),
                        child: InkResponse(
                          onTap: () {
                            Navigator.push(context, new MaterialPageRoute(builder: (context) {
                              return HomeDiscover();
                            },));
                          },
                          child: Text('Skip',style: TextStyle(    fontFamily: 'Nunito',color: appColors().colorTextHead,fontSize: 18),),
                        ))
                        ,
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(6, 48, 6, 6),
                      child: Text(
                        Resources.of(context).strings.musicYouMayLike,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: (sharedPreThemeData.themeImageBack.isEmpty)
                                ? Color(int.parse(AppSettings.colorText))
                                : Color(int.parse(
                                    sharedPreThemeData.themeColorFont))),
                      ),
                    ),
                  ),
                  FutureBuilder<ModelMusicLanguage>(
                      future:
                          futureCall ? (myFuture.whenComplete(() {})) : null,
                      builder: (context, projectSnap) {
                        print('----- Going right 1');
                        if (projectSnap.hasError) {
                          print('----- Going wrong '+projectSnap.error.toString());
                          Fluttertoast.showToast(
                              msg: Resources.of(context).strings.tryAgain,
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: appColors().colorBackground,
                              fontSize: 14.0);

                          return Material(
                              );
                        } else {
                          if (projectSnap.hasData) {

                            List<Data> data = projectSnap.data!.data;
                            print('----- Going right---- 2'+data.length.toString());
                            if (!isRemoveAny) {
                              for (int x = 0;
                                  x < projectSnap.data!.selectedLanguage.length;
                                  x++) {
                                selectedIndexList.add(int.parse(
                                    projectSnap.data!.selectedLanguage[x]));
                              }
                            }

                            if(data.length < 1){
                              return Container(
                                height: MediaQuery.of(context).size.height,
                                alignment: Alignment.center,
                                child: Text(
                                  'No Record Found',
                                  style: TextStyle(
                                      color:
                                      appColors().colorTextHead,
                                      fontSize: 18),
                                ),
                              );
                            }else {
                              return Container(
                                  padding: EdgeInsets.all(1.0),
                                  margin: (allowAds)
                                      ? EdgeInsets.fromLTRB(0, 88, 0, 105)
                                      : EdgeInsets.fromLTRB(0, 88, 0, 85),
                                  child: SmartRefresher(
                                    enablePullDown: true,
                                    enablePullUp: false,
                                    controller: _refreshController,
                                    onRefresh: _onRefresh,
                                    physics: BouncingScrollPhysics(),
                                    header: ClassicHeader(
                                      refreshingIcon: Icon(Icons.refresh,
                                          color: Colors.pinkAccent),
                                      refreshingText: '',
                                    ),
                                    child: GridView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: data.length,
                                      gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: (100 / 60),
                                          crossAxisSpacing: 9.0,
                                          mainAxisSpacing: 9.0),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        String imageUrl = AppConstant.ImageUrl +
                                            projectSnap.data!.imagePath +
                                            data[index].image;

                                        return Card(
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadiusDirectional
                                                  .circular(9.0)),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              // color: Color(colorToBeChange),
                                              gradient: LinearGradient(
                                                  colors: selectedIndexList
                                                      .contains(data[index].id)
                                                  ? [
                                                  appColors()
                                                      .primaryColorApp,
                                                  appColors()
                                                      .PrimaryDarkColorApp
                                                  ]
                                                  : [
                                                  appColors().gray,
                                              appColors().gray
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),

                                            borderRadius:
                                            BorderRadiusDirectional
                                                .circular(9.0),
                                            image:data[index].image.isNotEmpty? DecorationImage(
                                              colorFilter: new ColorFilter.mode(
                                                  appColors()
                                                      .gray2
                                                      .withOpacity(0.3),
                                                  BlendMode.dstATop),

                                              image: NetworkImage(
                                                  imageUrl) as ImageProvider,

                                              fit: BoxFit.fill,
                                              alignment: Alignment.topCenter,
                                            ):null,
                                          ),
                                          child: Container(
                                            child: InkResponse(
                                              child: Container(
                                                padding: EdgeInsets.all(12.0),
                                                child: Text(
                                                  data[index].language_name,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: appColors().white),
                                                ),
                                              ),
                                              onTap: () {
                                                if (!selectedIndexList
                                                    .contains(data[index].id)) {
                                                  selectedIndexList
                                                      .add(data[index].id);
                                                  isRemoveAny = true;
                                                } else {
                                                  selectedIndexList
                                                      .remove(data[index].id);
                                                  isRemoveAny = true;
                                                }
                                                change(index);
                                              },
                                            ),
                                          ),
                                        ),);
//
                                      },
                                    ),
                                  ));
                            }

                          } else {
                            return Material(
                                type: MaterialType.transparency,
                                child: Container(
                                    height: 130,
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.fromLTRB(10, 200, 10, 0),
                                    color: appColors().colorBackEditText,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                            child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        appColors()
                                                            .primaryColorApp),
                                                backgroundColor:
                                                    appColors().colorHint,
                                                strokeWidth: 4.0)),
                                        Container(
                                            margin: EdgeInsets.all(6),
                                            child: Text(
                                              Resources.of(context)
                                                  .strings
                                                  .loadingPleaseWait,
                                              style: TextStyle(
                                                  color:
                                                      appColors().colorTextHead,
                                                  fontSize: 18),
                                            )),
                                      ],
                                    )));
                          }
                        }
                      }),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 39,
                      margin: (allowAds)
                          ? EdgeInsets.fromLTRB(0, 0, 0, 60)
                          : EdgeInsets.fromLTRB(0, 0, 0, 9),
                      alignment: Alignment.bottomCenter,
                      child: DecoratedBox(
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
                          child: Text(Resources.of(context).strings.continu,
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: appColors().white)),
                          onPressed: () => {
                            allSelected = '',

                            for (int i = 0; i < selectedIndexList.length; i++)
                              {
                                tags.add(selectedIndexList[i].toString()),
                                if (allSelected.isEmpty)
                                  {
                                    allSelected =
                                        selectedIndexList[i].toString()
                                  }
                                else
                                  {
                                    allSelected =
                                        selectedIndexList[i].toString() +
                                            "," +
                                            allSelected,
                                  }
                              },
                            if (selectedIndexList.length < 1)
                              {
                                Fluttertoast.showToast(
                                    msg: 'Select any language !!',
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.grey,
                                    textColor: appColors().colorBackground,
                                    fontSize: 14.0),
                              }
                            else
                              {
                                MusicLanguagePresenter().setMusicLanguage(
                                    context, jsonEncode(tags), token),
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => HomeDiscover()))
                              },
                          },
                        ),
                      ),
                    ),
                  ),
                  if (allowAds)
                    (_isBannerAdReady)
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              alignment: Alignment.center,
                              width: _bannerAd.size.width.toDouble(),
                              height: 59,
                              child: AdWidget(ad: _bannerAd),
                            ))
                        : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
