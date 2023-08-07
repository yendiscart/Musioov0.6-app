import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';


class ForGotPassPresenter{
  late Dio _dio = Dio();
  SharedPref sharePrefs = SharedPref();

  Future<String> getOtp(BuildContext context,String email) async {


    var formData = FormData.fromMap({
      AppConstant.email: ''+email,
    });

    Response<String> response = await _dio.post(AppConstant.BaseUrl+AppConstant.API_FORGOT_PASSWORD, data: formData);


    try {

      if (response.statusCode == 200) {

        final Map parsed = json.decode(response.data.toString());



        return parsed['msg'];
      } else {



        return 'no';
      }
    } catch (error, stacktrace) {


      return throw UnimplementedError();

    }
  }


  Future<String> getChangePass(BuildContext context,String email,String pass,String confPass,String otp) async {


    var formData = FormData.fromMap({
      AppConstant.email: ''+email,
      AppConstant.password: ''+pass,
      AppConstant.confirmationPassword: ''+confPass,
      AppConstant.OTP: ''+otp,
    });

    Response<String> response = await _dio.post(AppConstant.BaseUrl+AppConstant.API_RESET_PASSWORD, data: formData);


    try {

      if (response.statusCode == 200) {

        final Map parsed = json.decode(response.data.toString());

        Fluttertoast.showToast(
            msg: ' ${parsed['msg']}!',
            toastLength: Toast
                .LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor:
            appColors().colorBackground,
            fontSize: 14.0);


        return parsed['msg'];
      } else {

        final Map parsed = json.decode(response.data.toString());

        return parsed['msg'];
      }
    } catch (error, stacktrace) {


      return throw UnimplementedError();

    }
  }
}
