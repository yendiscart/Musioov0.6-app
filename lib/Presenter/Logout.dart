import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';

class Logout
{
  late Dio _dio = Dio();

  SharedPref sharePrefs = SharedPref();
  Future<void> logout(
      BuildContext context, String token) async {


  await _dio.post(AppConstant.BaseUrl+AppConstant.API_logout, options: Options(headers: {
      "Accept":"application/json","authorization":"Bearer "+token
    }));



  }
  Future<int> deleteApi(
      BuildContext context, String token,int userid) async {

    var formData ;
    formData = FormData.fromMap({
     "user_id":userid,

    });
    try {

      Response<String> response = await _dio.post(
          AppConstant.BaseUrl + AppConstant.API_delete, data: formData,
          options: Options(headers: {
            "Accept": "application/json", "authorization": "Bearer " + token
          }));


      return 1;
    }catch(e){


      return 0;
    }

  }


}