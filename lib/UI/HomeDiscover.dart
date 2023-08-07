import 'dart:convert';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musioo/Model/ModelCatSubcatMusic.dart';
import 'package:musioo/Model/ModelChannelYT.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/Model/ModelPlayListYT.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/AppSettingsPresenter.dart';
import 'package:musioo/Presenter/CatSubCatMusicPresenter.dart';
import 'package:musioo/Presenter/Logout.dart';
import 'package:musioo/Presenter/YTPresenter.dart';
import 'package:musioo/UI/AllCategoryByName.dart';
import 'package:musioo/main.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/ConnectionCheck.dart';
import 'package:musioo/utils/PlaylistCall.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:we_slide/we_slide.dart';
import 'BottomNavigation.dart';
import 'Login.dart';
import 'Music.dart';
import 'MusicList.dart';
import 'MusicYt.dart';
import 'Search.dart';
import 'SideDrawer.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:upgrader/upgrader.dart';
import 'SearchPage.dart';



AudioPlayerHandler? _audioHandler;

class HomeDiscover extends StatefulWidget {
  @override
  _state createState() {
    return _state();
  }
}

class _state extends State<HomeDiscover> with WidgetsBindingObserver {
  late UserModel model;
  SharedPref sharePrefs = SharedPref();
  bool isOpen = false;
  var progressString = "";
  String isSelected = 'all';
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late BannerAd _bannerAd;
  String version = '';
  String buildNumber = '', appPackageName = '';
  bool _isBannerAdReady = false;
  String token = '';
  bool connected = true, checkRuning = false, hasYTPL = false;
  bool allowDown = false, allowAds = true;
  final WeSlideController _controller = WeSlideController();
  double _panelMinSize = 0.0;
  List<YouTubeVideo> videoResult = [];
  List<DataMusic> listVideo = [];
  int is_yt = 0;
  late ModelChannelYT modelChannelYT;
  late ModelPlayListYT modelListYT;
  late ModelSettings modelSettings ;





  Future<void> getSettings() async {
    String? sett = await sharePrefs.getSettings();

    final Map<String, dynamic> parsed = json.decode(sett!);
   modelSettings = ModelSettings.fromJson(parsed);
    is_yt = modelSettings.data.is_youtube;
    if (is_yt == 1) {
      if (modelSettings.data.google_api_key.isNotEmpty) {
        getYT(modelSettings.data.google_api_key,
            modelSettings.data.yt_country_code);
      }
    }
    if (modelSettings.data.status == 0) {
      sharePrefs.removeValues();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Login()),
          (Route<dynamic> route) => false);
      Logout().logout(context, token);
    }

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

  void _reload() {
    setState(() {});
  }



  Future<dynamic> value() async {
    token = await sharePrefs.getToken();
    apiSettings();
    try {
      model = await sharePrefs.getUserData();
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
        appPackageName = packageInfo.packageName;
      //  showUpdateDialog(context);
      });
      sharedPreThemeData = await sharePrefs.getThemeData();
      setState(() {});
      return model;
    } on Exception catch (e) {}
  }

  Future<void> apiSettings() async {
    String settingDetails = await AppSettingsPresenter().getAppSettings(token);

    sharePrefs.setSettingsData(settingDetails);
    model = await sharePrefs.getUserData();
    String? sett = await sharePrefs.getSettings();

    final Map<String, dynamic> parsed = json.decode(sett!);
     modelSettings = ModelSettings.fromJson(parsed);
    is_yt = modelSettings.data.is_youtube;
    if (is_yt == 1) {
      if (modelSettings.data.google_api_key.isNotEmpty) {
        getYT(modelSettings.data.google_api_key,
            modelSettings.data.yt_country_code);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {});
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _bannerAd.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {});
  }

  Future<void> checkConn() async {
    connected = await ConnectionCheck().checkConnection();
    setState(() {});
  }

  Future<void> checkRunning() async {
    checkRuning = true;
  }

  Future<void> getYT(String key, String code) async {
    YoutubeAPI ytApi = new YoutubeAPI(key, maxResults: 6, type: "video");
    videoResult = await ytApi.getTrends(
        regionCode: code);
    modelChannelYT = await YTPresenter().getYTPlayList(token);
    hasYTPL = true;
    setState(() {});
  }

  @override
  void initState() {
    checkConn();
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _audioHandler = MyApp().called();
    load();
    value();
    _initGoogleMobileAds();
    getSettings();
    checkRunning();
  }

  Future<bool> isBack(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            elevation: 5,
            backgroundColor: appColors().colorBackEditText,
            title: Text(
              'Do you want to exit the application?',
              style: TextStyle(color: appColors().white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // passing false
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
                      Resources.of(context).strings.no,
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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);
    if (route!.settings.arguments != null) {
      isSelected = ModalRoute.of(context)!.settings.arguments.toString();
      setState(() {});
    }

    final double _panelMaxSize = MediaQuery.of(context).size.height - 25;

    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: SideDrawer().defineDrawer(context, 'Discover', _audioHandler),
      key: _scaffoldKey,
      body: WeSlide(
        controller: _controller,
        overlayOpacity: 0.9,
        overlay: true,
        isDismissible: true,
        body: WillPopScope(
          onWillPop: () {
            return isBack(context);
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 2),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 2),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: (sharedPreThemeData.themeImageBack.isEmpty)
                    ? AssetImage(AppSettings.imageBackground)
                    : AssetImage(sharedPreThemeData.themeImageBack),
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  height: 50,
                  padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
                  margin: EdgeInsets.fromLTRB(6, 6, 5, 5),
                  child: InkResponse(
                    child: Image.asset(
                      'assets/icons/dropdown.png',
                      width: 30,
                      height: 30,
                      color: (sharedPreThemeData.themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(int.parse(sharedPreThemeData.themeColorFont)),
                    ),
                    onTap: () {
                      if (_scaffoldKey.currentState!.isDrawerOpen) {
                        _scaffoldKey.currentState!.openEndDrawer();
                      } else {
                        _scaffoldKey.currentState!.openDrawer();
                      }
                    },
                  ),
                ),
                isSelected.contains('Radio')
                    ? Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.fromLTRB(50, 13, 20, 8),
                        child: Text(
                          Resources.of(context).strings.radio,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                              color: appColors().colorTextHead),
                        ),
                      )
                    : Container(
                        height: 45,
                        margin: EdgeInsets.fromLTRB(52, 13, 20, 8),
                        decoration: new BoxDecoration(
                            border: Border.all(color: appColors().colorHint),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xff1c1f2e),
                                appColors().colorBackEditText
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(2.0)),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => SearchPage("")),
                            ).then((value) {
                              debugPrint(value);
                              _reload();
                            });
                            },
                          child: Stack(
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                      margin: EdgeInsets.fromLTRB(35, 0, 0, 0),
                                      child: Text(
                                        Resources.of(context)
                                            .strings
                                            .searchArtistSongAlbum,
                                        style: TextStyle(
                                            fontFamily: 'Nunito',
                                            fontSize: 15.0,
                                            color: appColors().colorText),
                                      ))),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                padding: EdgeInsets.all(5),
                                  child: Image(
                                    image:
                                    AssetImage('assets/icons/search.png'),color:appColors().colorText ,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                Container(
                  margin: EdgeInsets.fromLTRB(8, 65, 8, 0),
                  height: MediaQuery.of(context).size.height,
                  child: CustomScrollView(slivers: [
                    if (allowAds)
                      SliverToBoxAdapter(
                        child: //ads
                        Container(
                          height: 108,
                          margin: EdgeInsets.all(1),
                          child: (_isBannerAdReady)
                              ? Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: _bannerAd.size.width.toDouble(),
                                    height: 101,
                                    child: AdWidget(ad: _bannerAd),
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                    if (connected)
                      if (is_yt == 1)
                        if(videoResult.length >0)SliverToBoxAdapter(
                            child: SizedBox(
                                height: 30,
                                child: Stack(children: [
                                  Text(
                                    'Trending on Youtube',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 19,
                                        color: appColors().colorText),
                                  ),
                                Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 2, 4, 0),
                                          child: InkResponse(
                                            child: Text(
                                              'View all',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Nunito',
                                                  fontSize: 15,
                                                  color: appColors()
                                                      .primaryColorApp),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        Search("YT")),
                                              ).then((value) {
                                                debugPrint(value);
                                                _reload();
                                              });
                                            },
                                          ))),
                                ]))),
                    if (is_yt == 1)
                      if(videoResult.length >0)SliverToBoxAdapter(
                          child: SizedBox(
                              height: 150,
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: videoResult.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, idx) {
                                        return Column(
                                          // align the text to the left instead of centered
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            InkResponse(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadiusDirectional
                                                          .circular(7.0),
                                                  color: Colors.grey,
                                                  image: DecorationImage(
                                                    image: videoResult[idx]
                                                            .thumbnail
                                                            .medium
                                                            .url
                                                            .toString()
                                                            .isEmpty
                                                        ? AssetImage(
                                                            'assets/images/placeholder2.jpg')
                                                        : NetworkImage(
                                                                videoResult[idx]
                                                                    .thumbnail
                                                                    .medium
                                                                    .url
                                                                    .toString())
                                                            as ImageProvider,
                                                    fit: BoxFit.fill,
                                                    alignment:
                                                        Alignment.topCenter,
                                                  ),
                                                ),
                                                width: 120,
                                                height: 85,
                                                margin: EdgeInsets.all(4.8),
                                              ),
                                              onTap: () {
                                                listVideo = [];
                                                listVideo.add(DataMusic(
                                                    1,
                                                    videoResult[idx]
                                                        .thumbnail
                                                        .medium
                                                        .url
                                                        .toString(),
                                                    videoResult[idx].url,
                                                    videoResult[idx]
                                                        .duration
                                                        .toString(),
                                                    videoResult[idx]
                                                        .title
                                                        .toString(),
                                                    videoResult[idx]
                                                        .description
                                                        .toString(),
                                                    1,
                                                    "1",
                                                    videoResult[idx]
                                                        .channelTitle
                                                        .toString(),
                                                    '',
                                                    1,
                                                    1,
                                                    1,
                                                    "1",
                                                    1,
                                                    "1",''));

                                                Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                      builder: (context) =>
                                                          Music2(listVideo)),
                                                ).then((value) {
                                                  debugPrint(value);
                                                  _reload();
                                                });
                                              },
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 2, 0, 26),
                                              child: Text(
                                                videoResult[idx].title,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: (sharedPreThemeData
                                                            .themeImageBack
                                                            .isEmpty)
                                                        ? Color(int.parse(
                                                            AppSettings
                                                                .colorText))
                                                        : Color(int.parse(
                                                            sharedPreThemeData
                                                                .themeColorFont))),
                                              ),
                                              width: 127,
                                            ),
                                          ],
                                        );
                                      })))),
                    if (connected)
                      if (hasYTPL)
                        if (is_yt == 1)
                          SliverToBoxAdapter(
                            child: SizedBox(
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        modelChannelYT.data.results.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Stack(children: [
                                        Text(
                                          modelChannelYT.data.results[index]
                                              .snippet.title,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 19,
                                              color: appColors().colorText),
                                        ),
                                        Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, 29, 0, 0),
                                            child: FutureBuilder<ModelPlayListYT>(
                                                future: PlaylistCall().getPlaylist(modelChannelYT.data.results[index].id, ""+modelSettings.data.google_api_key),
                                                builder:
                                                    (context,AsyncSnapshot projectSnap) {

                                                  if(projectSnap.hasData) {
                                                    modelListYT=projectSnap.data!;
                                                    if(modelListYT.items.length == 0){
                                                      return Container(alignment: Alignment.center,
                                                      child: Text('No Videos Found!\n' , style: TextStyle(
                                                          fontFamily: 'Nunito',
                                                          fontSize: 19,
                                                          color: appColors().colorText),),);
                                                    }
                                                    return Container(height: 149,child: ListView.builder(
                                                        scrollDirection:
                                                        Axis.horizontal,
                                                        itemCount: projectSnap.data!.items.length,
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (context, idx) {
                                                          return Column(
                                                            // align the text to the left instead of centered
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              InkResponse(
                                                                child: Container(
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadiusDirectional
                                                                        .circular(
                                                                        7.0),
                                                                    color: Colors
                                                                        .grey,
                                                                    image:
                                                                    DecorationImage(
                                                                      image: projectSnap.data!.items[idx]
                                                                          .snippet
                                                                          .thumbnails
                                                                          .medium
                                                                          .url
                                                                          .toString()
                                                                          .isEmpty
                                                                          ? AssetImage(
                                                                          'assets/images/placeholder2.jpg')
                                                                          : NetworkImage(
                                                                          projectSnap.data!.items[idx]
                                                                              .snippet
                                                                              .thumbnails
                                                                              .medium
                                                                              .url
                                                                              .toString()) as ImageProvider,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                    ),
                                                                  ),
                                                                  width: 120,
                                                                  height: 86,
                                                                  margin:
                                                                  EdgeInsets
                                                                      .all(
                                                                      4),
                                                                ),
                                                                onTap: () {

                                                                  listVideo =
                                                                  [];
                                                                  listVideo.add(
                                                                      DataMusic(
                                                                          1,
                                                                          projectSnap.data!.items[idx].snippet.thumbnails.medium.url
                                                                              .toString(),
                                                                          "https://www.youtube.com/watch?v=" +
                                                                              projectSnap.data!.items[
                                                                              idx]
                                                                                  .snippet
                                                                                  .resourceId
                                                                                  .videoId,
                                                                          '',
                                                                          projectSnap.data!.items[
                                                                          idx]
                                                                              .snippet
                                                                              .title
                                                                              .toString(),
                                                                          projectSnap.data!.items[
                                                                          idx]
                                                                              .snippet
                                                                              .description
                                                                              .toString(),
                                                                          1,
                                                                          "1",
                                                                          projectSnap.data!.items[
                                                                          idx]
                                                                              .snippet
                                                                              .description
                                                                              .toString(),
                                                                          '',
                                                                          1,
                                                                          1,
                                                                          1,
                                                                          "1",
                                                                          1,
                                                                          "1",''));

                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder: (
                                                                            context) =>
                                                                            Music2(
                                                                                listVideo)),
                                                                  ).then((
                                                                      value) {
                                                                    debugPrint(
                                                                        value);
                                                                    _reload();
                                                                  });
                                                                },
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(0,
                                                                    2, 0, 26.5),
                                                                child: Text(
                                                                  projectSnap.data!.items[idx]
                                                                      .snippet
                                                                      .title,
                                                                  maxLines: 1,
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      14,
                                                                      color: (sharedPreThemeData
                                                                          .themeImageBack
                                                                          .isEmpty)
                                                                          ? Color(
                                                                          int
                                                                              .parse(
                                                                              AppSettings
                                                                                  .colorText))
                                                                          : Color(
                                                                          int
                                                                              .parse(
                                                                              sharedPreThemeData
                                                                                  .themeColorFont))),
                                                                ),
                                                                width: 127,
                                                              ),
                                                            ],
                                                          );
                                                        })
                                                    );
                                                  }else{
                                                    print("    === ${projectSnap.error.toString()}");
                                                    if(projectSnap.hasError){
                                                      return Container(height: 35,child: Text('Not present',style: TextStyle(fontSize: 14,color:Color(
                                                          int
                                                              .parse(
                                                              sharedPreThemeData
                                                                  .themeColorFont)) ),),);
                                                    }
                                                    return Container(height: 35,child: Text('Loading..',style: TextStyle(fontSize: 14,color:Color(
                                                        int
                                                            .parse(
                                                            sharedPreThemeData
                                                                .themeColorFont)) ),),);
                                                  }
                                                }))
                                      ]);
                                    })),
                          ),


                    if (!connected)
                      SliverToBoxAdapter(
                          child: SizedBox(
                        child: Container(
                            height: MediaQuery.of(context).size.height - 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/backnoimage.png',
                                  height: 260,
                                  width: MediaQuery.of(context).size.width,
                                ),
                                InkResponse(
                                  onTap: () {
                                    checkConn();
                                  },
                                  child: Text(
                                    'No Internet Found!\nTry Again',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 21,
                                        color: appColors().colorTextHead),
                                  ),
                                )
                              ],
                            )
                        ),
                      )),
                    if (connected)
                      SliverToBoxAdapter(
                          child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(margin: (Platform.isIOS) ?EdgeInsets.fromLTRB(0, 0, 0, 25):EdgeInsets.fromLTRB(0, 0, 0, 18),
                          child: FutureBuilder<ModelCatSubcatMusic>(
                            future: CatSubcatMusicPresenter()
                                .getCatSubCatMusicList(token),
                            builder: (context, projectSnap) {
                              if (projectSnap.hasError) {
                                return Container(
                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                  alignment: Alignment.center,
                                  child: InkResponse(
                                      onTap: () {
                                        setState(() {});
                                      },
                                      child: (connected)
                                          ? Text(
                                              'Something went wrong...\n Click here to reload...',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color:
                                                      appColors().colorTextHead,
                                                  fontSize: 18),
                                            )
                                          : Container()),
                                );
                              } else {
                                if (projectSnap.hasData) {
                                  ModelCatSubcatMusic m = projectSnap.data!;

                                  if (m.data.length < 1) {
                                    return Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        alignment: Alignment.center,
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 250,
                                              margin: EdgeInsets.fromLTRB(
                                                  18, 60, 18, 15),
                                              child: Image.asset(
                                                  'assets/images/placeholder.png'),
                                            ),
                                            Text(
                                              'No Record Found !!',
                                              style: TextStyle(
                                                color: (sharedPreThemeData
                                                        .themeImageBack.isEmpty)
                                                    ? Color(int.parse(
                                                        AppSettings.colorText))
                                                    : Color(int.parse(
                                                        sharedPreThemeData
                                                            .themeColorFont)),
                                                fontFamily: 'Nunito-Bold',
                                                fontSize: 20.0,
                                              ),
                                            ),
                                          ],
                                        ));
                                  } else {
                                    return ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: m.data.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {

                                        return Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: [
                                                if (m.data[index].sub_category
                                                        .length > 0)Stack(children: [
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(2.5,0,2,2),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      m.data[index].cat_name+"",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontSize: 19,
                                                          color: (sharedPreThemeData
                                                                  .themeImageBack
                                                                  .isEmpty)
                                                              ? Color(int.parse(
                                                                  AppSettings
                                                                      .colorText))
                                                              : Color(int.parse(
                                                                  sharedPreThemeData
                                                                      .themeColorFont)
                                                          )
                                                      ),
                                                    ),
                                                  ),
                                                  InkResponse(onTap:
                                                    () {

                                                      Navigator.push(context,
                                                        new MaterialPageRoute(builder: (context) =>
                                                            AllCategoryByName(_audioHandler,m.data[index].cat_name)),
                                                      ).then((value) {
                                                        debugPrint(value);
                                                        _reload();});
                                                    },
                                                  child:
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(2,0,2,1),
                                                    alignment:
                                                    Alignment.centerRight,
                                                    child:Text(
                                                      'View all',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: appColors().primaryColorApp),
                                                    ),
                                                  ),
                                                      )
                                                ],),
                                                Container(
                                                    width: 500,
                                                    height: (m.data[index].sub_category.length < 1) ? 10 : (Platform.isIOS) ?167:157,
                                                    alignment: Alignment.center,
                                                    child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount: m
                                                            .data[index]
                                                            .sub_category
                                                            .length,
                                                        itemBuilder:
                                                            (context, idx) {

                                                          return Column(
                                                            // align the text to the left instead of centered
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              InkResponse(
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey,
                                                                    borderRadius:
                                                                        BorderRadiusDirectional.circular(
                                                                            7.0),
                                                                    image:
                                                                        DecorationImage(
                                                                      image: m
                                                                              .data[
                                                                                  index]
                                                                              .sub_category[
                                                                                  idx]
                                                                              .image
                                                                              .isEmpty
                                                                          ? AssetImage(
                                                                              'assets/images/placeholder2.jpg')
                                                                          : NetworkImage(AppConstant.ImageUrl +
                                                                              m.data[index].imagePath +
                                                                              m.data[index].sub_category[idx].image
                                                                      ,) as ImageProvider,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      alignment:
                                                                      Alignment.topCenter,
                                                                    ),
                                                                  ),
                                                                  width: 120,
                                                                  height: 94,
                                                                  margin: EdgeInsets.all(4),
                                                                ),
                                                                onTap: () {
                                                                  if(m.data[index].cat_name.contains("Albums") || m.data[index].cat_name.contains("Artists") || m.data[index].cat_name.contains("Genres")){
                                                                    Navigator.push(context,
                                                                      new MaterialPageRoute(builder: (context) =>
                                                                          MusicList(_audioHandler, "" + m.data[index].sub_category[idx].id.toString(),m.data[index].cat_name, m.data[index].sub_category[idx].name)),
                                                                    ).then((value) {
                                                                      debugPrint(value);
                                                                      _reload();});
                                                                  }else{
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => Music(
                                                                              _audioHandler,
                                                                              "" +
                                                                                  m.data[index].sub_category[idx].id.toString(),
                                                                              m.data[index].cat_name, [], "", 0, false, '')),
                                                                    ).then((value) {
                                                                          debugPrint(value);
                                                                          _reload();
                                                                        });
                                                                  }

                                                                },
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        1.6),
                                                                child: Text(
                                                                  m
                                                                      .data[
                                                                          index]
                                                                      .sub_category[
                                                                          idx]
                                                                      .name,
                                                                  maxLines: 1,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                      14,
                                                                      color: (sharedPreThemeData
                                                                              .themeImageBack
                                                                              .isEmpty)
                                                                          ? Color(int.parse(AppSettings
                                                                              .colorText))
                                                                          : Color(
                                                                              int.parse(sharedPreThemeData.themeColorFont))),
                                                                ),
                                                                width: 127,
                                                              ),
                                                            ],
                                                          );
                                                        }))
                                              ],
                                            ));
                                      },
                                    );
                                  }
                                } else {
                                  return Material(
                                      type: MaterialType.transparency,
                                      child: Container(
                                          height: 120,
                                          width: MediaQuery.of(context).size.width,
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.fromLTRB(
                                              10, 70, 10, 0),
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
                                                  margin: EdgeInsets.all(4),
                                                  child: Text(
                                                    Resources.of(context)
                                                        .strings
                                                        .loadingPleaseWait,
                                                    style: TextStyle(
                                                        color: appColors()
                                                            .colorTextHead,
                                                        fontSize: 18),
                                                  )),
                                            ],
                                          )));
                                }
                              }
                            }),
                      ))
                      )
                  ]),

                  //start
                )
                ,
                Container(margin: EdgeInsets.fromLTRB(0, 62, 0, 0),child: UpgradeCard(),)//end
              ],
            ),
          ),
        ),
        panel: Music(_audioHandler, "", "", [], "bottomSlider", 0, true,
            _controller.hide),
        panelHeader: StreamBuilder<MediaItem?>(
            stream: _audioHandler!.mediaItem,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _panelMinSize = 63.0;

                return BottomNavigation(_audioHandler).getNaviagtion(context);
              } else {
                _panelMinSize = 0.0;
                return Container(
                  height: 0.0,
                  color: appColors().colorBackground,
                );
              }
            }),
        panelMinSize: _panelMinSize,
        panelMaxSize: _panelMaxSize,
        blur: true,
      ),
    ));
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
