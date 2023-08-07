import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:musioo/Model/ModelAllCat.dart';
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

import 'MusicList.dart';

String  typ = '';
AudioPlayerHandler? _audioHandler;
class AllCategoryByName extends StatefulWidget {
  AllCategoryByName(AudioPlayerHandler? audioHandler, String type,
      ) {

    typ = type;

  }



  @override
  _AllCategoryByNameState createState() => _AllCategoryByNameState();
}
class _AllCategoryByNameState extends State<AllCategoryByName> {
  late bool _isLastPage;
  late int _pageNumber;
  late bool _error;
  late bool _loading=true, noData=false;
  final int _numberOfPostsPerRequest = 15;
  late List<SubData> _posts=[];
  final int _nextPageTrigger = 3;
  SharedPref sharePrefs = SharedPref();
  final WeSlideController _controller = WeSlideController();
  double _panelMinSize = 0.0;
  String token="",path="";


  Future<void> getCate() async {
    token = await sharePrefs.getToken();
    _pageNumber = 1;
    _posts = [];
    _isLastPage = false;
    _loading = true;
    _error = false;
    fetchData();

  }

  @override
  void initState() {
    super.initState();
    _audioHandler = MyApp().called();
  getCate();
  }

  Future<void> _pullRefresh() async {
    if(_pageNumber != 1) {
      _pageNumber = 1;
      _posts = [];
      _isLastPage = false;
      _loading = true;
      _error = false;
      noData=false;
      fetchData();
    }
  }

  Future<void> fetchData() async {
    token = await sharePrefs.getToken();
    try {

final response = await CatSubcatMusicPresenter().getMusicCategory(token,typ, _pageNumber, _numberOfPostsPerRequest);

Map<String,dynamic> parsed =  json.decode(response.toString());
ModelAllCat allCat=ModelAllCat.fromJson(parsed);
path=allCat.imagePath;
      List<SubData> postList = allCat.sub_category;

if(postList.length != 0) {
  setState(() {
    _isLastPage = postList.length < _numberOfPostsPerRequest;
    _loading = false;
    _pageNumber = _pageNumber + 1;
    _posts.addAll(postList);
  });
}else{
noData=true;
if(_loading){
  _loading = false;
}

setState(() {

});
}

    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  void _reload() {
    setState(() {});
  }

  Widget errorDialog({required double size}){
    return SizedBox(
      height: 180,
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('An error occurred when fetching the posts.',
            style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w500,
                color:  appColors().colorTextHead
            ),
          ),
          const SizedBox(height: 10,),
          TextButton(
              onPressed:  ()  {
                setState(() {
                  _loading = true;
                  _error = false;
                  fetchData();
                });
              },
              child: Text("Retry", style: TextStyle(fontSize: 20, color:  appColors().PrimaryDarkColorApp),)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double _panelMaxSize = MediaQuery.of(context).size.height-30;
    return SafeArea(
        child:
        Scaffold(
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
    ),child:
    Stack(children: [
      Container(
        margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
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
          margin: EdgeInsets.all(5),
          alignment: Alignment.center,
          height: 45,
          child: Text(
            "" + typ,
            style: TextStyle(
              color: Color(
                int.parse(AppSettings.colorText),
              ),
              fontFamily: 'Nunito-Bold',
              fontSize: 18.0,
            ),
          )),
        Container(
          margin: EdgeInsets.fromLTRB(0, 54, 0, 0),child:  buildPostsView()
        )
    ],),
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

  Widget buildPostsView() {
    if (_posts.isEmpty) {
      if (_loading){
        return const Center(
            child: Padding(
              padding: EdgeInsets.all(9),
              child: CircularProgressIndicator(),
            ));
      } else if (_error) {
        return Center(
            child: errorDialog(size: 20)
        );
      }
    }
      return Container(
          padding:  EdgeInsets.fromLTRB(2, 2, 2, 55),
          child:RefreshIndicator(
          onRefresh: _pullRefresh,
          child:GridView.builder(
              scrollDirection: Axis.vertical,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 9.0,
                  mainAxisSpacing: 5.0),

          itemCount: _posts.length + (_isLastPage ? 0 : 1),

          itemBuilder: (context, index) {
        // request more data when the user has reached the trigger point.
            if (index == _posts.length - _nextPageTrigger) {
              if(!noData){
              fetchData();}
            }
            // when the user gets to the last item in the list, check whether
            // there is an error, otherwise, render a progress indicator.
            if (index == _posts.length) {
              if (_error) {
                return Center(
                    child: errorDialog(size: 15)
                );
              } else {
                return (!noData)?const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child:    CircularProgressIndicator(),
                    )
                ):Container();
              }
            }

            final SubData post = _posts[index];
            return  Column(
              // align the text to the left instead of centered
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkResponse(child:
                Container(
                  decoration:
                  BoxDecoration(
                    color: Colors.grey,
                    borderRadius:
                    BorderRadiusDirectional.circular(8.0),
                    image: DecorationImage(
                      image:post.image.isEmpty?
                      AssetImage(
                          'assets/images/placeholder2.jpg') :NetworkImage(AppConstant.ImageUrl +
                    path +
                    post.image
                      ,) as ImageProvider,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  width: 110,
                  height: 96,
                  margin: EdgeInsets.all(4.8),
                ),
                  onTap: () {
    if(typ.contains("Albums") || typ.contains("Artists") || typ.contains("Genres")){

    Navigator.push(context,
    new MaterialPageRoute(builder: (context) =>
    MusicList(_audioHandler, "" + post.id.toString(),typ, post.name)),
    ).then((value) {
    debugPrint(value);
    _reload();});

    }else{

    Navigator.push(context,
    new MaterialPageRoute(
    builder: (context) => Music(
    _audioHandler,
    "" +
    post.id.toString(), typ, [], "", 0, false, '')),
    ).then((value) {
    debugPrint(value);
    _reload();
    });
    }

    },),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 1),
                  child: Text(post.name,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: (sharedPreThemeData
                            .themeImageBack
                            .isEmpty)
                            ? Color(int.parse(AppSettings
                            .colorText))
                            : Color(
                            int.parse(sharedPreThemeData.themeColorFont))),
                  ),
                  width: 127,
                ),
              ],
            );
          })
          )
      );
    }


}

