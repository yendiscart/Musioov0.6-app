import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';




class HistoryPresenter {
  late Dio _dio = Dio();



  Future<String> getHistory(
     String token) async {

    Response<String> response = await _dio.get(
        AppConstant.BaseUrl + AppConstant.API_MUSIC_HISTORY,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {




        return response.data.toString();
      } else {


        return response.data.toString();
      }
    } catch (error, stacktrace) {


      return throw UnimplementedError();
    }
  }




  Future<void> addHistory(String MusId,String token, String tag) async {


    var formData ;
    formData = FormData.fromMap({

      AppConstant.music_id:MusId,
      AppConstant.tag:tag,




    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_ADD_REMOVE_MUSIC_HISTORY,data: formData,

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


