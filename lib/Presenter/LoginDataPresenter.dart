import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/Model/ModelTheme.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';

class LoginDataPresenter{
  late Dio _dio = Dio();
  SharedPref sharePrefs = SharedPref();

  Future<String> getUser(BuildContext context,String buildNumber,String email,String pass) async {


    var formData = FormData.fromMap({
      AppConstant.email: email,
      AppConstant.password: pass
    });


    try {

      Response<String> response = await _dio.post(AppConstant.BaseUrl+AppConstant.API_LOGIN, data: formData);


      if (response.statusCode == 200) {
        final Map parsed = json.decode(response.data.toString());
        if(parsed['status'].toString().contains('true')){
          final Map parsed = json.decode(response.data.toString());
        sharePrefs.setUserData('$response');
        sharePrefs.setToken(''+parsed['login_token']);
          sharePrefs.setThemeData(jsonEncode( new ModelTheme('', '', 'Default theme', '0xFFb5bada',
              'assets/images/default_screen.jpg', 'free')));
        return "1";

        }else{
          print(" -- "+response.toString());
          Fluttertoast.showToast(
              msg: parsed['msg'],
              toastLength:
              Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1,
              backgroundColor:
              Colors.grey,
              textColor:
              appColors().colorBackground,
              fontSize: 14.0);
          return "0";
        }


      } else {



        return "0";
      }
    } catch (error, stacktrace) {
      return "0";
    }
  }
}

