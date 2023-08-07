import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:musioo/ThemeMain/appColors.dart';
import 'package:musioo/utils/AppConstant.dart';
import 'package:musioo/utils/SharedPref.dart';

import 'AppSettingsPresenter.dart';


class ProfilePresenter{
  late Dio _dio = Dio();

  SharedPref sharePrefs = SharedPref();

  Future<void> getProfileUpdate(BuildContext context,File file,String name,String pass,String mbl,String dob, String gender,String token) async {

    var formData ;
if(name.isEmpty) {
   formData = FormData.fromMap({
    AppConstant.image: await MultipartFile.fromFile(
        file.path, filename: 'saloni'),
  });
}else{
if(gender.contains('female')){
  gender='1';
}else{
  gender='0';
}

   formData = FormData.fromMap({
    AppConstant.name: ''+name,
    AppConstant.mobile: ''+mbl,
    AppConstant.password: ''+pass,
    AppConstant.gender: ''+gender,
    AppConstant.dob: ''+dob,
  });


}

    Fluttertoast.showToast(
        msg:'Loading...',
        toastLength: Toast
            .LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor:
        appColors().colorBackground,
        fontSize: 14.0);



    Response<String> response = await _dio.post(AppConstant.BaseUrl+AppConstant.API_UPDATE_PROFILE, data: formData,options: Options(headers: {
      "Accept":"application/json","authorization":"Bearer "+token
    }));


    try {

      if (response.statusCode == 200) {

        final Map parsed = json.decode(response.data.toString());

        Fluttertoast.showToast(
            msg:parsed['msg'],
            toastLength: Toast
                .LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor:
            appColors().colorBackground,
            fontSize: 14.0);
        sharePrefs.setUserData('$response');
        if(parsed['status'].toString().contains('true')){
          String settingDetails = await AppSettingsPresenter().getAppSettings(token);

          sharePrefs.setSettingsData(settingDetails);

        }


      }
    } catch (error, stacktrace) {

      Fluttertoast.showToast(
          msg:"Try Again, Something went wrong!",
          toastLength: Toast
              .LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor:
          appColors().colorBackground,
          fontSize: 14.0);


    }
  }
}

