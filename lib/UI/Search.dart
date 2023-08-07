import 'dart:convert';

import 'package:iphone_has_notch/iphone_has_notch.dart';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/CatSubCatMusicPresenter.dart';
import 'package:musioo/Presenter/FavMusicPresenter.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:we_slide/we_slide.dart';
import '../main.dart';
import 'BottomNavigation.dart';
import 'CreatePlaylist.dart';
import 'Music.dart';
import 'MusicYt.dart';




AudioPlayerHandler? _audioHandler;
String yt="";
class Search extends StatefulWidget {
  Search(String s){
    yt=s;
  }

  @override
  StateClass createState() {
    return StateClass();
  }
}

class StateClass extends State {
  final double size = 80.0;
  final Color color = Colors.pink;
  SharedPref sharePrefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;
  bool _hasVoice = false,tillLoading=true;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '', searchTag = '', token = '';
  String _currentLocaleId = '';
  int resultListened = 0;
  List<YouTubeVideo> videoResult = [];
  var txtSearch = TextEditingController();
String yt_key='',yt_code='';
  List<DataMusic> list = [];
  String pathImage = '',audioPath='';
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  bool allowDown=false,allowAds=true;
  final WeSlideController _controller = WeSlideController();
  double _panelMinSize = 0.0;
  late ModelSettings modelSettings ;
  int is_yt = 0;



  Future<void> searchAPI() async {

    searchTag = txtSearch.text;

    ModelMusicList mList = await CatSubcatMusicPresenter()
        .getMusicListBySearchName(searchTag, token);
    mList.data.length;
    pathImage = mList.imagePath;
    audioPath=mList.audioPath;
    list = mList.data;
    tillLoading=false;
    setState(() {});
  }

  Future<void> addRemoveAPI(String id,String tag) async {
    searchTag = txtSearch.text;
  await FavMusicPresenter()
        .getMusicAddRemove(id,token ,tag);

    setState(() {});
  }


  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }

  void statusListener(String status) {
    if (status.contains('notListening')) {
      _hasVoice = false;
      txtSearch.text = Resources.of(context).strings.searchArtistSongAlbum;

      _hasVoice = false;
    }
    setState(() {
      lastStatus = '$status';
    });
  }



  Future<dynamic> value() async {
    try {
      token = await sharePrefs.getToken();

      if(!yt.contains("YT")){
      searchAPI();}
      model = await sharePrefs.getUserData();
      sharedPreThemeData = await sharePrefs.getThemeData();
      String? sett = await sharePrefs.getSettings();
      print(sett!);
      final Map<String, dynamic> parsed = json.decode(sett);
      modelSettings = ModelSettings.fromJson(parsed);
      is_yt = modelSettings.data.is_youtube;
      setState(() {});
    } on Exception catch (e) {}
    return model;
  }

  void _initGoogleMobileAds() {
   // MobileAds.instance.initialize();

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
    String? sett = await sharePrefs.getSettings() ;
    final Map<String, dynamic> parsed = json.decode(sett!);
    ModelSettings modelSettings = ModelSettings.fromJson(parsed);
    yt_code=modelSettings.data.yt_country_code;
    yt_key=modelSettings.data.google_api_key;

      getYT("Song");
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

    setState(() {

    });
  }

  void _reload() {
    setState(() {});
  }


  Future<void> getYT(String searc) async {

    String key = yt_key;

    if(key.isNotEmpty) {
try {
  YoutubeAPI ytApi = new YoutubeAPI(key, maxResults: 50, type: "video");
  videoResult =
  await ytApi.search(searc, regionCode: yt_code, type: "video");
  tillLoading = false;
  setState(() {

  });
}catch(e){

}
    }
  }


  @override
  void initState() {
    super.initState();
    _audioHandler = MyApp().called();
    value();
    getSettings();
    _initGoogleMobileAds();

  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  void showDialog(BuildContext context,String ids,String tag,String favTag) {
    showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 700),
        context: context,
        pageBuilder: (_, __, ___) {
          return Align(
            alignment: Alignment.center,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: 265,
                height: 260,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    gradient: LinearGradient(
                      colors: [
                        appColors().colorBackground,
                        appColors().colorBackground
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(1),
                          child: InkResponse(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(14),
                                    alignment: Alignment.centerLeft,
                                    width: 68,
                                    child: favTag.contains("1")? Image.asset(
                                      'assets/icons/favfill.png',color: appColors().colorText,
                                    ):Image.asset(
                                      'assets/icons/fav2.png',
                                    )

                                ),
                                Container(
                                    width: 145,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      favTag.contains("1")?'Remove Favorite':'Favorite',
                                      style: TextStyle(
                                          fontSize: 19,
                                          color: appColors().colorText),
                                    )),
                              ]),onTap: () {
                              addRemoveAPI(ids, tag);
                           Navigator.pop(context);
                          },
                          )),
                      Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(1),
                          child: InkResponse(child:Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width: 68,
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.all(16),

                                    child: Image.asset(
                                      'assets/icons/addto.png',
                                    )),
                                Container(
                                    width: 145,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Add to playlist',
                                      style: TextStyle(
                                          fontSize: 19,
                                          color: appColors().colorText),
                                    )),
                              ]) ,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) =>
                                      CreatePlaylist(ids),
                                ));
                          },)),
                    ]),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {

    final double _panelMaxSize = MediaQuery.of(context).size.height-30;
    return SafeArea(
      left: true,
      right: true,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: WeSlide(
    controller: _controller,
    overlayOpacity: 0.9,
    overlay: true,
    isDismissible: true,
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
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                height: 45,
                child: IconButton(
                  icon: new Icon(
                    Icons.arrow_back_ios_outlined,
                    color: (sharedPreThemeData.themeImageBack.isEmpty)
                        ? Color(int.parse(AppSettings.colorText))
                        : Color(int.parse(sharedPreThemeData.themeColorFont)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Container(
                height: 45,
                margin: EdgeInsets.fromLTRB(45, 14, 16, 8),
                padding: EdgeInsets.fromLTRB(9.5, 0, 2, 0),
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
                child: Stack(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            margin: EdgeInsets.fromLTRB(35, 0, 0, 0),
                            child: TextField(
                              onChanged: (value) {
                                if (value.length > 2) {


                                  if(!yt.contains("YT")){
                                  searchAPI();
                                  setState(() {});}else{
                                    getYT(""+txtSearch.text);
                                    setState(() {});
                                  }

                                }
                                if(value.isEmpty){
                                  if(!yt.contains("YT")){
                                    searchAPI();
                                  }else{
                                    getYT(""+txtSearch.text);
                                  }
                                }

                              },
                              controller: txtSearch,
                              decoration: new InputDecoration(
                                hintText: Resources.of(context)
                                    .strings
                                    .searchArtistSongAlbum,
                                hintStyle: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16.0,
                                    color: appColors().colorText),
                                focusColor: appColors().colorBackEditText,
                                hoverColor: appColors().colorBackEditText,
                              ),
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16.0,
                                  color: appColors().colorText),
                            ))),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 13),
                        child: Image(
                          image: AssetImage('assets/icons/search.png'),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              (tillLoading)?
                Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                appColors()
                                    .primaryColorApp),
                            backgroundColor:
                            appColors()
                                .colorHint,
                            strokeWidth:
                            4.0)),
                    Container(
                        margin:
                        EdgeInsets
                            .all(4),
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        child: Text(
                          Resources
                              .of(
                              context)
                              .strings
                              .loadingPleaseWait,     textAlign: TextAlign.center,
                          style: TextStyle(
                              color: appColors()
                                  .colorTextHead,
                              fontSize:
                              18),
                        )),
                  ],
                ):
              (list.length <= 0 &&    !yt.contains("YT"))
                  ? Align(
                      alignment: Alignment.center,
                      child: Container(
                          margin: EdgeInsets.all(16),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Container(
                                height: 340,
                                margin: EdgeInsets.fromLTRB(32, 90, 32, 5),
                                child: Image.asset(
                                    'assets/images/placeholder.png'),
                              ),
                              Text(
                                'Oops, No Search Results Found !',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: (sharedPreThemeData
                                          .themeImageBack.isEmpty)
                                      ? Color(int.parse(AppSettings.colorText))
                                      : Color(int.parse(
                                          sharedPreThemeData.themeColorFont)),
                                  fontFamily: 'Nunito-Bold',
                                  fontSize: 20.0,
                                ),
                              ),
                            ],
                          )),
                    )
                  : Container(),
              if(allowAds)
                (_isBannerAdReady)
                    ? Align(
                    alignment: Alignment.topCenter,
                    child:Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(6, 65, 0, 0),
                  width: _bannerAd.size.width.toDouble(),
                  height: 75,
                  child: AdWidget(ad: _bannerAd),
                ))
                    : Container(),
              Container(
                padding: IphoneHasNotch.hasNotch ? EdgeInsets.fromLTRB(10,0, 10, 5): EdgeInsets.fromLTRB(0, 0, 0, 1),
                margin:(allowAds)? EdgeInsets.fromLTRB(0, 126, 0, 32):EdgeInsets.fromLTRB(0, 75, 0, 32),
                child:CustomScrollView(slivers: [
                  if(!yt.contains("YT"))SliverToBoxAdapter(child:  ListView.builder(
                    itemCount: list.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      String imagepath = AppConstant.ImageUrl +
                          pathImage +
                          list[index].image;
                      return ListTile(
                        onTap: () {


                          Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>

                                    Music(_audioHandler,"","",list,""+audioPath,index,false,'')
                            ),
                          ).then((value) {
                            debugPrint(value);
                            _reload();
                          });

                        },
                        contentPadding:  IphoneHasNotch.hasNotch ?EdgeInsets.fromLTRB(15, 6, 15, 8):EdgeInsets.fromLTRB(14, 6, 14, 6),
                        leading: CircleAvatar(
                          radius: 28.5,
                          backgroundImage:
                          AssetImage('assets/images/placeholder2.jpg'),
                          foregroundImage: NetworkImage(imagepath),
                        ),
                        title: Text(
                          list[index].audio_title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 16.5,
                              color: (sharedPreThemeData.themeImageBack.isEmpty)
                                  ? Color(int.parse(AppSettings.colorText))
                                  : Color(int.parse(
                                  sharedPreThemeData.themeColorFont)),
                              fontFamily: 'Nunito-Bold',
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          list[index].artists_name,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 14,
                              color: (sharedPreThemeData.themeImageBack.isEmpty)
                                  ? Color(int.parse(AppSettings.colorText))
                                  : Color(int.parse(
                                  sharedPreThemeData.themeColorFont)),
                              fontFamily: 'Nunito'),
                        ),
                        trailing: InkResponse(
                          onTap: () {
                            showDialog(context,""+list[index].id.toString(),"add",""+list[index].favourite.toString());
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.all(14),
                            child: Image.asset(
                              'assets/icons/threedots.png',
                              color: (sharedPreThemeData.themeImageBack.isEmpty)
                                  ? Color(int.parse(AppSettings.colorText))
                                  : Color(int.parse(
                                  sharedPreThemeData.themeColorFont)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),),
                if(is_yt == 1)SliverToBoxAdapter(child:   Container(
                    child: ListView.builder(
                      itemCount: videoResult.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        String imagepath =videoResult[index].thumbnail.medium.url.toString();
                        return ListTile(
                          onTap: () {
                            list=[];
                            list.add(DataMusic(1, imagepath, videoResult[index].url, videoResult[index].duration.toString(), videoResult[index].title.toString(), videoResult[index].description.toString(), 1, "1", videoResult[index].channelTitle.toString(), '', 1, 1, 1, "1", 1, "1",''));
                            if(videoResult[index].url.contains("watch")){
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        Music2(list)
                                ),
                              ).then((value) {
                                debugPrint(value);
                                _reload();
                              });}

                          },
                          contentPadding: EdgeInsets.fromLTRB(14, 6, 14, 6),
                          leading: CircleAvatar(
                            radius: 28.5,
                            backgroundImage:
                            AssetImage('assets/images/placeholder2.jpg'),
                            foregroundImage: NetworkImage(imagepath),
                          ),
                          title: Text(
                            videoResult[index].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16.5,
                                color: (sharedPreThemeData.themeImageBack.isEmpty)
                                    ? Color(int.parse(AppSettings.colorText))
                                    : Color(int.parse(
                                    sharedPreThemeData.themeColorFont)),
                                fontFamily: 'Nunito-Bold',
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            videoResult[index].description.toString(),
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 14,
                                color: (sharedPreThemeData.themeImageBack.isEmpty)
                                    ? Color(int.parse(AppSettings.colorText))
                                    : Color(int.parse(
                                    sharedPreThemeData.themeColorFont)),
                                fontFamily: 'Nunito'),
                          ),
                          /* trailing: InkResponse(
                          onTap: () {
                            showDialog(context,""+list[index].id.toString(),"add",""+list[index].favourite.toString());
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.all(14),
                            child: Image.asset(
                              'assets/icons/threedots.png',
                              color: (sharedPreThemeData.themeImageBack.isEmpty)
                                  ? Color(int.parse(AppSettings.colorText))
                                  : Color(int.parse(
                                  sharedPreThemeData.themeColorFont)),
                            ),
                          ),
                        ),*/
                        );
                      },
                    ),

                  )

                  ),
                ]),




                //),
              )
            ],
          ),
        ),
          panel: Music(_audioHandler,"","",[],"bottomSlider",0, true,_controller.hide),

          panelHeader: StreamBuilder<MediaItem?>(
              stream: _audioHandler!.mediaItem,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                    _panelMinSize=63.0;
                  return BottomNavigation(_audioHandler)
                      .getNaviagtion(context);
                } else {
                  _panelMinSize=0.0;
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
