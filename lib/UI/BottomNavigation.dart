import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/SlideRightRoute.dart';
import 'package:rxdart/rxdart.dart';
import 'Music.dart';

AudioPlayerHandler? _audioHandler;
int indexNum=0;
  class BottomNavigation {
  static  String musicName='',musicImage='',artistName='';
  static double  main_posi=0.0,maxi=0.0;

  BottomNavigation(AudioPlayerHandler? audioHandler) {
    _audioHandler = audioHandler;
  }


  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          _audioHandler!.mediaItem,
          AudioService.position,
              (mediaItem, position) => MediaState(mediaItem, position));

  void _listenToPlaybackState() {

    _audioHandler!.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
      } else if (!isPlaying) {

      } else if (processingState == AudioProcessingState.completed) {

       ValueStream<List<MediaItem>> mList=  _audioHandler!.queue;

        if(mList.value.length > 1){
          if(indexNum < mList.value.length){
          indexNum++;
          }else{
            indexNum--;
          }


          _audioHandler!.play();
        }


      }
    });
  }
  Widget getNaviagtion(BuildContext context) {
_listenToPlaybackState();
    double valueHolder = 0.0;
    return StatefulBuilder(builder: (context, newState) {

      return Container(
        color: appColors().colorBackground,
        padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
        height: 62,
        child: Stack(
          children: [


                  StreamBuilder<MediaState>(
                      stream: _mediaStateStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final mediaState = snapshot.data;

                          var duration =
                              mediaState!.mediaItem!.duration ?? Duration.zero;
                          var position = mediaState.position ;
                          if(duration.inMilliseconds.toDouble() >= position.inMilliseconds.toDouble() ){
                          maxi = duration.inMilliseconds.toDouble();
                          valueHolder = position.inMilliseconds.toDouble();
                          }
                          musicName=mediaState.mediaItem!.title;
                          artistName=mediaState.mediaItem!.artist!;
                          musicImage=mediaState.mediaItem!.artUri.toString();
                          main_posi=position.inMilliseconds.toDouble();
                          return  Stack(
                              children: [
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                        child: Container(
                                          alignment: Alignment.topLeft,
                                          height: 3.6,
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                                thumbColor: Colors.green,
                                                trackHeight: 2.5,
                                                thumbShape:
                                                RoundSliderThumbShape(enabledThumbRadius: 4)),
                                            child: Slider(
                                              min: 0.0,
                                              max: maxi,
                                              value: valueHolder,
                                              activeColor: Color(0xfffb314f),
                                              inactiveColor: Color(0xffa7a7ac),
                                              onChanged: (double newValue) {
                                                valueHolder = newValue.round().toDouble();

                                                newState(() {
                                                  _audioHandler!.seek(
                                                      Duration(milliseconds: valueHolder.toInt()));
                                                });
                                              },
                                            ),
                                          )
                                        ))),
                          Container(
                             margin: EdgeInsets.fromLTRB(0, 7.5, 0, 0),
                             child:    Row(
                               children: [
                                 InkResponse(
                                   onTap: () {
                                     Navigator.push(context, SlideRightRoute(page: Music(_audioHandler,"","",[],"fromBottom",0,false,'')));

                                   },
                                   child: Container(
                                     decoration: BoxDecoration(
                                       borderRadius:
                                       BorderRadiusDirectional.circular(4.0),
                                       image: DecorationImage(
                                         image: (mediaState.mediaItem!.artUri.toString()
                                             .isEmpty || mediaState.mediaItem!.artUri.toString().contains("file://"))
                                             ? AssetImage(
                                             'assets/images/placeholder2.jpg')  as ImageProvider
                                             : NetworkImage(mediaState
                                             .mediaItem!.artUri
                                             .toString()),
                                         fit: BoxFit.fitWidth,
                                         alignment: Alignment.topCenter,
                                       ),
                                     ),
                                     width: 55,
                                     height: 51,
                                     margin: EdgeInsets.fromLTRB(21, 2, 0, 2),
                                   ),
                                 ),
                                 InkResponse(
                                   onTap: () {
                                     Navigator.push(context, SlideRightRoute(page: Music(_audioHandler,"","",[],"fromBottom",0,false,'')));
                                   },
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.start,
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Container(
                                         width: 185,
                                         alignment: Alignment.centerLeft,
                                         margin: EdgeInsets.fromLTRB(9, 4, 1, 0),

                                         child: Text(
                                           '' +
                                               mediaState.mediaItem!.title
                                                   .toString(),
                                           overflow: TextOverflow.ellipsis,
                                           textAlign: TextAlign.left,
                                           style: TextStyle(
                                               fontSize: 16,
                                               color: appColors().colorTextHead,
                                               fontFamily: 'Nunito-Bold'),
                                         ),
                                       ),
                                       Container(

                                         alignment: Alignment.centerLeft,
                                         margin: EdgeInsets.fromLTRB(9, 0, 15, 0),
                                         child: Text(
                                           '' +
                                               mediaState.mediaItem!.artist
                                                   .toString(),
                                           textAlign: TextAlign.left,
                                           style: TextStyle(
                                               fontSize: 14,
                                               color: appColors().colorText,
                                               fontFamily: 'Nunito'),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ]) ,)


                              ]
                          );
                        } else {
                          return Stack(
                              children: [

                                Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                        child: Container(


                                            alignment: Alignment.topLeft,
                                            height: 3.6,
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                  thumbColor: Colors.green,
                                                  trackHeight: 2.5,
                                                  thumbShape:
                                                  RoundSliderThumbShape(enabledThumbRadius: 4)),
                                              child: Slider(
                                                min: 0.0,
                                                max: maxi,
                                                value: main_posi,
                                                activeColor: Color(0xfffb314f),

                                                inactiveColor: Color(0xffa7a7ac),
                                                onChanged: (double newValue) {

                                                  main_posi = newValue.round().toDouble();

                                                  newState(() {
                                                    _audioHandler!.seek(
                                                        Duration(milliseconds: main_posi.toInt()));
                                                  });
                                                },
                                              ),
                                            )
                                        ))),
                               Container(
                                 margin: EdgeInsets.fromLTRB(0, 7, 0, 0),
                                 child:  Row(
                                   children: [
                                     InkResponse(
                                       onTap: () {
                                         Navigator.push(context, SlideRightRoute(page: Music(_audioHandler,"","",[],"fromBottom",0,false,'')));
                                       },
                                       child: Container(
                                         decoration: BoxDecoration(
                                           borderRadius:
                                           BorderRadiusDirectional.circular(4.0),
                                           image: DecorationImage(
                                             image: (musicImage.contains("file://"))?AssetImage(
                                                 'assets/images/placeholder2.jpg'):(!musicImage.isEmpty)?NetworkImage(musicImage) as ImageProvider
                                                 :AssetImage(
                                                 'assets/images/placeholder2.jpg'),
                                             fit: BoxFit.fitWidth,
                                             alignment: Alignment.topCenter,
                                           ),
                                         ),
                                         width: 55,
                                         height: 48,
                                         margin: EdgeInsets.fromLTRB(21, 5, 0, 2),
                                       ),
                                     ),
                                     InkResponse(
                                       onTap: () {
                                         Navigator.push(context, SlideRightRoute(page: Music(_audioHandler,"","",[],"fromBottom",0,false,'')));
                                       },
                                       child: Column(
                                         mainAxisAlignment: MainAxisAlignment.start,
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Container(
                                             width: 190,
                                             alignment: Alignment.centerLeft,
                                             margin: EdgeInsets.fromLTRB(9, 5, 0, 0),
                                             child: Text(
                                               '' +
                                                   musicName
                                                       .toString(),
                                               overflow: TextOverflow.ellipsis,
                                               textAlign: TextAlign.left,
                                               style: TextStyle(
                                                   fontSize: 16,
                                                   color: appColors().colorTextHead,
                                                   fontFamily: 'Nunito-Bold'),
                                             ),
                                           ),
                                           Container(
                                             alignment: Alignment.centerLeft,
                                             margin: EdgeInsets.fromLTRB(9, 0, 0, 0),
                                             child: Text(
                                               '' +artistName
                                                   .toString(),
                                               textAlign: TextAlign.left,
                                               style: TextStyle(
                                                   fontSize: 14,
                                                   color: appColors().colorText,
                                                   fontFamily: 'Nunito'),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                   ]),)


                              ]
                          );
                        }
                      }),
                  Container(
                    width: 600,
                    margin: EdgeInsets.fromLTRB(0, 4.2, 0, 0),
                    alignment: Alignment.bottomRight,child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [ StreamBuilder<bool>(
                      stream: _audioHandler!.playbackState
                          .map((state) => state.playing)
                          .distinct(),

                      builder: (context, snapshot) {
                        final playingServ = snapshot.data ?? false;
                        return Container(
                          height: 41,
                          width: 41,

                          margin: EdgeInsets.fromLTRB(1, 7, 2, 6),
                          padding: EdgeInsets.all(8),
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
                          child: InkResponse(
                              onTap: () {

                                if (playingServ) {
                                  _audioHandler!.pause();
                                } else {
                                  _audioHandler!.play();
                                }
                                newState(() {});
                              },
                              child: playingServ
                                  ? Icon(
                                Icons.pause,
                                color: appColors().white,
                                size: 26,
                              )
                                  : Container(
                                padding: EdgeInsets.all(5),
                                height: 25,
                                child: Image.asset(
                                  'assets/icons/play.png',
                                ),
                              )),
                        );
                      }),

                    InkResponse(
                      hoverColor: Color(0xffec5050),
                      highlightColor: Color(0xffec5050),
                      splashColor:Color(0xffec5050) ,
                      child:     Container(
                        height: 41,
                        width: 41,
                        margin: EdgeInsets.fromLTRB(5, 7, 17, 6),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                appColors().colorHint,
                                appColors().colorHint
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(35.0)),
                        child: Image.asset(
                          'assets/icons/forword.png',
                          width: 10,
                        ),
                      ),
                      onTap: () {
                        _audioHandler!.skipToNext();
                      },
                    )
                  ],),)

      ])
      );
    });
  }




}
class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}
