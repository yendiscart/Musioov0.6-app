import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:musioo/Model/ModelSettings.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/Model/UserModel.dart';
import 'package:musioo/Presenter/Logout.dart';
import 'package:musioo/Presenter/ProfilePresenter.dart';
import 'package:musioo/utils/AdHelper.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'Login.dart';

class ProfileEdit extends StatefulWidget {
  @override
  myState createState() {
    return myState();
  }
}

class myState extends State {
  bool _passwordVisible = false;
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final picker = ImagePicker();
  bool has = false,presentImage=true;
  late File _image;
  SharedPref sharePrefs = SharedPref();
  late ModelTheme sharedPreThemeData = new ModelTheme('', '', '', '', '', '');
  late UserModel model;
  String gender = " Select  ", dateOfBirth = '';
  String imagePresent='';
  String token='';
  bool allowDown=false,allowAds=true;
  bool isOpen = false;


  Future<dynamic> value() async {
    model = await sharePrefs.getUserData();
    token=await sharePrefs.getToken();
    getSettings();


    if(model.data.gender.toString().contains('0')){
      gender="Male";
    }else{
      gender='Female';
      //0 = male , 1= female
    }
    setState(() {});



    return model;
  }

  InterstitialAd? _interstitialAd;


  bool _isInterstitialAdReady = false;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          this._interstitialAd = ad;
          _interstitialAd?.show();

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              //  _moveToHome();
            },
          );

          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {

          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  @override
  void initState() {


    value();
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);
    dateOfBirth = formatted;
    super.initState();
  }

  Future<void> getSettings() async {
    String? sett = await sharePrefs.getSettings() ;

    final Map<String, dynamic> parsed = json.decode(sett!);
    ModelSettings modelSettings = ModelSettings.fromJson(parsed);
    if(modelSettings.data.image.isNotEmpty){
      imagePresent=AppConstant.ImageUrl+modelSettings.data.image;
      presentImage=false;}

    nameController.text=modelSettings.data.name;
    mobileController.text=modelSettings.data.mobile;
    nameController.text=modelSettings.data.name;

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

    if(allowAds){
        _loadInterstitialAd();
    }
    setState(() {
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  void showPickDialog(BuildContext context) {

    _imgFromCamera() async {
      final pickedFile = await picker.getImage(source: ImageSource.camera, imageQuality: 100);

      final File file = File(pickedFile!.path);

      has = true;
      _image = file;
      ProfilePresenter().getProfileUpdate(context, _image, '', '', '','','', token);
      Navigator.of(context).pop();
      setState(() {});
    }

    _openGallery() async {
      final pickedFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 100);
      final File file = File(pickedFile!.path);

      has = true;
      _image = file;
      ProfilePresenter().getProfileUpdate(context, _image, '', '', '','','', token);
      Navigator.of(context).pop();
      setState(() {});
    }

    Future<void> future = showModalBottomSheet(
        barrierColor: Color(0xeae5e5),
        context: context,
        backgroundColor: appColors().colorBackEditText,
        builder: (ctx) {
          return Container(
            padding: EdgeInsets.all(6),
              height: MediaQuery.of(context).size.height * 0.29,
              alignment: Alignment.center,
              child: Center(
child: Column(
  crossAxisAlignment: CrossAxisAlignment.center,children: [
    Container(
      padding: EdgeInsets.all(6),
      margin: EdgeInsets.all(7),
      child:  Text('From where would you like to \ntake the image ?',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: (Platform.isAndroid)?18:20,
            color: appColors().colorTextSideDrawer)),)
 ,
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Column(children: [

        GestureDetector(
          onTap: () {
_imgFromCamera();
          },
          child: CircleAvatar(
              backgroundColor: Color(0xff161826),

              child: Container(
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/Camera.png',

                ),
              )),
        ),
        Text('Camera',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: (Platform.isAndroid)?13:18,
                color: appColors().colorText)
        ),],),   Column(children: [GestureDetector(
        onTap: () {
          _openGallery();
        },
        child: CircleAvatar(
            backgroundColor: Color(0xff161826),

            child: Container(
              padding: EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/Gallery.png',

              ),
            )),
      ),
        Text('Gallery',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: (Platform.isAndroid)?13:18,
                color: appColors().colorText)),],),
      Column(children: [GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: CircleAvatar(
            backgroundColor: Color(0xff161826),

            child: Container(
              padding: EdgeInsets.all(13),
              child: Image.asset(
                'assets/images/Cancel.png',

              ),
            )),
      ),
        Text('Cancel',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: (Platform.isAndroid)?13:18,
                color: appColors().colorText)),],)

    ],
  )

],),
              )
          );
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



  void showDialogForLogout(BuildContext context) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            width: 255,
            height: 135,
            child: SizedBox.expand(
                child: Column(
              children: [
                Material(
                  type: MaterialType.transparency,
                  child: Text(Resources.of(context).strings.doYouWantToLogout,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 19.0,
                          color: appColors().colorTextSideDrawer)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {

                            Logout().logout(context, token);
                            sharePrefs.removeValues();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (BuildContext context) => Login()),
                                (Route<dynamic> route) => false);
                          },
                          child: Container(
                              margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
                              padding: EdgeInsets.fromLTRB(22, 7, 22, 7),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      appColors().PrimaryDarkColorApp,
                                      appColors().PrimaryDarkColorApp,
                                      appColors().primaryColorApp
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Text(
                                Resources.of(context).strings.yes,
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14.0,
                                    color: appColors().white),
                              )),
                        )),
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                margin: EdgeInsets.fromLTRB(2, 2, 2, 2),
                                padding: EdgeInsets.fromLTRB(22, 7, 22, 7),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        appColors().PrimaryDarkColorApp,
                                        appColors().PrimaryDarkColorApp,
                                        appColors().primaryColorApp
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Text(
                                  Resources.of(context).strings.no,
                                  style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14.0,
                                      color: appColors().white),
                                ))))
                  ],
                )
              ],
            )),
            margin: EdgeInsets.only(bottom: 1, left: 22, right: 22),
            padding: EdgeInsets.fromLTRB(22, 12, 22, 12),
            decoration: BoxDecoration(
                color: appColors().colorBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: appColors().colorHint)),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                padding: EdgeInsets.fromLTRB(6, 9, 9, 6),
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
                    Stack(children: <Widget>[
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(6, 6, 6, 6),
                          child: Text(
                            Resources.of(context).strings.editProfile,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: (sharedPreThemeData
                                        .themeImageBack.isEmpty)
                                    ? Color(int.parse(AppSettings.colorText))
                                    : Color(int.parse(
                                        sharedPreThemeData.themeColorFont))),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            padding: EdgeInsets.all(12),
                            child: InkResponse(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                'assets/icons/backarrow.png',
                                width: 20,
                                height: 20,
                                color: (sharedPreThemeData
                                        .themeImageBack.isEmpty)
                                    ? Color(int.parse(AppSettings.colorText))
                                    : Color(int.parse(
                                        sharedPreThemeData.themeColorFont)),
                              ),
                            )),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.all(4),
                            decoration: new BoxDecoration(
                                border: Border.all(color: Color(0xc94f5055)),
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xff1c1f2e),
                                    appColors().colorBackEditText
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(2.8)),
                            child: InkResponse(
                              onTap: () {
                                showDialogForLogout(context);
                              },
                              child: Image.asset(
                                'assets/icons/logout.png',
                                width: 16,
                                height: 16,
                              ),
                            )),
                      ),
                    ]),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        alignment: Alignment.center,
                        height: 200,
                        width: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 180,
                                  margin: EdgeInsets.fromLTRB(15, 25, 15, 0),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: appColors().colorBackEditText,
                                    border:
                                        Border.all(color: Color(0xa64f5055)),
                                  ),
                                  child: Container(
                                    width: 200,
                                    alignment: Alignment.center,
                                    child: InkResponse(
                                      onTap: () {

                                      },
                                      child: CircleAvatar(
                                        radius: 72.0,
                                        backgroundColor: Color(0xfffcf7f8),
                                        backgroundImage: has
                                            ? Image.file(
                                                _image,
                                                fit: BoxFit.cover,
                                              ).image
                                            : (presentImage)?AssetImage(
                                                'assets/icons/user2.png'):NetworkImage(imagePresent) as ImageProvider,
                                      ),
                                    ),
                                  ),
                                )),
                            Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 40, 14),
                                  child: GestureDetector(
                                    onTap: () {

                                      showPickDialog(context);
                                    },
                                    child: CircleAvatar(
                                        backgroundColor: appColors().red,
                                        radius: 15.0,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          child: Image.asset(
                                            'assets/icons/edit.png',
                                            color: appColors().white,
                                          ),
                                        )),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 55,
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      margin: EdgeInsets.fromLTRB(22, 26, 22, 6),
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              appColors().colorBackEditText,
                              appColors().colorBackEditText
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                              width: 0.5, color: appColors().colorBorder)),
                      child: new TextField(
                        style: TextStyle(
                            color: appColors().colorText,
                            fontSize: 17.0,
                            fontFamily: 'Nunito'),
                        controller: nameController,
                        decoration: new InputDecoration(
                          suffixIcon: Image.asset(
                            'assets/icons/person.png',
                            height: 10.0,
                            width: 10.0,
                          ),
                          suffixIconConstraints:
                              BoxConstraints(minHeight: 18, minWidth: 18),
                          hintText: Resources.of(context).strings.enterNameHere,

                          hintStyle: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17.0,

                              color: appColors().colorHint),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 57,
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      margin: EdgeInsets.fromLTRB(22, 10, 22, 6),
                      alignment: Alignment.center,
                      decoration: new BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              appColors().colorBackEditText,
                              appColors().colorBackEditText
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                              width: 0.5, color: appColors().colorBorder)),
                      child: new TextField(
                        maxLength: 20,
                        keyboardType: TextInputType.numberWithOptions(),
                        style: TextStyle(
                            color: appColors().colorText,
                            fontSize: 17.0,
                            fontFamily: 'Nunito'),
                        controller: mobileController,
                        decoration: new InputDecoration(
                          counterText: "",
                          suffixIcon: Image.asset(
                            'assets/icons/mobile.png',
                            height: 10.0,
                            width: 10.0,
                          ),
                          suffixIconConstraints:
                              BoxConstraints(minHeight: 18, minWidth: 18),
                          hintText:
                              Resources.of(context).strings.enterMobileHere,
                          hintStyle: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17.0,
                              color: appColors().colorHint),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 55,
                      padding: EdgeInsets.fromLTRB(20, 0, 8, 0),
                      margin: EdgeInsets.fromLTRB(22, 10, 22, 6),
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
                          border: Border.all(
                              width: 0.5, color: appColors().colorBorder)),
                      child:  TextField(
                        obscureText: !_passwordVisible,
                        controller: passwordController,
                        style: TextStyle(
                            color: appColors().colorText,
                            fontSize: 17.0,
                            fontFamily: 'Nunito'),
                        decoration: InputDecoration(
                          hintText: Resources.of(context).strings.enterPassHere,
                          hintStyle: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17.0,
                              color: appColors().colorHint),
                          suffixIcon: IconButton(
                              padding: EdgeInsets.all(13),
                              icon: _passwordVisible
                                  ? Image.asset('assets/icons/hide.png')
                                  : Image.asset('assets/icons/eyeshow.png'),
                              onPressed: () {

                                if (_passwordVisible) {
                                  _passwordVisible = false;
                                } else {
                                  _passwordVisible = true;
                                }
                                setState(() {

                                });
                              }),
                          suffixIconConstraints:
                              BoxConstraints(minHeight: 18, minWidth: 8),
                          border: InputBorder.none,
                        ),
                      ),
                    ),


                    Container(
                        margin: EdgeInsets.fromLTRB(19, 14, 19, 0),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                appColors().PrimaryDarkColorApp,
                                appColors().primaryColorApp
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30.0)),
                        child: TextButton(
                            child: Text(
                              Resources.of(context).strings.update,
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffffffff)),
                            ),
                            onPressed: () => {
                            ProfilePresenter().getProfileUpdate(context, new File(''),
                                nameController.text, passwordController.text, mobileController.text,dateOfBirth,gender, token)
                                }))
                  ],
                ))));
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
