import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/Model/ModelPlanList.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/CatSubCatMusicPresenter.dart';
import 'package:musioo/Presenter/DownloadPresenter.dart';
import 'package:musioo/Presenter/FavMusicPresenter.dart';
import 'package:musioo/Presenter/HistoryPresenter.dart';
import 'package:musioo/Presenter/PlanPresenter.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/UI/Plans.dart';
import 'package:musioo/databasefolder/AppDatabase.dart';
import 'package:musioo/databasefolder/ListEntity.dart';
import 'package:musioo/paymentgateway/PayStack.dart';
import 'package:musioo/paymentgateway/Paypal.dart';
import 'package:musioo/paymentgateway/Razorpay.dart';
import 'package:musioo/paymentgateway/Stripe.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'Common.dart';
import 'CreatePlaylist.dart';
import 'package:we_slide/we_slide.dart';
import 'InAppPurch.dart';

late AudioPlayerHandler _audioHandler;
List<DataMusic> listCopy = [];
int indixes = 0;
late UserModel model;
String token = '', type = '', idTag = '';
String audioPathMain = '';
List<MediaItem> listDataa = [];
MediaLibrary _mediaLibrary = MediaLibrary();
SharedPref sharePrefs = SharedPref();
late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
bool checkCurrent = false;
String currencySym = '\$';
String currentAmount="";
late int indexOnScreenSelect;



class Music extends StatefulWidget {
   WeSlideController _controller = WeSlideController();
   bool isOpn=false;
   dynamic ontap;
   Music(AudioPlayerHandler? audioHandler, String idGet, String typeGet,
      List<DataMusic> listMain, String audioPath, int index,this.isOpn ,this.ontap ) {
    indixes = index;
    indexOnScreenSelect=index;
    _audioHandler = audioHandler!;

    if (listMain.length > 0) {
      listCopy = listMain;
    }

    idTag = idGet;
    type = typeGet;
    audioPathMain = audioPath;
    checkCurrent = false;
  }

  @override
  MainScreen createState() {
    return MainScreen();
  }
}

/// The main screen.
class MainScreen extends State<Music> {
  static bool check = true;
  String downloading = "Not";
  var progressString = "";
  bool isOpen = false;
  bool local = false;
  late BannerAd _bannerAd;

  late ModelSettings modelSettings ;
  bool _isBannerAdReady = false;
  Duration? _remaining, start;
  String playing = '0:00';
  double valueHolder = 0;
  double maxi = 0.0, min = 0.0;
  bool isRepeat = false;
  late final access;
  late final database;
  late MediaItem currentData;
  String musicId = '';
  bool allowDown = false, allowAds = true;
  List<SubData> listPlans = [];
  InterstitialAd? interstitialAd;
  bool isInterstitialAdReady = false;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          this.interstitialAd = ad;
          interstitialAd?.show();

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              //  _moveToHome();
            },
          );

          isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {

          isInterstitialAdReady = false;
        },
      ),
    );
  }


 void  downloadAfterPayment(){


   downloadFile(currentData.audio_id.toString(),
       currentData.duration.toString(),
       currentData.title,
       currentData.id,
       currentData.artUri.toString(),
       currentData.artist.toString());

  }


  Future<void> planAPI() async {
    String response = await PlanPresenter().getAllPlans(token);
    final Map<String, dynamic> parsed = json.decode(response.toString());
    ModelPlanList mList = ModelPlanList.fromJson(parsed);
    listPlans = mList.data.first.all_plans;

    setState(() {});
  }


  Future<bool> showPaymentGatewaysList(BuildContext context,String amount) async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(

        elevation: 5,

        backgroundColor: appColors().colorBackEditText,
        actionsAlignment:MainAxisAlignment.center ,

        content:Container(height: 250, child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,children: [
          Text(
            'Pay Now Via:',
            style: TextStyle(color: appColors().white,fontSize: 17),

          ),
          if(modelSettings.payment_gateways.razorpay.razorpay_key.isEmpty && modelSettings.payment_gateways.paystack.paystack_public_key.isEmpty
          && modelSettings.payment_gateways.stripe.stripe_client_id.isEmpty) Text(
            '\nNot available',
            style: TextStyle(color: appColors().white,fontSize: 15),

          ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
          if(modelSettings.payment_gateways.stripe.stripe_client_id.isNotEmpty)Container(
              margin: EdgeInsets.fromLTRB(0, 29, 0, 18),
              width: 100,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appColors().white,
                      appColors().white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(5.0)),
              child: InkResponse(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    new MaterialPageRoute(
                      builder: (context) =>
                          StripePay(
                              currentData.title,
                              amount,
                              currentData.audio_id.toString()
                              ,
                              '',
                              'SingleSongPay',
                              amount,
                              model.data.email,
                              model.data.name),
                    ),
                  ).then((value) {
                    if(value != null){
                      downloadAfterPayment();}
                  });

                },

                child: Image.asset(
                  'assets/icons/stripe.png',
                  width: 19,
                  height: 20,

                ),
              )),
          if(modelSettings.payment_gateways.paystack.paystack_public_key.isNotEmpty)Container(
              margin: EdgeInsets.fromLTRB(0, 12, 1, 0),
              width: 100,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appColors().white,
                      appColors().white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(5.0)),
              child: InkResponse(
                onTap: () {

                  Navigator.pushReplacement(
                    context,
                    new MaterialPageRoute(
                      builder: (context) =>
                          PayStack(
                              currentData.title,
                              amount,
                              currentData.audio_id.toString()
                              ,
                              '',
                              'SingleSongPay',
                              amount,
                              model.data.email,
                              model.data.name),
                    ),
                  ).then((value) {
                    if(value != null){
                      downloadAfterPayment();}
                  });

                },

                child: Image.asset(
                  'assets/icons/paystack.png',
                  width: 19,
                  height: 20,

                ),
              )),
    ]),


    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
      if(modelSettings.payment_gateways.razorpay.razorpay_key.isNotEmpty) Container(
          margin: EdgeInsets.fromLTRB(0, 12, 0, 0),

width: 100,
          padding: EdgeInsets.all(12.5),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appColors().white,
                  appColors().white,
                  appColors().white
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5.0)),
          child: InkResponse(
            onTap: () {


              Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                  builder: (context) =>
                      Razorpayment(
                          currentData.title,
                          amount,
                          currentData.audio_id.toString()
                          ,
                          '',
                          'SingleSongPay',
                          amount,
                          model.data.email,
                          model.data.name),
                ),
              ).then((value) {
                if(value != null){
                  downloadAfterPayment();}
              });

            },

            child: Image.asset(
              'assets/icons/razorpay.png',
              width: 19,
              height: 22,

            ),
          )),
      if(modelSettings.payment_gateways.paypal.paypal_client_id.isNotEmpty)if(modelSettings.payment_gateways.paypal.paypal_client_id.isNotEmpty)Container(
    margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
          width: 100,
    padding: EdgeInsets.all(12.1),

    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [
    appColors().white,
    appColors().white,

    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(5.0)),
    child: InkResponse(
    onTap: () {
    Navigator.push(
    context,
    new MaterialPageRoute(
    builder: (context) =>
    Paypal(
        currentData.title,
        amount,
        currentData.audio_id.toString()
        ,
    '',
    'SingleSongPay',
    amount,
    model.data.email,
    model.data.name),
    ),
    );
    },

    child: Image.asset(
    'assets/icons/paypal.png',
    width: 19,
    height: 22,

    ),
    )),
    ])

        ],
      )
        )
    )));
  }



  Future<void> initDb() async {
    database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    access = database.daoaccess;
  }

  Stream<Duration> get _bufferedPositionStream => _audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();

  Stream<Duration?> get _durationStream =>
      _audioHandler.mediaItem.map((item) => item?.duration).distinct();

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          AudioService.position,
          _bufferedPositionStream,
          _durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  Future<dynamic> value() async {
    checkCurrent = true;

    try {
      model = await sharePrefs.getUserData();
      token = await sharePrefs.getToken();

      planAPI();
      listDataa = [];
      if(audioPathMain == "YT"){

        _audioHandler.stop();
      }else {
        if (audioPathMain.contains('Local')) {



          for (int x = 0; x < listCopy.length; x++) {
            String audiourl='';
            if (Platform.isAndroid) {
            audiourl = listCopy[x].audio+".mp3";}else{
              audiourl = 'file://' +listCopy[x].audio+".mp3";
            }



            String s = listCopy[x].audio_duration;
            List idx = s.split(':');

            if (idx.length == 3) {
              listDataa.add(MediaItem(
                  album: "",
                  id: '' + audiourl,
                  artist: "" + listCopy[x].artists_name,
                  title: '' + listCopy[x].audio_title,
                  duration: Duration(
                      hours: int.parse(idx[0]),
                      minutes: int.parse(idx[1]),
                      seconds:
                      int.parse(double.parse(idx[2]).round().toString())),
                  artUri: Uri.parse('file://' + listCopy[x].image),
              audio_id: listCopy[x].id.toString()));
            } else {
              listDataa.add(MediaItem(
                  album: "",
                  id: '' + audiourl,
                  artist: "" + listCopy[x].artists_name,
                  title: '' + listCopy[x].audio_title,
                  duration: Duration(
                      minutes: int.parse(idx[0]), seconds: int.parse(idx[1])),
                  artUri: Uri.parse('file://' + listCopy[x].image),
                audio_id: listCopy[x].id.toString()
              ));
            }
          }

          local = true;
          _mediaLibrary = MediaLibrary();

          _audioHandler
              .updateQueue(_mediaLibrary.items[MediaLibrary.albumsRootId]!);

          AudioPlayerHandlerImpl();

          setState(() {});
        } else {
          if (type.isEmpty) {


            _audioHandler.pause();
            listDataa = [];
            for (int x = 0; x < listCopy.length; x++) {
              String slug = listCopy[x].audio_slug;
              if (idTag.contains('Playing')) {
                slug = idTag;
              }
              String audiourl =
                   listCopy[x].audio;

              String imageUrl = AppConstant.ImageUrl +
                  'images/audio/thumb/' +
                  listCopy[x].image;


              String s = listCopy[x].audio_duration;
              int idx = s.indexOf(":");
              List parts = [
                s.substring(0, idx).trim(),
                s.substring(idx + 1).trim()
              ];

              local = true;
              listDataa.add(MediaItem(
                  album: "" + slug,
                  id: audiourl,
                  artist: "" + listCopy[x].artists_name,
                  title: listCopy[x].audio_title,
                  duration: Duration(
                      minutes: int.parse(parts[0]),
                      seconds: int.parse(parts[1])),
                  artUri: Uri.parse(imageUrl),
              audio_id: listCopy[x].id.toString()),
              );
            }

            _mediaLibrary = MediaLibrary();

            _audioHandler
                .updateQueue(_mediaLibrary.items[MediaLibrary.albumsRootId]!);
            musicId = listCopy[indixes].id.toString();
            addRemoveHisAPI(musicId);
            AudioPlayerHandlerImpl();
            audioPathMain = '0000';

            setState(() {
              audioPathMain = '0000';
            });
          } else {
            getByCat();
          }
        }
      }
      sharedPreThemeData = await sharePrefs.getThemeData();
      setState(() {});
      amount();
      return sharedPreThemeData;
    } on Exception catch (e) {}
  }

  Future<bool> isUpgrade(BuildContext context) async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Text('Subscribe or Upgrade plans to continue to download !'
            ,
            style: TextStyle(fontSize: 18,color: appColors().colorTextHead)),
        backgroundColor: appColors().colorBackEditText,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // passing false
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 16,color: appColors().colorTextHead),
            ),
          ),
          TextButton(
            onPressed: () async {
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
                    builder: (context) => InAppPurch(modelSettings.data.email,modelSettings.data.name),
                    settings: RouteSettings(
                      arguments: 'afterlogin',
                    ),
                  ),
                );
              }


            }, // passing true
            child: Text(
              'Continue',
              style: TextStyle(fontSize: 16,color: appColors().colorTextHead),
            ),
          ),
        ],
      ),
    )) ??
        false;
  }


  Future<void> getByCat() async {
    ModelMusicList mList = await CatSubcatMusicPresenter()
        .getMusicListByCategory(idTag, type, token);
    if (mList.data.length == 0) {
      Navigator.pop(context);
    }
    listCopy = mList.data;
    listDataa = [];
    for (int x = 0; x < mList.data.length; x++) {
      String slug = mList.data[x].audio_slug;
      String s = mList.data[x].audio_duration;

      int idx = s.indexOf(":");
      List parts = [s.substring(0, idx).trim(), s.substring(idx + 1).trim()];

      String audiourl =
           mList.data[x].audio;
      String imageUrl="";
      if(listCopy[x].image.isEmpty) {
        imageUrl = "";
      }else{
        imageUrl= AppConstant.ImageUrl + mList.imagePath + mList.data[x].image;
      }
      listDataa.add(MediaItem(
          album: "" + slug,
          id: audiourl,
          artist: "" + mList.data[x].artists_name,
          title: mList.data[x].audio_title,
          duration: Duration(
              minutes: int.parse(parts[0]), seconds: int.parse(parts[1])),
          artUri: Uri.parse(
             imageUrl),
      audio_id: mList.data[x].id.toString()));
    }
    _mediaLibrary = MediaLibrary();

    indixes = 0;

    _audioHandler.updateQueue(_mediaLibrary.items[MediaLibrary.albumsRootId]!);
   AudioPlayerHandlerImpl();
    local = true;
    _audioHandler.play();
    _audioHandler.pause();
    musicId = listCopy[indixes].id.toString();
    currentAmount=""+listCopy[indixes].download_price;
    addRemoveHisAPI(musicId);
    setState(() {
      local = true;
    });
  }

  Future<void> downloadFile(String audioId, String duration, String name,
      String url, String artUri, String artistname) async {
    Dio dio = Dio();
    var dir;
    if (Platform.isAndroid) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = (await getApplicationDocumentsDirectory());

    }

    try {

      var apiRespon = await dio.download('$url', "${dir.path}/$audioId.mp3",
          onReceiveProgress: (rec, total) {
        downloading = "Started";

        setState(() {
          double d = (rec / total) * 100;
          progressString = d.toStringAsFixed(0) + "%";
        });
      });
      apiRespon.data;
    } catch (e) {
      downloading = "Error";
    }
    try {
      var apiRespon = await dio.download('$artUri', "${dir.path}/$audioId"+"img.jpg",
          onReceiveProgress: (rec, total) {

          });
      apiRespon.data;
    } catch (e) {

    }
    setState(() {
      downloading = "Done";
      progressString = "Download Completed ${dir.path}/$name";

      if (downloading.contains("Done")) {
        insertQuery('' + audioId, '' + duration, url, '$name',
            '${dir.path}/$audioId', '${dir.path}/$audioId'+'img.jpg', artistname);
      }
    });
  }

  Future<void> insertQuery(String AudioId, String duration, String i,
      String name, String url, String imgurl, String artistname) async {
    final listMusic = ListEntity(AudioId, model.data.id.toString(), duration, i,
        name, url, imgurl, artistname);
    access.insertInList(listMusic);
  }

  Future<void> addRemoveFavAPI(String id, String tag) async {
    Navigator.pop(context);
    await FavMusicPresenter().getMusicAddRemove(id, token, tag);
    setState(() {});
  }

  Future<void> addRemoveDownAPI(String id) async {
    await DownloadPresenter().addRemoveFromDownload(id, token);
    setState(() {});
  }

  Future<void> addRemoveHisAPI(String id) async {
    await HistoryPresenter().addHistory(id, token, 'add');
    setState(() {});
  }

  void showDialogg(BuildContext context, String ids, String tag,String price) {
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
                          child: InkResponse(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      padding: EdgeInsets.all(14),
                                      alignment: Alignment.centerLeft,
                                      width: 68,
                                      child: Image.asset(
                                        'assets/icons/fav2.png',
                                      )),
                                  Container(
                                      width: 200,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Add/Remove to favorite',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: appColors().colorText),
                                      )),
                                ]),
                            onTap: () {
                              addRemoveFavAPI(ids, tag);

                            },
                          )),
                      Container(
                          height: 52,
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(1),
                          child: InkResponse(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (context) => CreatePlaylist(ids),
                                  ));
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                      width: 68,
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.all(14),
                                      child: Image.asset(
                                        'assets/icons/addto.png',
                                      )),
                                  Container(
                                      width: 200,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Add to playlist',
                                        style: TextStyle(
                                            fontSize: 19,
                                            color: appColors().colorText),
                                      )),
                                ]),
                          )),
                      StreamBuilder(
                          stream: access.findById(
                              '' + ids, model.data.id.toString()),
                          // for unique id,
                          builder: (context, snap) {
                            if (snap.hasData) {
                              var listData = snap.data as ListEntity;

                              return Container(
                                  height: 52,
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(1),
                                  child: InkResponse(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: 68,
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.all(14),
                                              child: Image.asset(
                                                'assets/icons/download.png',
                                              )),
                                          Container(
                                            width: 200,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                            'Downloaded !',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: appColors().colorText),
                                          )
                                          )
                                        ]),
                                    onTap: () {
                                      Fluttertoast.showToast(
                                          msg: 'Already Downloaded!..',
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey,
                                          textColor:
                                              appColors().colorBackground,
                                          fontSize: 14.0);
                                    },
                                  ));
                            } else {
                              return InkResponse(

                                onTap: () {
                                  if(currentAmount.isNotEmpty){

                                    Navigator.pop(context);
                                    showPaymentGatewaysList(context,currentAmount);


                                  }else {
                                    if (allowDown) {
                                      downloadFile(
                                          currentData.audio_id.toString(),
                                          currentData.duration.toString(),
                                          currentData.title,
                                          currentData.id,
                                          currentData.artUri.toString(),
                                          currentData.artist.toString());
                                      Navigator.pop(context);

                                      addRemoveDownAPI(ids);
                                    } else {
                                      // showDialogForCheck(context, ids, tag);
                                      isUpgrade(context);
                                    }
                                  }
                                },
                                child: Container(
                                    height: 52,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.all(1),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: 68,
                                              alignment: Alignment.centerLeft,
                                              padding: EdgeInsets.all(14),
                                              child: Image.asset(
                                                'assets/icons/download.png',
                                              )),
                                          Container(
                                              width: 200,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                (currentAmount.isEmpty)? 'Download Now':"Purchase & Download",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color:
                                                        appColors().colorText),
                                              )),
                                        ])),
                              );
                            }
                          }),
                    ]),
              ));
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

  Future<void> getSettings() async {
    String? sett = await sharePrefs.getSettings();

    final Map<String, dynamic> parsed = json.decode(sett!);

     modelSettings = ModelSettings.fromJson(parsed);
    currencySym = modelSettings.data.currencySymbol;
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

    if (!audioPathMain.contains('bottomSlider')) {
      if (allowAds) {
if(!idTag.contains("Playing")){
       _loadInterstitialAd();}


      }
    }
    setState(() {});
  }

  void amount(){
    currentAmount=""+listCopy[indixes].download_price;
  }

  @override
  void initState() {

    if (!audioPathMain.contains('fromBottom')) {
      if (!audioPathMain.contains('bottomSlider')) {
        value();
      }}

    initDb();
    super.initState();
    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors().colorBackground,
      bottomNavigationBar: downloading.contains('Not')
          ? null
          : downloading.contains('Started')
              ? Container(
                  height: 75,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 7),
                  decoration: BoxDecoration(
                    color: appColors().colorBackground,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      LinearProgressIndicator(
                        color: appColors().primaryColorApp,
                      ),
                      SizedBox(
                        height: 12.5,
                      ),
                      Text(
                        "Downloading : $progressString",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                )
              : downloading.contains('Done')
                  ? Container(
                      height: 70,
                      color: appColors().colorBackground,
                      alignment: Alignment.center,
                      child: Text(
                        'Downloaded Successfully!!',
                        style: TextStyle(color: appColors().white),
                      ),
                    )
                  : Container(
                      height: 60,
                      color: appColors().colorBackground,
                      alignment: Alignment.center,
                      child: Text(
                        'Failed Downloading !!',
                        style: TextStyle(color: appColors().white),
                      )),
      body: SafeArea(
        child: Container(
height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (sharedPreThemeData.themeImageBack.isEmpty)
                  ? AssetImage(AppSettings.imageBackground)
                  : AssetImage(sharedPreThemeData.themeImageBack),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(

            children: [
            Stack(
              children: [
                IconButton(
                    icon: isOpen
                        ? new Icon(
                      Icons.keyboard_arrow_down,
                      color: (sharedPreThemeData.themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(int.parse(
                          sharedPreThemeData.themeColorFont)),
                      size: 40,
                    )
                        : Icon(
                      Icons.arrow_back_ios_outlined,
                      color: (sharedPreThemeData.themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(int.parse(
                          sharedPreThemeData.themeColorFont)),
                    ),
                    onPressed: () {

                      if (audioPathMain.contains('bottomSlider')) {
                        try {
if(widget.isOpn){
                         widget.ontap();
}else{
  Navigator.of(context).pop();
}

                        } on Exception catch (e) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        Navigator.of(context).pop();
                      }
                    }),
                Container(
                    margin: EdgeInsets.all(6.5),
                    alignment: Alignment.topCenter,
                    child: StreamBuilder<MediaItem?>(
                        stream: _audioHandler.mediaItem,
                        builder: (context, snapshot) {
                          final mediaItem = snapshot.data;

                          if (snapshot.hasData) {

                            return Text(
                                (mediaItem!.album!.contains('Playing'))
                                    ? mediaItem.album!
                                    : "Playing Now",
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: (sharedPreThemeData
                                        .themeImageBack.isEmpty)
                                        ? Color(
                                        int.parse(AppSettings.colorText))
                                        : Color(int.parse(
                                        sharedPreThemeData.themeColorFont)),
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold));
                          }else{
                            return Text(
                                "Playing Now",
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: (sharedPreThemeData
                                        .themeImageBack.isEmpty)
                                        ? Color(
                                        int.parse(AppSettings.colorText))
                                        : Color(int.parse(
                                        sharedPreThemeData.themeColorFont)),
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold));}
                        }))
              ],
            ),     Container(
margin: EdgeInsets.fromLTRB(0, 62, 0, 0),
                child:ListView(
                children: [
                  // MediaItem display
                  Container(
                    child: StreamBuilder<MediaItem?>(
                      stream: _audioHandler.mediaItem,
                      builder: (context, snapshot) {
                        final mediaItem = snapshot.data;

                        if (mediaItem == null)
                          return Container(
                            height: 285,
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.fromLTRB(15, 20, 1, 4),
                            margin: EdgeInsets.fromLTRB(45,0, 45, 0),
                            decoration: new BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(402455548),
                                    Color(385678332)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(20.0)),
                            child: Column(children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(8, 2, 8, 6),
                                child: CircleAvatar(
                                  backgroundColor: appColors().colorBackground,
                                  radius: 90.0,
                                  backgroundImage:
                                  AssetImage('assets/gif/tenor2.gif')
                                  as ImageProvider,
                                ),
                              ),
                              Text(
                                'Loading...',
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 21,
                                    color: appColors().colorTextHead,
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                          );
                        currentData = mediaItem;

                        return Column(
                          children: [
                            Container(
                              height: 295,
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.fromLTRB(1, 18, 1, 13),
                              margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
                              decoration: new BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(402455548),
                                      Color(385678332)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Column(children: [
                                Container(
                                  margin: EdgeInsets.fromLTRB(8, 2, 8, 6),
                                  child:Stack( children: [
                                    Align(alignment: Alignment.center,child: CircleAvatar(
                                    backgroundColor: appColors().colorBackground,
                                    radius:  90.0,
                                    foregroundImage: (mediaItem.artUri
                                        .toString()
                                        .isEmpty)
                                        ? AssetImage(
                                        'assets/images/placeholder2.jpg')
                                    as ImageProvider
                                        : (snapshot.data!.id.contains(
                                        'https://s3.amazonaws.com/scifri-segments/scifri202011274.mp3'))
                                        ? AssetImage('assets/gif/tenor2.gif')
                                        :(mediaItem.artUri.toString().contains("file://"))? FileImage(File(mediaItem.artUri.toString().replaceAll("file://", ""))) as ImageProvider:NetworkImage(
                                        mediaItem.artUri.toString())
                                    as ImageProvider,
                                    backgroundImage:
                                    AssetImage('assets/gif/tenor2.gif')
                                    as ImageProvider,
                                  ),
                                    ),
                       if((currentAmount.isNotEmpty))Align(child:Container(
                         alignment: Alignment.center,
                         width: 90,
                         padding: EdgeInsets.fromLTRB(0, 1, 0,2),
                         decoration:new BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)) ,child:  Text(currentAmount+currencySym,
                        //amount for single pay
                        maxLines: 1,
                        style: TextStyle(
                        fontSize: 24,
                        color: appColors().primaryColorApp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito-Bold'),
                        ),),alignment: Alignment.centerRight,
                       )
                        ])
                                ),
                                Text(
                                  mediaItem.title.toString(),
                                  maxLines: 2,

                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: appColors().colorTextHead,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ""+mediaItem.artist.toString(),
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: appColors().colorTextHead,
                                      fontFamily: 'Nunito'),
                                )
                              ]),
                            ),

                            StreamBuilder<PositionData>(
                              stream: _positionDataStream,
                              builder: (context, snapshot) {
                                final positionData = snapshot.data ??
                                    PositionData(Duration.zero, Duration.zero,
                                        Duration.zero);
                                start = positionData.duration;
                                _remaining = positionData.position;
                                min = 0.0;
                                maxi =
                                    positionData.duration.inMilliseconds.toDouble();

                                if (positionData.position.inMilliseconds
                                    .toDouble() <=
                                    maxi) {
                                  valueHolder = positionData.position.inMilliseconds
                                      .toDouble();
                                }

                                return Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.fromLTRB(11, 24, 11, 0),
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                            thumbColor: Colors.green,
                                            trackHeight: 2.2,
                                            thumbShape: RoundSliderThumbShape(
                                                enabledThumbRadius: 6)),
                                        child: Slider(
                                          min: min,
                                          max: maxi,
                                          value: valueHolder,
                                          activeColor: Color(0xfffb314f),
                                          inactiveColor: Color(0xFF595d75),
                                          onChanged: (double newValue) {
                                            valueHolder =
                                                newValue.round().toDouble();

                                            setState(() {
                                              _audioHandler.seek(Duration(
                                                  milliseconds:
                                                  valueHolder.toInt()));
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Container(
                                        margin: EdgeInsets.fromLTRB(32, 0, 30, 9),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Text(
                                                  RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                                                      .firstMatch("$start")
                                                      ?.group(1) ??
                                                      '$start',
                                                  style: TextStyle(
                                                      color: (sharedPreThemeData
                                                          .themeImageBack
                                                          .isEmpty)
                                                          ? Color(int.parse(
                                                          AppSettings
                                                              .colorText))
                                                          : Color(int.parse(
                                                          sharedPreThemeData
                                                              .themeColorFont)),
                                                      fontSize: 16)),
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                                                    .firstMatch("$_remaining")
                                                    ?.group(1) ??
                                                    '$_remaining',
                                                style: TextStyle(
                                                    color: (sharedPreThemeData
                                                        .themeImageBack.isEmpty)
                                                        ? Color(int.parse(
                                                        AppSettings.colorText))
                                                        : Color(int.parse(
                                                        sharedPreThemeData
                                                            .themeColorFont)),
                                                    fontSize: 16,
                                                    letterSpacing: 0.5),
                                              ),
                                            ),
                                          ],
                                        ))
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Playback controls
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.fromLTRB(16.4, 0, 13, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkResponse(
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35.0)),
                            padding: EdgeInsets.fromLTRB(0, 15, 8, 16),
                            child: isRepeat
                                ? Icon(
                              Icons.repeat_one,
                              color: (sharedPreThemeData
                                  .themeImageBack.isEmpty)
                                  ? Color(int.parse(AppSettings.colorText))
                                  : Color(int.parse(
                                  sharedPreThemeData.themeColorFont)),
                              size: 32,
                            )
                                : Icon(
                              Icons.repeat,
                              color: (sharedPreThemeData
                                  .themeImageBack.isEmpty)
                                  ? Color(int.parse(AppSettings.colorText))
                                  : Color(int.parse(
                                  sharedPreThemeData.themeColorFont)),
                              size: 32,
                            ),
                          ),
                          onTap: () {
                            if (isRepeat) {
                              Fluttertoast.showToast(
                                  msg: 'Auto-repeat off',
                                  toastLength: Toast.LENGTH_SHORT,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey,
                                  textColor: appColors().colorBackground,
                                  fontSize: 14.0);
                              _audioHandler
                                  .setRepeatMode(AudioServiceRepeatMode.all);
                              isRepeat = false;
                            } else {
                              isRepeat = true;
                              Fluttertoast.showToast(
                                  msg: 'Auto-repeat is on',
                                  toastLength: Toast.LENGTH_SHORT,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey,
                                  textColor: appColors().colorBackground,
                                  fontSize: 14.0);
                              _audioHandler
                                  .setRepeatMode(AudioServiceRepeatMode.one);
                            }
                            setState(() {});
                          },
                        ),
                        Container(
                          height: 60,
                          width: 55,
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(16),
                          child: InkResponse(
                            onTap: () {
                              _audioHandler.skipToPrevious();
                              amount();
                            },
                            child: Image.asset(
                              'assets/icons/backwordarrow.png',
                              color: (sharedPreThemeData.themeImageBack.isEmpty)
                                  ? Color(int.parse(AppSettings.colorText))
                                  : Color(
                                  int.parse(sharedPreThemeData.themeColorFont)),
                            ),
                          ),
                        ),
                        Container(
                          height: 63,
                          width: 63,
                          margin: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  appColors().PrimaryDarkColorApp,
                                  appColors().primaryColorApp
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(35.0)),
                          child: StreamBuilder<PlaybackState>(
                            stream: _audioHandler.playbackState,
                            builder: (context, snapshot) {
                              final playbackState = snapshot.data;
                              final processingState =
                                  playbackState?.processingState;
                              final playing = playbackState?.playing;
                              if (processingState == AudioProcessingState.loading ||
                                  processingState ==
                                      AudioProcessingState.buffering) {
                                return Container(
                                  width: 50.0,
                                  height: 50.0,
                                  child: const CircularProgressIndicator(
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.red),
                                  ),
                                );
                              } else if (playing != true) {
                                return IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  color: Color(0xffffffff),
                                  iconSize: 46.0,
                                  onPressed: () {
                                    _audioHandler.play();
                                  },
                                );
                              } else {
                                return IconButton(
                                  icon: const Icon(Icons.pause),
                                  iconSize: 35.0,
                                  color: Color(0xffffffff),
                                  onPressed: _audioHandler.pause,
                                );
                              }
                            },
                          ),
                        ),
                        Container(
                          height: 60,
                          width: 55,
                          margin: EdgeInsets.all(9),
                          padding: EdgeInsets.all(16),
                          child: InkResponse(
                            onTap: () {
                              _audioHandler.skipToNext();
                            },
                            child: Image.asset(
                              'assets/icons/forword.png',
                              color: (sharedPreThemeData.themeImageBack.isEmpty)
                                  ? Color(int.parse(AppSettings.colorText))
                                  : Color(
                                  int.parse(sharedPreThemeData.themeColorFont)),
                            ),
                          ),
                        ),
                        Container(
                            height: 58,
                            padding: EdgeInsets.fromLTRB(10, 18, 8, 18),
                            child: InkResponse(
                              onTap: () {
                                isOpen = true;
if(!audioPathMain.contains("Local")) {
  if(currentData.artUri.toString().contains("file://")){

    Fluttertoast.showToast(
        msg: 'Not able to perform action in downloaded songs',
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: appColors().colorBackground,
        fontSize: 14.0);
  }else {
    if (listCopy.length > 0) {
      showDialogg(context,
          "" + listCopy[indixes].id.toString(), "add", currentAmount);
      setState(() {});
    }
  }
}else{
  Fluttertoast.showToast(
      msg: 'You are offline! Not able to perform action here',
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: appColors().colorBackground,
      fontSize: 14.0);
}
                              },
                              child: Image.asset(
                                'assets/icons/menu.png',
                                color: (sharedPreThemeData.themeImageBack.isEmpty)
                                    ? Color(int.parse(AppSettings.colorText))
                                    : Color(int.parse(
                                    sharedPreThemeData.themeColorFont)),
                              ),
                            ))
                      ],
                    ),
                  ),
                  // A seek bar.

                  const SizedBox(height: 8.0),
                  // Repeat/shuffle controls
                  Row(
                    children: [
                      if (listDataa.length > 1)
                        Container(
                          margin: EdgeInsets.fromLTRB(9, 2, 2, 1),
                          child: Text(
                            " Next",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 19,
                                color: (sharedPreThemeData.themeImageBack.isEmpty)
                                    ? Color(int.parse(AppSettings.colorText))
                                    : Color(int.parse(
                                    sharedPreThemeData.themeColorFont))),
                          ),
                        ),

                    ],
                  ),
                  // Playlist
                  if (listDataa.length > 1)
                    Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 2, 2),
                        width: 500,
                        height: 230,
                        alignment: Alignment.center,
                        child: ListView.builder(
                            scrollDirection:
                            Axis.horizontal,
                            itemCount: listDataa.length,
                            itemBuilder: (context, idx) {
                              return  Column(
                                // align the text to the left instead of centered
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  InkResponse(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadiusDirectional.circular(
                                            7.0),
                                        image: DecorationImage(
                                          image: listDataa[idx]
                                              .artUri!
                                              .hasEmptyPath
                                              ? AssetImage(
                                              'assets/images/placeholder2.jpg')
                                              :(listDataa[idx].artUri.toString().contains("file://"))? FileImage(File(listDataa[idx].artUri.toString().replaceAll("file://", ""))) as ImageProvider: NetworkImage("" +
                                              listDataa[idx]
                                                  .artUri
                                                  .toString())
                                          as ImageProvider,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                        ),
                                      ),
                                      width: 110,
                                      height: 75,
                                      margin:
                                      EdgeInsets.fromLTRB(5, 12, 1, 1),
                                    ),
                                    onTap: () {
                                      indixes = idx;
                                      amount();
                                      _audioHandler.skipToQueueItem(idx);
                                      musicId = listCopy[idx].id.toString();
                                      addRemoveHisAPI(musicId);
                                      _audioHandler.play();
                                      setState(() {});
                                    },
                                  ),
                                  Container(
                                    margin: EdgeInsets.fromLTRB(0, 2, 0, 6),
                                    child: Text(
                                      listDataa[idx].title,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: (indixes == idx)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 14,
                                          color: (sharedPreThemeData
                                              .themeImageBack.isEmpty)
                                              ? Color(int.parse(
                                              AppSettings.colorText))
                                              : Color(int.parse(
                                              sharedPreThemeData
                                                  .themeColorFont))),
                                    ),
                                    width: 127,
                                  ),
                                ],
                              );
                            })),
                ],
              ) ,)
            ],)
        ),
      ),
    );
  }
}

class QueueState {
  static final QueueState empty =
      const QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(
      this.queue, this.queueIndex, this.shuffleIndices, this.repeatMode);

  bool get hasPrevious =>
      repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;

  bool get hasNext =>
      repeatMode != AudioServiceRepeatMode.none ||
      (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}

/// An [AudioHandler] for playing a list of podcast episodes.
///
/// This class exposes the interface and not the implementation.
abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;

  Future<void> moveQueueItem(int currentIndex, int newIndex);

  ValueStream<double> get volume;

  Future<void> setVolume(double volume);

  ValueStream<double> get speed;
}


class AudioPlayerHandlerImpl extends BaseAudioHandler
    with SeekHandler
    implements AudioPlayerHandler {
  // ignore: close_sinks
  final BehaviorSubject<List<MediaItem>> _recentSubject =
      BehaviorSubject.seeded(<MediaItem>[]);

  final _player = AudioPlayer();
  late ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: []);
  @override
  final BehaviorSubject<double> volume = BehaviorSubject.seeded(1.0);
  @override
  final BehaviorSubject<double> speed = BehaviorSubject.seeded(1.0);
  final _mediaItemExpando = Expando<MediaItem>();

  /// A stream of the current effective sequence from just_audio.
  Stream<List<IndexedAudioSource>> get _effectiveSequence => Rx.combineLatest3<
              List<IndexedAudioSource>?,
              List<int>?,
              bool,
              List<IndexedAudioSource>?>(_player.sequenceStream,
          _player.shuffleIndicesStream, _player.shuffleModeEnabledStream,
          (sequence, shuffleIndices, shuffleModeEnabled) {
        if (sequence == null) return [];
        if (!shuffleModeEnabled) return sequence;
        if (shuffleIndices == null) return null;
        if (shuffleIndices.length != sequence.length) return null;
        return shuffleIndices.map((i) => sequence[i]).toList();
      }).whereType<List<IndexedAudioSource>>();

  /// Computes the effective queue index taking shuffle mode into account.
  int? getQueueIndex(
      int? currentIndex, bool shuffleModeEnabled, List<int>? shuffleIndices) {
    final effectiveIndices = _player.effectiveIndices ?? [];
    final shuffleIndicesInv = List.filled(effectiveIndices.length, 0);
    for (var i = 0; i < effectiveIndices.length; i++) {
      shuffleIndicesInv[effectiveIndices[i]] = i;
    }
    return (shuffleModeEnabled &&
            ((currentIndex ?? 0) < shuffleIndicesInv.length))
        ? shuffleIndicesInv[currentIndex ?? 0]
        : currentIndex;
  }

  /// A stream reporting the combined state of the current queue and the current
  /// media item within that queue.
  @override
  Stream<QueueState> get queueState =>
      Rx.combineLatest3<List<MediaItem>, PlaybackState, List<int>, QueueState>(
          queue,
          playbackState,
          _player.shuffleIndicesStream.whereType<List<int>>(),
          (queue, playbackState, shuffleIndices) => QueueState(
                queue,
                playbackState.queueIndex,
                playbackState.shuffleMode == AudioServiceShuffleMode.all
                    ? shuffleIndices
                    : null,
                playbackState.repeatMode,
              )).where((state) =>
          state.shuffleIndices == null ||
          state.queue.length == state.shuffleIndices!.length);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode mode) async {
    final enabled = mode == AudioServiceShuffleMode.all;
    if (enabled) {
      await _player.shuffle();
    }
    playbackState.add(playbackState.value.copyWith(shuffleMode: mode));
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    await _player.setLoopMode(LoopMode.values[repeatMode.index]);
  }

  @override
  Future<void> setSpeed(double speed) async {
    this.speed.add(speed);
    await _player.setSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume.add(volume);
    await _player.setVolume(volume);
  }

  AudioPlayerHandlerImpl() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Broadcast speed changes. Debounce so that we don't flood the notification
    // with updates.
    speed.debounceTime(const Duration(milliseconds: 250)).listen((speed) {
      playbackState.add(playbackState.value.copyWith(speed: speed));
    });
_init2();
  }

  Future<void> _init2() async {
    // Load and broadcast the initial queue
    await updateQueue(_mediaLibrary.items[MediaLibrary.albumsRootId]!);
    // For Android 11, record the most recent item so it can be resumed.
    mediaItem
        .whereType<MediaItem>()
        .listen((item) => _recentSubject.add([item]));
    // Broadcast media item changes.
    Rx.combineLatest4<int?, List<MediaItem>, bool, List<int>?, MediaItem?>(
        _player.currentIndexStream,
        queue,
        _player.shuffleModeEnabledStream,
        _player.shuffleIndicesStream,
            (index, queue, shuffleModeEnabled, shuffleIndices) {
          final queueIndex =
          getQueueIndex(index, shuffleModeEnabled, shuffleIndices);
          return (queueIndex != null && queueIndex < queue.length)
              ? queue[queueIndex]
              : null;
        }).whereType<MediaItem>().distinct().listen(mediaItem.add);
    // Propagate all events from the audio player to AudioService clients.
    _player.playbackEventStream.listen(_broadcastState);
    _player.shuffleModeEnabledStream
        .listen((enabled) => _broadcastState(_player.playbackEvent));
    // In this pixelnx, the service stops when reaching the end.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
        _player.seek(Duration.zero, index: 0);
      }
    });
    // Broadcast the current queue.
    _effectiveSequence
        .map((sequence) =>
        sequence.map((source) => _mediaItemExpando[source]!).toList())
        .pipe(queue);
    // Load the playlist.

    if(_playlist.length > 0){

      _playlist.addAll(queue.value.map(_itemToSource).toList());
    await _player.setAudioSource(_playlist);
    }
  }

  AudioSource _itemToSource(MediaItem mediaItem) {
    final audioSource = AudioSource.uri(Uri.parse(mediaItem.id));

    _mediaItemExpando[audioSource] = mediaItem;
    return audioSource;
  }

  List<AudioSource> _itemsToSources(List<MediaItem> mediaItems) =>
      mediaItems.map(_itemToSource).toList();

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId,
      [Map<String, dynamic>? options]) async {
    switch (parentMediaId) {
      case AudioService.recentRootId:
        // When the user resumes a media session, tell the system what the most
        // recently played item was.
        return _recentSubject.value;
      default:
        // Allow client to browse the media library.
        return _mediaLibrary.items[parentMediaId]!;
    }
  }

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    switch (parentMediaId) {
      case AudioService.recentRootId:
        final stream = _recentSubject.map((_) => <String, dynamic>{});
        return _recentSubject.hasValue
            ? stream.shareValueSeeded(<String, dynamic>{})
            : stream.shareValue();
      default:
        return Stream.value(_mediaLibrary.items[parentMediaId])
            .map((_) => <String, dynamic>{})
            .shareValue();
    }
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _playlist.add(_itemToSource(mediaItem));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    await _playlist.addAll(_itemsToSources(mediaItems));
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    await _playlist.insert(index, _itemToSource(mediaItem));
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    if(newQueue.length > 0){
    await _playlist.clear();
    await _playlist.addAll(_itemsToSources(newQueue));
    await _player.setAudioSource(_playlist);

    skipToQueueItem(indixes);
    }
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    final index = queue.value.indexWhere((item) => item.id == mediaItem.id);
    _mediaItemExpando[_player.sequence![index]] = mediaItem;
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    await _playlist.removeAt(index);
  }

  @override
  Future<void> moveQueueItem(int currentIndex, int newIndex) async {
    await _playlist.move(currentIndex, newIndex);
  }

  @override
  Future<void> skipToNext() async {
    if (_player.currentIndex == _playlist.length - 1) {

      Fluttertoast.showToast(
          msg: 'Don\'t have track to play in next ',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: appColors().colorBackground,
          fontSize: 14.0);
    }
    _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.currentIndex == 0) {
      Fluttertoast.showToast(
          msg: 'Don\'t have track in previous',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: appColors().colorBackground,
          fontSize: 14.0);
    }
    _player.seekToPrevious();
  }

  @override
  Future<void> skipToQueueItem(int index) async {



    if (index < 0 || index >= _playlist.children.length) return;
    // This jumps to the beginning of the queue item at [index].
    _player.seek(Duration.zero,
        index: _player.shuffleModeEnabled
            ? _player.shuffleIndices![index]
            : index);
  }

  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere(
        (state) => state.processingState == AudioProcessingState.idle);
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = getQueueIndex(
        event.currentIndex, _player.shuffleModeEnabled, _player.shuffleIndices);
    if (checkCurrent) {}

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: queueIndex,
    ));
  }
}

/// Provides access to a library of media items. In your app, this could come
/// from a database or web service.
class MediaLibrary {
  static const albumsRootId = 'albums';

  Map<String, List<MediaItem>> items = <String, List<MediaItem>>{
    AudioService.browsableRootId: const [
      MediaItem(
        id: albumsRootId,
        title: "Albums",
        playable: false,
      ),
    ],
    albumsRootId: listDataa,
  };
}

