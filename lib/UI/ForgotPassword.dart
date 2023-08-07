import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Presenter/ForGotPassPresenter.dart';
import 'package:musioo/Resources/Strings/StringsLocalization.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/UI/Login.dart';

bool sendOtp=false;
String textEmail='';
class ForgotPassword extends StatefulWidget {
  ForgotPassword(bool bool, String text){
    sendOtp=bool;
    textEmail=text;

  }

  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<ForgotPassword> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController passConfirmController = TextEditingController();
  TextEditingController otpController = TextEditingController();

@override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: appColors().colorBackground,
      appBar: AppBar(
        title:  Text("Forgot Password",
            style: TextStyle(
                fontSize: 21,
                color: appColors().colorTextHead,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold)),
        backgroundColor: appColors().colorBackground,
        centerTitle: true,
        leading:  IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: appColors().colorTextHead,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 1,
      ),
      body: Container(
          margin: EdgeInsets.all(14),
          child: ListView(children: <Widget>[
            if(sendOtp)Image.asset('assets/images/email.png',height: 60,),
            Container(
              margin: EdgeInsets.all(12),
              child: Text(
                (!sendOtp) ?'Don\'t worry!! Just enter your registered email below..':'OTP has been sent to your email.. $textEmail',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 21,
                    color: appColors().colorText),
              ),
            ),
            (sendOtp) ? Container():Container(
              height: 57,
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              margin: EdgeInsets.fromLTRB(14, 22, 14, 6),
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
                  borderRadius: BorderRadius.circular(30.0)),
              child: new TextField(
                keyboardType: TextInputType.emailAddress,

                style: TextStyle(
                    color: appColors().colorText,
                    fontSize: 17.0,
                    fontFamily: 'Nunito'),
                controller: emailController,
                decoration: new InputDecoration(
                  counterText: "",
                  suffixIcon: Image.asset(
                    'assets/icons/email.png',
                    height: 10.0,
                    width: 10.0,
                  ),
                  suffixIconConstraints:
                      BoxConstraints(minHeight: 18, minWidth: 18),
                  hintText: Resources.of(context).strings.enterUserEmailHere,
                  hintStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 17.0,
                      color: appColors().colorHint),
                  border: InputBorder.none,
                ),
              ),
            ),
            (sendOtp) ? Container():Align( alignment: Alignment.center, child: Container(
                margin: EdgeInsets.fromLTRB(13, 10, 12, 12),
                width: 200,
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
                      Resources.of(context).strings.otp,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffffffff)),
                    ),
                    onPressed: () => {


if(emailController.text.isEmpty){
  Fluttertoast.showToast(
      msg: 'Please Enter Email To Continue..',
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: appColors()
          .colorBackground,
      fontSize: 14.0),
}else
  {
    if(!RegExp(
        r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(emailController.text)){
      Fluttertoast.showToast(
          msg: Resources
              .of(context)
              .strings
              .incorrectEmail,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: appColors()
              .colorBackground,
          fontSize: 14.0),
    } else
      {
        showGeneralDialog(
            barrierLabel: "Barrier",
            barrierDismissible: true,
            barrierColor:
            Colors.black.withOpacity(0.5),
            transitionDuration:
            Duration(milliseconds: 700),
            context: context,
            pageBuilder: (_, __, ___) {
              return FutureBuilder<String>(
                future: ForGotPassPresenter().getOtp(
                    context,
                    emailController.text,
                   ),
                builder: (context, projectSnap) {



                  if (projectSnap
                      .connectionState ==
                      ConnectionState.none) {
                    Fluttertoast.showToast(
                        msg: Resources.of(context)
                            .strings
                            .noConnection,
                        toastLength:
                        Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                        backgroundColor:
                        Colors.grey,
                        textColor:
                        appColors().colorBackground,
                        fontSize: 14.0);
                  }
                  if (projectSnap.hasData) {

                    String msg=projectSnap.data.toString();
                    sendOtp=true;

                    if(msg.contains("successfully")){

                    Fluttertoast.showToast(
                        msg: 'OTP has been sent on your email!!',
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: appColors()
                            .colorBackground,
                        fontSize: 14.0);
                return ForgotPassword(true,emailController.text);

                    }else{
                      Navigator.pop(context);
                      Fluttertoast.showToast(
                          msg: msg,
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: appColors()
                              .colorBackground,
                          fontSize: 14.0);
                    }








                  }
                  if (projectSnap.hasError) {
                    Fluttertoast.showToast(
                        msg: Resources.of(context)
                            .strings
                            .tryAgain,
                        toastLength:
                        Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                        backgroundColor:
                        Colors.grey,
                        textColor:
                        appColors().colorBackground,
                        fontSize: 14.0);

                    Navigator.pop(context);

                    return  Material();
                  }else{
                    return Material(
                        type: MaterialType
                            .transparency,
                        child: Container(
                            height: 100,
                            width: 200,
                            color:
                            Color(0x2dff0008),
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                              children: <Widget>[
                                SizedBox(
                                    child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            appColors()
                                                .primaryColorApp),
                                        backgroundColor:
                                        appColors()
                                            .colorHint,
                                        strokeWidth:
                                        4.0)),
                                Container(
                                    margin:
                                    EdgeInsets
                                        .all(6),
                                    child: Text(
                                      Resources.of(
                                          context)
                                          .strings
                                          .loadingPleaseWait,
                                      style: TextStyle(
                                          color: appColors()
                                              .colorTextHead,
                                          fontSize:
                                          18),
                                    )),
                              ],
                            )));} //Android loading Widget
                },
              );
            }),

      }
  }




                    }
                    ))),
            (sendOtp) ?Container(
              height: 57,
              padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
              margin: EdgeInsets.fromLTRB(14, 8, 14, 6),
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
                  borderRadius: BorderRadius.circular(30.0)),
              child:  TextField(
                obscureText: !_passwordVisible,
                maxLength: 20,

                style: TextStyle(

                    color: appColors().colorText,
                    fontSize: 17.0,
                    fontFamily: 'Nunito'),
                controller: passController,

                decoration: InputDecoration(
                  counterText: "",
                  suffixIcon: IconButton(
                      iconSize: 5.0,
                      padding: EdgeInsets.all(13.2),
                      icon: _passwordVisible
                          ? Image.asset('assets/icons/hide.png')
                          : Image.asset('assets/icons/eyeshow.png'),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        if (_passwordVisible) {
                          _passwordVisible = false;
                        } else {
                          _passwordVisible = true;
                        }
                        setState(() {
                          //  _passwordVisible = !_passwordVisible;
                        });
                      }),
                  suffixIconConstraints:
                      BoxConstraints(minHeight: 20, minWidth: 20),
                  hintText: Resources.of(context).strings.enterPassHere,
                  hintStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 17.0,
                      color: appColors().colorHint),
                  border: InputBorder.none,
                ),
              ),
            ):Container(),
            (sendOtp) ?Container(
              height: 57,
              padding: EdgeInsets.fromLTRB(20, 0, 9, 0),
              margin: EdgeInsets.fromLTRB(14, 8, 14, 8),
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
                  borderRadius: BorderRadius.circular(30.0)),
              child: TextField(
                maxLength: 20,
                obscureText: !_confirmPasswordVisible,
                controller: passConfirmController,
                style: TextStyle(
                    color: appColors().colorText,
                    fontSize: 17.0,
                    fontFamily: 'Nunito'),
                decoration: new InputDecoration(
                  counterText: "",
                  hintText: Resources.of(context).strings.confirmPass,
                  hintStyle: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 17.0,
                      color: appColors().colorHint),
                  suffixIcon: IconButton(
                      iconSize: 5.0,
                      padding: EdgeInsets.all(13.2),
                      icon: _confirmPasswordVisible
                          ? Image.asset('assets/icons/hide.png')
                          : Image.asset('assets/icons/eyeshow.png'),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        if (_confirmPasswordVisible) {
                          _confirmPasswordVisible = false;
                        } else {
                          _confirmPasswordVisible = true;
                        }
                        setState(() {
                          //  _passwordVisible = !_passwordVisible;
                        });
                      }),
                  suffixIconConstraints: BoxConstraints(
                      minHeight: 5,
                      minWidth: 5
                  ),
                  border: InputBorder.none,
                ),
              ),
            ):Container(),
            (sendOtp) ?Stack(
              children: [
                Container(


                  height: 55,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextField(
                    controller: otpController,
                    maxLength: 6,
textAlign: TextAlign.center,
                    style: TextStyle(

                        color: appColors().colorText,
                        fontSize: 17.0,
                        fontFamily: 'Nunito',
                        letterSpacing: 1.0),
                    decoration:  InputDecoration(

                      hintText: 'Enter OTP here',
                      counterText: "",
                      hintStyle: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17.0,

                          color: appColors().colorHint),
                      border: InputBorder.none,
                    ),
                  ),

                  margin: EdgeInsets.fromLTRB(12, 14, 12, 0),
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
                      borderRadius: BorderRadius.circular(30.0)),
                ),


              ],
            ):Container(),
            (sendOtp) ?Container(
                margin: EdgeInsets.fromLTRB(12, 25, 12, 0),
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
                      Resources.of(context).strings.resetMyPass,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffffffff)),
                    ),
                    onPressed: () => {
                      if (passController.text.isEmpty)
                        {
                          Fluttertoast.showToast(
                              msg: Resources.of(context).strings.enterPassContinue,
                              toastLength: Toast.LENGTH_SHORT,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor:
                              appColors().colorBackground,
                              fontSize: 14.0),
                        }else{
                        if (otpController.text.isEmpty)
                          {
                            Fluttertoast.showToast(
                                msg: 'Enter OTP to continue..',
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.grey,
                                textColor:
                                appColors().colorBackground,
                                fontSize: 14.0),
                          }else{
                    if (passConfirmController.text.isEmpty)
                    {
                    Fluttertoast.showToast(
                    msg: Resources.of(context).strings.enterPassContinue,
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey,
                    textColor:
                    appColors().colorBackground,
                    fontSize: 14.0),
                    }else
                      {

                        showGeneralDialog(
                            barrierLabel: "Barrier",
                            barrierDismissible: true,
                            barrierColor:
                            Colors.black.withOpacity(0.5),
                            transitionDuration:
                            Duration(milliseconds: 700),
                            context: context,
                            pageBuilder: (_, __, ___) {
                              return FutureBuilder<String>(
                                future: ForGotPassPresenter().getChangePass(
                                  context,
                                  textEmail,
                                  passController.text,
                                  passConfirmController.text,
                                  otpController.text,
                                ),
                                builder: (context, projectSnap) {

                                  if (projectSnap
                                      .connectionState ==
                                      ConnectionState.none) {
                                    Fluttertoast.showToast(
                                        msg: Resources.of(context)
                                            .strings
                                            .noConnection,
                                        toastLength:
                                        Toast.LENGTH_SHORT,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor:
                                        Colors.grey,
                                        textColor:
                                        appColors().colorBackground,
                                        fontSize: 14.0);
                                  }
                                  if (projectSnap.hasData) {

                                    String msg=projectSnap.data.toString();


                                    if(msg.contains("successfully")){
                                      sendOtp=true;
                                      Fluttertoast.showToast(
                                          msg: msg,
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey,
                                          textColor: appColors()
                                              .colorBackground,
                                          fontSize: 14.0);
                                      return Material(
                                          child: Login());

                                    }else{
                                      Navigator.pop(context);
                                      Fluttertoast.showToast(
                                          msg: msg,
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.grey,
                                          textColor: appColors()
                                              .colorBackground,
                                          fontSize: 14.0);
                                    }

return Container();






                                  }
                                  if (projectSnap.hasError) {
                                    Fluttertoast.showToast(
                                        msg: Resources.of(context)
                                            .strings
                                            .tryAgain,
                                        toastLength:
                                        Toast.LENGTH_SHORT,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor:
                                        Colors.grey,
                                        textColor:
                                        appColors().colorBackground,
                                        fontSize: 14.0);

                                    Navigator.pop(context);

                                    return  Material();
                                  }else{
                                    return Material(
                                        type: MaterialType
                                            .transparency,
                                        child: Container(
                                            height: 100,
                                            width: 200,
                                            color:
                                            Color(0x2dff0008),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                SizedBox(
                                                    child: CircularProgressIndicator(
                                                        valueColor: AlwaysStoppedAnimation(
                                                            appColors()
                                                                .primaryColorApp),
                                                        backgroundColor:
                                                        appColors()
                                                            .colorHint,
                                                        strokeWidth:
                                                        4.0)),
                                                Container(
                                                    margin:
                                                    EdgeInsets
                                                        .all(6),
                                                    child: Text(
                                                      Resources.of(
                                                          context)
                                                          .strings
                                                          .loadingPleaseWait,
                                                      style: TextStyle(
                                                          color: appColors()
                                                              .colorTextHead,
                                                          fontSize:
                                                          18),
                                                    )),
                                              ],
                                            )));} //Android loading Widget
                                },
                              );
                            }),



                      }
                        }

                      }
                    })):Container()
          ])),
    ));
  }
}
class ResetSuccess extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
        backgroundColor: appColors().colorBackground,
    body: Container(
      child: Stack(children: [
        Image.asset('assets/images/SuccessfullysetBackground.jpg'),
        Align(alignment: Alignment.bottomCenter
            ,child: Container(
                margin: EdgeInsets.fromLTRB(6, 0, 6, 230),child:Text(

          Resources.of(context).strings.resetMyPassSuccess,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.bold,

              color: appColors().colorText),))
        ),

      ],)
    )
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
