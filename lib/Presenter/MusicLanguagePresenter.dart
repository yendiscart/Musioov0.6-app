import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelMusicLanguage.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';



class MusicLanguagePresenter {
  late Dio _dio = Dio();



  Future<ModelMusicLanguage> getMusicLanguage(
      String token) async {


    Response<String> response = await _dio.get(
        AppConstant.BaseUrl + AppConstant.API_MUSIC_LANGUAGES,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));

print('>>>$response');
    try {
      if (response.statusCode == 200) {

        final Map parsed = json.decode(response.data.toString());

        print('$response');
        return ModelMusicLanguage.fromJson(parsed);
      } else {

        final Map parsed = json.decode(response.data.toString());
        return ModelMusicLanguage.fromJson(parsed);
      }
    } catch (error, stacktrace) {
      print('>>>     $error '+error.toString());
      return throw UnimplementedError();
    }
  }

  Future<void> setMusicLanguage(
      BuildContext context, String list,String token) async {
    var formData ;
    formData = FormData.fromMap({
      AppConstant.language_id:list,
    });

    Response<String> response = await _dio.post(AppConstant.BaseUrl+AppConstant.API_SET_MUSIC_LANGUAGES, data: formData,options: Options(headers: {
      "Accept":"application/json","authorization":"Bearer "+token
    }));


    final Map parsed = json.decode(response.data.toString());
    Fluttertoast.showToast(
        msg: parsed['msg'],
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: appColors().colorBackground,
        fontSize: 14.0);
  }
}


