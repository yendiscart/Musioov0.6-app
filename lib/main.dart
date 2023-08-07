import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musioo/ThemeMain/AppSettings.dart';
import 'ThemeMain/appColors.dart';
import 'UI/Music.dart';
import 'UI/SplashScreen.dart';

AudioPlayerHandler? _audioHandler;
Future<void> main() async {
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );


  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
 static AudioPlayerHandler _audioHandlerr=_audioHandler!;
 AudioPlayerHandler called(){
 return _audioHandlerr;
  }

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: appColors().colorBackEditText,
        statusBarIconBrightness: Brightness.light));

    return MaterialApp(
      color: appColors().colorBackground,
      debugShowCheckedModeBanner: false,
      theme: AppSettings.define(),
      home: AudioServiceWidget( child :SplashScreen()),

    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}



