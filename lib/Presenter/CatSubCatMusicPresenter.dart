import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelCatSubcatMusic.dart';
import 'package:musioo/Model/ModelMusicList.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';



class CatSubcatMusicPresenter {
  late Dio _dio = Dio();

Future<String> getMusicCategory(String token,String type,int _pageNumber, int _numberOfPostsPerRequest) async {

    var formData ;
    formData = FormData.fromMap({
      "type":type,
      "page":_pageNumber,
      "limit":_numberOfPostsPerRequest
    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_GETMUSIC,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));

/*  Response<String> response = await _dio.get(
      "https://jsonplaceholder.typicode.com/posts?_page=$_pageNumber&_limit=$_numberOfPostsPerRequest");*/

  return response.toString();
}

  Future<ModelCatSubcatMusic> getCatSubCatMusicList(
     String token) async {


    Response<String> response = await _dio.get(
        AppConstant.BaseUrl + AppConstant.API_GET_MUSIC_CATEGORIES,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {
        final Map<String,dynamic> parsed = json.decode(response.data.toString());
        return ModelCatSubcatMusic.fromJson(parsed);
      } else {
        final Map<String,dynamic> parsed = json.decode(response.data.toString());
        return ModelCatSubcatMusic.fromJson(parsed);
      }
    } catch (error, stacktrace) {
      return throw UnimplementedError();
    }
  }

  Future<String> getMusicListBySearchNamePage(String search,String token,int _pageNumber, int _numberOfPostsPerRequest) async {

    var formData ;
    formData = FormData.fromMap({
      AppConstant.search:search,
          "page":_pageNumber,
      "limit":_numberOfPostsPerRequest
    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_GET_SEARCH_MUSIC,data: formData,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));

 //   Response<String> response = await _dio.get("https://jsonplaceholder.typicode.com/posts?_page=$_pageNumber&_limit=$_numberOfPostsPerRequest");

    return response.toString();

  }

  Future<ModelMusicList> getMusicListBySearchName(String search,String token) async {

    var formData ;
    formData = FormData.fromMap({
      AppConstant.search:search,
    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_GET_SEARCH_MUSIC,data: formData,
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

  Future<ModelMusicList> getMusicListByCategory(
      String id,String type,String token) async {

    var formData ;
    formData = FormData.fromMap({
      AppConstant.type:type,
      AppConstant.id:id,
    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_GET_GET_MUSIC_BY_CATEGORY,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));

    try {
      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());

        if(parsed['status'].toString().contains('false')){
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
        return ModelMusicList.fromJson(parsed);
      } else {
        final Map<String,dynamic> parsed = json.decode(response.data.toString());
        return ModelMusicList.fromJson(parsed);
      }
    } catch (error, stacktrace) {
      return throw UnimplementedError();
    }
  }


}


