import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';
import 'package:musioo/UI/Login.dart';
import 'package:musioo/utils/circle_painter.dart';
import 'package:musioo/utils/curve_wave.dart';
import 'HomeDiscover.dart';

class SplashScreen extends StatefulWidget {
  final double size = 80.0;
  final Color color = Colors.pink;

  @override
  _RipplesAnimationState createState() {
    return _RipplesAnimationState();
  }
}

class _RipplesAnimationState extends State<SplashScreen>
    with TickerProviderStateMixin {

  SharedPref sharePrefs = SharedPref();
  late AnimationController _controller;
  bool loginPresent = false;

  value() async {
    loginPresent = await sharePrefs.check();
  }


  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () async {
      loginPresent = await sharePrefs.check();
      if (loginPresent) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => HomeDiscover()));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => Login()));
      }});
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[widget.color, Colors.pink],
            ),
          ),
          child: ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const CurveWave(),
                ),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 80,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/default_screen.jpg"),
              fit: BoxFit.cover),
        ),
        padding: EdgeInsets.all(6.0),
        child: ListView(
            children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, 58, 0, 0),
            child: CustomPaint(
              painter: CirclePainter(
                _controller,
                color: widget.color,
              ),
              child: SizedBox(
                width: widget.size * 4.125,
                height: widget.size * 4.125,
                child: _button(),
              ),
            ),
          ),
         Container(
           margin: EdgeInsets.fromLTRB(12, 65, 12, 10),
           alignment: Alignment.center,
           child: Text('Welcome To',
             style: TextStyle(
             fontFamily: 'Nunito',
             fontSize: 26,
             fontWeight: FontWeight.bold,
             color: appColors().colorTextHead),),),
      Container(
          alignment: Alignment.center,
          child:Text(AppConstant.appName  , style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: appColors().primaryColorApp),)
      )
        ]),
      ),
    ),
    );
  }
}
