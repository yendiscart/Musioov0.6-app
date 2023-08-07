import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:musioo/utils/SharedPref.dart';

List<DataMusic> list = [];

class Music2 extends StatefulWidget {
  Music2(List<DataMusic> listMusic) {
    list = listMusic;
  }

  @override
  State<StatefulWidget> createState() {
    return MusicState();
  }
}

class MusicState extends State {
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  SharedPref sharePrefs = SharedPref();
  late YoutubePlayerController _controller;
  Future<dynamic> value() async {
    sharedPreThemeData = await sharePrefs.getThemeData();
  }

  @override
  void initState() {
    super.initState();
    print(list[0].audio);
    /*_controller = VideoPlayerController.network(
        list[0].audio)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });*/
    String videoId;
    videoId = YoutubePlayer.convertUrlToId(list[0].audio)!;
    print(videoId); // BBAyRBTfsOU
 /*_controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,


        mute: false,
      ),
    );*/


    value();
  }
  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return  OrientationBuilder(builder:
          (BuildContext context, Orientation orientation) {

            String videoId;
            videoId = YoutubePlayer.convertUrlToId(list[0].audio)!;
            _controller = YoutubePlayerController(
              initialVideoId: videoId,
              flags: YoutubePlayerFlags(
                autoPlay: true,
                hideControls: false,
                mute: false,
              ),
            );
            if (orientation == Orientation.landscape) {
              return Scaffold(
                body: SafeArea(
                    child: Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height,

                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: (sharedPreThemeData.themeImageBack.isEmpty)
                                ? AssetImage(AppSettings.imageBackground)
                                : AssetImage(sharedPreThemeData.themeImageBack),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(children: [

                          ListView(children: [
                            Container(
                              alignment: Alignment.topCenter,
                              child: Stack(
                                  children: [
                                    Container(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                      height: MediaQuery
                                          .of(context)
                                          .size
                                          .height - 24,
                                      child:
                                      YoutubePlayer(
                                        controller: _controller,
                                        showVideoProgressIndicator: true,
                                        onReady: () {
                                        },
                                      ),

                                    ),


                                  ]),
                            ),

                          ],)


                        ]))
                ),
              );
            } else {
              return Scaffold(
                body: SafeArea(
                    child: Container(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: (sharedPreThemeData.themeImageBack.isEmpty)
                                ? AssetImage(AppSettings.imageBackground)
                                : AssetImage(sharedPreThemeData.themeImageBack),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: ListView(children: [
                          Stack(children: [IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_outlined,
                                color: (sharedPreThemeData.themeImageBack
                                    .isEmpty)
                                    ? Color(int.parse(AppSettings.colorText))
                                    : Color(
                                    int.parse(
                                        sharedPreThemeData.themeColorFont)),
                              ),
                              onPressed: () {

                                Navigator.of(context).pop();
                                // }
                              }),
                            Container(
                              margin: EdgeInsets.all(6.5),
                              alignment: Alignment.topCenter,
                              child: Text("Playing Now",
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: (sharedPreThemeData.themeImageBack
                                          .isEmpty)
                                          ? Color(
                                          int.parse(AppSettings.colorText))
                                          : Color(int.parse(
                                          sharedPreThemeData.themeColorFont)),
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.bold)),
                            ),
                          ]),

                          Container(

                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            decoration: new BoxDecoration(

                                borderRadius: BorderRadius.circular(20.0)),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width,

                                    margin: EdgeInsets.fromLTRB(0, 8, 0, 10),
                                    child:
                                    YoutubePlayer(

                                      controller: _controller,
                                      showVideoProgressIndicator: true,


                                      onReady: () {

                                      },
                                    ),

                                  ),

                                  Text(
                                    list[0].audio_title.toString(),

                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: appColors().colorTextHead,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.bold),
                                  ),

                                  Text(
                                    list[0].audio_slug.toString(),
                                    textAlign: TextAlign.center,
                                    maxLines: 10,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: appColors().colorTextHead,
                                        fontFamily: 'Nunito'),
                                  ),
                                ]),
                          ),


                        ]))
                ),
              );
            }
          }
    );
  }
}
