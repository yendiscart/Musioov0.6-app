import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelPlayList.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';



class PlaylistMusicPresenter {
  late Dio _dio = Dio();

  Future<ModelPlayList> getPlayList(
     String token) async {
    Response<String> response = await _dio.get(
        AppConstant.BaseUrl + AppConstant.API_PLAYLIST,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));

    try {
      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());


        return ModelPlayList.fromJson(parsed);
      } else {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());
        return ModelPlayList.fromJson(parsed);
      }
    } catch (error, stacktrace) {

      Fluttertoast.showToast(
          msg: 'Something went wrong!! Restart app',
          toastLength:
          Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor:
          Colors.grey,
          textColor: appColors().colorBackground,
          fontSize: 14.0);
      return throw UnimplementedError();
    }
  }



  Future<void> createPlaylist(String id,String tag,String token) async {
    var formData ;
    formData = FormData.fromMap({
      AppConstant.playlist_name:tag,
    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_CREATE_PLAYLIST,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());

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
    } catch (error, stacktrace) {



    }
  }

  Future<void> addMusicPlaylist(String MusId,String PlayListId,String token) async {
    var formData ;
    formData = FormData.fromMap({

      AppConstant.music_id:MusId,
      AppConstant.playlist_id:PlayListId,



    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_ADD_PLAYLIST_MUSIC,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());

        Fluttertoast.showToast(
            msg: parsed['msg'],
            toastLength:
            Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor:
            Colors.grey,
            textColor: appColors().colorBackground,
            fontSize: 14.0);




      } else {



      }
    } catch (error, stacktrace) {



    }
  }

  Future<void> updatePlaylist(String playlistname,String PlayListId,String token) async {
    var formData ;
    formData = FormData.fromMap({

      AppConstant.playlist_name:playlistname,
      AppConstant.playlist_id:PlayListId,



    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_UPDATE_PLAYLIST_NAME,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());

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
    } catch (error, stacktrace) {
      Fluttertoast.showToast(
          msg: 'Something went wrong!! Restart app',
          toastLength:
          Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor:
          Colors.grey,
          textColor: appColors().colorBackground,
          fontSize: 14.0);


    }
  }

  Future<void> removeMusicFromPlaylist(String musicId,String PlayListId,String token) async {


    var formData ;
    formData = FormData.fromMap({


      AppConstant.playlist_id:PlayListId,
      AppConstant.music_id:musicId,



    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_REMOVE_PLAYLIST_MUSIC,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());

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
    } catch (error, stacktrace) {



    }
  }
  Future<void> removePlaylist(String PlayListId,String token) async {
    var formData ;
    formData = FormData.fromMap({


      AppConstant.playlist_id:PlayListId,



    });

    Response<String> response = await _dio.post(
        AppConstant.BaseUrl + AppConstant.API_DELETE_PLAYLIST,data: formData,

        options: Options(headers: {
          "Accept": "application/json",
          "authorization": "Bearer " + token
        }));


    try {
      if (response.statusCode == 200) {

        final Map<String,dynamic> parsed = json.decode(response.data.toString());

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
    } catch (error, stacktrace) {



    }
  }




}


