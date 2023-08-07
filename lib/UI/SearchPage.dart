import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:musioo/Presenter/CatSubCatMusicPresenter.dart';
import 'package:musioo/Presenter/FavMusicPresenter.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/AppConstant.dart';
import '../main.dart';
import 'BottomNavigation.dart';
import 'CreatePlaylist.dart';
import 'Music.dart';
import 'package:we_slide/we_slide.dart';
import 'package:audio_service/audio_service.dart';

AudioPlayerHandler? _audioHandler;
String yt="";
class SearchPage extends StatefulWidget {
  SearchPage(String s){
    yt=s;
  }

  @override
  _InfiniteScrollPaginatorDemoState createState() => _InfiniteScrollPaginatorDemoState();
}

class _InfiniteScrollPaginatorDemoState extends State {
  final _numberOfPostsPerRequest = 9;
  var txtSearch = TextEditingController();
  bool allowAds=true;
  late ModelSettings modelSettings ;
  bool _isBannerAdReady = false;
  late BannerAd _bannerAd;
  int is_yt = 0;
  String lastStatus = '', searchTag = '', token = '';
  String pathImage = '',audioPath='';
  bool tillLoading=true;
  List<DataMusic> list = [];
  double _panelMinSize = 0.0;
  final PagingController<int, DataMusic> _pagingController =
  PagingController(firstPageKey: 1);
  final WeSlideController _controller = WeSlideController();

  Future<void> searchAPI() async {
    list=[];
    PagingController(firstPageKey: 1);
    _pagingController.refresh();
  }

  Future<dynamic> value() async {
    try {

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

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    _audioHandler = MyApp().called();
    value();
    getSettings();
    _initGoogleMobileAds();
  }



  Future<void> _fetchPage(int pageKey) async {
    token = await sharePrefs.getToken();
    try {
  final response= await CatSubcatMusicPresenter().getMusicListBySearchNamePage(txtSearch.text, token, pageKey, _numberOfPostsPerRequest);

  Map<String,dynamic> parsed =  json.decode(response.toString());
  ModelMusicList all=ModelMusicList.fromJson(parsed);
pathImage=''+all.imagePath;
audioPath=''+all.audioPath;
list.addAll(all.data);
     // List responseList = json.decode(response.toString());
      List<DataMusic> postList = all.data;
      final isLastPage = postList.length < _numberOfPostsPerRequest;
      if (isLastPage) {
        _pagingController.appendLastPage(postList);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(postList, nextPageKey);
      }
    } catch (e) {
 _pagingController.error = e;
    }
  }

  Future<void> addRemoveAPI(String id,String tag) async {
    searchTag = txtSearch.text;
    await FavMusicPresenter()
        .getMusicAddRemove(id,token ,tag);
    setState(() {});
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

        child:  Scaffold(
            resizeToAvoidBottomInset: false,
            body:  WeSlide(
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
    child:Stack(
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
    setState(() {});
    if(!yt.contains("YT")){

    searchAPI();
    setState(() {});}

    }
    if(value.isEmpty){

    if(!yt.contains("YT")){

    searchAPI();
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
    ), if(allowAds)
                if(_isBannerAdReady)
                     Align(
                    alignment: Alignment.topCenter,
                    child:Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.fromLTRB(6, 50, 0, 0),
                      width: _bannerAd.size.width.toDouble(),
                      height: 75,
                      child: AdWidget(ad: _bannerAd),
                    ))
                    ,Container(margin: EdgeInsets.fromLTRB(0,112, 0, 45),child: RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedListView<int, DataMusic>(
            pagingController: _pagingController,

            builderDelegate: PagedChildBuilderDelegate<DataMusic>(

                firstPageErrorIndicatorBuilder: (_) => Container(
                  alignment: Alignment.center,
                  child: Text("Server error\nSomething went wrong!",textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20,color: appColors().primaryColorApp),),
                ),
newPageProgressIndicatorBuilder: (context) {
  return Container(
    padding: EdgeInsets.all(7),
    alignment: Alignment.center,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,children: [
      SizedBox(child: CircularProgressIndicator(strokeWidth:2,),
      width: 22,
      height: 22,),
      SizedBox(width: 15,),
      Text("Loading..",textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15,color: appColors().primaryColorApp),),

    ],)
  );
},
              itemBuilder: (context, item, index) {
                String imagepath = AppConstant.ImageUrl +
                    pathImage +
                   item.image;
                print("imagepath  $imagepath");
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
                contentPadding:  EdgeInsets.fromLTRB(15, 6, 15, 8),
                leading: CircleAvatar(
                  radius: 28.5,
                  backgroundImage:
                  AssetImage('assets/images/placeholder2.jpg'),
                 foregroundImage: NetworkImage(imagepath),
                ),
                title: Text(
                  ""+item.audio_title,
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
                  ""+item.artists_name,
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
                    print("-----------  "+list[index].id.toString());
                    showDialog(context,""+item.id.toString(),"add",""+item.favourite.toString());
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


              }),

          ),
        ),
              ),


]      )

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
        )
        ) );
}

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
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