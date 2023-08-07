import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelPlayList.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/PlaylistMusicPresenter.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'PlayList.dart';

String idMusic = '';

class CreatePlaylist extends StatefulWidget {
  CreatePlaylist(String ids) {
    idMusic = ids;
  }

  @override
  state createState() {
    return state();
  }
}

class state extends State {
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  SharedPref sharePrefs = SharedPref();
  String token = '';
  TextEditingController nameController = TextEditingController();
  late UserModel model;
  String checkFun = "Create";
  String updateId = '', updateName = '';

  Future<bool> isDelete(BuildContext context, String PlayListId) async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text('Are you sure want to delete it?'
              ,
              style: TextStyle(fontSize: 16,color: appColors().colorTextHead)),
            backgroundColor: appColors().colorBackEditText,
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
                      .removePlaylist(PlayListId, token);
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

  Future<void> createAPI(String tag) async {
    await PlaylistMusicPresenter()
        .createPlaylist("" + model.data.id.toString(), tag, token);
    nameController.text = '';
    if(idMusic.isEmpty){
    Navigator.pop(context);}else{setState(() {

    });}
  }

  Future<void> updateAPI(
      String playlistname, String PlayListId, String token) async {
    await PlaylistMusicPresenter()
        .updatePlaylist("" + playlistname, PlayListId, token);
    nameController.text = '';
    checkFun = 'Create';
    setState(() {});
  }

  Future<void> addMusicToPlayListAPI(String playListID) async {
    await PlaylistMusicPresenter().addMusicPlaylist(idMusic, playListID, token);
    nameController.text = '';
    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(
        builder: (context) => PlayList(),
        settings: RouteSettings(
          arguments: 'book',
        ),
      ),
    );
  }

  Future<dynamic> value() async {
    try {
      model = await sharePrefs.getUserData();
      token = await sharePrefs.getToken();
      sharedPreThemeData = await sharePrefs.getThemeData();
      setState(() {});
      return model;
    } on Exception catch (e) {}
  }

  @override
  void initState() {
    super.initState();

    value();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
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
          child: ListView(
            children: [
              Stack(
                children: [
                  Container(
                    height: 45,
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.fromLTRB(0, 15.2, 2, 2),
                    child: Text('Playlist Update',
                        style: TextStyle(
                            fontSize: 20,
                            color: (sharedPreThemeData.themeImageBack.isEmpty)
                                ? Color(int.parse(AppSettings.colorText))
                                : Color(int.parse(
                                    sharedPreThemeData.themeColorFont)),
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    height: 45,
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.fromLTRB(6, 9, 2, 2),
                    child: IconButton(
                      icon: new Icon(
                        Icons.arrow_back_ios_outlined,
                        color: (sharedPreThemeData.themeImageBack.isEmpty)
                            ? Color(int.parse(AppSettings.colorText))
                            : Color(
                                int.parse(sharedPreThemeData.themeColorFont)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              Container(
                height: 55,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                margin: EdgeInsets.fromLTRB(22, 26, 22, 6),
                alignment: Alignment.center,
                decoration:  BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appColors().colorBackEditText,
                        appColors().colorBackEditText
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(width: 1, color: appColors().colorHint)),
                child: TextField(
                  controller: nameController,
                  style: TextStyle(
                      color: appColors().colorText,
                      fontSize: 17.0,
                      fontFamily: 'Nunito'),
                  decoration: InputDecoration(
                    hintText: 'Enter Playlist name here..',
                    hintStyle: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 17.0,
                        color: appColors().colorHint),
                    suffixIcon: Image.asset(
                      'assets/icons/pencil.png',
                      color: appColors().colorText,
                      height: 20,
                      width: 18,
                    ),
                    suffixIconConstraints:
                        BoxConstraints(minHeight: 18, minWidth: 8),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                  width: 200,
                  margin: EdgeInsets.fromLTRB(80, 14, 80, 0),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors().PrimaryDarkColorApp,
                          appColors().primaryColorApp,
                          appColors().primaryColorApp
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30.0)),
                  child: TextButton(
                      child: Text(
                        checkFun,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffffffff)),
                      ),
                      onPressed: () => {
                            if (checkFun.contains('Create'))
                              {
                                if(nameController.text.isNotEmpty){
                                createAPI(nameController.text),
                                }else{
              Fluttertoast.showToast(
              msg: 'Enter name to create playlist',
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.grey,
              textColor: appColors().colorBackground,
              fontSize: 14.0),
                                }
                              }
                            else
                              {
                                updateAPI(nameController.text, updateId, token),
                              }
                          })),
              if (checkFun.contains('Create'))
                Container(
                  margin: EdgeInsets.fromLTRB(12, 22, 12, 5),
                  child: Text('Select/update Playlist',
                      style: TextStyle(
                          fontSize: 19,
                          color: (sharedPreThemeData.themeImageBack.isEmpty)
                              ? Color(int.parse(AppSettings.colorText))
                              : Color(int.parse(
                                  sharedPreThemeData.themeColorFont)))),
                ),
              if (checkFun.contains('Create'))
                FutureBuilder<ModelPlayList>(
                    future: PlaylistMusicPresenter().getPlayList(token),
                    builder: (context, projectSnap) {
                      if (projectSnap.hasError) {
                        Fluttertoast.showToast(
                            msg: Resources.of(context).strings.tryAgain,
                            toastLength: Toast.LENGTH_SHORT,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey,
                            textColor: appColors().colorBackground,
                            fontSize: 14.0);

                        return Material(
                            // child: LanguageChoose(''),
                            );
                      } else {
                        if (projectSnap.hasData) {
                          ModelPlayList m = projectSnap.data!;
                          if (m.data.length < 1) {
                            return Container(
                              alignment: Alignment.center,
                                margin: EdgeInsets.fromLTRB(12, 23, 12, 3),child: Column(
                              children: [Container(
                                height: 200,
                                margin: EdgeInsets.fromLTRB(18,60,18,23), child:Image.asset('assets/images/placeholder.png') ,),
                                Text('Nothing created!',style: TextStyle(color: (sharedPreThemeData.themeImageBack.isEmpty)
                                    ? Color(int.parse(AppSettings.colorText))
                                    : Color(int.parse(
                                    sharedPreThemeData.themeColorFont)),  fontFamily: 'Nunito-Bold',
                                  fontSize: 20.0,),),],)
                            );
                          }
                          return Container(
                            height: MediaQuery.of(context).size.height,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: m.data.length,
                              itemBuilder: (context, index) {
                                return Container(
                                    margin: EdgeInsets.fromLTRB(12, 3, 12, 3),

                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkResponse(
                                          child: Container(
                                            width: 200,
                                            margin: EdgeInsets.fromLTRB(
                                                1, 12, 12, 12),
                                            alignment: Alignment.centerLeft,
                                            child: Text(

                                              m.data[index].playlist_name,
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Color(int.parse(
                                                      AppSettings.colorText))),
                                            ),
                                          ),
                                          onTap: () {
                                            if (!idMusic.isEmpty) {
                                              addMusicToPlayListAPI(
                                                  m.data[index].id.toString());
                                            }
                                          },
                                        ),
                                        InkResponse(
                                          onTap: () {
                                            checkFun = 'Update';
                                            updateName = m
                                                .data[index].playlist_name
                                                .toString();
                                            updateId =
                                                m.data[index].id.toString();
                                            nameController.text = m
                                                .data[index].playlist_name
                                                .toString();
                                            setState(() {});
                                          },
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                12, 12, 1, 12),
                                            child: Image.asset(
                                              'assets/icons/pencil.png',
                                              color: appColors().colorText,
                                              width: 17,
                                            ),
                                          ),
                                        ),
                                        InkResponse(
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                1, 12, 12, 12),
                                            height: 20,
                                            width: 20,
                                            child: Image.asset(
                                              'assets/icons/bin.png',
                                              color: appColors().colorText,
                                            ),
                                          ),
                                          onTap: () {
                                            isDelete(context,
                                                m.data[index].id.toString());
                                          },
                                        )
                                      ],
                                    ));
                              },
                            ),
                          );
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
                                                color:
                                                    appColors().colorTextHead,
                                                fontSize: 18),
                                          )),
                                    ],
                                  )));
                        }
                      }
                    })
            ],
          )),
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
