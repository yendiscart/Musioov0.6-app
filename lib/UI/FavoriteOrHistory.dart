import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/FavMusicPresenter.dart';
import 'package:musioo/Presenter/HistoryPresenter.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/ConnectionCheck.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../main.dart';
import 'CreatePlaylist.dart';
import 'Music.dart';




AudioPlayerHandler? _audioHandler;
String from='';
class Favorite extends StatefulWidget{
  Favorite(String s){
    from=s;
}



@override
StateClass createState() {
  return StateClass();
}




}
class StateClass extends State {

SharedPref sharePrefs = SharedPref();
late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
late UserModel model;
List<DataMusic> list = [];
String pathImage = '',audioPath='',token='';
bool showArrow=false,isLoading = true;


Future<void> favAPI() async {
  ModelMusicList mList = await FavMusicPresenter()
      .getFavMusicList(token);
  mList.data.length;
  pathImage = mList.imagePath;
  audioPath=mList.audioPath;
  list = mList.data;
  isLoading=false;
  setState(() {});
}


Future<void> hisAPI() async {
  //
  String data = await HistoryPresenter().getHistory(token);
  final Map<String,dynamic> parsed = json.decode(data.toString());
  ModelMusicList mList=ModelMusicList.fromJson(parsed);
  mList.data.length;
  pathImage = mList.imagePath;
  audioPath=mList.audioPath;
  list = mList.data;
  isLoading=false;
setState(() {
});
}

Future<void> addRemoveAPI(String id,String tag) async {

  await FavMusicPresenter()
      .getMusicAddRemove(id,token ,tag);

  if(!from.contains('fav')){
    showArrow=true;

    Future.delayed(Duration(seconds: 3)).then((_) {
      setState(() {
        showArrow = false; //goes back to arrow Icon
        // Anything else you want
      });});

  }
  if(from.contains('fav'))
  {
    favAPI();
  }else{

    hisAPI();
  }

  setState(() {});
}
RefreshController _refreshController =
RefreshController(initialRefresh: false);

void _onRefresh() async {

  // monitor network fetch
  await Future.delayed(Duration(milliseconds: 1000));
  setState(() {});
  _refreshController.refreshCompleted();
}

Future<void> addRemoveHisAPI(String id) async {
  await HistoryPresenter().addHistory(id,token,'remove');
  hisAPI();
}

void showDialog(BuildContext context,String ids,String tag,String favrateStatus) {
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
                    if(!from.contains('fav'))Container(

                          alignment: Alignment.center,
                          margin: EdgeInsets.all(1),
                          child: InkResponse(
                            onTap: () {
                              addRemoveHisAPI(ids);
                              Navigator.pop(context);
                            },child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(16),
                                    alignment: Alignment.centerLeft,
                                    width: 68,
                                    child: Image.asset(
                                      'assets/icons/history.png',color: appColors().colorText,
                                    )),
                                Container(
                                    width: 140,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Remove from history',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: appColors().colorText),
                                    )),
                              ])
                            ,)


                      ),
                      Container(

                          alignment: Alignment.center,
                          margin: EdgeInsets.all(1),
                          child: InkResponse( child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(14),
                                    alignment: Alignment.centerLeft,
                                    width: 68,
                                    child:favrateStatus.contains("1")? Image.asset(
                                      'assets/icons/favfill.png',color: appColors().colorText,
                                    ):Image.asset(
                        'assets/icons/fav2.png',
                      )),
                                Container(
                                    width: 145,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      from.contains('fav')? 'Remove from favorite': favrateStatus.contains("1")?'Remove Favorite':'Favorite',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: appColors().colorText),
                                    )),
                              ])
                          ,onTap: () {
                              addRemoveAPI(ids, tag);
                              Navigator.pop(context);
                          },
                          )
                      ),
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
                                      'assets/icons/addto.png',
                                    )),
                                Container(
                                    width: 145,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Add to playlist',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: appColors().colorText),
                                    )),
                              ]),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) =>
                                      CreatePlaylist(ids),
                                ));

                          },

                          )


                      ),



                    ]),),),
          );});
  }
Future<dynamic> value() async {
  token = await sharePrefs.getToken();
  model = await sharePrefs.getUserData();
  if(from.contains('fav'))
  {
  favAPI();
  }else{
    hisAPI();
  }
  sharedPreThemeData = await sharePrefs.getThemeData();
  setState(() {});
  return model;
}
  @override
  void initState() {
    super.initState();
    _audioHandler=MyApp().called();
    checkConn();
    value();
  }


Future<void> checkConn() async {
   await ConnectionCheck().checkConnection();
  setState(() {});
}


  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);
    if (route!.settings.arguments != null) {
      from = ModalRoute.of(context)!.settings.arguments.toString();

      setState(() {});
    }
    return  SafeArea(
      child: Scaffold(
        backgroundColor: appColors().colorBackground,


        body : Container(

          decoration: BoxDecoration(
            image: DecorationImage(
              image: (sharedPreThemeData.themeImageBack.isEmpty) ? AssetImage(AppSettings.imageBackground) : AssetImage(sharedPreThemeData.themeImageBack),
              fit: BoxFit.fill,
            ),
          ),
          child:Stack(
            alignment: Alignment.topRight,
            fit: StackFit.loose,
            children: <Widget>[
              Container(
                height:45,alignment: Alignment.topCenter,margin: EdgeInsets.fromLTRB(0, 12, 2, 2),child: Text(from.contains('fav')?'Favorites':from.contains('his')?'History':'Playlist',  style: TextStyle(
                  fontSize: 20, color:(sharedPreThemeData.themeImageBack.isEmpty) ? Color(int.parse(AppSettings.colorText)) : Color(int.parse(sharedPreThemeData.themeColorFont)), fontFamily: 'Nunito',fontWeight: FontWeight.bold )),),
              Container(height:45,alignment: Alignment.topLeft,margin: EdgeInsets.fromLTRB(6, 2, 2, 2),child:IconButton(
                icon: new Icon(Icons.arrow_back_ios_outlined,color: (sharedPreThemeData.themeImageBack.isEmpty) ? Color(int.parse(AppSettings.colorText)) : Color(int.parse(sharedPreThemeData.themeColorFont)),),
                onPressed: () => Navigator.of(context).pop(),
              ) ,),
              Align(
                alignment: Alignment.center,child: Container(
                  margin: EdgeInsets.all(14),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      if(!isLoading)if(list.length <= 0)Container(
                      height: 200,
                      margin: EdgeInsets.fromLTRB(18,10,18,15), child:Image.asset('assets/images/placeholder.png') ,),

                      Text((!isLoading)?(list.length <= 0)?'No Music Found !!':"":"Loading...",style: TextStyle(color: (sharedPreThemeData.themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(int.parse(
                          sharedPreThemeData.themeColorFont)),  fontFamily: 'Nunito-Bold',
                        fontSize: 20.0,),),],)
              ),),




              Container(
                margin: EdgeInsets.fromLTRB(0, 45, 2, 2)
                ,child:RawScrollbar(
                isAlwaysShown: true,
                thumbColor: Color(0xfffb314f),
                radius: Radius.circular(20),
                thickness: 5,

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
                  ), child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      //change saloni replace comment
                      onTap: () {

                        Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  Music(_audioHandler,"","",list,""+audioPath,index,false,'')
                          ),
                        );
                      },
                      contentPadding: EdgeInsets.fromLTRB(14,6,14,6),
                      leading: CircleAvatar(
                        radius: 28.0,
                        backgroundImage:
                        AssetImage('assets/images/placeholder2.jpg'),
                        foregroundImage: NetworkImage(AppConstant.ImageUrl+pathImage+list[index].image),

                      ),
                      title: Text(list[index].audio_title,  style: TextStyle(

                          fontSize: 16, color:(sharedPreThemeData.themeImageBack.isEmpty) ? Color(int.parse(AppSettings.colorText)) : Color(int.parse(sharedPreThemeData.themeColorFont)),
                          fontFamily: 'Nunito',fontWeight: FontWeight.bold ),),
                      subtitle: Text(list[index].artists_name,  style: TextStyle(
                          fontSize: 14, color: (sharedPreThemeData.themeImageBack.isEmpty) ? Color(int.parse(AppSettings.colorText)) : Color(int.parse(sharedPreThemeData.themeColorFont)),
                          fontFamily: 'Nunito'),),
                      trailing: InkResponse(
                        onTap: () {
                          showDialog(context,""+list[index].id.toString(),"add",""+list[index].favourite.toString());
                        },child: Container(
                        height: 50,
                        padding: EdgeInsets.all(14),
                        child: Image.asset('assets/icons/threedots.png',color: (sharedPreThemeData.themeImageBack.isEmpty) ? Color(int.parse(AppSettings.colorText))
                            : Color(int.parse(sharedPreThemeData.themeColorFont)),),),
                      ),
                    );
                  },
                ),
                ),
              ) ,) ,

            ],
          ),
        ),

      ),);


  }

}