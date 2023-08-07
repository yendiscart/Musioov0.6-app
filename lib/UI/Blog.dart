import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:musioo/Model/BlogModel.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/BlogPresenter.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:webview_flutter/webview_flutter.dart';




class Blog extends StatefulWidget {
 

  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

class MyState extends State<Blog> {
  String token='';
  SharedPref sharePrefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;
  late BlogModel _blogModel;



  Future<dynamic> value() async {
    model = await sharePrefs.getUserData();
    sharedPreThemeData = await sharePrefs.getThemeData();
    setState(() {});
    return model;
  }



  Future<void> getSettings() async {
    token = await sharePrefs.getToken();
    String? sett = await sharePrefs.getSettings();
    final Map<String, dynamic> parsed = json.decode(sett!);
    ModelSettings modelSettings = ModelSettings.fromJson(parsed);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getSettings();
    WebView.platform = SurfaceAndroidWebView();
    value();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
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
        alignment: Alignment.topCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 12, 0, 0),
              height: 45,
              child: Text("All blogs",
                  style: TextStyle(
                      fontSize: 20,
                      color: (sharedPreThemeData.themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(int.parse(sharedPreThemeData.themeColorFont)),
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: EdgeInsets.all(3),
              child: IconButton(
                alignment: Alignment.topLeft,
                icon:  Icon(
                  Icons.arrow_back_ios_outlined,
                  color: (sharedPreThemeData.themeImageBack.isEmpty)
                      ? Color(int.parse(AppSettings.colorText))
                      : Color(int.parse(sharedPreThemeData.themeColorFont)),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16, 50, 16, 9),
            child:FutureBuilder<String>(
    future:BlogPresenter().getBlog(token),
    builder:
    (context,AsyncSnapshot projectSnap) {
    if(projectSnap.hasData) {
      final Map<dynamic, dynamic> parsed = json.decode(projectSnap.data.toString());
    _blogModel=  BlogModel.fromJson(parsed);
      return ListView.builder(
          itemCount: _blogModel.data.blogs.length,
          itemBuilder: (context, index) {
            return
              Column(children: [
                SizedBox(height: 20,),
                Stack(
                  alignment: Alignment.topLeft,children: [
                  CircleAvatar(
                    radius: 29.0,
                    backgroundColor: Color(0xfffcf7f8),
                    backgroundImage: _blogModel.data.blogs[index].image.isEmpty ? AssetImage('assets/icons/user2.png'):NetworkImage(AppConstant.ImageUrl+"images/blogs/"+_blogModel.data.blogs[index].image) as ImageProvider,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(65, 4, 0, 2), child: Text(
                      _blogModel.data.blogs[index].blog_cat_name,
                      style: TextStyle(fontSize: 20, color: (sharedPreThemeData
                          .themeImageBack.isEmpty)
                          ? Color(int.parse(AppSettings.colorText))
                          : Color(int.parse(sharedPreThemeData.themeColorFont)),
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold)
                  ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(65, 29, 0, 2), child: Text(
                      _blogModel.data.blogs[index].created_at.split("T").first,
                      style: TextStyle(fontSize: 12, color:
                           appColors().colorHint,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold)
                  ),
                  ),
                ],),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 2), child: Text(
                    _blogModel.data.blogs[index].title,
                    style: TextStyle(fontSize: 18, color: (sharedPreThemeData
                        .themeImageBack.isEmpty)
                        ? Color(int.parse(AppSettings.colorText))
                        : Color(int.parse(sharedPreThemeData.themeColorFont)),
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold)
                ),
                ),
                HtmlWidget(
                  _blogModel.data.blogs[index].detail,
                  textStyle: TextStyle(color: appColors().colorText, fontSize: 16),
                ),
                SizedBox(height: 29,),
              ],);
          }


      );
    }else{
      return Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
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
              margin: EdgeInsets.all(6),
              child: Text(
                Resources.of(context)
                    .strings
                    .loadingPleaseWait,
                style: TextStyle(
                    color: appColors().colorTextHead,
                    fontSize: 18),
              )),
        ],

      );
    }

    }
            ))
        ],
      ),
    )));
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