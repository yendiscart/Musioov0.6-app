import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/DownloadPresenter.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/databasefolder/AppDatabase.dart';
import 'package:musioo/databasefolder/ListEntity.dart';
import 'package:musioo/utils/ConnectionCheck.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import '../main.dart';
import 'Music.dart';

AudioPlayerHandler? _audioHandler;
final _player = AudioPlayer();
class Download extends StatefulWidget {
  @override
  StateClass createState() {
    return StateClass();
  }
}

class StateClass extends State {
  late final access;
  SharedPref shareprefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;
  List file = [];
  late List<ListEntity> listMain=[];
  late final database;
  String token='';
  var txtSearch = TextEditingController();
int playIndex=0;

  void _listofFiles() async {
    var directory = (await getApplicationDocumentsDirectory()).path;
    file = io.Directory("$directory")
        .listSync();
    setState(() {
       //use your folder name insted of resume.
    });
  }

  Future<void> downListAPI(String id) async {
    ModelMusicList mList= await DownloadPresenter().getDownload(token);
  }

  Future<dynamic> value() async {
    model = await shareprefs.getUserData();
    token = await shareprefs.getToken();
    sharedPreThemeData = await shareprefs.getThemeData();
    setState(() {});
    return model;
  }

  Future<dynamic> getDb() async {
    database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    access = database.daoaccess;
    listMain = await access.findAllList(model.data.id.toString());


    setState(() {});
    downListAPI(token);
    return listMain;

  }

  Future<void> set(String url) async {
String songLink=url+'.mp3';
    await _player.setFilePath(songLink);

    _player.play();
setState(() {
});
  }



  Future<void> searchDbRefresh() async {
    listMain = await access.searchAllList(model.data.id.toString(),txtSearch.text);
    setState(() {});
  }
  Future<void> dataDbRefresh() async {
  listMain = await access.findAllList(model.data.id.toString());
  setState(() {});
  }

  void showDialog(BuildContext context,String ids,String tag) {
    showGeneralDialog(
        barrierLabel: "Barrier",
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: Duration(milliseconds: 700),
        context: context,
        pageBuilder: (_, __, ___) {
          return Align(
            alignment: Alignment.center,
            child:   Material(
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
                          child: InkResponse(child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width: 68,
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.all(14),
                                    child: Image.asset(
                                      'assets/icons/download.png',
                                    )),
                                Container(
                                    width: 145,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Remove From Download',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: appColors().colorText),
                                    )),
                              ]),
                            onTap: () {


                          access.delete(listMain[int.parse(ids)]);
                          dataDbRefresh();
                              Navigator.pop(context);


                            },

                          )


                      ),



                    ]),),),
          );});
  }

  @override
  void initState() {
 _audioHandler=MyApp().called();
    getDb();
checkConn();
    super.initState();
    value();
  }

  Future<void> checkConn() async {
    await ConnectionCheck().checkConnection();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _player.stop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (sharedPreThemeData.themeImageBack.isEmpty)
                  ? AssetImage(AppSettings.imageBackground)
                  : AssetImage(sharedPreThemeData.themeImageBack),
              fit: BoxFit.fill,
            ),
          ),
          padding: EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.topRight,
            fit: StackFit.loose,
            children: <Widget>[
              Container(
                height: 45,
                alignment: Alignment.topCenter,
                margin: EdgeInsets.fromLTRB(0, 12, 2, 2),
                child: Text('Downloads',
                    style: TextStyle(
                        fontSize: 20,
                        color: (sharedPreThemeData.themeImageBack.isEmpty)
                            ? Color(int.parse(AppSettings.colorText))
                            : Color(
                                int.parse(sharedPreThemeData.themeColorFont)),
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 45,
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(6, 2, 2, 2),
                child: IconButton(
                  icon: new Icon(
                    Icons.arrow_back_ios_outlined,
                    color: (sharedPreThemeData.themeImageBack.isEmpty)
                        ? Color(int.parse(AppSettings.colorText))
                        : Color(int.parse(sharedPreThemeData.themeColorFont)),
                  ),
                  onPressed: () {
                    _player.stop();
                    Navigator.of(context).pop();
                  }
                ),
              ),


              Container(
                height: 45,
                margin: EdgeInsets.fromLTRB(18, 52, 16, 8),
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

                                  searchDbRefresh();

                                }

                                if(value.length < 1 ){
                                  dataDbRefresh();
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
              (listMain.length <= 0)?Align(alignment: Alignment.center,child: Container(
                  margin: EdgeInsets.fromLTRB(0, 40, 0, 0),
                  alignment: Alignment.center,
                  child: Column(
                    children: [Container(
                      height: 350,
                      margin: EdgeInsets.fromLTRB(18,55,18,15), /*child:Image.asset('assets/images/placeholder.png') ,*/),
                      Text('Go and download music first',style: TextStyle(color: (sharedPreThemeData.themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(int.parse(
                          sharedPreThemeData.themeColorFont)),  fontFamily: 'Nunito-Bold',
                        fontSize: 20.0,),),],)
              ),):Container(),
          Container(
            margin: EdgeInsets.fromLTRB(0, 95, 0, 0),
            height: MediaQuery.of(context).size.height,
            child:RawScrollbar(
                          isAlwaysShown: true,
                          thumbColor: Color(0xfffb314f),
                          radius: Radius.circular(20),
                          thickness: 5,
                          child: ListView.builder(
                            itemCount: listMain.length,
                            itemBuilder: (context, index) {

                              return ListTile(
                                onTap: () {

                                  List<DataMusic> listData = [];

                                  for (int x = 0; x < listMain.length; x++) {
                                    listData.add(

                                      DataMusic(
x ,
                                          ''+listMain[x].image,
                                          listMain[x].url,
                                         ""+ listMain[x].duration,
                                            listMain[x].name, "",
                                     0 ,
                                      "",
                                          ""+listMain[x].artistname,
                                         "",
                                     0,
                                     0,
                                     0,
                                     '',
                                          0,
                                          '',''
                                      ));
                                  }
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>

                                            Music(_audioHandler,"","",listData,"Local",index,false,'')
                                    ),
                                  );



                                },
                                contentPadding:
                                    EdgeInsets.fromLTRB(14, 6, 14, 6),
                                leading: CircleAvatar(
                                  radius: 28.5,
                                  backgroundImage:
                                      FileImage(File(listMain[index].image)),
                                ),
                                title: Text(
                                  '' + listMain[index].name.toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: (sharedPreThemeData
                                              .themeImageBack.isEmpty)
                                          ? Color(
                                              int.parse(AppSettings.colorText))
                                          : Color(int.parse(sharedPreThemeData
                                              .themeColorFont)),
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '' + listMain[index].artistname.toString(),
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: (sharedPreThemeData
                                              .themeImageBack.isEmpty)
                                          ? Color(
                                              int.parse(AppSettings.colorText))
                                          : Color(int.parse(sharedPreThemeData
                                              .themeColorFont)),
                                      fontFamily: 'Nunito'),
                                ),

                                trailing:
                                    Row(mainAxisSize: MainAxisSize.min ,children: [   InkResponse(
                                      onTap: () {

                                    /*    playIndex=index;
                                        _audioHandler!.stop();
                                        set(listMain[index].url);*/
                                        if(_player.playing ){

                                        _player.pause();
                                        if(playIndex!=index){
                                          set(listMain[index].url);
                                          playIndex=index;
                                        }
                                        }else{
                                          playIndex=index;
                                          _audioHandler!.stop();
                                          set(listMain[index].url);

                                        }
                                        setState(() {

                                        });
                                      },child: Container(
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              appColors().PrimaryDarkColorApp,
                                              appColors().primaryColorApp
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(width: 0.7, color: appColors().colorHint)),
                                      height: 35,
                                      width: 35,
                                      margin: EdgeInsets.fromLTRB(0, 0, 12, 0),
                                      padding: EdgeInsets.fromLTRB(2, 1, 2, 1),
                                      alignment: Alignment.center,
                                      child:  (!_player.playing || index!=playIndex)?Image.asset(
                                       'assets/icons/play.png',width: 13,height: 13,
                                        color: Color(
                                            int.parse(AppSettings.colorText)),
                                      ):Icon(Icons.pause,color: Color(
                                          int.parse( AppSettings.colorText)),size: 19,),

                                    ),
                                    ), InkResponse(
                                      onTap: () {
                                        showDialog(context,index.toString(),"add");
                                      },child: Container(
                                      height: 45,
                                      padding: EdgeInsets.fromLTRB(6, 10, 0, 10),
                                      child: Image.asset(
                                        'assets/icons/threedots.png',
                                        color: (sharedPreThemeData
                                            .themeImageBack.isEmpty) ? Color(
                                            int.parse(AppSettings.colorText)) : Color(int.parse(
                                            sharedPreThemeData.themeColorFont)),
                                      ),
                                    ),
                                    )],)

                              );
                            },
                          ),)
                  )
            ],
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