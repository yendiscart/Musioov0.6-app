import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';

class FavMusicPresenter {
  late Dio _dio = Dio();

  Future<ModelMusicList> getFavMusicList(String token) async {
    var formData;
    formData = FormData.fromMap({
      AppConstant.type: "audio",
    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_GET_FAVOURITE_LIST,
        data: formData,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> parsed =
            json.decode(response.data.toString());

        return ModelMusicList.fromJson(parsed);
      } else {
        final Map<String, dynamic> parsed =
            json.decode(response.data.toString());
        return ModelMusicList.fromJson(parsed);
      }
    } catch (error, stacktrace) {
      return throw UnimplementedError();
    }
  }

  Future<void> getMusicAddRemove(String id, String token, String tag) async {
    var formData;
    formData = FormData.fromMap({
      AppConstant.id: id,
      AppConstant.type: "audio",
    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_ADD_FAVOURITE_LIST,
        data: formData,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));

    try {
      if (response.statusCode == 200) {
        final Map<String, dynamic> parsed =
            json.decode(response.data.toString());

        Fluttertoast.showToast(
            msg: parsed['msg'],
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: appColors().colorBackground,
            fontSize: 14.0);
      } else {
        final Map<String, dynamic> parsed =
            json.decode(response.data.toString());
      }
    } catch (error, stacktrace) {}
  }
}
