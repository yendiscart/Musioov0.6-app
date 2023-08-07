import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';



class DownloadPresenter {
  late Dio _dio = Dio();


  Future<ModelMusicList> getDownload(
     String token) async {
    Response<String> response = await _dio.get(
        AppConstant.BaseUrl + AppConstant.API_DOWNLOADED_MUSIC_LIST,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));

    try {
      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());


        return ModelMusicList.fromJson(parsed);
      } else {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());
        return ModelMusicList.fromJson(parsed);
      }
    } catch (error, stacktrace) {
      return throw UnimplementedError();
    }
  }




  Future<void> addRemoveFromDownload(String MusId,String token) async {
    var formData ;
    formData = FormData.fromMap({

      AppConstant.music_id:MusId,




    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_ADD_REMOVE_DOWNLOAD_MUSIC,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {


        final Map<String,dynamic> parsed = json.decode(response.data.toString());

        if(parsed['msg'].contain('Removed')){
          Fluttertoast.showToast(
              msg: parsed['msg'],
              toastLength:
              Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor:
              Colors.grey,
              textColor: appColors().colorBackground,
              fontSize: 14.0);
        }


      }
    } catch (error, stacktrace) {


    }
  }





}


