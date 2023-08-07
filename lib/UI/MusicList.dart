import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/Presenter/CatSubCatMusicPresenter.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';
import '../main.dart';
import 'BottomNavigation.dart';
import 'Music.dart';
import 'package:we_slide/we_slide.dart';
import 'package:audio_service/audio_service.dart';

String catName = '', idTag = '', typ = '';
AudioPlayerHandler? _audioHandler;
class MusicList extends StatefulWidget {
  MusicList(AudioPlayerHandler? audioHandler, String mID, String type,
      String cat_name) {
    catName = cat_name;
    typ = type;
    idTag = mID;
  }

  @override
  State<StatefulWidget> createState() {
    return StateClass();
  }
}

class StateClass extends State {
  List<DataMusic> list = [];
  String pathImage = '',audioPath='';
  bool tillLoading = true;
  String token="";
  SharedPref sharePrefs = SharedPref();
  final WeSlideController _controller = WeSlideController();
  double _panelMinSize = 0.0;

  Future<void> getCate() async {
    token = await sharePrefs.getToken();
    ModelMusicList mList = await CatSubcatMusicPresenter()
        .getMusicListByCategory(idTag, typ, token);
    list = mList.data;
    pathImage = mList.imagePath;
    audioPath=mList.audioPath;
    tillLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getCate();
    _audioHandler = MyApp().called();
    super.initState();
  }

  void _reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double _panelMaxSize = MediaQuery.of(context).size.height-30;
    return SafeArea(
        child: Scaffold(
            body:
        WeSlide(
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
                ),child:  Stack(children: <Widget>[
      Container(
        margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
        height: 43,
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Color(int.parse(AppSettings.colorText)),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      Container(
          margin: EdgeInsets.all(6),
          alignment: Alignment.center,
          height: 45,
          child: Text(
            "" + catName,
            style: TextStyle(
              color: Color(
                int.parse(AppSettings.colorText),
              ),
              fontFamily: 'Nunito-Bold',
              fontSize: 18.0,
            ),
          )
      ),
      if (tillLoading)
        Container(
            alignment: Alignment.center,
            child: Text(
              "Loading...",
              style: TextStyle(
                color: Color(
                  int.parse(AppSettings.colorText),
                ),
                fontFamily: 'Nunito-Bold',
                fontSize: 18.0,
              ),
            )),
      if (!tillLoading)
        (list.length == 0)?
          Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/backnoimage.png',
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                  ),
                  InkResponse(
                    onTap: () {
                    //  checkConn();
                    },
                    child: Text(
                      'Music Not Found!\nTry Again',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: appColors().colorTextHead),
                    ),
                  )
                ],
              )):Container(
              margin: EdgeInsets.fromLTRB(0, 47, 0, 0)
            ,padding: EdgeInsets.fromLTRB(0, 0, 0, 35),child: ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            String imagepath = AppConstant.ImageUrl + pathImage + list[index].image;
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
              contentPadding:EdgeInsets.fromLTRB(14, 6, 14, 10),
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

            );
          },
        )
        ),
    ])
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
        )
    );
  }
}
