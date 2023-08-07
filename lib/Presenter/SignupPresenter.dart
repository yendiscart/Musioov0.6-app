import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/UserModel.dart';

import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';


class SignupPresenter{
  late Dio _dio = Dio();
  SharedPref sharePrefs = SharedPref();

  Future<UserModel> getRegister(BuildContext context,String name,String email,String pass,String mobileNum) async {


    var formData = FormData.fromMap({
      AppConstant.name: ''+name,
      AppConstant.email: ''+email,
      AppConstant.mobile: ''+mobileNum,
      AppConstant.password: ''+pass,
      AppConstant.password_confirmation: ''+pass,
      "accept_term_and_policy":"1"
    });

    Response<String> response = await _dio.post(AppConstant.BaseUrl+AppConstant.API_SIGNUP, data: formData);



      if (response.statusCode == 200) {


        final Map parsed = json.decode(response.data.toString());

        Fluttertoast.showToast(
            msg: parsed['msg'],
            toastLength: Toast
                .LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor:
            appColors().colorBackground,
            fontSize: 14.0);
        if(parsed['status'].toString().contains('true')){

          sharePrefs.setUserData(response.data.toString());
          sharePrefs.setToken(parsed['login_token']);
          return UserModel.fromJson(parsed);

        }

        return UserModel.fromJson(parsed);
      } else {

        Fluttertoast.showToast(
            msg: 'Something went wrong',
            toastLength: Toast
                .LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor:
            appColors().colorBackground,
            fontSize: 14.0);
        final Map parsed = json.decode(response.data.toString());

        return UserModel.fromJson(parsed);
      }

  }
}
