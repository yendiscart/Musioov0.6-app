import 'dart:convert';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelPlayList.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/Logout.dart';
import 'package:musioo/Presenter/PlaylistMusicPresenter.dart';
import 'package:musioo/UI/CreatePlaylist.dart';
import 'package:musioo/UI/SearchPage.dart';
import 'package:musioo/main.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/ConnectionCheck.dart';
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
import 'Search.dart';
import 'SideDrawer.dart';

AudioPlayerHandler? _audioHandler;

int touchindex = 0;

class PlayList extends StatefulWidget {
  @override
  _state createState() {
    return _state();
  }
}

class _state extends State<PlayList> with WidgetsBindingObserver {
  late UserModel model;
  SharedPref sharePrefs = SharedPref();
  bool isOpen = false;
  var progressString = "";
  String isSelected = 'all';
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  bool allowDown = false, allowAds = true;
  late BannerAd _bannerAd;
  String version = '';
  String buildNumber = '', appPackageName = '';
  String audioPath = 'images/audio/thumb/';
  bool _isBannerAdReady = false;
  String token = '';
  TextEditingController nameController = TextEditingController();
  final WeSlideController _controller = WeSlideController();
  double _panelMinSize = 0.0;
  var focusNode = FocusNode();
  bool _isEnabled = false;
  bool connected = true, checkRuning = false;

  void _reload() {
    setState(() {});
  }

  Future<void> updateAPI(
      String playlistname, String PlayListId, String token) async {
    await PlaylistMusicPresenter()
        .updatePlaylist("" + playlistname, PlayListId, token);
    nameController.text = '';

    setState(() {});
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _isEnabled = false;
    setState(() {});
    _refreshController.refreshCompleted();
  }



  Future<dynamic> value() async {
    try {
      model = await sharePrefs.getUserData();

      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        version = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
        appPackageName = packageInfo.packageName;


      });
      token = await sharePrefs.getToken();
      sharedPreThemeData = await sharePrefs.getThemeData();
      setState(() {});

      return model;
    } on Exception catch (e) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {});
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

  Future<void> loadd() async {
    setState(() {});
  }

  Future<void> getSettings() async {
    String? sett = await sharePrefs.getSettings();

    final Map<String, dynamic> parsed = json.decode(sett!);
    ModelSettings modelSettings = ModelSettings.fromJson(parsed);
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

  Future<void> checkConn() async {
    connected = await ConnectionCheck().checkConnection();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
   _audioHandler = MyApp().called();
    loadd();
    checkConn();
    getSettings();

      _initGoogleMobileAds();


    value();
  }

  void displayBottomSheet(BuildContext context) {
    Future<void> future = showModalBottomSheet(
        barrierColor: Color(0xeae5e5),
        context: context,
        backgroundColor: appColors().colorBackground,
        builder: (ctx) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(1),
                      child: Column(
                        children: [
                          Text(
                            Resources.of(context).strings.goPro,
                            style: TextStyle(
                                fontFamily: 'Nunito-Bold',
                                fontWeight: FontWeight.bold,
                                fontSize: 21,
                                color: appColors().red),
                          ),
                          Container(
                            margin: EdgeInsets.all(13),
                            child: Text(
                              'Buy No-Ads Pack to remove all ads',
                              style: TextStyle(
                                  fontFamily: 'Nunito-Bold',
                                  fontSize: 17,
                                  color: Color(0xffffffff)),
                            ),
                          ),
                          Container(
                              width: 285,
                              margin: EdgeInsets.fromLTRB(8, 5, 5, 5),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [appColors().red, appColors().red],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: TextButton(

                                  child: Text(
                                    'Buy For 100 Per Year ',
                                    style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 16,
                                        color: Color(0xffffffff)),
                                  ),
                                  onPressed: () => {})),
                          Container(
                              width: 285,
                              margin: EdgeInsets.fromLTRB(8, 5, 5, 5),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      appColors().colorBackEditText,
                                      appColors().colorBackEditText
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: TextButton(

                                  child: Text(
                                    'Buy For 15 Per Month ',
                                    style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 16,
                                        color: Color(0xffffffff)),
                                  ),
                                  onPressed: () => {})),
                        ],
                      ),
                    )
                  ])));
        });
    void _closeModal(void value) {
      if (isOpen) {
        isOpen = false;
        setState(() {});
      } else {
        isOpen = true;
        setState(() {});
      }
    }

    future.then((value) => _closeModal(value));
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
    var route = ModalRoute.of(context);
    if (route!.settings.arguments != null) {
      isSelected = ModalRoute.of(context)!.settings.arguments.toString();

      setState(() {});
    }
    final double _panelMaxSize = MediaQuery.of(context).size.height;

    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: SideDrawer().defineDrawer(context, 'Playlist', _audioHandler),
      key: _scaffoldKey,
      body: WeSlide(
        controller: _controller,
        overlayOpacity: 0.9,
        overlay: true,
        isDismissible: true,
        body: Container(
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
                            setState(() {});
                            print("...kl;.kjlklkj..");
                            Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => SearchPage('')),
                            );
                          },
                          child: InkResponse(
                            child: Stack(
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                        margin:
                                            EdgeInsets.fromLTRB(35, 0, 0, 0),
                                        child: Text(
                                          Resources.of(context)
                                              .strings
                                              .searchArtistSongAlbum+".",
                                          style: TextStyle(
                                              fontFamily: 'Nunito',
                                              fontSize: 15.0,
                                              color: appColors().colorText),
                                        ))),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    child: Image(
                                      width: 25,
                                      height: 25,
                                      color: appColors().colorText,
                                      image: AssetImage('assets/icons/search.png'),
                                    ),
                                  ),
                                ),/*
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 12, 0, 13),
                                    child: Image(
                                      image: AssetImage('assets/icons/mic.png'),
                                    ),
                                  ),
                                )*/
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => SearchPage('')),
                              ).then((value) {
                                debugPrint(value);
                                _reload();
                              });
                              setState(() {});
                            },
                          )),
                    ),

              if (allowAds)
                (_isBannerAdReady)
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.fromLTRB(8, 86, 0, 0),
                          height: 101,
                          width: _bannerAd.size.width.toDouble(),
                          child: AdWidget(ad: _bannerAd),
                        ))
                    : Container(),

              FutureBuilder<ModelPlayList>(
                  future: PlaylistMusicPresenter().getPlayList(token),
                  builder: (context, projectSnap) {
                    if (projectSnap.hasError) {

                      return Container(
                        alignment: Alignment.center,
                 margin: EdgeInsets.fromLTRB(2, 52, 2, 0),
                        child: InkResponse(
                          onTap: () {

                          setState(() {

                          });
                        },child:      (connected)? Text('Something went wrong...\n click here to reload..',
                          style: TextStyle(
                              color:
                              appColors().colorTextHead,
                              fontSize: 18),
                        ):Container(),
                        ),
                      );
                    } else {
                      if (projectSnap.hasData) {
                        ModelPlayList m = projectSnap.data!;
                        if (m.data.length < 1) {
                          return Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(12, 89, 12, 3),
                              child: Column(
                                children: [
                                  Container(
                                    height: 250,
                                    margin:
                                        EdgeInsets.fromLTRB(18, 100, 18, 2),
                                    child: Image.asset(
                                        'assets/images/placeholder.png'),
                                  ),
                                  Text(
                                    'No Playlist Found !!',
                                    style: TextStyle(
                                      color: (sharedPreThemeData
                                              .themeImageBack.isEmpty)
                                          ? Color(
                                              int.parse(AppSettings.colorText))
                                          : Color(int.parse(sharedPreThemeData
                                              .themeColorFont)),
                                      fontFamily: 'Nunito-Bold',
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ));
                        }
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            margin: (allowAds)
                                ? EdgeInsets.fromLTRB(12, 200, 3, 0)
                                : EdgeInsets.fromLTRB(6, 80, 3, 0),
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


                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: m.data.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        children: [

                                          Stack(
                                            children: [
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                child: Container(
                                                  margin: EdgeInsets.all(2.5),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    m.data[index].playlist_name,
                                                    textAlign: TextAlign.left,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                                    .themeColorFont))),
                                                  ),
                                                ),
                                                onTap: () {
                                                  nameController.text = m
                                                      .data[index]
                                                      .playlist_name;

                                                  setState(() {
                                                    _isEnabled = !_isEnabled;
                                                    touchindex = index;
                                                  });
                                                  focusNode.requestFocus();
                                                },
                                              ),
                                              if (_isEnabled)
                                                if (touchindex == index)
                                                  Container(
                                                    height: 40,
                                                    margin: EdgeInsets.fromLTRB(
                                                        3, 5, 2, 8),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            4, 0, 2, 0),
                                                    decoration:
                                                        new BoxDecoration(
                                                            border: Border.all(
                                                                color: appColors()
                                                                    .colorHint),
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Color(
                                                                    0xff1c1f2e),
                                                                appColors()
                                                                    .colorBackEditText
                                                              ],
                                                              begin: Alignment
                                                                  .centerLeft,
                                                              end: Alignment
                                                                  .centerRight,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2.0)),
                                                    child: TextField(
                                                      //   enabled: _isEnabled,
                                                      focusNode: focusNode,
                                                      onSubmitted: (value) {
                                                        _isEnabled = false;
                                                        if (nameController
                                                            .text.isNotEmpty) {
                                                          updateAPI(
                                                              nameController
                                                                  .text,
                                                              m.data[touchindex]
                                                                  .id
                                                                  .toString(),
                                                              token);
                                                        }
                                                      },
                                                      controller:
                                                          nameController,
                                                      style: TextStyle(
                                                          color: appColors()
                                                              .colorText,
                                                          fontSize: 17.0,
                                                          fontFamily: 'Nunito'),
                                                      decoration: InputDecoration(
                                                          hintText:
                                                              '  Enter playlist name..',
                                                          hintStyle: TextStyle(
                                                              color: appColors()
                                                                  .colorHint,
                                                              fontSize: 16)),
                                                    ),
                                                  ),
                                              if (_isEnabled)
                                                if (touchindex == index)
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: InkResponse(
                                                      child: Container(
                                                        height: 35,
                                                        width: 36,
                                                        margin:
                                                            EdgeInsets.all(4),
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Icon(
                                                          Icons.cancel,
                                                          color: appColors()
                                                              .colorHint,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          _isEnabled = false;
                                                        });
                                                      },
                                                    ),
                                                  )
                                            ],
                                          ),

                                          if (m.data[index].song_list.length ==
                                              0)
                                            Container(
                                              alignment: Alignment.topLeft,
                                              margin: EdgeInsets.fromLTRB(
                                                  12, 8, 12, 25),
                                              child: Text(
                                                  'No Music Found in this playlist',
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
                                                                  .themeColorFont)))),
                                            ),
                                          if (m.data[index].song_list.length >
                                              0)
                                            Container(
                                                width: 500,
                                                height: 148,
                                                alignment: Alignment.center,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: m.data[index]
                                                        .song_list.length,
                                                    itemBuilder:
                                                        (context, idx) {
                                                      return Column(
                                                        // align the text to the left instead of centered
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadiusDirectional
                                                                      .circular(
                                                                          7.0),
                                                              image:
                                                                  DecorationImage(
                                                                image: m
                                                                        .data[
                                                                            index]
                                                                        .song_list[
                                                                            idx]
                                                                        .image
                                                                        .isEmpty
                                                                    ? AssetImage(
                                                                        'assets/images/placeholder2.jpg')
                                                                    : NetworkImage(AppConstant
                                                                            .ImageUrl +
                                                                        audioPath +
                                                                        m
                                                                            .data[index]
                                                                            .song_list[idx]
                                                                            .image) as ImageProvider,
                                                                fit:
                                                                    BoxFit.fill,
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                              ),
                                                            ),
                                                            width: 118,
                                                            height: 85,
                                                            margin:
                                                                EdgeInsets.all(
                                                                    8),
                                                            child: Stack(
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child:
                                                                      InkResponse(
                                                                    child: Container(
                                                                        margin: EdgeInsets.fromLTRB(1, 1, 5, 12),
                                                                        height: 18,
                                                                        width: 19.2,
                                                                        child: new Icon(
                                                                          Icons
                                                                              .cancel,
                                                                          color:
                                                                              Color(int.parse(AppSettings.colorPrimary)),
                                                                          size:
                                                                              25,
                                                                        )
                                                                        ),
                                                                    onTap: () {
                                                                      isDelete(
                                                                          context,
                                                                          m.data[index].id
                                                                              .toString(),
                                                                          m.data[index].song_list[idx]
                                                                              .id
                                                                              .toString());
                                                                    },
                                                                  ),
                                                                ),
                                                                Align(
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    width: 29,
                                                                    height: 29,
                                                                    child:
                                                                        InkResponse(
                                                                      child:
                                                                          Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        padding:
                                                                            EdgeInsets.all(7),
                                                                        decoration: BoxDecoration(
                                                                            gradient: LinearGradient(
                                                                              colors: [
                                                                                appColors().colorBackEditText,
                                                                                appColors().colorBackEditText
                                                                              ],
                                                                              begin: Alignment.centerLeft,
                                                                              end: Alignment.centerRight,
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(30.0),
                                                                            border: Border.all(width: 0.5, color: appColors().colorHint)),
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/icons/play.png',
                                                                          color:
                                                                              appColors().colorTextHead,
                                                                        ),
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        List<DataMusic>
                                                                            listMain =
                                                                            m.data[index].song_list;

                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          new MaterialPageRoute(
                                                                              builder: (context) => Music(_audioHandler, "Playing " + m.data[index].playlist_name, '', listMain, "images/audio/", idx, false,'')),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets
                                                                .fromLTRB(
                                                                    0, 2, 0, 6),
                                                            child: Text(
                                                              m
                                                                  .data[index]
                                                                  .song_list[
                                                                      idx]
                                                                  .audio_title,
                                                              maxLines: 1,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
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
                                                    }))
                                        ],
                                      ));
                                },
                              ),
                            ));
                      } else {
                        return Material(
                            type: MaterialType.transparency,
                            child: Container(
                                height: 120,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                margin: EdgeInsets.fromLTRB(10, 220, 10, 0),
                                color: appColors().colorBackEditText,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                        child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation(
                                                appColors().primaryColorApp),
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
                                              color: appColors().colorTextHead,
                                              fontSize: 18),
                                        )),
                                  ],
                                )));
                      }
                    }
                  }),
              (connected)
                  ? Container()
                  : Container(
                  margin: EdgeInsets.fromLTRB(22, 100, 22, 0),
                  child: Column(
                    children: [
                      Image.asset('assets/images/backnoimage.png',height: 250,width: MediaQuery.of(context).size.width,),
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
                  )),
              Align(
                alignment: Alignment.bottomRight,
                child: InkResponse(
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => CreatePlaylist(''),
                        ));
                  },
                  child: Container(
                    height: (Platform.isAndroid) ?55:62,
                    width: (Platform.isAndroid) ? 55:62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appColors().primaryColorApp,
                            appColors().primaryColorApp,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0)),
                    margin: (Platform.isAndroid) ?EdgeInsets.fromLTRB(11, 68, 25, 88):EdgeInsets.fromLTRB(11, 68, 28, 115),
                    child: Text(
                      '+',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: appColors().white),
                    ),
                  ),
                ),
              ),
              //start

              //end
            ],
          ),
        ),
        panel: Music(
            _audioHandler, "", "", [], "bottomSlider", 0,true,_controller.hide),
        panelHeader: StreamBuilder<MediaItem?>(
            stream: _audioHandler!.mediaItem,
            builder: (context, snapshot) {
              if (snapshot.hasData) {

                  _panelMinSize=63.0;
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

  Future<bool> isDelete(
      BuildContext context, String PlayListId, String music_id) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: appColors().colorBackEditText,
            title: Text('Are you sure want to delete it?',
              style: TextStyle(fontSize: 16,color: appColors().colorTextHead),),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // passing false
                child: Text(
                  'No',
                  style: TextStyle(fontSize: 16,color: appColors().colorTextHead),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await PlaylistMusicPresenter()
                      .removeMusicFromPlaylist(music_id, PlayListId, token);
                  Navigator.pop(context, false);
                  setState(() {});
                }, // passing true
                child: Text(
                  'Yes',
                  style: TextStyle(fontSize: 16,color: appColors().colorTextHead),
                ),
              ),
            ],
          ),
        )) ??
        false;
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
//saloni